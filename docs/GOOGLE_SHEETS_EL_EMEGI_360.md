# Google Sheets — El_Emegi_360

Drive: `El_Emegi_360` klasörü · Spreadsheet: **El_Emegi_360**

Web App: `lib/core/app_config.dart` → `sheetsWebAppUrl`

## Kurulum (güncel script)

1. **El_Emegi_360** dosyasını açın.
2. **Uzantılar → Apps Script** → `scripts/Code.gs` içeriğini yapıştırın → Kaydet.
3. Fonksiyon: **`setupEeSheets`** → Çalıştır.  
   - Oluşturur: `EE_PERSONEL`, `EE_KAYIT`, `EE_ODEME_OZET`  
   - Siler: `EE_CIHAZ`, `EE_URUN_CINSI`, `EE_ISLEM`, `EE_OLCU`, `EE_FIYAT` (master artık FB’de)
4. **Dağıt → Web uygulaması** (mevcut URL’yi güncelleyebilirsiniz).
5. Tarayıcıda test:  
   `.../exec?action=ping`  
   Beklenen: `{"status":"success","message":"El Emeği 360 Sheets API",...}`

`{"status":"error","message":"Geçersiz istek"}` → URL sonuna **`?action=ping`** ekleyin; kök URL boş istek kabul etmez.

## EE_PERSONEL = kişi / IBAN listesi

Evet — **EE_PERSONEL** sekmesi tam olarak bu: telefon sahibi adı, `owner_uid`, **IBAN**, güncelleme tarihi. Muhasebe ödeme öncesi buradan okur.

Mobil IBAN kaydedince: `updateIban` action (ileride otomatik bağlanacak).

## APK / GitHub

`scripts/build-release-apk.bat` → release APK → [fabrika360-updates](https://github.com/ilyasyesildevelop/fabrika360-updates) release + `elemegi360/version.json` (`latestVersionCode`: **26050001**).
