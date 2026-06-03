/**
 * EL EMEĞİ 360 — Google Apps Script (yalnızca yedek yazma)
 * Birincil veri: Firestore (fabrika360). GS: muhasebe yedeği / liste.
 *
 * Sayfalar:
 *   EE_PERSON    — kişi listesi (ad, IBAN)
 *   EE_KAYIT     — işçilik kayıtları
 *   EE_ODEME_OZET — dönem özeti (opsiyonel yedek)
 *
 * NOT: getRecords / listPersons kaldırıldı — uygulama Sheets'ten okumaz.
 */

function doGet(e)  { return handleRequest_(e); }
function doPost(e) { return handleRequest_(e); }

/** Yalnızca kayıt sayfaları (master tablolar FB'de). */
function setupEeSheets() {
  var defs = {
    EE_PERSON: ["owner_uid", "worker_key", "ad_soyad", "iban", "locked", "platform", "app_version", "created_at", "iban_updated_at"],
    EE_PERSONEL: ["owner_uid", "worker_key", "ad_soyad", "iban", "locked", "platform", "app_version", "created_at", "iban_updated_at"],
    EE_KAYIT: ["kayit_id", "owner_uid", "worker_key", "ad_soyad", "tarih", "date_key", "donem_key", "urun_cinsi", "islem_turu", "olcu_label", "en", "boy", "adet", "iscilik_turu", "birim_fiyat", "toplam_metre", "tutar", "durum", "odeme_tarihi", "created_at", "updated_at", "synced_to_sheets"],
    EE_ODEME_OZET: ["donem_key", "owner_uid", "worker_key", "ad_soyad", "toplam_tutar", "kayit_sayisi", "durum", "odeme_tarihi", "updated_at"]
  };
  var obsolete = ["EE_CIHAZ", "EE_URUN_CINSI", "EE_ISLEM", "EE_OLCU", "EE_FIYAT", "EE_CINS"];
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  for (var name in defs) {
    var sh = ss.getSheetByName(name) || ss.insertSheet(name);
    _ensureHeaders_(sh, defs[name]);
  }
  obsolete.forEach(function(name) {
    var old = ss.getSheetByName(name);
    if (old) ss.deleteSheet(old);
  });
  return { status: "success", message: "Kayıt sayfaları hazır (EE_PERSON, EE_KAYIT, EE_ODEME_OZET)" };
}

function _personSheet_() {
  return _sheet_("EE_PERSON") || _sheet_("EE_PERSONEL");
}

function handleRequest_(e) {
  var output = ContentService.createTextOutput();
  output.setMimeType(ContentService.MimeType.JSON);
  try {
    if (e && e.postData && e.postData.contents) {
      var postBody = JSON.parse(e.postData.contents);
      if (postBody.action) {
        return output.setContent(JSON.stringify(handlePost_(postBody)));
      }
    }
    if (!e || !e.parameter || !e.parameter.action) {
      return output.setContent(JSON.stringify({ status: "error", message: "Geçersiz istek — ?action=ping deneyin" }));
    }
    var action = e.parameter.action;
    var result = { status: "error", message: "Bilinmeyen action: " + action };
    if (action === "ping") result = { status: "success", message: "El Emeği 360 Sheets API", version: "2.2" };
    else if (action === "getRecords" || action === "listPersons") {
      result = { status: "error", message: "Okuma devre dışı — birincil kaynak Firestore. GS yalnızca yedek yazma." };
    }
    else if (action === "saveRecord") result = saveRecord_(e.parameter);
    else if (action === "deleteRecord") result = deleteRecord_(e.parameter);
    else if (action === "registerDevice") result = registerPerson_(e.parameter);
    else if (action === "registerPerson") result = registerPerson_(e.parameter);
    else if (action === "updateIban") result = updateIban_(e.parameter);
    else if (action === "deletePerson") result = deletePerson_(e.parameter);
    else if (action === "saveOdemeOzet") result = saveOdemeOzet_(e.parameter);
    else if (action === "deleteOdemeOzet") result = deleteOdemeOzet_(e.parameter);
    return output.setContent(JSON.stringify(result));
  } catch (err) {
    return output.setContent(JSON.stringify({ status: "error", message: String(err) }));
  }
}

