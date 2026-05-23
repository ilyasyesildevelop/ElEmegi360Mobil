# El Emeği 360 — Veri modeli (Firestore + Google Sheets)

**Sürüm:** 1.0 · **Tarih:** 2026-05-18  
**Önceki taslak:** `EL_EMEGI_360_FIRESTORE_SCHEMA_DRAFT.md` (personel master + 5 kayıt koleksiyonu) — **bu doküman geçerlidir.**

---

## 1) Temel kararlar

| Konu | Karar |
|------|--------|
| Personel listesi | **Yok.** Her telefon ilk açılışta ad soyad girer; **büyük harf**, sonra **değiştirilemez**. |
| Kimlik (güvenlik) | Firebase **Anonymous Auth** → `ownerUid` (cihaz oturumu). |
| Kimlik (raporlama) | `adSoyad` + `workerKey` (ad soyaddan türetilmiş, sabit slug). |
| Geçmiş / kayıt | Sadece `ownerUid == auth.uid` olan kayıtlar okunur ve yazılır. |
| Kayıt deposu | **Tek koleksiyon** `ee_kayit` (`islemTuru` ile sacak/etiket/… ayrımı). |
| `ee_personel_master` | Mobil akışta **kullanılmaz** (isteğe bağlı sadece masaüstü/Excel import). |
| Sheets yedek | Vardiya 360 ile aynı desen: Firestore birincil, Apps Script **append** yedek. |

---

## 2) İlk kurulum (mobil)

1. Uygulama açılır → Anonymous Auth.
2. `ee_cihaz/{ownerUid}` veya yerel profil yoksa → **Ad Soyad** ekranı (bloklayıcı).
3. Kullanıcı yazar → `TurkishText.toUpperCase` → örn. `AYŞE YILMAZ`.
4. `ee_cihaz` dokümanı **bir kez** oluşturulur (`locked: true`).
5. Yerel `SharedPreferences` aynı bilgiyi önbelleğe alır (çevrimdışı başlık).
6. Ayarlar’da ad soyad **salt okunur**; düzenleme UI yok.

**Yeniden yükleme:** Aynı cihazda Auth UID korunursa profil geri gelir. Uygulama verisi silinirse yeni UID → **yeni profil** (yeni “telefon sahibi”); bu kabul edilen sınırdır.

---

## 3) Firestore koleksiyonları

Veritabanı: `fabrika360` (Suite ortak).

### 3.1 `ee_cihaz` — cihaz / işçi profili

| Alan | Tip | Açıklama |
|------|-----|----------|
| *(doc id)* | string | `ownerUid` (= `request.auth.uid`) |
| `ownerUid` | string | Aynı değer (sorgu kolaylığı) |
| `adSoyad` | string | `AYŞE YILMAZ` — oluşturulduktan sonra değişmez |
| `workerKey` | string | `AYSE_YILMAZ` — indeks / ödeme özeti anahtarı |
| `locked` | bool | `true` |
| `platform` | string | `android` |
| `appVersion` | string | `0.1.0+1` |
| `createdAt` | timestamp | server |
| `lastSeenAt` | timestamp | opsiyonel heartbeat |

**Kurallar (özet):**

- `create`: sadece kendi uid, `locked==true`, `adSoyad` dolu.
- `update`: **yasak** (veya yalnızca `lastSeenAt`).
- `read`: kendi dokümanı; admin tümü.

---

### 3.2 `ee_kayit` — işçilik kayıtları (birleşik)

**doc id:** `kayitId` — `yyyyMMddHHmmss-XY-ZZZ` (kayıt **tarihine** göre; Vardiya `RecordIdGenerator` ile uyumlu).

