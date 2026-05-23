# El Emeği 360 — Firestore + Google Sheets paralel şema

**Amaç:** FB (camelCase) ve GS (snake_case) aynı alanları taşır; sütun karmaşası olmaz.

## Ortam

| | Değer |
|---|--------|
| Firebase proje | `fabrika360suite-ekohali-cloud` |
| Firestore DB | `fabrika360` |
| Android paket | `com.greenlabs.development.elemegi360` |

---

## Eşleme tablosu (FB ↔ GS)

### `ee_cihaz` ↔ **EE_CIHAZ**

| Firestore (camelCase) | Google Sheets (snake_case) | Tip |
|----------------------|---------------------------|-----|
| ownerUid | owner_uid | string (doc id) |
| workerKey | worker_key | string |
| adSoyad | ad_soyad | string |
| iban | iban | string? |
| locked | locked | bool / TRUE |
| platform | platform | string |
| appVersion | app_version | string |
| createdAt | created_at | timestamp |
| ibanUpdatedAt | iban_updated_at | timestamp? |

### `ee_kayit` ↔ **EE_KAYIT**

| Firestore | Sheets |
|-----------|--------|
| kayitId | kayit_id |
| ownerUid | owner_uid |
| workerKey | worker_key |
| adSoyad | ad_soyad |
| tarih | tarih |
| dateKey | date_key |
| donemKey | donem_key |
| urunCinsi | urun_cinsi |
| islemTuru | islem_turu |
| olcuLabel | olcu_label |
| en | en |
| boy | boy |
| adet | adet |
| iscilikTuru | iscilik_turu |
| birimFiyat | birim_fiyat |
| toplamMetre | toplam_metre |
| tutar | tutar |
| durum | durum |
| odemeTarihi | odeme_tarihi |
| createdAt | created_at |
| updatedAt | updated_at |
| syncedToSheets | synced_to_sheets |

### Master koleksiyonlar

| Firestore | Sheet | Doc id / anahtar |
|-----------|-------|------------------|
| ee_urun_cinsi_master | EE_URUN_CINSI | cinsId → cins_id |
| ee_islem_master | EE_ISLEM | islemId → islem_id |
| ee_olcu_master | EE_OLCU | olcuId → olcu_id |
| ee_fiyat_master | EE_FIYAT | fiyatKey → fiyat_key |

### `ee_odeme_ozet` ↔ **EE_ODEME_OZET**

| Firestore | Sheets |
|-----------|--------|
| donemKey | donem_key |
| ownerUid | owner_uid |
| toplamTutar | toplam_tutar |
| kayitSayisi | kayit_sayisi |
| durum | durum |
| odemeTarihi | odeme_tarihi |

---

## Dosyalar

| Dosya | Açıklama |
|-------|----------|
| `firebase/firestore.rules` | Güvenlik kuralları |
| `firebase/firestore.indexes.json` | Bileşik indeksler |
| `scripts/Code.gs` | Apps Script (EE_* sayfaları) |
| `plan/FIREBASE_ANDROID_APP.md` | Konsola eklenecek uygulama bilgileri |

---

## Kurulum sırası

1. Firebase Console → Firestore → veritabanı `fabrika360` (yoksa oluştur).
2. `firebase deploy --only firestore:rules,firestore:indexes` (Firebase CLI, proje seçili).
3. Google Sheets’te sayfaları `scripts/sheets/EE_SHEET_HEADERS.md` başlıklarıyla oluştur.
4. Apps Script’i yayınla (web app); mobilde URL env’e eklenecek (ileride).