function handlePost_(payload) {
  var action = payload.action;
  var data = Object.assign({}, payload.data || {}, payload);
  if (action === "ping") return { status: "success", message: "El Emeği 360 Sheets API" };
  if (action === "saveRecord") return saveRecord_(data);
  if (action === "registerDevice" || action === "registerPerson") return registerPerson_(data);
  if (action === "updateIban") return updateIban_(data);
  if (action === "deletePerson") return deletePerson_(data);
  if (action === "saveOdemeOzet") return saveOdemeOzet_(data);
  if (action === "deleteOdemeOzet") return deleteOdemeOzet_(data);
  if (action === "deleteRecord" || action === "deleteKayit") {
    var id = data.kayitId || data.kayit_id;
    return deleteRecord_({ kayit_id: id });
  }
  return { status: "error", message: "Bilinmeyen POST action: " + action };
}

function saveRecord_(data) {
  var sheet = _sheet_("EE_KAYIT");
  if (!sheet) return { status: "error", message: "EE_KAYIT sayfası yok — setupEeSheets çalıştırın" };

  var headers = _ensureHeaders_(sheet, [
    "kayit_id", "owner_uid", "worker_key", "ad_soyad", "tarih", "date_key", "donem_key",
    "urun_cinsi", "islem_turu", "olcu_label", "en", "boy", "adet", "iscilik_turu",
    "birim_fiyat", "toplam_metre", "tutar", "durum", "odeme_tarihi", "created_at", "updated_at", "synced_to_sheets"
  ]);

  var kayitId = data.kayitId || data.kayit_id || Utilities.getUuid();
  var now = Utilities.formatDate(new Date(), Session.getScriptTimeZone(), "yyyy-MM-dd HH:mm:ss");
  var rowData = {
    kayit_id: kayitId,
    owner_uid: data.ownerUid || data.owner_uid || "",
    worker_key: data.workerKey || data.worker_key || "",
    ad_soyad: data.adSoyad || data.ad_soyad || "",
    tarih: data.tarih || data.dateKey || now,
    date_key: data.dateKey || data.date_key || "",
    donem_key: data.donemKey || data.donem_key || "",
    urun_cinsi: data.urunCinsi || data.urun_cinsi || "",
    islem_turu: data.islemTuru || data.islem_turu || "",
    olcu_label: data.olcuLabel || data.olcu_label || "",
    en: data.en != null ? data.en : "",
    boy: data.boy != null ? data.boy : "",
    adet: data.adet != null ? data.adet : "",
    iscilik_turu: data.iscilikTuru || data.iscilik_turu || "",
    birim_fiyat: data.birimFiyat != null ? data.birimFiyat : "",
    toplam_metre: data.toplamMetre != null ? data.toplamMetre : "",
    tutar: data.tutar != null ? data.tutar : "",
    durum: data.durum || "BEKLEMEDE",
    odeme_tarihi: data.odemeTarihi || data.odeme_tarihi || "",
    created_at: data.createdAt || now,
    updated_at: now,
    synced_to_sheets: "TRUE"
  };
  var existingRow = _findRowById_(sheet, "kayit_id", kayitId);
  if (existingRow) {
    headers.forEach(function(h, colIdx) {
      if (h === "created_at") return;
      sheet.getRange(existingRow, colIdx + 1).setValue(rowData[h] != null ? rowData[h] : "");
    });
  } else {
    _appendRowByHeaders_(sheet, headers, rowData);
  }
  return { status: "success", data: { kayitId: kayitId } };
}

/** Kişi + IBAN listesi (EE_PERSON / EE_PERSONEL) */
function registerPerson_(data) {
  var sheet = _personSheet_();
  if (!sheet) return { status: "error", message: "EE_PERSON yok — setupEeSheets" };
  var headers = _ensureHeaders_(sheet, [
    "owner_uid", "worker_key", "ad_soyad", "iban", "locked", "platform", "app_version", "created_at", "iban_updated_at"
  ]);
  var uid = data.ownerUid || data.owner_uid;
  if (!uid) return { status: "error", message: "owner_uid zorunlu" };
  var now = Utilities.formatDate(new Date(), Session.getScriptTimeZone(), "yyyy-MM-dd HH:mm:ss");
  var iban = data.iban || "";
  var existingRow = _findRowById_(sheet, "owner_uid", uid);
  if (existingRow) {
    if (iban) {
      var ibanCol = headers.indexOf("iban");
      var updCol = headers.indexOf("iban_updated_at");
      if (ibanCol >= 0) sheet.getRange(existingRow, ibanCol + 1).setValue(iban);
      if (updCol >= 0) sheet.getRange(existingRow, updCol + 1).setValue(now);
    }
    return { status: "success", data: { exists: true, updated: !!iban } };
  }
  _appendRowByHeaders_(sheet, headers, {
    owner_uid: uid,
    worker_key: data.workerKey || data.worker_key || "",
    ad_soyad: data.adSoyad || data.ad_soyad || "",
    iban: iban,
    locked: "TRUE",
    platform: data.platform || "android",
    app_version: data.appVersion || data.app_version || "",
    created_at: now,
    iban_updated_at: iban ? now : ""
  });
  return { status: "success", data: { registered: true } };
}