| Alan | Tip | Zorunlu | Açıklama |
|------|-----|---------|----------|
| `kayitId` | string | ✓ | doc id |
| `ownerUid` | string | ✓ | Yazan cihaz |
| `adSoyad` | string | ✓ | Kayıt anındaki sabitlenmiş ad (profilden kopya) |
| `workerKey` | string | ✓ | Profilden kopya |
| `tarih` | timestamp | ✓ | İş günü |
| `dateKey` | string | ✓ | `yyyy-MM-dd` |
| `donemKey` | string | ✓ | `yyyy-MM` |
| `islemTuru` | string | ✓ | `SACAK` \| `ETIKET` \| `OVERLOGU` \| `KUCUK_ETIKET` \| `KARTELA` |
| `urunCinsi` | string | ✓ | Örn. `MADDER`, `NOSTALJI` veya sacak için ölçü adı |
| `olcuLabel` | string | | `30x30` gösterim |
| `en` | number | | cm |
| `boy` | number | | cm |
| `adet` | number | ✓ | |
| `iscilikTuru` | string | | `Saçak bağlama`, `Püskül`, … |
| `birimFiyat` | number | ✓ | Hesap sonrası |
| `toplamMetre` | number | | Etiket / overlogu / kartela |
| `tutar` | number | ✓ | TL |
| `durum` | string | ✓ | `BEKLEMEDE` \| `ONAYLANDI` \| `ODENDI` |
| `odemeTarihi` | timestamp | | `durum==ODENDI` iken |
| `createdAt` | timestamp | ✓ | server |
| `updatedAt` | timestamp | ✓ | server |
| `syncedToSheets` | bool | | Yedek bayrağı |

**Mobil oluştururken:** `durum = BEKLEMEDE`.  
**Masaüstü:** onay → `ONAYLANDI`; ödeme → `ODENDI` + `odemeTarihi`.

**Sorgular:**

- Geçmiş: `ee_kayit` where `ownerUid == uid` order by `tarih` desc.
- Ücret (bekleyen): `ownerUid == uid` AND `durum in [BEKLEMEDE, ONAYLANDI]` (veya dönem özeti koleksiyonundan).

**İndeksler:**

- `ownerUid` ASC, `tarih` DESC  
- `ownerUid` ASC, `donemKey` DESC  
- `workerKey` ASC, `donemKey` DESC *(masaüstü)*  
- `durum` ASC, `donemKey` DESC *(masaüstü)*

---

### 3.3 `ee_odeme_ozet` — dönem hakediş özeti (masaüstü yazar)

| Alan | Tip | Açıklama |
|------|-----|----------|
| *(doc id)* | string | `{donemKey}_{workerKey}` örn. `2026-05_AYSE_YILMAZ` |
| `donemKey` | string | |
| `workerKey` | string | |
| `adSoyad` | string | Görüntüleme |
| `ownerUid` | string | Opsiyonel; mobil kullanıcıya filtre |
| `toplamTutar` | number | |
| `kayitSayisi` | number | |
| `odendi` | bool | |
| `odemeTarihi` | timestamp | |
| `updatedAt` | timestamp | |

Mobil **okur** (kendi `workerKey` / `ownerUid`); ödeme işaretleme **admin/masaüstü**.

---

### 3.4 Master veri (değişmedi — personel hariç)

| Koleksiyon | doc id | Alanlar |
|------------|--------|---------|
| `ee_cins_master` | `cinsId` | `cinsAdi`, `active` |
| `ee_olcu_master` | `olcuId` (`30x30`) | `en`, `boy`, `active` |
| `ee_fiyat_master` | `fiyatKey` | `keyType`, `deger`, `birimFiyat`, `active` |

Mobil: **sadece okuma**. Hesap motoru Excel V3 kuralları (`EL_EMEGI_360_FIRESTORE_SCHEMA_DRAFT.md` §2).

---

## 4) Google Sheets yapısı

Tek spreadsheet (ör. **El Emeği 360**) — Fabrika 360 Suite dosyasında ayrı sekme grubu veya ayrı dosya.

### 4.1 `EE_CIHAZ`

