# El Emeği 360 — Uygulama Dokümantasyonu

**Sürüm:** 26.5.1 (26050100)  
**Paket:** `com.greenlabs.development.elemegi360`  
**Platform:** Flutter (Android / iOS)  
**Suite:** Fabrika 360 Suite  
**Geliştirici:** İlyas Yeşil — Green Labs Development Technology Inc.

---

## Genel bakış

El Emeği 360, ev işçiliği (saçak, etiket, overlogu, kartela vb.) kayıtlarının mobil cihazdan tutulmasını, hakediş takibini ve yöneticilerin merkezi raporlama yapmasını sağlayan bir uygulamadır. Tasarım dili Vardiya 360 ile uyumludur; renk paleti daha sıcak ve el emeği temasına göre uyarlanmıştır.

**Slogan:** *Emeğinize değer, geleceğe iz*

---

## 1. Arayüz özellikleri

### 1.1 Tasarım dili

| Özellik | Açıklama |
|---------|----------|
| Tema | Koyu mod (Material 3), varsayılan dark theme |
| Tipografi | Google Fonts — Inter (gövde), Playfair Display (marka başlığı) |
| Renk paleti | Deep navy arka plan, teal vurgu, altın/amber aksan, kilim kırmızısı uyarılar |
| Kartlar | Cam efektli (`PremiumGlowCard`), ince altın kenarlık |
| Butonlar | Teal gradient CTA, kompakt mod desteği (`compact: true`) |
| Arka plan | WebP dokuma deseni + yarı saydam lacivert overlay |

**Ana renkler**

| Token | Hex | Kullanım |
|-------|-----|----------|
| deepNavy | `#1A1F36` | Üst başlık, kart zeminleri |
| darkNavy | `#0F1425` | Ana arka plan |
| teal | `#00C2A8` | Birincil aksiyon, aktif sekme |
| tealLight | `#33D4BE` | Tutar vurguları |
| amber / gold | `#F5A623` | Marka altın tonları |
| kilimRed | `#D7263D` | Kilitli profil, hata |
| threadCream | `#F7F2E8` | Açık metin |
| olive | `#8A9A5B` | İkincil bilgi |
| softBlueGray | `#7FA6B8` | Alt metin, boş durum |

### 1.2 Üst marka başlığı

Tüm ana ekranlarda sabit üst bölüm:

- Uygulama ikonu (sol)
- **El Emeği 360** — metalik sweep / shimmer efektli başlık
- Alt slogan
- Yuvarlatılmış alt köşeler, gradient arka plan

### 1.3 Alt navigasyon

Dört sekme — `PageView` ile kaydırmalı geçiş:

| Sekme | İkon | İçerik |
|-------|------|--------|
| Kayıt | Kalem / form | Yeni işçilik kaydı |
| Geçmiş | Liste | Geçmiş kayıtlar |
| Ücret | Cüzdan | Hakediş özeti |
| Ayarlar | Dişli | Profil, IBAN, yönetici girişi |

Aktif sekme teal glow ile vurgulanır.

### 1.4 Ekran bazlı arayüz

#### İlk kurulum (Onboarding)

- Ad soyad girişi (en az 3 karakter, ad + soyad zorunlu)
- Otomatik büyük harf (`AYŞE YILMAZ`)
- Profil bir kez oluşturulur, sonra değiştirilemez
- Marka başlığı + form kartı düzeni

#### Kayıt ekranı

- Kompakt yatay form satırları (`DesignFormRow`): etiket solda, değer sağda
- Çalışan kartı (profil adı, avatar harfi)
- Ürün cinsi, işçilik türü seçicileri (alt sayfa listesi)
- En / Boy yan yana iki sütun
- Ölçü otomatik hesaplanır, salt okunur
- Adet: elle giriş + / − stepper (1–9999)
- Birim ücret ve toplam tutar anlık gösterim
- **Kaydet** — kompakt gradient buton
- Son seçimler cihazda hatırlanır (`RecordDraftStore`)

#### Geçmiş ekranı

