# El Emeği 360 — Premium UI planı (v1)

**Tarih:** 2026-05-19  
**Bağlam:** Evde iş yapan kadınlara dağıtılacak mobil uygulama; Fabrika 360 ailesi dilinde ama **daha sıcak, renkli, el işi ve premium** his.

**Referans ekranlar:** Kullanıcı ekran görüntüleri (İlk kurulum, Kayıt, Ücret) — 2026-05-19.

---

## 1) Mevcut durum (gözlem)

| Alan | Şu an | Sorun |
|------|--------|--------|
| Genel ton | Koyu lacivert + teal, düz kartlar | Şirket içi / resmi; “el emeği” sıcaklığı zayıf |
| Header | Düz gradient, statik metin | Canlılık yok; ikon yok |
| Kartlar | Beyaz/koyu yüzey, ince gölge | “Kutu” hissi; premium derinlik yok |
| Vurgu renkleri | Teal ağırlıklı | Kilim kırmızısı / amber / krem az kullanılıyor |
| Animasyon | Yok | Premium beklentisi karşılanmıyor |
| Form | Standart Material alanları | Ham M3 hissi |

**Korunacak:** Okunaklılık, büyük dokunma alanları, sade bilgi hiyerarşisi, bottom nav.

---

## 2) Hedef his

- **Premium:** Yumuşak ışık, hafif derinlik, kaliteli mikro detay (kenar ışıltısı, ince parıltı).
- **Sıcak / insani:** İplik kremi, kilim kırmızısı dokunuşları; soğuk kurumsal panel değil.
- **El işi:** Küçük motif (halı köşesi, iplik) — **dekoratif**, içeriği boğmadan.
- **Güven:** Net tutarlar, kilitli isim, sade durum etiketleri.

---

## 3) Renk ve tipografi (mevcut palet üzerinde)

| Token | Kullanım önerisi |
|-------|------------------|
| `#1A1F36` → `#2A3050` | Header gradient (sabit) |
| `#00C2A8` / `#33D4BE` | CTA, aktif sekme, birim fiyat |
| `#D7263D` | İnce kenar ışıltısı alternatif ton, önemli uyarı |
| `#F5A623` | Bekleyen ödeme, ikincil vurgu |
| `#F7F2E8` | Alt başlık, yumuşak kart içi bant |
| `#8A9A5B` | Meta chip, dekoratif ikon |

**Tipografi:** Başlıklarda biraz daha yuvarlak ağırlık (w600–w700); gövde okunaklı; tutarlar **tabular figures** (monospace veya `fontFeatures`).

---

## 4) Önerilen görsel efektler

### 4.1 Header — başlık parıltısı

- **Ne:** “El Emeği 360” metninde 5–8 saniyede bir geçen **shimmer** (beyaz/teal düşük opaklık gradient bandı).
- **Nasıl:** `ShaderMask` + `AnimationController` (tek seferlik header widget’ta).
- **Dikkat:** Epilepsi / dikkat — çok hızlı veya parlak olmasın; süre yavaş.

### 4.2 Kartlar — kenar ışıltısı (glow border)

- **Ne:** Form kartları ve “Ödenecek Toplam” kartında **dönen veya nefes alan** ince gradient kenarlık (teal → amber → kilim kırmızısı, düşük opaklık).
- **Nasıl:** `CustomPainter` veya `DecoratedBox` + `GradientRotation` / `AnimatedContainer` border.
- **Performans:** Sadece görünür kartlarda; liste öğelerinde statik hafif border (animasyonsuz).

### 4.3 Kaydet butonu

- Mevcut teal gradient korunur; **hafif pulse** gölge (scale 1.0 → 1.02, 2s) kayıt ekranında.

### 4.4 Geçişler

- Sekme değişiminde içerik **Fade + 80ms slide** (çok abartısız).
- Liste öğeleri: `AnimatedList` veya staggered fade-in (ilk yüklemede).

### 4.5 Dekoratif motif

- Kayıt ekranı köşesinde mevcut `ElEmegiMotif` — opaklık %8–12; kırmızı/krem dokunuş.

---

## 5) Ekran bazlı öneriler

### İlk kurulum

- Önizleme kutusu: glow border + krem zemin bandı.
- Klavye: `tr_TR` locale; Türkçe büyük harf önizlemesi (`İ`, `Ş`, `Ğ`).
- İpucu: “Ad ve soyadınızı Türkçe karakterlerle yazın” (küçük, olive renk).

### Kayıt

- Alan sırası: **Ürün cinsi** (Zara, Nostalji…) → **İşlem türü** (Saçak, Etiket…) → **Ölçü** → Adet → tutarlar.
- Kullanıcı kartı: sadece **ad soyad** (tek satır); teknik anahtar gizli.
- Birim/toplam: teal + hafif glow.

### Geçmiş

- Kartlarda sol **durum şeridi** (renkli 4px).
- Tarih küçük, ürün + işlem belirgin.

### Ücret

- Özet kart: gradient + glow + büyük tutar.
- Alt satırda **yalnızca ad soyad** (çift isim yok).
- Dönem kartları: ödendi/beklemede şerit rengi.

### Ayarlar

- IBAN alanı: maskeli gösterim, kaydet.
- “Birim ücret listesi” ve “Hakkında” girişleri suite ile uyumlu satırlar.

### Birim ücret listesi (yeni)

- Tablo: İşlem | Ölçü | Birim ücret | Not.
- Salt okunur; üstte bilgi bandı “Fiyatlar yönetim tarafından güncellenir”.

---

## 6) Uygulama fazları

| Faz | İçerik | Öncelik |
|-----|--------|---------|
| **A** | Türkçe locale, çift isim düzeltme, header ikon, sürüm/Hakkında | ✅ Hemen |
| **B** | Ürün/işlem/ölçü alan ayrımı, birim fiyat ekranı, IBAN (yerel) | ✅ Hemen |
| **C** | Glow kart + header shimmer (temel animasyon) | Kısa vade |
| **D** | Sekme geçişi, liste animasyonu | Orta |
| **E** | Firestore master + GS yedek; muhasebe desktop | Sonra |

---

## 7) Kaçınılacaklar

- Aşırı folklorik desen, fotoğraf halı dokusu.
- Sürekli hızlı yanıp sönme.
- Çok fazla renk aynı anda (maks. 2 sıcak vurgu + teal).
- Endüstriyel ikonlar (çark, fabrika).

---

## 8) Başarı kriterleri (kullanıcı testi)

1. İlk bakışta “sıcak ve özenli” hissi (5 üzerinden ≥4).
2. Yaşlı kullanıcıda okunaklılık (büyük tutar, yüksek kontrast).
3. Animasyonlar “fark edilir ama rahatsız etmez”.
4. Suite ile aynı aileden olduğu anlaşılır (header, nav).

---

*Sonraki adım: Faz C kodlaması (`premium_glow_card.dart`, `shimmer_header.dart`) — Faz A/B ile birlikte iteratif.*
