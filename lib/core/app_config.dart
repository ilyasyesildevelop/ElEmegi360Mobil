/// Uygulama sabitleri (OTA, Google Sheets yedek yazma).
abstract final class AppConfig {
  static const updateInfoUrl =
      'https://api.github.com/repos/ilyasyesildevelop/fabrika360-updates/contents/elemegi360/version.json?ref=master';

  /// El_Emegi_360 spreadsheet — yalnızca yedek yazma (Apps Script Web App).
  static const sheetsWebAppUrl =
      'https://script.google.com/macros/s/AKfycbyfPS-qTmwEnxZTXWGme-dO-hIA5kvR5utP-uJAZc7aNSup_FgehJ8EE-39fSpv94TJtQ/exec';

  /// Test: .../exec?action=ping

  /// Ayarlar → Birim ücret listesi (ekran kodu duruyor, UI kapalı).
  static const showUnitPriceListInSettings = false;
}