- Kayıt listesi (tarih, ürün, tutar, durum rozeti)
- Aşağı çekerek yenileme (`RefreshIndicator`)
- Bekleyen kayıtlar düzenlenebilir / silinebilir
- Ödenmiş kayıtlar salt okunur
- Düzenleme alt sayfası (`RecordEditSheet`)

#### Ücret ekranı

- Hero kart: ödenecek toplam tutar
- Bekleyen kayıt sayısı
- Dönem bazlı ödeme geçmişi listesi
- Durum rozetleri (beklemede / onaylandı / ödendi)

#### Ayarlar ekranı

- **Telefon sahibi** — kilitli ad soyad (değiştirilemez)
- **IBAN** — metin alanı + kaydet butonu
- **Bildirimler** — toggle (yakında, şimdilik kapalı)
- **Güncelleme kontrolü** — GitHub OTA (`fabrika360-updates`)
- **Yönetici paneli** — gizli admin girişi
- **Hakkında** — sürüm, kullanım, geliştirici bilgisi
- Kompakt liste satırları (`dense`, düşük dikey boşluk)

#### Yönetici paneli (Dashboard)

- Ayarlar → Yönetici paneli ile erişilir (alt menüde yok)
- Giriş: kullanıcı adı + şifre, beni hatırla, göster/gizle ikonları
- Kişi seçimi + ay okları ile filtre
- Özet: kayıt sayısı, toplam tutar
- Kayıt listesi, düzenleme / silme
- **Aylık PDF raporu kaydet / paylaş** (Vardiya tarzı tablo + imza alanları)
- Çıkış ve yenileme ikonları

### 1.5 Ortak bileşenler

| Bileşen | Dosya | Açıklama |
|---------|-------|----------|
| `FabrikaGradientButton` | `widgets/fabrika_gradient_button.dart` | Ana CTA |
| `FabrikaFormCard` | `widgets/fabrika_form_card.dart` | Ayarlar form kartları |
| `PremiumGlowCard` | `widgets/premium_glow_card.dart` | Kayıt / liste kartları |
| `DesignFormRow` | `widgets/design/design_form_row.dart` | Yatay form satırı |
| `DesignStatusBadge` | `widgets/design/design_status_badge.dart` | Kayıt durumu rozeti |
| `CurrencyText` | `widgets/currency_text.dart` | ₺ formatlı tutar |
| `ScreenBackdrop` | `widgets/premium/screen_backdrop.dart` | Sekme arka planı |
| `PasswordVisibilityField` | `widgets/password_visibility_field.dart` | Admin şifre alanı |

### 1.6 Boş ve yükleme durumları

- İlk açılış: kısa spinner (yalnızca yerel profil okunurken)
- Geçmiş: yükleme spinner + boş liste metni
- Dashboard: ilk yükleme spinner; boş ay metni + yenileme
- Firebase / kayıt senkronu arka planda; UI bloklanmaz

---

## 2. Uygulama işlevleri

### 2.1 Kullanıcı akışı (işçi)

```
Uygulama açılış
    → Yerel profil yükle
    → [Profil yok] Onboarding (ad soyad)
    → Ana kabuk (4 sekme)
    → Kayıt oluştur → Firestore + yerel önbellek + Sheets yedek
    → Geçmiş / Ücret ekranlarında görüntüle
    → Ödeme yapıldığında push-benzeri SnackBar bildirimi
```

### 2.2 Kayıt oluşturma

1. Ürün cinsi seçilir (NOSTALJİ, MADDER, ETIKET vb.)
2. İşçilik türü seçilir (Saçak, Etiket, Overlogu, Kartela, Küçük etiket)
3. En / Boy seçilir (işlem türüne göre filtrelenmiş ölçü kataloğu)
4. Adet girilir
5. **PricingEngine** birim fiyat ve toplam tutarı hesaplar (Excel V3 kuralları)
6. Kayıt `ee_kayit` koleksiyonuna yazılır
7. Google Sheets’e arka planda yedek yazılır

