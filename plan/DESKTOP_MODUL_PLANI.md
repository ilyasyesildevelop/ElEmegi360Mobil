# El Emeği 360 — Fabrika360 Desktop entegrasyon planı

**Tarih:** 2026-05-19  
**Durum:** Planlama (henüz Desktop kodu yok)  
**Hedef:** Mobil El Emeği 360 verisini Fabrika360 Desktop (WPF) üzerinden yönetmek — muhasebe, ödeme, tam tablo CRUD.

**Referanslar:**
- Mobil dokümantasyon: `ElEmegi360Mobil/docs/UYGULAMA_DOKUMANTASYONU.md`
- Veri modeli: `ElEmegi360Mobil/plan/EL_EMEGI_360_DATA_MODEL.md`
- Ödeme bildirimi: `ElEmegi360Mobil/docs/FIRESTORE_ODEME_BILDIRIM.md`
- Desktop kabuk: `Fabrika360Desktop/Fabrika360/` (WPF, `MainViewModel` merkezli)

---

## 0. Temel kararlar

| Konu | Karar |
|------|--------|
| Mimari | Mevcut **tek MainViewModel + paylaşılan View** deseni; ayrı proje/assembly yok |
| Veri kaynağı | Firestore `fabrika360` — birincil; Sheets yalnızca mobil yedek yazma (Desktop okumaz) |
| Kimlik | Desktop: Firebase Auth + `users` (admin). Mobil işçi: Anonymous — Desktop tüm `ee_*` okur/yazar |
| Modül adı | `ActiveModule = "ElEmegi"` — üst sekme: **El Emeği 360** |
| Renk vurgusu | Mobil ile uyum: teal `#00C2A8`, amber altın (mevcut `Themes/` üzerine modül accent) |

---

## 1. Dashboard — tasarım ve öneriler

### 1.1 Amaç

Muhasebe / yönetici, tek bakışta **hangi dönemde ne kadar hakediş var, kimler bekliyor, son kayıtlar neler** görmeli. Üretim/Performans’taki makine grafiklerinden farklı olarak El Emeği **kişi + ay + TL** odaklıdır.

### 1.2 Önerilen layout (Vardiya dashboard + KPI kartları karışımı)

```
┌─────────────────────────────────────────────────────────────────┐
│  El Emeği 360 — Dashboard          [◀ Mayıs 2026 ▶]  [Yenile]   │
├─────────────────────────────────────────────────────────────────┤
│ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐            │
│ │ Bekleyen │ │ Bu ay    │ │ Kayıt    │ │ Aktif    │            │
│ │ ödeme    │ │ ödenen   │ │ sayısı   │ │ kişi     │            │
│ │ ₺42.350  │ │ ₺18.200  │ │ 127      │ │ 23       │            │
│ └──────────┘ └──────────┘ └──────────┘ └──────────┘            │
├──────────────────────────────┬──────────────────────────────────┤
│  Kişi bazlı bekleyen (Top 10)  │  Durum dağılımı (pasta / bar)     │
│  ████████ AYŞE Y.    ₺4.200  │  BEKLEMEDE  ████████ 62%         │
│  ██████   FATMA K.   ₺3.100  │  ONAYLANDI  ███      28%         │
│  ...                         │  ODENDI     ██       10%         │
├──────────────────────────────┴──────────────────────────────────┤
│  Son kayıtlar (10) — tarih | kişi | işlem | tutar | durum        │
│  [Ödeme ekranına git]  [Kayıt tablosuna git]                      │
└─────────────────────────────────────────────────────────────────┘
```

### 1.3 KPI tanımları (seçili `donemKey`)

| KPI | Hesap |
|-----|--------|
| Bekleyen ödeme | `ee_kayit` where `donemKey` + `durum in (BEKLEMEDE, ONAYLANDI)` → Σ tutar |
| Bu ay ödenen | `durum == ODENDI` + `odemeTarihi` veya `donemKey` aynı ay → Σ tutar |
| Kayıt sayısı | Seçili ay toplam kayıt |
| Aktif kişi | Seçili ayda en az 1 kaydı olan benzersiz `workerKey` / `adSoyad` |