| Sütun | Örnek |
|-------|--------|
| owner_uid | `kR3x...` |
| worker_key | `AYSE_YILMAZ` |
| ad_soyad | `AYŞE YILMAZ` |
| locked | `TRUE` |
| platform | `android` |
| app_version | `0.1.0` |
| created_at | `2026-05-18 14:30:00` |

*İlk kayıt anında tek satır append (denetim).*

---

### 4.2 `EE_KAYIT` (ana tablo — Desktop + yedek)

| Sütun | Firestore alanı |
|-------|-----------------|
| kayit_id | kayitId |
| owner_uid | ownerUid |
| worker_key | workerKey |
| ad_soyad | adSoyad |
| tarih | tarih (gg.AA.yyyy veya ISO) |
| date_key | dateKey |
| donem_key | donemKey |
| islem_turu | islemTuru |
| urun_cinsi | urunCinsi |
| olcu_label | olcuLabel |
| en | en |
| boy | boy |
| adet | adet |
| iscilik_turu | iscilikTuru |
| birim_fiyat | birimFiyat |
| toplam_metre | toplamMetre |
| tutar | tutar |
| durum | durum |
| odeme_tarihi | odemeTarihi |
| created_at | createdAt |
| updated_at | updatedAt |

**Apps Script aksiyonları (Vardiya ile paralel):**

- `saveRecord` → satır append (mobil `kayitId` varsa aynı id)
- `updateRecord` → `kayit_id` ile güncelle (masaüstü)
- `deleteRecord` → sil (masaüstü)
- `getRecords` → filtre: `owner_uid` veya `worker_key`, `donem_key`

---

### 4.3 `EE_ODEME_OZET`

| Sütun |
|-------|
| odeme_id |
| donem_key |
| worker_key |
| ad_soyad |
| owner_uid |
| toplam_tutar |
| kayit_sayisi |
| odendi |
| odeme_tarihi |
| updated_at |

---

### 4.4 Master sayfalar (isteğe bağlı senkron)

`EE_CINS`, `EE_OLCU`, `EE_FIYAT` — Firestore master ile çift yönlü veya Firestore → Sheet export (masaüstü).

---

## 5) Güvenlik kuralları (özet)

```text
ee_cihaz/{uid}:
  read:   auth.uid == uid || admin
  create: auth.uid == uid && locked == true && adSoyad.size() >= 3
  update: false   // veya sadece lastSeenAt

ee_kayit/{id}:
  read:   resource.data.ownerUid == auth.uid || admin
  create: request.resource.data.ownerUid == auth.uid
          && profil ile adSoyad/workerKey uyumlu (opsiyonel CF doğrulama)
  update: admin || (owner && durum değişmedi)  // mobil düzenleme politikası netleştirilecek
  delete: admin

ee_odeme_ozet: read owner/admin; write admin

ee_*_master: read auth; write admin
```

---

## 6) Uygulama eşlemesi

| UI | Veri |
|----|------|
| İlk açılış | `OnboardingScreen` → `ee_cihaz` + local |
| Kayıt kartı “Kullanıcı” | `ProfileStore.adSoyad` + `workerKey` |
| Geçmiş | `ee_kayit` + `ownerUid` |
| Ücret | `ee_odeme_ozet` + bekleyen `ee_kayit` toplamı |
| Ayarlar | Sabit `adSoyad`, tema, çıkış (Auth reset yapmaz) |

---

## 7) Kaldırılan / kullanılmayan

- `ee_personel_master` — mobil seçim listesi yok.
- `ee_sacak_kayit`, `ee_etiket_kayit`, … — yerine tek `ee_kayit`.
- Kayıtlarda `personelId` (int) — yerine `ownerUid` + `workerKey`.

---

## 8) Sonraki kod adımları

1. ✅ Mobil: profil store + onboarding + ayarlar (salt okunur ad).
2. Firestore writer/reader + Auth.
3. `scripts/ElEmegi360/Code.gs` — `EE_KAYIT` append.
4. Masaüstü Fabrika360 modülü + ödeme işaretleme.
