package com.example.namaz_vakitleri_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

class HomeWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Called when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Called when the last widget is removed
    }
}

internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    val prefs = context.getSharedPreferences(WidgetUpdateHelper.PREFS_NAME, Context.MODE_PRIVATE)
    val views = RemoteViews(context.packageName, R.layout.home_widget_layout)

    val fajr = WidgetUpdateHelper.getPrefString(prefs, "fajr", "--:--")
    val dhuhr = WidgetUpdateHelper.getPrefString(prefs, "dhuhr", "--:--")
    val asr = WidgetUpdateHelper.getPrefString(prefs, "asr", "--:--")
    val maghrib = WidgetUpdateHelper.getPrefString(prefs, "maghrib", "--:--")
    val isha = WidgetUpdateHelper.getPrefString(prefs, "isha", "--:--")
    val city = WidgetUpdateHelper.getPrefString(prefs, "city", "Yükleniyor...")

    views.setTextViewText(R.id.fajr_text, fajr)
    views.setTextViewText(R.id.dhuhr_text, dhuhr)
    views.setTextViewText(R.id.asr_text, asr)
    views.setTextViewText(R.id.maghrib_text, maghrib)
    views.setTextViewText(R.id.isha_text, isha)
    views.setTextViewText(R.id.city_text, city)

    appWidgetManager.updateAppWidget(appWidgetId, views)
}