### 1.4 Filtreler

- **Ay seçici** (Vardiya’daki ay okları ile aynı UX)
- Opsiyonel **kişi filtresi** (ComboBox — tüm kişiler)
- Dashboard verisi: önce `TableCacheStore`, arka planda Firestore refresh

### 1.5 Grafik önerisi

| Seçenek | Artı | Eksi |
|---------|------|------|
| **A — Kişi bazlı yatay bar (Top N bekleyen)** | Muhasebe için en faydalı | Uzun liste |
| **B — Durum pasta (bekleyen/onaylı/ödendi)** | Hızlı özet | Detay az |
| **C — 30 günlük sütun (mobil kayıt hacmi)** | Üretim modülüne benzer | El emeği için ay granularity daha doğru |

**Öneri:** **A + B** birlikte; C isteğe bağlı Faz 2.

### 1.6 Dashboard aksiyonları

- **Ödeme ekranına git** — seçili ay ile açılır
- **Kayıt tablosu** — `TBL_EEKayit` filtreli
- **PDF özet** (Faz 2) — ay + tüm kişiler toplu rapor (QuestPDF, mobil PDF ile uyumlu)

### 1.7 Teknik uygulama

- `MainViewModel.FillElEmegiDashboard()` — Vardiya `FillVardiyaDashboard` klonu
- `DashboardView.xaml` — `ActiveModule == ElEmegi` visibility bölümü
- Property’ler: `ElEmegiDashboardMetrics`, `ElEmegiTopPendingPersons`, `ElEmegiRecentRecords`, `ElEmegiSelectedDonem`

---

## 2. İşçilik ücretleri — ödeme ekranı

### 2.1 Ekran adı ve navigasyon

- Sidebar: **Ödemeler** (modüle özel — Vardiya “Dilekçeler” gibi)
- `ActivePage = "EE_Odeme"` → yeni `EEOdemeView.xaml`
- Dashboard’dan kısayol ile aynı view

### 2.2 Satır modeli (kişi × dönem)

Her satır = **bir kişi + bir dönem (`donemKey`)** özeti:

| Sütun | Tip | Açıklama |
|-------|-----|----------|
| ☐ | Checkbox | **Ödendi** işareti (kullanıcı talebi) |
| Ad Soyad | read-only | `adSoyad` |
| Dönem | read-only | `2026-05` → “Mayıs 2026” |
| Kayıt adedi | read-only | Bekleyen + onaylı kayıt sayısı |
| Hesaplanan tutar | read-only | İlgili kayıtların Σ `tutar` |
| **Ödeme tutarı** | **TextBox (editable)** | Varsayılan = hesaplanan; muhasebe düzeltebilir |
| Durum | badge | Bekliyor / Ödendi / Kısmi? |
| IBAN | read-only kısaltılmış | `TR12 … 4521` + kopyala ikonu |
| Son ödeme tarihi | read-only | `odemeTarihi` (ödendiyse) |

### 2.3 Checkbox davranışı (kritik iş kuralı)

**Checkbox işaretlendiğinde:**

1. Onay diyaloğu: *“{Ad Soyad} — {Ay}: ₺{tutar} ödendi olarak işaretlensin mi?”*
2. Firestore batch yazımı:
   - İlgili tüm `ee_kayit` (o kişi + dönem + ödenmemiş): `durum = ODENDI`, `odemeTarihi = now`
   - `ee_odeme_ozet/{donemKey}_{workerKey}` upsert:
     - `toplamTutar` = **TextBox’taki ödeme tutarı** (hesaplanandan farklı olabilir)
     - `hesaplananTutar` = Σ kayıt (audit için — yeni alan önerisi)
     - `odendi = true`, `odemeTarihi`, `kayitSayisi`
   - `ee_bildirim` yeni doküman (`ownerUid`, `donemKey`, `toplamTutar`, `delivered: false`) — mobil SnackBar
3. Checkbox kilitlenir / satır “Ödendi” stiline geçer
4. Sheets yedek: Desktop’tan **yazma opsiyonel** (Faz 2 — mobil zaten yedekliyor)

**Checkbox kaldırıldığında (sadece IT/DIRECTOR):**

