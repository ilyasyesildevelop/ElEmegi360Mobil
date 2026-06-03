# El Emeği 360 Mobil (Flutter)

Fabrika 360 — ev işçiliği (saçak, etiket, overlogu vb.) kayıt ve hakediş takibi.

**Git:** [ElEmegi360Mobil](https://github.com/ilyasyesildevelop/ElEmegi360Mobil) (bu klasör kendi deposudur).

## Editor modda açma

1. Cursor’da **File → Open Folder** → bu klasörün kökü (`ElEmegi360Mobil`)
2. Sohbette **Editor** veya dar kapsamlı **Agent** kullan; `lib/` altını hedefle.
3. Bağlam: `@AGENTS.md`, `@plan/EL_EMEGI_360_FIRESTORE_SCHEMA_DRAFT.md`

## İlk kurulum (bir kez)

Flutter SDK PATH’te olmalı.

### Windows — proje D: sürücüsündeyse (önemli)

Pub önbelleği varsayılan olarak `C:\Users\...\Pub\Cache` içindedir. Proje **D:** sürücüsündeyken Gradle şu hatayı verebilir:

`this and base files have different roots` (`shared_preferences_android` vb.)

**Kalıcı çözüm** — `PUB_CACHE` kullanıcı ortam değişkeni:

- Ad: `PUB_CACHE`
- Değer: `D:\AndroidSDK\PubCache`

C: altındaki eski önbellek (`%LOCALAPPDATA%\Pub\Cache`) buraya taşındı; yedek adı `Cache_from_C_backup` (silinebilir).

Android Studio / Cursor’u **PUB_CACHE ekledikten sonra yeniden başlatın**.

Eski `C:` yolları `.flutter-plugins-dependencies` içinde kalmışsa Gradle yine patlar. **Bir kez** şunu çalıştırın:

```powershell
cd ElEmegi360Mobil
.\scripts\fix-pub-cache.ps1
```

Sonra derleyin veya `.\scripts\run-android.ps1`

Cursor terminali için `.vscode/settings.json` içinde `PUB_CACHE` tanımlıdır.

```bash
flutter pub get
flutter run
```

Android Studio’da **bu klasörün kökünü** açın (`ElEmegi360Mobil`), içindeki eski boş `ElEmegi360Flutter` klasörünü değil. Proje tipi: **Flutter** (`pubspec.yaml` + `lib/`).

Tasarım görselleri (`el emegi plan/` klasöründeki ikon ve UI konseptleri):

```text
el emegi plan/app_icon.png          → assets/images/app_icon.png
el emegi plan/launcher_icons/       → android/... (flutter_launcher_icons ile)
```

`google-services.json`: `android/app/google-services.json` (Firebase Console → `com.greenlabs.development.elemegi360`).

## Eski Android Studio projeleri

| Klasör | Durum |
|--------|--------|
| **`ElEmegi360Mobil`** | Güncel **Flutter** uygulaması — burada çalışın |
| **`ElEmegi360Flutter`** | Boş AS iskeleti (`.idea` / iç içe `ElEmegi360/`) — kaynak kod yok; silinebilir |

Kökteki eski **native Android** `app/` modülü kaldırıldı. `android/.../MainActivity.kt` Flutter’ın zorunlu giriş noktasıdır; Kotlin uygulama kodu değildir.

## Klasör yapısı (hedef)

```
lib/
  main.dart
  app.dart
  theme/          # renkler, ThemeData
  core/           # record_id, date_key, firebase
  features/
    record/
    history/
    payment/
    settings/
```

Plan ve Firestore taslağı: `plan/`.
