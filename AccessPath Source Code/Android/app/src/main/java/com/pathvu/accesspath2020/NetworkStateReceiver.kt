package com.pathvu.accesspath2020

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.util.Log


/**
 * This class is a receiver which detects updates in WiFi or mobile connectivity.
 */
open class NetworkStateReceiver : BroadcastReceiver() {
    /*
     * @see android.content.BroadcastReceiver#onReceive(android.content.Context,
     * android.content.Intent)
     */
    override fun onReceive(context: Context, intent: Intent) {
        val connectivityManager =
            context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val networkType = intent.extras?.getInt(ConnectivityManager.EXTRA_NETWORK_TYPE)
        val isWiFi = networkType == ConnectivityManager.TYPE_WIFI
        val isMobile = networkType == ConnectivityManager.TYPE_MOBILE
        val networkInfo = networkType?.let { connectivityManager.getNetworkInfo(it) }
        val isConnected = networkInfo?.isConnected
        if (isWiFi) {
            if (isConnected!!) {
                Log.i("APP_TAG", "Wi-Fi - CONNECTED")
            } else {
                Log.i("APP_TAG", "Wi-Fi - DISCONNECTED")
            }
        } else if (isMobile) {
            if (isConnected!!) {
                Log.i("APP_TAG", "Mobile - CONNECTED")
            } else {
                Log.i("APP_TAG", "Mobile - DISCONNECTED")
            }
        } else {
            if (isConnected!!) {
                Log.i("APP_TAG", networkInfo.typeName + " - CONNECTED")
            } else {
                Log.i("APP_TAG", networkInfo.typeName + " - DISCONNECTED")
            }
        }
    }
}