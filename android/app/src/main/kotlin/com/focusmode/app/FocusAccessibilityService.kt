package com.focusmode.app

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.os.SystemClock
import android.view.accessibility.AccessibilityEvent

class FocusAccessibilityService : AccessibilityService() {
    private var lastLaunchAt = 0L

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        if (event.packageName == null) return

        val packageName = event.packageName.toString()
        if (packageName == packageNameOfApp()) return

        val store = FocusConfigStore(this)
        if (!store.shouldBlock(packageName)) return

        val now = SystemClock.elapsedRealtime()
        if (now - lastLaunchAt < 1200L) return
        lastLaunchAt = now

        val overlayIntent = Intent(this, BlockingOverlayActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra(BlockingOverlayActivity.EXTRA_PACKAGE_NAME, packageName)
            putExtra(BlockingOverlayActivity.EXTRA_APP_LABEL, event.contentDescription?.toString().orEmpty())
            putExtra(BlockingOverlayActivity.EXTRA_CONTEXT_MESSAGE, store.getBlockingMessage())
        }
        startActivity(overlayIntent)
    }

    override fun onInterrupt() = Unit

    private fun packageNameOfApp(): String = packageName
}