**Kayıt ID formatı:** `yyyyMMddHHmmss-XY-ZZZ` (kayıt tarihine göre)

### 2.3 Fiyat hesaplama kuralları

| İşlem türü | Hesap |
|------------|-------|
| Saçak | `tutar = adet × birimFiyat(en)` |
| Etiket | `toplamMetre = adet × en × 2 / 100`, `tutar = toplamMetre × sabit birim fiyat` |
| Overlogu | `(en + boy) × adet × 2 / 100 × birimFiyat` |
| Küçük etiket | `adet × birimFiyat` |
| Kartela | `en × adet × 2 / 100 × birimFiyat(en)` |

Fiyat tablosu: `EeMasterData` (Excel V3 ile hizalı sabitler).

### 2.4 Geçmiş ve düzenleme

- Kullanıcı yalnızca **kendi** kayıtlarını görür (`ownerUid`)
- `BEKLEMEDE` durumundaki kayıtlar düzenlenebilir ve silinebilir
- Onaylanmış / ödenmiş kayıtlar mobilde salt okunur
- Yerel önbellek (`RecordsCache`) — ağ yokken geçmiş gösterimi

### 2.5 Hakediş / ücret takibi

- Bekleyen toplam tutar ve kayıt sayısı
- Aylık dönem (`donemKey`: `yyyy-MM`) bazında gruplama
- Kayıt durumları: `BEKLEMEDE` → `ONAYLANDI` → `ODENDI`
- Masaüstü ödeme onayı sonrası `ee_bildirim` dinlenir; uygulama açıkken SnackBar gösterilir

### 2.6 Profil ve IBAN

- Profil: `ee_person/{ownerUid}` (eski: `ee_cihaz`)
- IBAN ayarlardan güncellenir → Firestore + Sheets yedek
- Ad soyad ilk kurulumdan sonra **kilitli**

### 2.7 Yönetici paneli

| Özellik | Açıklama |
|---------|----------|
| Giriş | Varsayılan `eko` / `eko2026` (+ Firestore `users` tablosu) |
| Oturum | Firestore `dashboard_crud_sessions/{uid}` (12 saat TTL, Spark plan) |
| Liste | Tüm `ee_kayit` kayıtları |
| Filtre | Ay + kişi (ad soyad) |
| CRUD | Admin düzenleme / silme |
| Rapor | Aylık PDF — tablo, toplam, imza alanları, paylaşım menüsü |

Panel alt menüde **görünmez**; yalnızca Ayarlar → Yönetici paneli.

### 2.8 Google Sheets yedekleme

- **Birincil veri:** Firestore
- **Sheets:** Yalnızca yedek **yazma** (okuma yok)
- Tetikleyiciler: kayıt ekle/güncelle/sil, profil kaydı, IBAN güncelleme
- Arka planda, ana işlemi bekletmez (`EeSheetsService.enqueueBackup`)
- Apps Script: `scripts/Code.gs` — `EE_PERSON`, `EE_KAYIT` sayfaları

### 2.9 OTA güncelleme

- GitHub: `fabrika360-updates` / `elemegi360/version.json`
- Ayarlar → Güncellemeyi kontrol et
- Yeni sürüm varsa APK indirme linki tarayıcıda açılır

### 2.10 Çevrimdışı davranış

- Profil ve kayıtlar yerel önbellekte
- Kayıt oluşturma Firestore erişilemezse yerelde saklanır; bağlantı gelince senkron
- Geçmiş ekranı önbellekten anında açılır, arka planda güncellenir

---

## 3. Teknik detaylar

### 3.1 Mimari

