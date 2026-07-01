package com.example.namaz_vakitleri_app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.SharedPreferences

object WidgetUpdateHelper {
    const val PREFS_NAME = "FlutterSharedPreferences"
    private const val KEY_PREFIX = "flutter."

    fun getPrefString(prefs: SharedPreferences, key: String, default: String): String {
        return prefs.getString("$KEY_PREFIX$key", default) ?: default
    }

    fun updateAllWidgets(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        val widgetIds = manager.getAppWidgetIds(
            ComponentName(context, HomeWidgetProvider::class.java)
        )
        for (id in widgetIds) {
            updateAppWidget(context, manager, id)
        }
    }
}