function deletePerson_(data) {
  var uid = data.ownerUid || data.owner_uid;
  if (!uid) return { status: "error", message: "owner_uid zorunlu" };
  var sheet = _personSheet_();
  if (!sheet) return { status: "error", message: "EE_PERSON yok" };
  if (_deleteFromSheet_(sheet.getName(), "owner_uid", uid)) {
    return { status: "success", data: { deleted: true } };
  }
  return { status: "error", message: "Kişi bulunamadı" };
}

function saveOdemeOzet_(data) {
  var sheet = _sheet_("EE_ODEME_OZET");
  if (!sheet) return { status: "error", message: "EE_ODEME_OZET sayfası yok" };

  var headers = _ensureHeaders_(sheet, [
    "donem_key", "owner_uid", "worker_key", "ad_soyad", "toplam_tutar", "kayit_sayisi", "durum", "odeme_tarihi", "updated_at"
  ]);

  var donemKey = data.donemKey || data.donem_key || "";
  var ownerUid = data.ownerUid || data.owner_uid || "";
  var workerKey = data.workerKey || data.worker_key || "";
  if (!donemKey || !ownerUid) return { status: "error", message: "donem_key ve owner_uid zorunlu" };

  var now = Utilities.formatDate(new Date(), Session.getScriptTimeZone(), "yyyy-MM-dd HH:mm:ss");
  var rowData = {
    donem_key: donemKey,
    owner_uid: ownerUid,
    worker_key: workerKey,
    ad_soyad: data.adSoyad || data.ad_soyad || "",
    toplam_tutar: data.toplamTutar != null ? data.toplamTutar : (data.odemeTutar != null ? data.odemeTutar : ""),
    kayit_sayisi: data.kayitSayisi != null ? data.kayitSayisi : "",
    durum: data.durum || "ODENDI",
    odeme_tarihi: data.odemeTarihi || data.odeme_tarihi || now,
    updated_at: now
  };

  var existingRow = 0;
  var allRows = sheet.getDataRange().getDisplayValues();
  for (var i = 1; i < allRows.length; i++) {
    if (allRows[i][headers.indexOf("owner_uid")] === ownerUid && allRows[i][headers.indexOf("donem_key")] === donemKey) {
      existingRow = i + 1;
      break;
    }
  }

  if (existingRow) {
    headers.forEach(function(h, colIdx) {
      sheet.getRange(existingRow, colIdx + 1).setValue(rowData[h] != null ? rowData[h] : "");
    });
  } else {
    _appendRowByHeaders_(sheet, headers, rowData);
  }

  return { status: "success", data: { saved: true } };
}

/** Dönem özeti satırını siler (donem_key + owner_uid). Firestore birincil; GS yedek. */
function deleteOdemeOzet_(data) {
  var donemKey = data.donemKey || data.donem_key || "";
  var ownerUid = data.ownerUid || data.owner_uid || "";
  if (!donemKey || !ownerUid) return { status: "error", message: "donem_key ve owner_uid zorunlu" };

  var sheet = _sheet_("EE_ODEME_OZET");
  if (!sheet || sheet.getLastRow() < 2) {
    return { status: "success", data: { deleted: false, notFound: true } };
  }

  var headers = sheet.getRange(1, 1, 1, sheet.getLastColumn()).getDisplayValues()[0];
  var ownerCol = headers.indexOf("owner_uid");
  var donemCol = headers.indexOf("donem_key");
  if (ownerCol < 0 || donemCol < 0) {
    return { status: "error", message: "EE_ODEME_OZET sütunları bulunamadı" };
  }

  var rows = sheet.getRange(2, 1, sheet.getLastRow(), headers.length).getDisplayValues();
  for (var i = rows.length - 1; i >= 0; i--) {
    if (rows[i][ownerCol] === ownerUid && rows[i][donemCol] === donemKey) {
      sheet.deleteRow(i + 2);
      return { status: "success", data: { deleted: true } };
    }
  }

  return { status: "success", data: { deleted: false, notFound: true } };
}

