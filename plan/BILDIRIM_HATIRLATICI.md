# Günlük hatırlatıcı bildirimi (arşiv)

Ayarlar ekranından bildirim anahtarı kaldırıldı; kod saklanıyor. Tekrar açmak için:

1. `PreferencesManager.getNotificationsEnabled()` varsayılanını `true` yapın veya ayarlara switch geri ekleyin.
2. `MainViewModel.init` içinde `ReminderScheduler.schedule` çağrısı zaten pref’e bağlı.
3. Android 13+ için `MainActivity` içinde `POST_NOTIFICATIONS` izin diyaloğunu geri bağlayın.

## Bileşenler

| Dosya | Görev |
|--------|--------|
| `notify/ReminderScheduler.kt` | Kanal, günlük `AlarmManager.setInexactRepeating` |
| `notify/ReminderReceiver.kt` | `BroadcastReceiver` → bildirim göster |
| `AndroidManifest.xml` | `POST_NOTIFICATIONS`, `ReminderReceiver` kaydı |
| `PreferencesManager.kt` | `notifications_enabled`, `daily_reminder_time` (varsayılan `16:45`) |
| `MainViewModel.kt` | `setNotificationsEnabled`, `setDailyReminderTime`, `init` schedule |

## Tam kaynak — ReminderScheduler.kt

```kotlin
package com.greenlabs.development.vardiya360.notify

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.greenlabs.development.vardiya360.MainActivity
import com.greenlabs.development.vardiya360.R
import java.util.Calendar

object ReminderScheduler {
    private const val ALARM_REQ = 78101
    const val CHANNEL_ID = "daily_reminder"

    fun ensureChannel(ctx: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val mgr = ctx.getSystemService(NotificationManager::class.java) ?: return
        if (mgr.getNotificationChannel(CHANNEL_ID) != null) return
        val ch = NotificationChannel(
            CHANNEL_ID,
            ctx.getString(R.string.settings_daily_reminder),
            NotificationManager.IMPORTANCE_DEFAULT,
        ).apply {
            description = ctx.getString(R.string.notif_permission_body)
        }
        mgr.createNotificationChannel(ch)
    }

    fun schedule(ctx: Context, hhmm: String) {
        ensureChannel(ctx)
        val parts = hhmm.split(":")
        val h = parts.getOrNull(0)?.toIntOrNull()?.coerceIn(0, 23) ?: 16
        val m = parts.getOrNull(1)?.toIntOrNull()?.coerceIn(0, 59) ?: 45
        val next = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, h)
            set(Calendar.MINUTE, m)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            if (timeInMillis <= System.currentTimeMillis()) add(Calendar.DAY_OF_MONTH, 1)
        }
        val pi = pendingIntent(ctx)
        val mgr = ctx.getSystemService(AlarmManager::class.java) ?: return
        mgr.setInexactRepeating(
            AlarmManager.RTC_WAKEUP,
            next.timeInMillis,
            AlarmManager.INTERVAL_DAY,
            pi,
        )
    }

    fun cancel(ctx: Context) {
        val mgr = ctx.getSystemService(AlarmManager::class.java) ?: return
        mgr.cancel(pendingIntent(ctx))
    }

    private fun pendingIntent(ctx: Context): PendingIntent {
        val i = Intent(ctx, ReminderReceiver::class.java).setAction(ACTION_FIRE)
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        return PendingIntent.getBroadcast(ctx, ALARM_REQ, i, flags)
    }

    internal const val ACTION_FIRE = "com.greenlabs.development.vardiya360.REMINDER_FIRE"
}

class ReminderReceiver : BroadcastReceiver() {
    override fun onReceive(ctx: Context, intent: Intent) {
        if (intent.action != ReminderScheduler.ACTION_FIRE) return
        ReminderScheduler.ensureChannel(ctx)
        val tap = PendingIntent.getActivity(
            ctx, 0,
            Intent(ctx, MainActivity::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val notif = NotificationCompat.Builder(ctx, ReminderScheduler.CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(ctx.getString(R.string.app_name))
            .setContentText(ctx.getString(R.string.reminder_default_text))
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)
            .setContentIntent(tap)
            .build()
        ctx.getSystemService(NotificationManager::class.java)?.notify(7001, notif)
    }
}
```

## MainViewModel (bildirim API)

```kotlin
fun setNotificationsEnabled(enabled: Boolean) {
    prefs.setNotificationsEnabled(enabled)
    _notificationsEnabled.value = enabled
    val ctx = getApplication<Application>().applicationContext
    if (enabled) ReminderScheduler.schedule(ctx, _dailyReminderTime.value)
    else ReminderScheduler.cancel(ctx)
}

fun setDailyReminderTime(hhmm: String) {
    prefs.setDailyReminderTime(hhmm)
    _dailyReminderTime.value = hhmm
    if (_notificationsEnabled.value) {
        ReminderScheduler.schedule(getApplication<Application>().applicationContext, hhmm)
    }
}

// init { ... if (_notificationsEnabled.value) ReminderScheduler.schedule(...) }
```

## strings.xml

- `reminder_default_text`: *Vardiya kaydını unutma — bugünün giriş/çıkış kaydı bekliyor.*
- `settings_daily_reminder`: *Günlük Hatırlatıcı*
- `notif_permission_title` / `notif_permission_body` / `notif_permission_allow` / `notif_permission_deny`

## Ayarlara geri ekleme (Compose örneği)

```kotlin
SettingsGroup(title = stringResource(R.string.settings_section_notifications)) {
    FabrikaSettingsCard {
        Row(/* Bildirimler switch */) {
            Switch(
                checked = notificationsEnabled,
                onCheckedChange = { viewModel.setNotificationsEnabled(it) },
            )
        }
        FabrikaSettingsRow(
            icon = Icons.Outlined.Schedule,
            label = stringResource(R.string.settings_daily_reminder),
            value = dailyReminder,
            onClick = { /* TimePickerDialog */ },
        )
    }
}
```

## Not

- Kesin saat için `SCHEDULE_EXACT_ALARM` gerekir; mevcut kod bilinçli olarak `setInexactRepeating` kullanır (Doze uyumlu, saat kayabilir).
