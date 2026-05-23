# El Emeği 360 — Master veri ve yedek tablolar (FB + GS)

**Sürüm:** 1.1 · **2026-05-19**  
**Kaynak:** Excel `2026.04 SACAK VE ETIKET LISTESI_V3.xlsm` (`plan/` klasörü — rehber).  
**Ara not / devam:** `plan/KALDI_NOTU.md` (ürün cinsi = yalnız halı koleksiyon adları; Tamir vb. = işlem; ölçüler = Excel’in tam listesi).

---

## 1) Kavram ayrımı (önemli)

| Kavram | Örnek | Nerede seçilir |
|--------|--------|----------------|
| **Ürün cinsi** | ZARA, NOSTALJI, MADDER, ZD, TAMIR | Halı serisi / model adı |
| **İşlem / işçilik türü** | Saçak, Etiket, El Overlogu, Küçük Etiket, Kartela | Yapılan iş |
| **Ölçü** | 80×150, 80×300, Q160, Q200, 30×30 | Boyut kodu |
| **Birim ücret** | Master tablodan | Otomatik hesap |

**Saçak ürün cinsi değildir** — işlem türüdür.

---

## 2) Firestore koleksiyonları

Veritabanı: `fabrika360`.

### 2.1 `ee_cihaz` (işçi / telefon profili)

doc id = `ownerUid`

| Alan | Tip | Not |
|------|-----|-----|
| ownerUid | string | |
| adSoyad | string | BÜYÜK, kilitli |
| workerKey | string | `AYSE_YILMAZ` slug |
| iban | string? | TR… maskeleme UI |
| ibanUpdatedAt | timestamp? | |
| locked | bool | true |
| platform | string | |
| appVersion | string | örn. v26.05.0.0 |
| createdAt | timestamp | |

**Akış:** İlk kurulum → kayıt. IBAN sonradan Ayarlar’dan; aynı dokümanda güncellenir (sadece `iban`, `ibanUpdatedAt`).

---

### 2.2 Master (salt okuma mobil)

#### `ee_urun_cinsi_master`

| Alan | Örnek |
|------|--------|
| cinsId (doc id) | `ZARA` |
| cinsAdi | `ZARA` |
| active | bool |

Örnek değerler (yalnız koleksiyon): MADDER, NOSTALJI, ZARA, ZD, …  
**Olmamalı (işlemdir):** EL OVERLOGU, ETIKET, KARTELA, KUCUK ETIKET, TAMIR → `ee_islem_master`.

#### `ee_islem_master`

| Alan | Örnek |
|------|--------|
| islemId | `SACAK` |
| islemAdi | `Saçak` |
| islemKodu | `SACAK` (hesap motoru) |
| active | bool |

#### `ee_olcu_master`

| Alan | Örnek |
|------|--------|
| olcuId | `80x150` |
| en | number? |
| boy | number? |
| olcuTipi | `dikdortgen` \| `kare` \| `Q` |
| active | bool |

Örnek: 80×150, 80×300, 100×200, Q160, Q200, 30×30.

#### `ee_fiyat_master`

| Alan | Örnek |
|------|--------|
| fiyatKey (doc id) | `SACAK_80` veya `ETIKET` |
| islemKodu | SACAK, ETIKET, … |
| olcuId | nullable |
| urunCinsiId | nullable (özel fiyat) |
| birimFiyat | number |
| birim | `ADET` \| `METRE` |
| active | bool |

Hesap kuralları: mevcut `EL_EMEGI_360_DATA_MODEL.md` §2 (Excel V3).

---

### 2.3 `ee_kayit` (işçilik kaydı)

Mevcut birleşik kayıt + alan netliği:

| Alan | Tip |
|------|-----|
| kayitId | string |
| ownerUid | string |
| adSoyad | string |
| workerKey | string |
| urunCinsi | string (ZARA…) |
| islemTuru | string (SACAK…) |
| olcuLabel | string |
| en, boy | number |
| adet | number |
| birimFiyat, toplamMetre, tutar | number |
| durum | BEKLEMEDE \| ONAYLANDI \| ODENDI |
| tarih, dateKey, donemKey | |
| createdAt, updatedAt | |

---

### 2.4 `ee_odeme_ozet`

Muhasebe / desktop: dönem bazlı ödeme özeti (değişmedi).

---

## 3) Google Sheets (yedek — FB ile aynı mantık)

Spreadsheet: **El Emeği 360** (veya Suite master dosyasında sekme grubu).

| Sayfa | Firestore karşılığı |
|-------|---------------------|
| **EE_CIHAZ** | ee_cihaz |
| **EE_URUN_CINSI** | ee_urun_cinsi_master |
| **EE_ISLEM** | ee_islem_master |
| **EE_OLCU** | ee_olcu_master |
| **EE_FIYAT** | ee_fiyat_master |
| **EE_KAYIT** | ee_kayit |
| **EE_ODEME_OZET** | ee_odeme_ozet |

### EE_CIHAZ sütunları

`owner_uid`, `worker_key`, `ad_soyad`, `iban`, `locked`, `platform`, `app_version`, `created_at`, `iban_updated_at`

### EE_KAYIT sütunları

Mevcut `EL_EMEGI_360_DATA_MODEL.md` + `urun_cinsi`, `islem_turu` ayrımı.

**Apps Script:** `ElEmegi360Mobil/scripts/Code.gs` — `registerDevice` IBAN alanı eklenecek.

---

## 4) Yeni işçi kaydı akışı

1. İlk kurulum → `ee_cihaz` create.
2. Apps Script `registerDevice` → **EE_CIHAZ** satırı (IBAN boş olabilir).
3. IBAN girilince → Firestore `iban` update + Sheet satırı güncelleme.
4. Muhasebe desktop → tüm `ee_cihaz` + `ee_kayit` + ödeme onayı (ileride).

---

## 5) Mobil ekran ↔ tablo

| Ekran | Veri kaynağı |
|-------|----------------|
| Kayıt formu | master picker’lar (şimdilik `ProductCatalog` stub) |
| Birim ücret listesi | `ee_fiyat_master` join |
| Ayarlar IBAN | `ee_cihaz.iban` |
| Geçmiş | `ee_kayit` where ownerUid |

---

## 6) Sonraki teknik adımlar

1. Excel V3 → seed script (`firebase/scripts/seed-ee-master.py`).
2. Firestore rules + indeksler.
3. `KayitRepository` master fiyat okuma.
4. GS append/update IBAN.
5. Fabrika360 Desktop muhasebe modülü.

---

*Bu doküman `EL_EMEGI_360_DATA_MODEL.md` ile birlikte geçerlidir; çelişki halinde bu dosya (master/ürün-işlem) önceliklidir.*
