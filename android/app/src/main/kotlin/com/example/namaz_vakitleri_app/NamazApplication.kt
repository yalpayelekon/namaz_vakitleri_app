package com.example.namaz_vakitleri_app

import android.app.Application
import android.content.SharedPreferences

/**
 * Refreshes home-screen widgets when Flutter SharedPreferences write prayer data.
 * Needed because headless WorkManager isolates cannot reliably reach MainActivity's MethodChannel.
 */
class NamazApplication : Application() {
    private val prefsListener =
        SharedPreferences.OnSharedPreferenceChangeListener { _, key ->
            if (key == "flutter.city") {
                WidgetUpdateHelper.updateAllWidgets(this)
            }
        }

    override fun onCreate() {
        super.onCreate()
        getSharedPreferences(WidgetUpdateHelper.PREFS_NAME, MODE_PRIVATE)
            .registerOnSharedPreferenceChangeListener(prefsListener)
    }
}