```
lib/
├── main.dart              # Firebase + locale init, runApp
├── app.dart               # MaterialApp, tema, AppGate
├── core/                  # Sabitler, tarih, fiyat motoru, kayıt ID
├── theme/                 # Renkler, tipografi, ThemeData
├── models/                # WorkRecord, WorkerProfile, IslemTuru
├── data/
│   ├── local/             # ProfileStore, RecordsCache, RecordDraftStore
│   ├── remote/            # Firestore repos, Sheets, AppWarmup
│   ├── records_store.dart # Geçmiş / ücret state
│   ├── dashboard_store.dart
│   └── admin_auth_service.dart
├── features/
│   ├── shell/             # AppGate, MainShell
│   ├── onboarding/
│   ├── record/
│   ├── history/
│   ├── payment/
│   ├── settings/
│   ├── dashboard/
│   └── about/
└── widgets/               # Paylaşılan UI bileşenleri
```

**State yönetimi:** `ChangeNotifier` + `ListenableBuilder` (Provider/Riverpod yok).

### 3.2 Firebase

| Servis | Kullanım |
|--------|----------|
| Firebase Core | Başlatma |
| Firebase Auth | Anonymous Auth → `ownerUid` |
| Cloud Firestore | Birincil veri deposu |

**Proje:** `fabrika360suite-ekohali-cloud`  
**Veritabanı:** `fabrika360` (named database)

**Firestore koleksiyonları (mobil)**

| Koleksiyon | Amaç |
|------------|------|
| `ee_person` | Cihaz profili, IBAN |
| `ee_kayit` | Tüm işçilik kayıtları |
| `ee_bildirim` | Ödeme bildirimleri |
| `dashboard_crud_sessions` | Admin CRUD oturumu |
| `users` | Admin kullanıcı doğrulama |

### 3.3 Kimlik doğrulama

- **İşçi modu:** Anonymous Firebase Auth; UID = `ownerUid`
- **Admin modu:** Kullanıcı adı/şifre → Firestore oturum belgesi
- Cloud Functions **kullanılmaz** (Spark plan uyumlu)

### 3.4 Bağımlılıklar (özet)

| Paket | Amaç |
|-------|------|
| cloud_firestore | Veri okuma/yazma |
| firebase_auth | Anonim oturum |
| shared_preferences | Yerel profil, taslak, admin tercihleri |
| google_fonts | Inter, Playfair |
| intl | Türkçe tarih / para formatı |
| http | Sheets, OTA |
| pdf + printing | Dashboard PDF raporu |
| share_plus | PDF paylaşım |
| path_provider | Geçici PDF dosyası |
| package_info_plus | Sürüm bilgisi |
| url_launcher | APK indirme |

### 3.5 Açılış optimizasyonu (`AppWarmup`)

1. **Hızlı aşama:** Yerel profil + admin prefs + kayıt önbelleği → UI hemen açılır
2. **Arka plan:** Firebase oturum, profil senkronu (`touchLastSeen`), kayıt refresh
3. Sheets yalnızca veri değişiminde yazılır; açılışta çağrılmaz

### 3.6 Derleme ve dağıtım

```bash
# Geliştirme
flutter run

# Release (cihaz başına ~25 MB — önerilen)
flutter build apk --release --split-per-abi

# Universal APK (~61 MB — tüm CPU mimarileri)
flutter build apk --release
```

**Android paket:** `com.greenlabs.development.elemegi360`  
**Minimum SDK:** Flutter varsayılan  
**İmzalama:** Release yapılandırması (production için keystore gerekir)

### 3.7 Asset boyutları (optimize)

| Dosya | Açıklama |
|-------|----------|
| `app_icon.png` | Launcher ikonu |
| `bg_02.webp` | Arka plan deseni (WebP) |
| `pass_show.png` / `pass_hide.png` | Admin şifre görünürlük |

Kullanılmayan arka plan PNG’leri kaldırıldı.

### 3.8 Güvenlik kuralları (özet)

- İşçi: yalnızca `ownerUid == auth.uid` kayıtları okur/yazar
- Admin oturumu aktifken: `dashboard_crud_sessions` üzerinden geniş CRUD
- Profil: oluşturma bir kez; ad soyad sonradan değiştirilemez

Detay: kök `firestore.rules` + `plan/EL_EMEGI_360_DATA_MODEL.md`

---

## 4. Diğer özellikler

