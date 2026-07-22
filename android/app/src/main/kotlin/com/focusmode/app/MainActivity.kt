package com.focusmode.app

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "focus_mode/blocking"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> result.success(null)
                "getInstalledApps" -> result.success(FocusBlockerNative.getInstalledApps(this))
                "configureBlocking" -> {
                    val configJson = call.arguments as? String ?: "{}"
                    FocusConfigStore(this).saveBlockingConfiguration(configJson)
                    result.success(null)
                }
                "updateSessionState" -> {
                    val sessionJson = call.arguments as? String ?: "{}"
                    FocusConfigStore(this).saveSessionState(sessionJson)
                    result.success(null)
                }
                "clearSessionState" -> {
                    FocusConfigStore(this).clearSessionState()
                    result.success(null)
                }
                "hasUsageAccess" -> result.success(FocusBlockerNative.hasUsageAccess(this))
                "hasOverlayPermission" -> result.success(Settings.canDrawOverlays(this))
                "isAccessibilityEnabled" -> result.success(FocusBlockerNative.isAccessibilityEnabled(this))
                "openUsageAccessSettings" -> {
                    startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                    result.success(null)
                }
                "openAccessibilitySettings" -> {
                    startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                    result.success(null)
                }
                "openOverlaySettings" -> {
                    val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName"))
                    startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                    result.success(null)
                }
                "openBatteryOptimizationSettings" -> {
                    FocusBlockerNative.openBatteryOptimizationSettings(this)
                    result.success(null)
                }
                "requestNotificationPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        ActivityCompat.requestPermissions(this, arrayOf(android.Manifest.permission.POST_NOTIFICATIONS), 1001)
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
