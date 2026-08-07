package com.focusmode.app

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

data class FocusSessionSnapshot(
    val active: Boolean = false,
    val strictMode: Boolean = false,
    val untilStopped: Boolean = false,
    val durationMinutes: Int = 0,
    val elapsedSeconds: Int = 0,
    val message: String = "Ready when you are.",
    val startedAtMillis: Long = 0L,
)

class FocusConfigStore(private val context: Context) {
    private val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun saveBlockingConfiguration(json: String) {
        val root = JSONObject(json)
        prefs.edit()
            .putStringSet(BLOCKED_PACKAGES_KEY, extractPackages(root, "blockedApps"))
            .putStringSet(ALLOWED_PACKAGES_KEY, extractPackages(root, "allowedApps"))
            .putString(SCHEDULE_WINDOWS_JSON_KEY, root.optJSONArray("scheduledWindows")?.toString() ?: "[]")
            .putBoolean(DEFAULT_STRICT_KEY, root.optBoolean("defaultStrictMode", false))
            .apply()
    }

    fun saveSessionState(json: String) {
        val root = JSONObject(json)
        prefs.edit()
            .putBoolean(SESSION_ACTIVE_KEY, root.optBoolean("active", false))
            .putBoolean(SESSION_STRICT_KEY, root.optBoolean("strictMode", false))
            .putBoolean(SESSION_UNTIL_STOPPED_KEY, root.optBoolean("untilStopped", false))
            .putInt(SESSION_DURATION_KEY, root.optInt("durationMinutes", 0))
            .putInt(SESSION_ELAPSED_KEY, root.optInt("elapsedSeconds", 0))
            .putString(SESSION_MESSAGE_KEY, root.optString("message", "Ready when you are."))
            .putLong(SESSION_STARTED_KEY, root.optLong("startedAtMillis", 0L))
            .apply()
    }

    fun clearSessionState() {
        prefs.edit()
            .putBoolean(SESSION_ACTIVE_KEY, false)
            .remove(SESSION_STRICT_KEY)
            .remove(SESSION_UNTIL_STOPPED_KEY)
            .remove(SESSION_DURATION_KEY)
            .remove(SESSION_ELAPSED_KEY)
            .remove(SESSION_MESSAGE_KEY)
            .remove(SESSION_STARTED_KEY)
            .apply()
    }

    fun setScheduleState(active: Boolean, strictMode: Boolean, title: String) {
        prefs.edit()
            .putBoolean(SCHEDULE_ACTIVE_KEY, active)
            .putBoolean(SCHEDULE_STRICT_KEY, strictMode)
            .putString(SCHEDULE_TITLE_KEY, title)
            .apply()
    }

    fun getScheduledWindows(): List<ScheduledWindowRecord> {
        val raw = prefs.getString(SCHEDULE_WINDOWS_JSON_KEY, "[]") ?: "[]"
        val result = mutableListOf<ScheduledWindowRecord>()
        val array = JSONArray(raw)
        for (index in 0 until array.length()) {
            val window = array.optJSONObject(index) ?: continue
            result.add(
                ScheduledWindowRecord(
                    id = window.optString("id", ""),
                    title = window.optString("title", "Scheduled block"),
                    startMinutes = window.optInt("startMinutes", 0),
                    endMinutes = window.optInt("endMinutes", 0),
                    weekdays = extractWeekdays(window.optJSONArray("weekdays")),
                    enabled = window.optBoolean("enabled", true),
                    strictMode = window.optBoolean("strictMode", false),
                ),
            )
        }
        return result
    }

    fun isSessionActive(): Boolean = prefs.getBoolean(SESSION_ACTIVE_KEY, false)
    fun isScheduleActive(): Boolean = prefs.getBoolean(SCHEDULE_ACTIVE_KEY, false)
    fun isStrictModeActive(): Boolean {
        return prefs.getBoolean(SESSION_STRICT_KEY, prefs.getBoolean(SCHEDULE_STRICT_KEY, prefs.getBoolean(DEFAULT_STRICT_KEY, false)))
    }
    fun isUntilStopped(): Boolean = prefs.getBoolean(SESSION_UNTIL_STOPPED_KEY, false)
    fun getSessionDurationMinutes(): Int = prefs.getInt(SESSION_DURATION_KEY, 0)
    fun getSessionElapsedSeconds(): Int = prefs.getInt(SESSION_ELAPSED_KEY, 0)
    fun getSessionMessage(): String = prefs.getString(SESSION_MESSAGE_KEY, "Ready when you are.") ?: "Ready when you are."
    fun getSessionStartedMillis(): Long = prefs.getLong(SESSION_STARTED_KEY, 0L)
    fun getScheduleTitle(): String = prefs.getString(SCHEDULE_TITLE_KEY, "Scheduled block") ?: "Scheduled block"
    fun getBlockingMessage(): String {
        return if (isSessionActive()) {
            getSessionMessage()
        } else if (isScheduleActive()) {
            "Your scheduled block is active. Take a breath and stay with your plan."
        } else {
            "Ready when you are."
        }
    }

    fun shouldBlock(packageName: String): Boolean {
        if (!isSessionActive() && !isScheduleActive()) return false
        if (isAllowed(packageName)) return false
        return isBlocked(packageName)
    }

    private fun isBlocked(packageName: String): Boolean {
        return prefs.getStringSet(BLOCKED_PACKAGES_KEY, emptySet())?.any { packageName.startsWith(it) || packageName == it } == true
    }

    private fun isAllowed(packageName: String): Boolean {
        return prefs.getStringSet(ALLOWED_PACKAGES_KEY, emptySet())?.any { packageName.startsWith(it) || packageName == it } == true
    }

    private fun extractPackages(root: JSONObject, key: String): Set<String> {
        val result = linkedSetOf<String>()
        val apps = root.optJSONArray(key) ?: JSONArray()
        for (index in 0 until apps.length()) {
            val app = apps.optJSONObject(index) ?: continue
            val packageName = app.optString("packageName", "")
            if (packageName.isNotBlank()) {
                result.add(packageName)
            }
        }
        return result
    }

    private fun extractWeekdays(array: JSONArray?): List<Int> {
        val result = mutableListOf<Int>()
        if (array == null) return result
        for (index in 0 until array.length()) {
            val value = array.optInt(index, 0)
            if (value in 1..7) {
                result.add(value)
            }
        }
        return result
    }

    companion object {
        private const val PREFS_NAME = "focus_mode_native"
        private const val BLOCKED_PACKAGES_KEY = "blocked_packages"
        private const val ALLOWED_PACKAGES_KEY = "allowed_packages"
        private const val SCHEDULE_WINDOWS_JSON_KEY = "scheduled_windows_json"
        private const val SCHEDULE_ACTIVE_KEY = "schedule_active"
        private const val SCHEDULE_STRICT_KEY = "schedule_strict"
        private const val SCHEDULE_TITLE_KEY = "schedule_title"
        private const val DEFAULT_STRICT_KEY = "default_strict_mode"
        private const val SESSION_ACTIVE_KEY = "session_active"
        private const val SESSION_STRICT_KEY = "session_strict"
        private const val SESSION_UNTIL_STOPPED_KEY = "session_until_stopped"
        private const val SESSION_DURATION_KEY = "session_duration_minutes"
        private const val SESSION_ELAPSED_KEY = "session_elapsed_seconds"
        private const val SESSION_MESSAGE_KEY = "session_message"
        private const val SESSION_STARTED_KEY = "session_started_millis"
    }
}
