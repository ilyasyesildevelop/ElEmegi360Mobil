# Google Sheets — yalnızca kayıt sekmeleri

Master tablolar **Firestore** (`ee_*_master`). GS yedek + muhasebe listesi.

## EE_PERSONEL (kişi + IBAN listesi)

Muhasebeci için: kim, hangi IBAN.

```
owner_uid | worker_key | ad_soyad | iban | locked | platform | app_version | created_at | iban_updated_at
```

Firestore `ee_cihaz` ile aynı mantık; GS’te okunabilir liste.

## EE_KAYIT

```
kayit_id | owner_uid | worker_key | ad_soyad | tarih | date_key | donem_key | urun_cinsi | islem_turu | olcu_label | en | boy | adet | iscilik_turu | birim_fiyat | toplam_metre | tutar | durum | odeme_tarihi | created_at | updated_at | synced_to_sheets
```

## EE_ODEME_OZET

```
donem_key | owner_uid | toplam_tutar | kayit_sayisi | durum | odeme_tarihi | updated_at
```

## Apps Script test

Web App URL + `?action=ping` → `{"status":"success",...}`

Diğer action örnekleri: `registerPerson`, `updateIban`, `saveRecord`, `listPersons`
