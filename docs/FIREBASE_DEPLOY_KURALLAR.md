# Firestore kuralları — ne, nereden, nasıl?

## Kısa cevap

**Evet, El Emeği için yeni `match` blokları ekliyoruz** — ama **mevcut Vardiya/Üretim kurallarının üzerine**, ayrı bir dosyayla değiştirmiyoruz.

Canlı dosya: **`D:\Projects\Fabrika360Suite\firestore.rules`**

`firebase deploy --only firestore:rules` = bu dosyanın tamamını Firebase’e yükler (tüm uygulamalar aynı `fabrika360` veritabanını paylaşır).

## `deploy` ne demek?

| Parça | Anlamı |
|--------|--------|
| `firebase deploy` | Yerel `firestore.rules` + `firestore.indexes.json` → buluta kopyala |
| `--only firestore:rules` | Sadece güvenlik kuralları |
| `--only firestore:indexes` | Sadece sorgu indeksleri (karmaşık sorgular için) |

Konsoldan elle kural yazmıyorsunuz; **dosyayı düzenleyip bir kez deploy** ediyorsunuz.

## Diğer uygulamalar

Aynı veritabanında zaten var:

- `vardiya_kayit`, `izin_kayit`, `uretim_kayit`, `performans_kayit`
- `personel_master`, `users`, `vardiyalar`, …
- Sonda: bilinmeyen koleksiyon → **red** (`match /{document=**}`)

El Emeği eklentisi (aynı dosyada, red kuralından **önce**):

- `ee_cihaz`, `ee_kayit`, `ee_*_master`, `ee_odeme_ozet`, `ee_bildirim`

Masaüstü admin: mevcut `isDesktopAdmin()` — `users/{uid}` rolü (İlyas, IT, …).

## Yanlış klasörden deploy ETMEYİN

`ElEmegi360Mobil\firebase\firestore.rules` artık **yönlendirme notu**; oradan deploy ederseniz sadece `ee_*` kalır, Vardiya kuralları silinir.

## Komut (PowerShell)

```powershell
cd D:\Projects\Fabrika360Suite
firebase login
firebase deploy --only firestore:rules,firestore:indexes
```

Proje: `fabrika360suite-ekohali-cloud` (`.firebaserc` suite kökünde).

## İndeksler

`firestore.indexes.json` suite kökünde; Vardiya indeksleri + `ee_kayit` / `ee_bildirim` eklendi. Eski `firebase/firestore.indexes.json` ile aynı projeye ikinci kez deploy ederseniz Firebase birleştirir (çakışan tanımlar hata verir).

## Kontrol

Firebase Console → Firestore → **Rules** sekmesinde `ee_kayit` ve `vardiya_kayit` birlikte görünmeli.