- Geri alma diyaloğu + kayıtları `ONAYLANDI` veya `BEKLEMEDE`’ye döndürme
- `ee_odeme_ozet.odendi = false`
- Bildirim dokümanı silinmez (audit)

### 2.4 Tutar düzenleme

- **Hesaplanan tutar** kayıtlardan otomatik; salt okunur ayrı sütun veya tooltip
- **Ödeme tutarı** TextBox:
  - Varsayılan: hesaplanan
  - Manuel değişiklik: `ee_odeme_ozet` ve bildirimde bu tutar kullanılır
  - Kayıt satır tutarları **değişmez** (muhasebe farkı özet seviyesinde)
- Negatif / sıfır validasyonu

### 2.5 Toplu işlemler

- Üst toolbar: **Tümünü seç (bekleyenler)**, **Seçilenleri öde**
- Filtre: yalnızca bekleyen / tümü / ödendi
- Excel export (ClosedXML — projede mevcut)

### 2.6 Onay akışı

**Güncel karar:** Ödeme öncesi ayrı onay adımı yok. Checkbox = ödendi + `ee_odeme_ozet` + `ee_bildirim`. Kayıt durumu (`ODENDI`) mobil tutarlılık için güncellenebilir; zorunlu iş kuralı değil.

### 2.7 UI mockup (DataGrid)

