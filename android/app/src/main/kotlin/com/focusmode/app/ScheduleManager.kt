package com.focusmode.app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar

object ScheduleManager {
    private const val ALARM_REQUEST_CODE = 42001
    private const val ACTION_SCHEDULE_ALARM = "com.focusmode.app.ACTION_SCHEDULE_ALARM"

    fun refresh(context: Context) {
        val store = FocusConfigStore(context)
        val windows = store.getScheduledWindows()
        val now = Calendar.getInstance()
        val activeWindow = windows.firstOrNull { it.enabled && isWindowActive(it, now) }
        store.setScheduleState(activeWindow != null, activeWindow?.strictMode ?: false, activeWindow?.title ?: "")
        scheduleNextAlarm(context, windows, now)
    }

    fun onAlarm(context: Context) {
        refresh(context)
    }

    private fun scheduleNextAlarm(context: Context, windows: List<ScheduledWindowRecord>, now: Calendar) {
        val nextTransition = windows
            .filter { it.enabled }
            .flatMap { window -> upcomingTransitions(window, now) }
            .filter { it.timeInMillis > now.timeInMillis }
            .minByOrNull { it.timeInMillis }

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, ScheduleAlarmReceiver::class.java).apply {
            action = ACTION_SCHEDULE_ALARM
        }
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or pendingIntentImmutableFlag()
        val pendingIntent = PendingIntent.getBroadcast(context, ALARM_REQUEST_CODE, intent, flags)
        alarmManager.cancel(pendingIntent)

        if (nextTransition == null) {
            return
        }

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, nextTransition.timeInMillis, pendingIntent)
            } else {
                alarmManager.set(AlarmManager.RTC_WAKEUP, nextTransition.timeInMillis, pendingIntent)
            }
        } catch (_: SecurityException) {
            alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, nextTransition.timeInMillis, pendingIntent)
        }
    }

    private fun upcomingTransitions(window: ScheduledWindowRecord, now: Calendar): List<Calendar> {
        val transitions = mutableListOf<Calendar>()
        for (offset in 0..7) {
            val date = now.clone() as Calendar
            date.add(Calendar.DAY_OF_YEAR, offset)
            val dayOfWeek = javaDayOfWeekToIso(date.get(Calendar.DAY_OF_WEEK))
            if (!window.weekdays.contains(dayOfWeek)) continue

            val start = date.atMinutes(window.startMinutes)
            val end = if (window.endMinutes <= window.startMinutes) {
                (date.clone() as Calendar).apply {
                    add(Calendar.DAY_OF_YEAR, 1)
                    atMinutes(window.endMinutes)
                }
            } else {
                date.clone() as Calendar
            }.apply {
                set(Calendar.HOUR_OF_DAY, window.endMinutes / 60)
                set(Calendar.MINUTE, window.endMinutes % 60)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }

            transitions.add(start)
            transitions.add(end)
        }
        return transitions
    }

    private fun isWindowActive(window: ScheduledWindowRecord, now: Calendar): Boolean {
        val nowMinutes = now.get(Calendar.HOUR_OF_DAY) * 60 + now.get(Calendar.MINUTE)
        val todayIso = javaDayOfWeekToIso(now.get(Calendar.DAY_OF_WEEK))
        val yesterday = (now.clone() as Calendar).apply { add(Calendar.DAY_OF_YEAR, -1) }
        val yesterdayIso = javaDayOfWeekToIso(yesterday.get(Calendar.DAY_OF_WEEK))

        return if (window.endMinutes > window.startMinutes) {
            window.weekdays.contains(todayIso) && nowMinutes in window.startMinutes until window.endMinutes
        } else {
            (window.weekdays.contains(todayIso) && nowMinutes >= window.startMinutes) ||
                (window.weekdays.contains(yesterdayIso) && nowMinutes < window.endMinutes)
        }
    }

    private fun Calendar.atMinutes(totalMinutes: Int): Calendar = apply {
        set(Calendar.HOUR_OF_DAY, totalMinutes / 60)
        set(Calendar.MINUTE, totalMinutes % 60)
        set(Calendar.SECOND, 0)
        set(Calendar.MILLISECOND, 0)
    }

    private fun javaDayOfWeekToIso(dayOfWeek: Int): Int {
        return when (dayOfWeek) {
            Calendar.SUNDAY -> 7
            else -> dayOfWeek - 1
        }
    }

    private fun pendingIntentImmutableFlag(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
    }
}
