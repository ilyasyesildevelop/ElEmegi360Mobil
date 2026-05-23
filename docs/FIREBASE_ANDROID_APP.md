# Firebase — Android uygulama ekleme bilgileri (El Emeği 360)

Konsolda **Project settings → Your apps → Add app → Android** için aşağıdaki değerleri kullanın.

## Zorunlu alanlar

| Alan | Değer |
|------|--------|
| **Android package name** | `com.greenlabs.development.elemegi360` |
| **App nickname** (isteğe bağlı) | `El Emeği 360` |
| **Debug signing certificate SHA-1** | Android Studio / Gradle ile üretin (aşağıda) |

## Proje (zaten mevcut)

| | |
|---|---|
| **Project ID** | `fabrika360suite-ekohali-cloud` |
| **Project number** | `790650900454` |
| **Mobil SDK App ID** (Android) | `1:790650900454:android:8a2ef931a4efa823ffd027` |

`android/app/google-services.json` içinde bu paket zaten tanımlı. Konsolda uygulama listede görünmüyorsa aynı **package name** ile tekrar ekleyin veya JSON’u yeniden indirip `android/app/` altına koyun.

## SHA-1 / SHA-256 (Auth ve bazı API’ler için)

Debug keystore (varsayılan):

```powershell
cd $env:USERPROFILE\.android
keytool -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Çıktıdaki **SHA-1** ve **SHA-256** değerlerini Firebase Console → uygulama → **Add fingerprint** ile ekleyin.

Release için kendi `.jks` / `.keystore` dosyanızın SHA’larını da ekleyin.

## Firestore veritabanı adı

Kod `FabrikaFirestore` ile **`fabrika360`** adlı veritabanına bağlanır (default `(default)` değil).

Console: **Firestore Database →** varsa `fabrika360` seçin; yoksa **Create database** → Database ID: `fabrika360`.

## Kimlik doğrulama

Mobil: **Anonymous** sign-in açık olmalı (`ee_cihaz` ownerUid = auth uid).

## Özet kontrol listesi

- [ ] Android app: `com.greenlabs.development.elemegi360`
- [ ] `google-services.json` → `ElEmegi360Mobil/android/app/`
- [ ] SHA-1 (debug + release) eklendi
- [ ] Firestore DB `fabrika360` oluşturuldu
- [ ] Anonymous Auth etkin
- [ ] `firebase/firestore.rules` deploy edildi
