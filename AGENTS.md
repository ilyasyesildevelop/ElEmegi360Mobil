# El Emeği 360 — Agent / Editor bağlamı

## Ürün

Ev işçiliği (saçak, etiket, overlogu, kartela vb.) kayıt ve hakediş takibi. Fabrika 360 Suite ailesi; tasarım dili Vardiya360 ile aynı yapı, **daha sıcak renk paleti**.

## Stack

- **Flutter** (Material 3), tek modül: `ElEmegi360Mobil/`
- **Firebase:** proje `fabrika360`, DB `fabrika360` (Vardiya ile aynı)
- **Referans UI:** `../Vardiya360Mobil/.../FabrikaSuiteComponents.kt`, `Theme.kt`, `Color.kt`
- **Şema:** `plan/EL_EMEGI_360_FIRESTORE_SCHEMA_DRAFT.md`
- **Tasarım brief:** `../el emegi plan/El Emeği 360 için mobil uygulama.txt`

## Renkler (kaynak)

| Token | Hex |
|-------|-----|
| deepNavy | `#1A1F36` |
| darkNavy | `#0F1425` |
| teal | `#00C2A8` |
| tealLight | `#33D4BE` |
| amber | `#F5A623` |
| kilimRed | `#D7263D` |
| threadCream | `#F7F2E8` |
| olive | `#8A9A5B` |
| softBlueGray | `#7FA6B8` |

## Cihaz profili (sabit personel yok)

- İlk açılış: ad soyad → `TurkishText.toUpperCase` → `ee_cihaz/{ownerUid}`, yerel `ProfileStore` (kilitli, değişmez).
- Kayıt/geçmiş: `ownerUid` + donmuş `adSoyad` / `workerKey`. Şema: `plan/EL_EMEGI_360_DATA_MODEL.md`.

## Kayıt ID

Mobil format: `yyyyMMddHHmmss-XY-ZZZ` — **zaman damgası kayıt `dateKey` tarihinden**, import/oluşturma anından değil (Vardiya `RecordIdGenerator` ile uyumlu mantık).

## Ekranlar (MVP)

1. **Kayıt** — personel, ürün cinsi, ölçü, adet → hesap motoru → Firestore
2. **Geçmiş** — `dateKey` / `donemKey` filtre
3. **Ücret / Hakediş** — `odemeDurumu`, dönem özeti
4. **Ayarlar** — tema, çıkış

Bottom nav: Kayıt | Geçmiş | Ücret | Ayarlar

## Editor modda çalışma

- Küçük, dosya odaklı istekler ver (`lib/features/record/...`).
- `@AGENTS.md` ve `@plan/EL_EMEGI_360_FIRESTORE_SCHEMA_DRAFT.md` bağlamda kalsın.
- Büyük refaktör yerine ekran ekran ilerle.

## Yapılmayacaklar (şimdilik)

- Compose/Android modülü bu klasörde yok; Kotlin kopyalama yok.
- Excel import scriptleri Vardiya firebase/scripts altında kalır; EE için ayrı script gerekirse `firebase/scripts/` altına ekle.

## İnsan okunur notlar

Konuşma özeti, tasarım dili, kararlar: **`KALDI_NOTU.md`**
