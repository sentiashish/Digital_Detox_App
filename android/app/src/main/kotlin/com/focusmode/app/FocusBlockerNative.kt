package com.focusmode.app

import android.app.AppOpsManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import java.util.Locale

object FocusBlockerNative {
    fun getInstalledApps(context: Context): List<Map<String, Any>> {
        val pm = context.packageManager
        val launchIntent = Intent(Intent.ACTION_MAIN, null).addCategory(Intent.CATEGORY_LAUNCHER)
        @Suppress("DEPRECATION")
        val resolved = pm.queryIntentActivities(launchIntent, 0)
        return resolved
            .mapNotNull { info ->
                val packageName = info.activityInfo.packageName
                val label = info.loadLabel(pm)?.toString() ?: packageName
                if (packageName == context.packageName) return@mapNotNull null
                mapOf(
                    "name" to label,
                    "packageName" to packageName,
                    "isEssential" to isEssential(packageName, label),
                    "isSystemApp" to isSystemApp(pm, packageName),
                )
            }
            .distinctBy { it["packageName"] as String }
    }

    fun hasUsageAccess(context: Context): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), context.packageName)
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), context.packageName)
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    fun isAccessibilityEnabled(context: Context): Boolean {
        val enabled = Settings.Secure.getString(context.contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES) ?: return false
        val serviceName = ComponentName(context, FocusAccessibilityService::class.java).flattenToString()
        return enabled.split(':').any { it.equals(serviceName, ignoreCase = true) }
    }

    fun openBatteryOptimizationSettings(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
            data = Uri.parse("package:${context.packageName}")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    fun isEssential(packageName: String, label: String): Boolean {
        val normalized = (packageName + " " + label).lowercase(Locale.US)
        return listOf("phone", "dialer", "whatsapp", "messages", "gmail", "email", "maps", "camera").any { normalized.contains(it) }
    }

    private fun isSystemApp(pm: PackageManager, packageName: String): Boolean {
        return try {
            val info = pm.getApplicationInfo(packageName, 0)
            info.flags and ApplicationInfo.FLAG_SYSTEM != 0
        } catch (_: PackageManager.NameNotFoundException) {
            false
        }
    }
}
