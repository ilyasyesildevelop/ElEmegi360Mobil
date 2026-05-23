# El Emegi 360 — Firestore Sema ve Hesap Motoru Taslagi (ARSIV)

> **Güncel veri modeli:** `EL_EMEGI_360_DATA_MODEL.md` (cihaz profili, tek `ee_kayit`, personel master yok).

Bu taslak, `2026.04 SACAK VE ETIKET LISTESI_V3.xlsm` yapisina gore hazirlanmistir.

## 1) Koleksiyonlar

### Master koleksiyonlar
- `ee_personel_master`
  - `personelId` (string, doc id)
  - `adSoyad` (string)
  - `active` (bool)
- `ee_cins_master`
  - `cinsId` (string, doc id)
  - `cinsAdi` (string) -> `EL OVERLOGU`, `ETIKET`, `KARTELA`, `KUCUK ETIKET`, `MADDER`, `NOSTALJI`, `TAMIR`, `ZARA`, `ZD`
  - `active` (bool)
- `ee_olcu_master`
  - `olcuId` (string, doc id: `30x30` gibi)
  - `en` (number)
  - `boy` (number)
- `ee_fiyat_master`
  - `fiyatKey` (string, doc id; ornek: `20`, `EL_OVERLOGU`, `Q120`)
  - `keyType` (`"en" | "cins" | "q"`)
  - `deger` (string)
  - `birimFiyat` (number)

### Kayit koleksiyonlari
- `ee_sacak_kayit`
- `ee_etiket_kayit`
- `ee_overlogu_kayit`
- `ee_kucuk_etiket_kayit`
- `ee_kartela_kayit`

Ortak alanlar:
- `kayitId` (string, doc id)
- `tarih` (Timestamp)
- `dateKey` (string: `yyyy-MM-dd`)
- `donemKey` (string: `yyyy-MM`)
- `personelId` (string)
- `adSoyad` (string)
- `urunCinsi` (string)
- `en` (number)
- `boy` (number)
- `adet` (number)
- `birimFiyat` (number)
- `toplamMetre` (number, gerekiyorsa)
- `tutar` (number)
- `odemeDurumu` (`"BEKLIYOR" | "ODENDI"`)
- `odemeTarihi` (Timestamp?, nullable)
- `createdAt` (serverTimestamp)
- `updatedAt` (serverTimestamp)
- `createdByUid` (string)

### Ozet / Odeme koleksiyonu (yonetim kolayligi)
- `ee_odeme_ozet`
  - `odemeId` (string: `donemKey_personelId`)
  - `donemKey` (string)
  - `personelId` (string)
  - `adSoyad` (string)
  - `toplamTutar` (number)
  - `odendi` (bool)
  - `odemeTarihi` (Timestamp?)
  - `kayitSayisi` (number)

## 2) Hesap kurallari (Excel V3'e gore)

- `Sacak`
  - `birimFiyat = fiyat_master[en]`
  - `tutar = adet * birimFiyat`
- `Etiket`
  - `toplamMetre = adet * en * 2 / 100`
  - `birimFiyat = fiyat_master["ETIKET"]` (sabit)
  - `tutar = toplamMetre * birimFiyat`
- `El Overlogu`
  - `birimFiyat = fiyat_master[urunCinsi]` (genelde `EL OVERLOGU`)
  - `toplamMetre = (en + boy) * adet * 2 / 100`
  - `tutar = toplamMetre * birimFiyat`
- `Kucuk Etiket`
  - `birimFiyat = fiyat_master[urunCinsi]` (genelde `KUCUK ETIKET`)
  - `tutar = adet * birimFiyat`
- `Kartela`
  - `birimFiyat = fiyat_master[en]`
  - `toplamMetre = en * adet * 2 / 100`
  - `tutar = toplamMetre * birimFiyat`

## 3) Guvenlik kurallari (onerilen)

- Isci kullanici:
  - Sadece kendi kayitlarini okuyup yazabilir (`createdByUid == request.auth.uid`)
  - Master tablolari sadece okuyabilir
- Admin:
  - Tum kayit ve master tablolarinda CRUD
  - `ee_odeme_ozet` yazma/yayinlama

## 4) Dizin ve indeks onerileri

Kritik composite indexler:
- Kayit koleksiyonlari:
  - `personelId ASC, tarih DESC`
  - `donemKey ASC, personelId ASC`
  - `odemeDurumu ASC, donemKey DESC`
- `ee_odeme_ozet`:
  - `donemKey ASC, odendi ASC`

## 5) Uygulama akis notu

- Mobil:
  - Kayit olusturur/gunceller.
  - Kendi gecmisini gorur (`dateKey` veya `donemKey` filtreli).
- Desktop:
  - Tum kayitlari ve ozet odeme ekranini gorur.
  - `Odendi` isaretler; bu islem hem `ee_odeme_ozet` hem ilgili kayitlarin `odemeDurumu` alanini gunceller.

## 6) Sonraki adim

1. Bu semayi `firebase/functions` icinde validator + hesap fonksiyonlari olarak kodlamak.
2. `ElEmegi360Mobil` icine Firebase Auth + Firestore yazim/okuma katmani eklemek.
3. Desktop'ta yeni modul tablolari icin `FirestoreService` map + `MainViewModel` grid kolonlarini eklemek.
