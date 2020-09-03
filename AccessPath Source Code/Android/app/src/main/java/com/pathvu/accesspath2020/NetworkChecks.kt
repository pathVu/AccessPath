package com.pathvu.accesspath2020

import android.content.Context
import android.net.ConnectivityManager
import android.os.Handler
import android.os.StrictMode
import com.pathvu.accesspath2020.listener.NavigationListener
import java.io.IOException
import java.net.HttpURLConnection
import java.net.MalformedURLException
import java.net.URL


class NetworkChecks(context: Context) {
    //Class Instance Variables
    private val context: Context = context
    private val handler: Handler = Handler()

    /**
     * Checks for a WiFi or mobile connection
     * @return A boolean based on if a WiFi or mobile connection is found
     */
    fun checkForInternet(): Boolean {
        var haveConnectedWifi = false
        var haveConnectedMobile = false
        val cm =
            context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val netInfo = cm.allNetworkInfo
        for (ni in netInfo) {
            if (ni.typeName
                    .equals("WIFI", ignoreCase = true)
            ) if (ni.isConnected) haveConnectedWifi = true
            if (ni.typeName
                    .equals("MOBILE", ignoreCase = true)
            ) if (ni.isConnected) haveConnectedMobile = true
        }
        return haveConnectedWifi || haveConnectedMobile
    }

    /**
     * Checks if a server is online
     * Returns a boolean in the onCompleteListener based on if the server is reachable or not
     * @param onCompleteListener Returns a value when the asynchronous task finishes
     * @throws MalformedURLException If the server URL is not a valid URL or has no legal protocol
     */
    fun checkServerStatus(onCompleteListener: NavigationListener<Boolean?>) {
        val policy =
            StrictMode.ThreadPolicy.Builder().permitAll().build()
        StrictMode.setThreadPolicy(policy)
        handler.post {
            val connMan =
                context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            val netInfo = connMan.activeNetworkInfo
            if (netInfo != null && netInfo.isConnected) {
                try {
                    val urlServer =
                        URL("https://services7.arcgis.com/lCps1TIE7mFpTJoN/arcgis/rest/services")
                    val urlConn =
                        urlServer.openConnection() as HttpURLConnection
                    urlConn.connectTimeout = 3000
                    urlConn.connect()
                    if (urlConn.responseCode == 200) {
                        onCompleteListener.on(true)
                    } else {
                        onCompleteListener.on(false)
                    }
                } catch (e1: MalformedURLException) {
                    onCompleteListener.on(false)
                } catch (e: IOException) {
                    onCompleteListener.on(false)
                }
            }
        }
    }

    init {
        //Class Instance Variables
    }
}
