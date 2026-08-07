package com.focusmode.app

import android.app.Activity
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.updatePadding
import java.util.concurrent.TimeUnit

class BlockingOverlayActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        makeFullScreen()

        val store = FocusConfigStore(this)
        val packageName = intent.getStringExtra(EXTRA_PACKAGE_NAME).orEmpty()
        val label = intent.getStringExtra(EXTRA_APP_LABEL).orEmpty().ifBlank { packageName }
        val sessionMessage = intent.getStringExtra(EXTRA_CONTEXT_MESSAGE).orEmpty().ifBlank { store.getSessionMessage() }
        val elapsed = store.getSessionElapsedSeconds()
        val strictMode = store.isStrictModeActive()

        val root = ScrollView(this).apply {
            isFillViewport = true
        }

        val container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(48, 64, 48, 48)
            background = null
        }

        val title = TextView(this).apply {
            text = "This app is paused for now"
            textSize = 28f
            setTextColor(0xFF0F172A.toInt())
        }

        val message = TextView(this).apply {
            text = "$sessionMessage\n\n$label is blocked during your focus session."
            textSize = 16f
            setTextColor(0xFF334155.toInt())
        }

        val stats = TextView(this).apply {
            text = "Focused for ${formatDuration(elapsed)}"
            textSize = 16f
            setTextColor(0xFF0F766E.toInt())
        }

        container.addView(title)
        container.addView(space(24))
        container.addView(message)
        container.addView(space(16))
        container.addView(stats)
        container.addView(space(24))

        if (strictMode) {
            val instruction = TextView(this).apply {
                text = "Type this sentence to continue"
                textSize = 14f
                setTextColor(0xFF475569.toInt())
            }
            val requiredSentence = TextView(this).apply {
                text = "I choose focus now"
                textSize = 18f
                setTextColor(0xFF0F172A.toInt())
            }
            val input = EditText(this).apply {
                hint = "Type here"
            }
            val action = Button(this).apply {
                text = "I understand"
                isEnabled = false
            }
            action.setOnClickListener {
                finish()
            }
            input.addTextChangedListener(SimpleTextWatcher {
                action.isEnabled = input.text?.toString()?.trim() == "I choose focus now"
            })

            container.addView(instruction)
            container.addView(space(8))
            container.addView(requiredSentence)
            container.addView(space(12))
            container.addView(input)
            container.addView(space(12))
            container.addView(action)
        } else {
            val action = Button(this).apply {
                text = "Return to home screen"
                setOnClickListener { finish() }
            }
            container.addView(action)
        }

        val close = Button(this).apply {
            text = "Close blocker"
            setOnClickListener { finishAndRemoveTask() }
        }
        container.addView(space(16))
        container.addView(close)

        root.addView(container)
        setContentView(root)

        ViewCompat.setOnApplyWindowInsetsListener(root) { view, insets ->
            val bars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            view.updatePadding(left = bars.left, top = bars.top, right = bars.right, bottom = bars.bottom)
            insets
        }
    }

    private fun makeFullScreen() {
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        window.addFlags(WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD)
        window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED)
        window.addFlags(WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }
    }

    private fun space(height: Int): View = View(this).apply {
        layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, height)
    }

    private fun formatDuration(totalSeconds: Int): String {
        val minutes = TimeUnit.SECONDS.toMinutes(totalSeconds.toLong())
        val seconds = totalSeconds - TimeUnit.MINUTES.toSeconds(minutes)
        return "${minutes}m ${seconds}s"
    }

    companion object {
        const val EXTRA_PACKAGE_NAME = "extra_package_name"
        const val EXTRA_APP_LABEL = "extra_app_label"
        const val EXTRA_CONTEXT_MESSAGE = "extra_context_message"
    }
}
