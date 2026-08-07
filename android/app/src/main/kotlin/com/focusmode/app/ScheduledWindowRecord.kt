package com.focusmode.app

data class ScheduledWindowRecord(
    val id: String,
    val title: String,
    val startMinutes: Int,
    val endMinutes: Int,
    val weekdays: List<Int>,
    val enabled: Boolean,
    val strictMode: Boolean,
)
