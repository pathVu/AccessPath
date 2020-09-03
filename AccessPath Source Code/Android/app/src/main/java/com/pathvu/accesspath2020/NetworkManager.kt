package com.pathvu.accesspath2020

import android.content.Context
import android.content.SharedPreferences
import android.provider.Settings.System.getString
import android.util.Log
import android.view.View
import com.android.volley.DefaultRetryPolicy
import com.android.volley.RequestQueue
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import com.pathvu.accesspath2020.Util.AppConstants
import com.pathvu.accesspath2020.listener.CustomListener
import kotlinx.android.synthetic.main.activity_main_favorites_list.*
import java.util.*

/**
 * This class contains all the PHP calls used in the app.
 */
class NetworkManager(context: Context) {
    companion object {
        private val TAG = "NetworkManager"
        private var instance: NetworkManager? = null
        private val SOCKET_TIMEOUT = 60000

        @Synchronized
        fun getInstance(context: Context): NetworkManager? {
            if (null == instance) instance = NetworkManager(context)
            return instance
        }

        //So that context doesn't have to be passed every time
        @Synchronized
        fun getInstance(): NetworkManager? {
            checkNotNull(instance) {
                NetworkManager::class.java.simpleName + " is not initialized, call getInstance(...) first"
            }
            return instance
        }
    }

    //for Volley API
    private var requestQueue: RequestQueue = Volley.newRequestQueue(context.applicationContext)


    /**
     * Send an adding a new recent request to the server
     */
    fun newRecent(acctid: String, readdress: String, rlat: String, rlon: String, listener: CustomListener<String?>) {
        val postRequest: StringRequest = object :
            StringRequest(
                Method.POST, AppConstants.NEW_RECENT_URL,
                Response.Listener { response ->
                    Log.d("$TAG: ", "POST Response: $response")
                    if (response != null) listener.getResult(response)
                },
                Response.ErrorListener { error ->
                    if (null != error.networkResponse) {
                        listener.getResult(error.toString())
                    }
                }
            ) {
            override fun getParams(): Map<String, String> {
                val params: MutableMap<String, String> =
                    HashMap()
                params["uacctid"] = acctid
                params["raddress"] = readdress
                params["rlat"] = rlat
                params["rlon"] = rlon
                params["apitoken"] = R.string.pathvu_api_key.toString()
                return params
            }
        }
        requestQueue.add(postRequest)
    }


    /**
     * Get user's favorite list from server
     */
    fun getFavorite(prefs: SharedPreferences, listener: CustomListener<String?>) {
        Log.d(TAG, "initPlaceNames: started")
        val uacctidInt = prefs.getInt("uacctid", 0)

        val getFavoritesUrl = "https://pathvudata.com/api1/api/users/favorites?uacctid=$uacctidInt/*removed for security purposes*/"
        val stringRequest = object : StringRequest(
            Method.GET, getFavoritesUrl,
            Response.Listener<String> { response ->
                if (response != null) listener.getResult(response)
            },
            Response.ErrorListener { error ->
                if (null != error.networkResponse) {
                    listener.getResult(error.toString())
                }
            }
        ) {
            //
        }
        requestQueue.add(stringRequest)
    }


    /**
     * Initialize and get the nearby places through Google Place API
     */
    fun getNearbyPlaces(apiKey: String, fromLat: String, fromLng: String, radius: String, listener: CustomListener<String?>) {
        val nearbyUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=$apiKey&location=$fromLat,$fromLng&radius=$radius"
        val stringRequest = object : StringRequest(
            Method.GET, nearbyUrl,
            Response.Listener<String> { response ->
                if (response != null) listener.getResult(response)
            },
            Response.ErrorListener { error ->
                if (null != error.networkResponse) {
                    listener.getResult(error.toString())
                }
            }
        ) {
            //
        }
        requestQueue.add(stringRequest)
    }


    /**
     * Send a routing request to the server given source location and destination
     */
    fun getRoute(uacctidInt: String, fromLat: String, fromLon: String, toLat: String, toLon: String , listener: CustomListener<String?>) {
        val routeUrl = "https://pathvudata.com/api1/api/routing/"
        val stringRequest = object : StringRequest(
            Method.POST, routeUrl,
            Response.Listener<String> { response ->
                if (response != null) listener.getResult(response)
            },
            Response.ErrorListener { error ->
                if (null != error.networkResponse) {
                    listener.getResult(error.toString())
                }
            })
        {
            override fun getParams(): MutableMap<String, String> {
                val routeParams = HashMap<String, String>()
                routeParams["fromlat"] = fromLat
                routeParams["fromlon"] = fromLon
                routeParams["tolat"] = toLat
                routeParams["tolon"] = toLon
                routeParams["uacctid"] = uacctidInt
                routeParams["apitoken"] = R.string.pathvu_api_key.toString()
                return routeParams
            }
        }
        stringRequest.retryPolicy = DefaultRetryPolicy(50000, DefaultRetryPolicy.DEFAULT_MAX_RETRIES, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT)
        requestQueue.add(stringRequest)
    }

}