/// Excel V3 master — `firebase/scripts/ee-master-from-excel.json` ile senkron.
/// Yenileme: `python firebase/scripts/extract-ee-master-from-excel.py`
abstract final class EeMasterData {
  static const source = '2026.04 SAÇAK VE ETİKET LİSTESİ_V3.xlsm';

  static const urunCinsleri = [
  'MADDER',
  'NOSTALJİ',
  'ZARA',
  'ZD',
  ];

  static const islemTurleri = [
  'El Overlogu',
  'Etiket',
  'Kartela',
  'Küçük Etiket',
  'Saçak',
  'Tamir',
  ];

  static const sacakEnCm = [
  '20',
  '30',
  '40',
  '45',
  '60',
  '70',
  '80',
  '90',
  '100',
  '120',
  '125',
  '130',
  '140',
  '160',
  '170',
  '180',
  '185',
  '190',
  '200',
  '230',
  '240',
  '250',
  '300',
  ];

  static const standartOlculer = [
  '100×200',
  '120×180',
  '130×190',
  '135×295',
  '160×230',
  '170×240',
  '190×270',
  '20×20',
  '200×290',
  '200×300',
  '240×340',
  '250×350',
  '30×30',
  '300×390',
  '300×400',
  '40×40',
  '45×45',
  '60×90',
  '80×150',
  '80×300',
  '90×150',
  '90×290',
  '90×300',
  'Q100',
  'Q120',
  'Q130',
  'Q150',
  'Q160',
  'Q190',
  'Q200',
  'Q300',
  'Q80',
  'Q90',
  ];

  static const kareOlculer = [
  '30×30',
  '40×40',
  '45×45',
  '60×60',
  '70×70',
  '80×80',
  '90×90',
  '100×100',
  '120×120',
  '130×130',
  '140×140',
  '150×150',
  '160×160',
  '170×170',
  '180×180',
  '190×190',
  '200×200',
  '200×260',
  '230×230',
  '240×240',
  '250×250',
  '300×300',
  ];

  static const sacakQEn = [
  'Q90',
  'Q120',
  'Q130',
  'Q140',
  'Q150',
  'Q160',
  'Q190',
  'Q200',
  ];

  static const sacakByEn = <int, double>{
    20: 40.0,
    30: 55.0,
    40: 75.0,
    45: 85.0,
    60: 115.0,
    70: 135.0,
    80: 150.0,
    90: 170.0,
    100: 190.0,
    120: 225.0,
    125: 235.0,
    130: 245.0,
    140: 265.0,
    160: 300.0,
    170: 320.0,
    180: 340.0,
    185: 350.0,
    190: 360.0,
    200: 365.0,
    230: 425.0,
    240: 445.0,
    250: 475.0,
    300: 570.0,
  };

  static const sacakByQ = <String, double>{
    'Q120': 600.0,
    'Q130': 650.0,
    'Q140': 700.0,
    'Q150': 750.0,
    'Q160': 800.0,
    'Q190': 925.0,
    'Q200': 1000.0,
    'Q90': 450.0,
  };

  static const etiketBirim = 48.0;
  static const overloguBirim = 165.0;
  static const kartelaBirim = 7.0;
  static const kucukEtiketBirim = 3.0;
}