function updateIban_(data) {
  var sheet = _personSheet_();
  if (!sheet) return { status: "error", message: "EE_PERSON yok" };
  var uid = data.ownerUid || data.owner_uid;
  var row = _findRowById_(sheet, "owner_uid", uid);
  if (!row) return { status: "error", message: "Kişi bulunamadı" };
  var headers = sheet.getRange(1, 1, 1, sheet.getLastColumn()).getDisplayValues()[0];
  var ibanCol = headers.indexOf("iban");
  var updCol = headers.indexOf("iban_updated_at");
  var iban = data.iban || "";
  var now = Utilities.formatDate(new Date(), Session.getScriptTimeZone(), "yyyy-MM-dd HH:mm:ss");
  if (ibanCol >= 0) sheet.getRange(row, ibanCol + 1).setValue(iban);
  if (updCol >= 0) sheet.getRange(row, updCol + 1).setValue(now);
  return { status: "success", data: { updated: true } };
}

function listPersons_() {
  var sheet = _personSheet_();
  if (!sheet) return { status: "success", data: [] };
  return { status: "success", data: _sheetToList_(sheet.getName()) };
}

function getRecords_(params) {
  var sheet = _sheet_("EE_KAYIT");
  if (!sheet) return { status: "success", data: [] };
  var rows = _sheetToList_("EE_KAYIT");
  var ownerUid = params.owner_uid || params.ownerUid;
  var donemKey = params.donem_key || params.donemKey;
  var filtered = rows;
  if (ownerUid) filtered = filtered.filter(function(r) { return r.owner_uid === ownerUid; });
  if (donemKey) filtered = filtered.filter(function(r) { return r.donem_key === donemKey; });
  filtered.sort(function(a, b) { return (b.date_key || "").localeCompare(a.date_key || ""); });
  return { status: "success", data: filtered.slice(0, 200) };
}

function updateRecord_(data) {
  return { status: "error", message: "updateRecord — masaüstü fazında" };
}

function deleteRecord_(params) {
  var id = params.kayit_id || params.kayitId;
  if (!id) return { status: "error", message: "kayit_id zorunlu" };
  if (_deleteFromSheet_("EE_KAYIT", "kayit_id", id)) {
    return { status: "success", data: { deleted: true } };
  }
  // Firestore birincil kaynak; GS satırı hiç yedeklenmemiş olabilir (synced_to_sheets=false).
  return { status: "success", data: { deleted: false, notFound: true } };
}

function _sheet_(name) {
  return SpreadsheetApp.getActiveSpreadsheet().getSheetByName(name);
}

function _ensureHeaders_(sheet, defaultHeaders) {
  if (sheet.getLastRow() < 1) {
    sheet.appendRow(defaultHeaders);
    return defaultHeaders;
  }
  var existing = sheet.getRange(1, 1, 1, sheet.getLastColumn()).getDisplayValues()[0];
  var merged = existing.slice();
  defaultHeaders.forEach(function(h) {
    if (merged.indexOf(h) < 0) {
      merged.push(h);
    }
  });
  if (merged.length !== existing.length) {
    sheet.getRange(1, 1, 1, merged.length).setValues([merged]);
  }
  return merged;
}

function _appendRowByHeaders_(sheet, headers, rowObj) {
  var row = headers.map(function(h) { return rowObj[h] != null ? rowObj[h] : ""; });
  sheet.appendRow(row);
}

function _sheetToList_(sheetName) {
  var sheet = _sheet_(sheetName);
  if (!sheet || sheet.getLastRow() < 2) return [];
  var data = sheet.getDataRange().getDisplayValues();
  var headers = data[0];
  return data.slice(1).map(function(r) {
    var o = {};
    headers.forEach(function(h, i) { o[h] = r[i]; });
    return o;
  });
}

function _findRowById_(sheet, col, val) {
  if (sheet.getLastRow() < 2) return null;
  var headers = sheet.getRange(1, 1, 1, sheet.getLastColumn()).getDisplayValues()[0];
  var idx = headers.indexOf(col);
  if (idx < 0) return null;
  var rows = sheet.getRange(2, 1, sheet.getLastRow(), headers.length).getDisplayValues();
  for (var i = 0; i < rows.length; i++) {
    if (rows[i][idx] === val) return i + 2;
  }
  return null;
}

function _deleteFromSheet_(sheetName, idField, idValue) {
  var sheet = _sheet_(sheetName);
  if (!sheet || sheet.getLastRow() < 2) return false;
  var headers = sheet.getRange(1, 1, 1, sheet.getLastColumn()).getDisplayValues()[0];
  var idCol = headers.indexOf(idField);
  if (idCol < 0) return false;
  var rows = sheet.getRange(2, 1, sheet.getLastRow(), headers.length).getDisplayValues();
  for (var i = 0; i < rows.length; i++) {
    if (rows[i][idCol] === idValue) {
      sheet.deleteRow(i + 2);
      return true;
    }
  }
  return false;
}