### 4.1 Türkçe yerelleştirme

- UI metinleri Türkçe
- Tarih: `tr_TR` locale (`d MMMM yyyy`, `MMMM yyyy`)
- Para: ₺ formatı, ondalık virgül
- Ad soyad: otomatik büyük harf, Türkçe karakter desteği

### 4.2 Kayıt taslağı hatırlama

Son kullanılan ürün cinsi, işlem türü, en, boy ve adet cihazda saklanır; uygulama yeniden açıldığında form aynı seçimlerle gelir.

### 4.3 PDF rapor (yönetici)

- A4, Noto Sans font (Türkçe karakter)
- Başlık, dönem, personel adı
- Tablo: tarih, ürün, işçilik, ölçü, adet, tutar
- Toplam satırı
- Personel / yönetici imza alanları
- Paylaşım menüsü (Drive, WhatsApp, Dosyalar)

### 4.4 Bildirimler

- Push notification altyapısı hazırlık aşamasında
- Ödeme bildirimi: Firestore `ee_bildirim` → uygulama içi SnackBar
- Ayarlar toggle şimdilik devre dışı

### 4.5 Fabrika 360 Suite entegrasyonu

- Vardiya 360, Performans 360, Üretim 360 ile aynı Firebase projesi
- Ortak Firestore veritabanı (`fabrika360`)
- Benzer UI bileşen desenleri ve admin oturum modeli
- Masaüstü **Fabrika 360** ile kayıt onayı ve ödeme işlemleri (mobil salt okur)

### 4.6 Geliştirme ortamı

| Konu | Değer |
|------|-------|
| Flutter SDK | `D:\AndroidSDK\FlutterSDK` (veya PATH) |
| PUB_CACHE | `D:\AndroidSDK\PubCache` (D: sürücüsü projeleri için) |
| Scripts | `scripts/build-release-apk.bat`, `scripts/run-android.ps1` |
| Plan dokümanları | `plan/` klasörü |
| Agent bağlamı | `AGENTS.md` |

### 4.7 Bilinen sınırlar

- Profil cihaz UID’sine bağlı; uygulama verisi silinirse yeni profil gerekir
- Admin paneli ağ gerektirir (Firestore oturum)
- Sheets yedek yazma başarısız olsa bile Firestore birincil kalır
- Bildirimler tam push değil; uygulama açıkken SnackBar

### 4.8 Yol haritası (planlanan / kapalı)

- Birim ücret listesi ekranı (kod var, ayarlarda gizli)
- Tam push notification desteği
- Gizlilik politikası URL (`AppMeta.privacyPolicyUrl` boş)

---

## Hızlı referans — ekran → dosya

| Ekran | Dart dosyası |
|-------|----------------|
| Açılış kapısı | `lib/features/shell/app_gate.dart` |
| Ana kabuk | `lib/features/shell/main_shell.dart` |
| Onboarding | `lib/features/onboarding/onboarding_screen.dart` |
| Kayıt | `lib/features/record/record_screen.dart` |
| Geçmiş | `lib/features/history/history_screen.dart` |
| Ücret | `lib/features/payment/payment_screen.dart` |
| Ayarlar | `lib/features/settings/settings_screen.dart` |
| Yönetici | `lib/features/dashboard/dashboard_screen.dart` |
| Hakkında | `lib/features/about/about_screen.dart` |

---

## İlgili dokümanlar

- [README.md](../README.md) — Kurulum ve geliştirme
- [AGENTS.md](../AGENTS.md) — AI / editor bağlamı
- [plan/EL_EMEGI_360_DATA_MODEL.md](../plan/EL_EMEGI_360_DATA_MODEL.md) — Veri modeli
- [plan/GOOGLE_SHEETS_EL_EMEGI_360.md](../plan/GOOGLE_SHEETS_EL_EMEGI_360.md) — Sheets kurulumu
- [scripts/Code.gs](../scripts/Code.gs) — Apps Script yedek API

---

*Son güncelleme: 2026-05-19 — sürüm 26.5.1*
