# Firestore — ödeme bildirimi (ee_bildirim)

## Akış

1. Ay sonu muhasebe **Fabrika360 Desktop** üzerinden dönem/kayıtları **ÖDENDİ** işaretler (`ee_kayit.durum = ODENDI`, `odemeTarihi`).
2. Desktop (Admin SDK) her işçi için **yeni** bir bildirim dokümanı oluşturur — eski ödemeler için tekrar oluşturulmaz (`odemeBatchId` ile idempotent).
3. Mobil, `ee_bildirim` koleksiyonunu dinler; `delivered == false` ve kendi `ownerUid` için gelen kayıtta:
   - Yerel bildirim + ses: **"El emeğinizin ücreti hesabınıza yatırıldı"**
   - `delivered: true`, `deliveredAt` yazar.

## Koleksiyon: `ee_bildirim`

| Alan | Tip | Açıklama |
|------|-----|----------|
| bildirimId | string | doc id (örn. `{ownerUid}_{donemKey}_{batch}`) |
| ownerUid | string | işçi |
| type | string | `ODEME_YATIRILDI` |
| donemKey | string | `2026-05` |
| toplamTutar | number | yatırılan tutar |
| message | string | `El emeğinizin ücreti hesabınıza yatırıldı` |
| odemeBatchId | string | masaüstü ödeme işlemi id (tekrar önleme) |
| delivered | bool | mobil gösterdikten sonra true |
| deliveredAt | timestamp? | |
| readAt | timestamp? | |
| createdAt | timestamp | |

## Masaüstü (örnek pseudo)

```javascript
// Admin SDK — güvenlik kuralları geçerli değil
await db.collection('ee_bildirim').doc(`${ownerUid}_${donemKey}_${batchId}`).set({
  ownerUid,
  type: 'ODEME_YATIRILDI',
  donemKey,
  toplamTutar,
  message: 'El emeğinizin ücreti hesabınıza yatırıldı',
  odemeBatchId: batchId,
  delivered: false,
  createdAt: FieldValue.serverTimestamp(),
}, { merge: true });
```

## Deploy (suite kökü)

Kurallar **tek dosyada** birleşik: `Fabrika360Suite/firestore.rules` (Vardiya, İzin, Üretim, **ee_***).  
`ElEmegi360Mobil/firebase/` altından deploy etmeyin.

```powershell
cd D:\Projects\Fabrika360Suite
firebase deploy --only firestore:rules,firestore:indexes --project fabrika360suite-ekohali-cloud
```

Firebase CLI yüklü değilse: `npm install -g firebase-tools` → `firebase login`

## Mobil

`lib/data/remote/payment_notification_service.dart` — dinleyici (bildirim izni sonraki fazda tam ses).
