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

    fun isSessionActive(): Boolean = prefs.getBoolean(SESSION_ACTIVE_KEY, false)
    fun isStrictModeActive(): Boolean = prefs.getBoolean(SESSION_STRICT_KEY, prefs.getBoolean(DEFAULT_STRICT_KEY, false))
    fun isUntilStopped(): Boolean = prefs.getBoolean(SESSION_UNTIL_STOPPED_KEY, false)
    fun getSessionDurationMinutes(): Int = prefs.getInt(SESSION_DURATION_KEY, 0)
    fun getSessionElapsedSeconds(): Int = prefs.getInt(SESSION_ELAPSED_KEY, 0)
    fun getSessionMessage(): String = prefs.getString(SESSION_MESSAGE_KEY, "Ready when you are.") ?: "Ready when you are."
    fun getSessionStartedMillis(): Long = prefs.getLong(SESSION_STARTED_KEY, 0L)

    fun shouldBlock(packageName: String): Boolean {
        if (!isSessionActive()) return false
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

    companion object {
        private const val PREFS_NAME = "focus_mode_native"
        private const val BLOCKED_PACKAGES_KEY = "blocked_packages"
        private const val ALLOWED_PACKAGES_KEY = "allowed_packages"
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
