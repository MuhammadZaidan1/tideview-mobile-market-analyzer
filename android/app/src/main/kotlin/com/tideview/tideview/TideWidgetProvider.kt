package com.tideview.tideview

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import android.net.Uri

class TideWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            // Tarik 4 Data dari Flutter
            val name = widgetData.getString("widget_name", "TideView") ?: "TideView"
            val symbol = widgetData.getString("widget_symbol", "MARKET") ?: "MARKET"
            val price = widgetData.getString("widget_price", "Syncing...")
            val change = widgetData.getString("widget_change", "-") ?: "-"

            // Masukin ke UI
            views.setTextViewText(R.id.tv_widget_name, name)
            views.setTextViewText(R.id.tv_widget_symbol, symbol)
            views.setTextViewText(R.id.tv_widget_price, price)
            views.setTextViewText(R.id.tv_widget_change, change)

            // Logic Warna
            if (change.startsWith("-")) {
                views.setTextColor(R.id.tv_widget_change, Color.parseColor("#FF5252"))
            } else if (change.startsWith("+")) {
                views.setTextColor(R.id.tv_widget_change, Color.parseColor("#4CAF50"))
            } else {
                views.setTextColor(R.id.tv_widget_change, Color.parseColor("#8D8D8D"))
            }

            // Klik loncat ke detail
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("tideview://asset?symbol=$symbol")
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}