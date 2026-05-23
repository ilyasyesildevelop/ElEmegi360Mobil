# El Emeği 360 — Ara not (devam edilecek)

**Son güncelleme:** 2026-05-19  
**Durum:** Ara verildi — sonraki oturumda master veri + Excel rehberi öncelikli.

---

## Bu oturumda tamamlananlar

| Konu | Durum |
|------|--------|
| Firestore kuralları (`ee_*` + Vardiya/Üretim) | Deploy edildi — `Fabrika360Suite/firestore.rules`, DB `fabrika360` |
| Firestore indeksler | Deploy edildi — `firestore.indexes.json` |
| Master seed (ilk taslak) | `firebase/scripts/seed-ee-master.js` çalıştırıldı (9 ürün / 5 işlem / 10 ölçü / 15 fiyat) |
| Pub cache kısayolu | `scripts/fix-pub-cache.bat`, `Masaustu-Kisayol-Olustur.bat` |
| Google Sheets Web App URL | `lib/core/app_config.dart` |
| Ödeme bildirimi şeması | `ee_bildirim` + `plan/FIRESTORE_ODEME_BILDIRIM.md` (mobil dinleyici SnackBar) |
| OTA `version.json` şablonu | `plan/fabrika360-updates-elemegi360-version.json` |

**Bilinçli olarak boş:** `ee_cihaz`, `ee_kayit`, `ee_odeme_ozet`, `ee_bildirim` (mobil / masaüstü ile dolacak).

---

## Karar: Ürün cinsi ≠ İşlem (2026-05-19)

Kullanıcı geri bildirimi — **Excel ve FB master buna göre yenilenecek.**

### Ürün cinsi (`ee_urun_cinsi_master`)

- **Sadece halı koleksiyon / seri adları** (model adları).
- Örnek: **ZARA**, **NOSTALJI**, **MADDER**, **ZD**, …
- **Silinecek / taşınmayacak:** işlem adıyla aynı olanlar → `EL OVERLOGU`, `ETIKET`, `KARTELA`, `KUCUK ETIKET` vb. bunlar **ürün cinsi değil**.

### İşlem (`ee_islem_master`)

- Yapılan **işçilik türü**.
- Örnek: **Saçak**, **Etiket**, **El Overlogu**, **Küçük Etiket**, **Kartela**
- **Buraya taşınacak:** **Tamir** ve benzeri iş türleri (şu an yanlışlıkla ürün cinsinde olabilir).

### Kısa kural

| Soru | Cevap |
|------|--------|
| “Hangi halı?” | → **Ürün cinsi** |
| “Ne iş yaptı?” | → **İşlem** |

Mobil stub: `lib/models/product_catalog.dart` — devamda FB ile hizalanacak.

---

## Excel = tek rehber (ölçüler + fiyatlar)

**Hedef dosyalar:** `ElEmegi360Mobil/plan/` altına konacak (repo’da henüz yok; kullanıcı ekleyecek):

- `2026.04 SACAK VE ETIKET LISTESI_V3.xlsm` (ana referans — şema taslaklarında geçiyor)
- Plan klasöründeki diğer Excel’ler (varsa hepsi taranacak)

### Yapılacak (sonraki oturum)

1. **Excel’leri plan/** altına koy / doğrula.
2. Sayfa/sütun taraması → çıkarım listesi:
   - Tüm **ölçü kodları** (`ee_olcu_master`) — şu an seed’de sadece ~10 örnek var; **Excel’deki tam liste** yüklenecek.
   - **İşlem** listesi (Tamir dahil).
   - **Ürün cinsi** = yalnız koleksiyon adları.
   - **Birim fiyat** satırları → `ee_fiyat_master`.
3. `seed-ee-master.js` (veya `seed-ee-from-excel.js`) Excel’den okuyacak şekilde güncelle.
4. FB’de eski yanlış master dokümanlarını temizle veya `merge: false` ile tam yeniden seed.
5. Mobil: `ProductCatalog` → Firestore master repository; kayıt formu picker’ları FB’den.

### Hesap motoru

Excel V3 kuralları: `EL_EMEGI_360_FIRESTORE_SCHEMA_DRAFT.md` §2 (Sacak / Etiket / Overlogu / … formülleri). Kod: `islem_turu.dart`, kayıt ekranı hesabı.

---

## Firestore master — şu anki seed (yenilenecek)

İlk seed **taslak**; ürün/işlem ayrımı düzeltilmeden önce atıldı:

| Koleksiyon | Adet | Not |
|------------|------|-----|
| `ee_urun_cinsi_master` | 9 | İşlem adları karışık — **kullanıcı FB’den siliyor / yeniden seed** |
| `ee_islem_master` | 5 | **Tamir** ve Excel’deki eksik işlemler eklenecek |
| `ee_olcu_master` | 10 | Excel’deki **tüm ölçüler** eklenecek |
| `ee_fiyat_master` | 15 | Excel fiyat tablosuna göre güncellenecek |

Tekrar seed:

```powershell
cd D:\Projects\Fabrika360Suite\firebase\scripts
node seed-ee-master.js
node verify-ee-collections.js
```

---

## Henüz yapılmayanlar (sıra önerisi)

1. Excel → master çıkarımı + FB seed (ürün/işlem/ölçü/fiyat doğru ayrımı)
2. Mobil kayıt formu → Firestore master + gerçek `ee_kayit` yazma
3. IBAN → `ee_cihaz` + GS `EE_PERSONEL` senkronu
4. Release APK + GitHub `elemegi360/version.json`
5. Masaüstü: ödeme onayı → `ee_kayit.durum` + `ee_bildirim`
6. Sesli yerel bildirim (`flutter_local_notifications`)

---

## Teknik referanslar

| Dosya | Açıklama |
|-------|----------|
| `plan/EL_EMEGI_360_MASTER_DATA_SCHEMA.md` | FB/GS master alanları |
| `plan/EL_EMEGI_360_DATA_MODEL.md` | `ee_kayit`, `ee_cihaz` |
| `plan/FIREBASE_DEPLOY_KURALLAR.md` | Deploy suite kökünden |
| `firebase/scripts/seed-ee-master.js` | Master seed |
| `firestore.rules` (suite kökü) | Canlı kurallar |

---

## Kullanıcı aksiyonu (ara öncesi / sonrası)

- [ ] Excel dosyalarını `ElEmegi360Mobil/plan/` altına kopyala
- [ ] FB Console’da yanlış `ee_urun_cinsi_master` kayıtlarını sil (işlem adları)
- [ ] Sonraki sohbette: “Excel’den master seed’e devam” de

*Bu dosya devam oturumunun giriş noktasıdır.*
