package com.focusmode.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class ScheduleAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != null && intent.action != "com.focusmode.app.ACTION_SCHEDULE_ALARM") return
        ScheduleManager.onAlarm(context)
    }
}