```
┌────────────────────────────────────────────────────────────────────────┐
│ Ödemeler — Mayıs 2026    [◀ ▶]  [Ara...]  [Yalnızca bekleyen ▼]       │
├────┬─────────────┬───────┬──────────┬──────────┬──────────┬────────────┤
│ ☐  │ Ad Soyad    │ Kayıt │ Hesaplan │ Ödeme ₺  │ IBAN     │ Durum      │
├────┼─────────────┼───────┼──────────┼──────────┼──────────┼────────────┤
│ ☐  │ AYŞE YILMAZ │ 12    │ 4.200,00 │ [4200,00]│ TR..4521📋│ Bekliyor  │
│ ☑  │ FATMA KAYA  │ 8     │ 3.100,00 │ [3100,00]│ TR..8832📋│ Ödendi    │
└────┴─────────────┴───────┴──────────┴──────────┴──────────┴────────────┘
│ Seçilenleri öde (2)                              Toplam bekleyen: ₺… │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Tam tablo hakimiyeti (CRUD)

Diğer modüller gibi **TabloView + MainViewModel** ile tüm Firestore tabloları.

### 3.1 Modül tablo haritası (`ModuleTableMap`)

```csharp
["ElEmegi"] = [
    "TBL_Kullanicilar",      // paylaşılan users
    "TBL_EEPerson",          // ee_person (profil + IBAN)
    "TBL_EEKayit",           // ee_kayit — ana kayıt
    "TBL_EEOdemeOzet",       // ee_odeme_ozet — salt okunur veya kısıtlı yazma
    "TBL_EECinsMaster",      // opsiyonel master
    "TBL_EEOlcuMaster",
    "TBL_EEFiyatMaster",
]
```

### 3.2 Firestore eşlemesi (`FirestoreService.TblToCollection`)

| TBL anahtarı | Koleksiyon | CRUD |
|--------------|------------|------|
| `TBL_EEPerson` | `ee_person` | RU (create mobil; desktop IBAN update) |
| `TBL_EEKayit` | `ee_kayit` | **Tam CRUD** — `IsRecordTableKey()` |
| `TBL_EEOdemeOzet` | `ee_odeme_ozet` | R + ödeme ekranından W |
| `TBL_EECinsMaster` | `ee_cins_master` | CRUD |
| `TBL_EEOlcuMaster` | `ee_olcu_master` | CRUD |
| `TBL_EEFiyatMaster` | `ee_fiyat_master` | CRUD |
| `TBL_EEBildirim` | `ee_bildirim` | R (audit; silme IT) |

### 3.3 Kayıt tablosu özel kurallar

- Yeni satır: Desktop’tan manuel kayıt (muhasebe düzeltmesi) — `PricingEngine` desktop port veya ham tutar
- Silme: onay diyaloğu + Sheets yedek silme (opsiyonel HTTP Apps Script)
- Durum sütunu: ComboBox `BEKLEMEDE | ONAYLANDI | ODENDI`
- Filtre preset: dönem, kişi, durum

### 3.4 Sync ve bildirim

- Login sync: `TableCacheStore` altına `ElEmegi/` klasörü
- Periyodik refresh: mevcut timer’a modül ekle
- Tray: yeni mobil `ee_kayit` → “El Emeği: yeni kayıt — {adSoyad}”

---

## 4. Kişi listesi ve IBAN ekranı

### 4.1 Konum

- Sidebar: **Kişiler (EE)** veya `TBL_EEPerson` tablo sayfası + zenginleştirilmiş **EEPersonView**
- Ödeme ekranından farklı: **master liste** odaklı; ödeme özeti yok

### 4.2 Tablo sütunları

| Sütun | Not |
|-------|-----|
| Ad Soyad | Sabitlenmiş profil adı |
| workerKey | `AYSE_YILMAZ` |
| IBAN | Tam gösterim veya maskeli toggle |
| Platform | android |
| Son görülme | `lastSeenAt` |
| Kayıt sayısı (ay) | Hesaplanan — join `ee_kayit` |
| ownerUid | IT için; gizlenebilir sütun |

### 4.3 Extra özellikler (talep + öneri)

| Özellik | Açıklama |
|---------|----------|
| **IBAN kopyala** | Satır aksiyonu + sağ tık — panoya `TR…` (boşluksuz) |
| **IBAN düzenle** | Modal → Firestore `ee_person` + Sheets yedek POST |
| **IBAN doğrula** | TR IBAN mod-97 basit kontrol (checksum) |
| **Kişi ara** | Ad / workerKey filtre |
| **Excel aktar** | ClosedXML |
| **Son kayıt tarihi** | `ee_kayit` max `tarih` |
| **Bekleyen bakiye** | Σ ödenmemiş tutar (link → ödeme ekranı filtreli) |

### 4.4 UX detayı

- IBAN hücresi: `TR64 0006 …` formatlı gösterim; kopyala **tek tık**
- IBAN yok: kırmızı “Eksik” badge — ödeme ekranında uyarı
- Çift tık satır → kişinin kayıt geçmişi (`TBL_EEKayit` filtreli)

---

## 5. Ek öneriler (modül geneli)

### 5.1 Mobil ↔ Desktop tutarlılık

| Konu | Öneri |
|------|--------|
| Durum enum | Aynı string: `BEKLEMEDE`, `ONAYLANDI`, `ODENDI` |
| `donemKey` | Her zaman `yyyy-MM` |
| PDF rapor | Desktop QuestPDF — mobil PDF layout ile aynı başlık/sütun |
| Admin dashboard mobil | Değişmez; Desktop ayrı yetki |

### 5.2 Raporlar (Faz 2)

- Aylık kişi bazlı PDF (mobil admin PDF ile aynı)
- Dönem kapanış raporu (tüm kişiler, ödenen/bekleyen)
- Google Sheets **okuma yok**; export CSV/Excel yeterli

### 5.3 Ayarlar

- `ConnectionSettingsStore`: `WebAppUrlElEmegi`, `SheetsIdElEmegi` (yedek yazma test ping — opsiyonel)
- Modül aç/kapa yetkisi: `users.role` veya modül bayrağı

### 5.4 Güvenlik

- Ödeme checkbox: yalnızca `IT` / `DIRECTOR` / `MUHASEBE` rolü (rol tablosu genişletme)
- Geri alma (ödendi → bekliyor): sadece IT
- Firestore rules: Desktop service account veya mevcut admin token ile REST (kurallar güncel)

### 5.5 Performans

- Ödeme ekranı: `ee_kayit` + `ee_person` + `ee_odeme_ozet` birleşimi bellekte (login cache)
- 500+ kayıt: VirtualizingStackPanel DataGrid (WPF default)

### 5.6 Test senaryoları

1. Mobil kayıt → Desktop tabloda görünür
2. Onay → ödeme ekranında bekleyen tutar
3. Checkbox + tutar değiştir → `ee_odeme_ozet` + mobil bildirim
4. IBAN kopyala → pano doğru format
5. Kayıt CRUD → mobil geçmiş senkron

---

## 6. Uygulama fazları

### Faz 0 — Hazırlık (1–2 gün)

- [ ] `ModuleTableMap` + üst sekme + sidebar iskelet
- [ ] `FirestoreService` TBL → koleksiyon eşlemesi
- [ ] `IsRecordTableKey("ee_kayit")`
- [ ] Login sync’e El Emeği tabloları
- [ ] Modül accent rengi

### Faz 1 — Tablolar + CRUD (3–5 gün)

- [ ] `TBL_EEKayit` — TabloView tam CRUD
- [ ] `TBL_EEPerson` — TabloView + IBAN düzenleme (yeni profil oluşturma yok)
- [ ] Master tablolar (fiyat/ölçü/cins) — ihtiyaç halinde

### Faz 2 — Kişiler ekranı (2–3 gün)

- [ ] `EEPersonView.xaml` — zengin tablo
- [ ] IBAN kopyala, doğrula, Excel export
- [ ] Kişi → kayıt geçmişi drill-down

### Faz 3 — Dashboard (2–3 gün)

- [ ] `FillElEmegiDashboard()`
- [ ] KPI kartları + ay seçici
- [ ] Top bekleyen kişiler + durum grafiği
- [ ] Son kayıtlar listesi

### Faz 4 — Ödeme ekranı (4–6 gün)

- [ ] `EEOdemeView.xaml` — DataGrid + checkbox + editable tutar
- [ ] Batch Firestore yazımı + `ee_bildirim`
- [ ] Toplu ödeme + onay diyalogları
- [ ] `ee_odeme_ozet` upsert (`hesaplananTutar` alanı ekleme — schema)

### Faz 5 — Cila (2–3 gün)

- [ ] Tray bildirimleri
- [ ] PDF export (QuestPDF)
- [ ] Rol bazlı yetki
- [ ] Kullanıcı dokümantasyonu güncelleme

**Toplam tahmin:** ~14–20 iş günü (tek geliştirici, mevcut Desktop pattern’e hakim)

---

## 7. Dosya değişiklik listesi (özet)

| Dosya | Değişiklik |
|-------|------------|
| `Views/MainWindow.xaml` | El Emeği sekmesi, sidebar Ödemeler/Kişiler |
| `Views/DashboardView.xaml` | ElEmegi dashboard bölümü |
| `Views/EEOdemeView.xaml` | **Yeni** — ödeme ekranı |
| `Views/EEPersonView.xaml` | **Yeni** — kişi/IBAN (opsiyonel TabloView yeterli Faz 1) |
| `ViewModels/MainViewModel.cs` | Module map, dashboard fill, ödeme logic |
| `Services/FirestoreService.cs` | TBL eşlemeleri |
| `Services/TableCacheStore.cs` | `ElEmegi` alt klasör |
| `Services/ConnectionSettingsStore.cs` | EE Sheets URL (opsiyonel) |
| `Models/ElEmegi/*.cs` | **Yeni** — `EEOdemeRow`, `EEPersonRow`, `EEKayitRow` |
| `Themes/` | Modül accent (teal) |
| `firestore.rules` | Desktop admin write (gerekirse) |
| `ElEmegi360Mobil/docs/` | Ödeme alanları senkron |

---

## 8. Kararlar (2026-05-19 — netleştirildi)

### 8.1 Ödeme akışı (Soru 1)

**Karar:** Ayrı bir “ödeme öncesi onay” (`ONAYLANDI`) adımı **yok**.

- Desktop **Ödendi** checkbox’ı yalnızca:
  1. Ödeme kaydını **`ee_odeme_ozet`** tablosuna yazar (ödeme tutarı = düzenlenebilir alan)
  2. Mobil bildirim için **`ee_bildirim`** dokümanı oluşturur
  3. İsteğe bağlı: ilgili `ee_kayit` satırlarında `durum = ODENDI` (mobil geçmiş tutarlılığı)
- Mobil uygulama **`ee_bildirim`** dinleyecek şekilde sonra güncellenecek; Desktop önce bu veriyi üretir.

`BEKLEMEDE` / `ONAYLANDI` ayrımı muhasebe için zorunlu değil; ödeme ekranı **bekleyen tutarı kayıtlardan hesaplar**, checkbox = “bankaya yatırıldı + işçiye haber ver”.

### 8.2 Tutar farkı (Soru 2)

**Karar:** Evet — **hesaplanan ≠ ödenen** olabilir.

| Alan | Kaynak |
|------|--------|
| `hesaplananTutar` | Σ `ee_kayit.tutar` (kişi + dönem) — salt okunur |
| `odemeTutar` / `toplamTutar` | TextBox — muhasebe girer; **ee_odeme_ozet**’e yazılır |

Kayıt satır tutarları değiştirilmez; fark yalnızca ödeme özetinde kalır.

Ödeme işaretlenince: **Firestore + Google Sheets** yedek (Desktop’tan da GS yazımı — Soru 4).

### 8.3 Desktop’tan yeni kişi (Soru 3)

**Öneri: Desktop yeni `ee_person` profili oluşturmasın.**

Gerekçe:

- Mobilde kimlik = **Firebase Anonymous `ownerUid`**; `ee_person` doküman id’si bu uid’dir.
- Telefon kaydı olmadan Desktop’ta açılan profilin **mobil karşılığı yok** → bildirim gitmez, işçi kendi kaydını göremez.
- Kişi listesi **`ee_person` + `ee_kayit`** ile doğal oluşur: ilk onboarding → profil; kayıt girince → `ee_kayit`.

**Desktop yetkileri (önerilen):**

| Koleksiyon | Desktop |
|------------|---------|
| `ee_person` | **Okuma + IBAN düzenleme** (mevcut profil) |
| `ee_kayit` | **Tam CRUD** (düzeltme, manuel muhasebe kaydı — mevcut `ownerUid` ile) |
| `ee_odeme_ozet` | Ödeme ekranından yazma |
| Yeni profil oluşturma | **Hayır** (istisna: ileride “davet kodu” akışı ayrı proje) |

Mobilde kullanım değişmez: işçi telefonda adını bir kez girer; Desktop yalnızca IBAN ve kayıtları yönetir.

**İstisna senaryo:** Ad soyad yazım hatası — Desktop **IBAN ekranından** düzeltme önerilmez (profil kilitli); IT Firestore’da manuel düzeltme veya yeni telefon profili.

### 8.4 Google Sheets (Soru 4)

**Karar:** Evet — Desktop ödeme işaretleme ve CRUD sonrası **GS yedek yazımı** (Apps Script `Code.gs`: `saveRecord`, `registerPerson`, `updateIban`, ödeme özeti için yeni action gerekirse eklenir).

Mobil: Firestore birincil + GS yedek. Desktop: aynı desen.

### 8.5 `ee_personel_master` vs `ee_person` (Soru 5)

**Açıklama:** Plan taslağındaki **`ee_personel_master`** eski Excel import fikrinden kalmış ayrı bir koleksiyondu; **mobil ve güncel modelde kullanılmıyor**.

Sizin kullandığınız doğru tablo:

| Koleksiyon | Rol |
|------------|-----|
| **`ee_person`** | Telefon sahibi profili (ad soyad, IBAN, `ownerUid`) — ilk mobil kayıtta oluşur |
| **`ee_kayit`** | İşçilik kayıtları |
| **`ee_odeme_ozet`** | Dönem / kişi ödeme özeti (Desktop ödeme checkbox) |
| **`ee_bildirim`** | Mobilde “ücret yatırıldı” bildirimi |

GS sayfası **EE_PERSON** = `ee_person` yedeği. Ayrı `ee_personel_master` Desktop planından **çıkarıldı**.

---

## 9. Sonraki adım

1. Bu plandaki kararlar onaylandı → **Faz 0** (modül iskeleti + `TBL_EEKayit` okuma)
2. Ödeme ekranı mockup’ını onayla → Faz 4
3. Mobil: `ee_bildirim` + `ee_odeme_ozet` dinleme/gösterme (Desktop sonrası)

---

*Plan: Desktop entegrasyon — El Emeği 360 · Fabrika 360 Suite*
