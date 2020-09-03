package com.pathvu.accesspath2020

import android.Manifest
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.speech.tts.TextToSpeech.OnInitListener
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import com.esri.arcgisruntime.geometry.Point
import com.esri.arcgisruntime.geometry.SpatialReferences
import com.google.gson.Gson
import com.pathvu.accesspath2020.listener.CustomListener
import com.pathvu.accesspath2020.model.FavoritePlace
import java.util.*

/**
 * FavoritePlaceAlert is a class which constantly get the update
 * for uer location to check for the favorite places.
 */

class FavoritePlaceAlert(context: Context) {
    private val mContext: Context
    private var mFavoritePlaces: List<FavoritePlace>? = null
    private val mPrefs: SharedPreferences
    private var mTts: TextToSpeech? = null

    //Initialize the favorite place list after fetching from service and start location update.
    fun initFavoritePlaceList() {
        NetworkManager.getInstance()
            ?.getFavorite(mPrefs, object : CustomListener<String?> {
                override fun getResult(result: String?) {
                    if (result!!.isNotEmpty()) {
                        try {
                            println(result)
                            if (result != null && result.isNotEmpty()) {
                                //Set the favorite place list
                                mFavoritePlaces = listOf(*Gson().fromJson<Array<FavoritePlace>>(result, Array<FavoritePlace>::class.java))
                                for (favoritePlace in mFavoritePlaces!!) {
                                    favoritePlace.isNotified = false
                                }
                                //Start the location updates
                                setLocationUpdate()
                            }
                        } catch (t: Throwable) {
                            t.printStackTrace()
                        }
                    } else {
                        println(result)
                        println("Could not get favorites")
                    }
                }
            })
    }

    //Setup the location update to check the favorite place.
    private fun setLocationUpdate() {
        var locationProvider: String? = null
        //GET LOCATION MANAGER
        val locationManager =
            mContext.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        //CHECK GPS STATE
        val isGPSEnabled =
            locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)
        //CHECK NETWORK STATE
        val isNetworkEnabled =
            locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
        if (isGPSEnabled) {
            locationProvider = LocationManager.GPS_PROVIDER
        } else if (isNetworkEnabled) {
            locationProvider = LocationManager.NETWORK_PROVIDER
        }
        if (ActivityCompat.checkSelfPermission(
                mContext,
                Manifest.permission.ACCESS_FINE_LOCATION
            )
            != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(
                mContext
                , Manifest.permission.ACCESS_COARSE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }
        locationManager.requestLocationUpdates(
            locationProvider,
            0,
            5f,
            object : LocationListener {
                override fun onLocationChanged(location: Location) {
                    //Convert the Location value to Point
                    val lat: Double = ("" + location.latitude).toDouble()
                    val lon: Double =
                        ("" + location.longitude).replace("-".toRegex(), "").toDouble()
                    val userPoint =
                        Point(
                            lon,
                            lat,
                            SpatialReferences.getWgs84()
                        )
                    checkFavoritePlace(userPoint)
                }

                override fun onStatusChanged(
                    provider: String,
                    status: Int,
                    extras: Bundle
                ) {
                }

                override fun onProviderEnabled(provider: String) {}
                override fun onProviderDisabled(provider: String) {}
            })
    }

    /*
    * Create the boundary on user point to check that the user is in the bound of favorite place.
    * */
    private fun checkFavoritePlace(userPoint: Point) {
        if (mFavoritePlaces != null && mFavoritePlaces!!.isNotEmpty()) {
            for (favoritePlace in mFavoritePlaces!!) {
                val lat: Double = favoritePlace.flat.toDouble()
                val lon: Double = favoritePlace.flon.toDouble()

                //Distance threshold when calculating bounds for favorite place
                val distance = 0.00020

                //Create the four corners of the favorite place
                val bound1 =
                    Point(
                        lon - distance,
                        lat - distance,
                        SpatialReferences.getWgs84()
                    )
                val bound2 =
                    Point(
                        lon - distance,
                        lat + distance,
                        SpatialReferences.getWgs84()
                    )
                val bound3 =
                    Point(
                        lon + distance,
                        lat - distance,
                        SpatialReferences.getWgs84()
                    )
                val bound4 =
                    Point(
                        lon + distance,
                        lat + distance,
                        SpatialReferences.getWgs84()
                    )

                //Check if user is within bounds of maneuver
                if (userPoint.x > bound1.x && userPoint.y > bound1.y) {
                    if (userPoint.x > bound2.x && userPoint.y < bound2.y) {
                        if (userPoint.x < bound3.x && userPoint.y > bound3.y) {
                            if (userPoint.x < bound4.x && userPoint.y < bound4.y) {
                                //Check if this hazard has already occured for this boundary.
                                if (!favoritePlace.isNotified) {
                                    //Show notification for the hazard.
                                    openNotification()

                                    //read approaching hazard
                                    if (mPrefs.getBoolean("soundKey", true)) {
                                        mTts = TextToSpeech(mContext,
                                            OnInitListener { status ->
                                                if (status != TextToSpeech.ERROR) {
                                                    mTts!!.language = Locale.US
                                                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                                                        mTts!!.speak(mContext.getString(R.string.approaching_hazard), TextToSpeech.QUEUE_ADD, null, null);
                                                    } else {
                                                        mTts!!.speak(mContext.getString(R.string.approaching_hazard), TextToSpeech.QUEUE_ADD, null)
                                                    }
                                                }
                                            })
                                    }
                                    favoritePlace.isNotified = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    /*
    * Create and display the notification for favorite place occurrence.
    * */
    private fun openNotification() {
        val builder =
            NotificationCompat.Builder(mContext, "0")
                .setSmallIcon(R.drawable.app_icon)
                .setContentTitle(mContext.getString(R.string.approaching_fav_notification_header))
                .setContentText(mContext.getString(R.string.fav_notification_desc))
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)

        //Send the user to Home screen on click of notification.
        val notificationIntent = Intent(mContext, MainNavigationHome::class.java)
        val contentIntent = PendingIntent.getActivity(mContext, 0, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT)
        builder.setContentIntent(contentIntent)

        // Add as notification
        val manager = mContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(0, builder.build())
    }

    //Constructor
    init {
        mContext = context
        mPrefs = mContext.getSharedPreferences("pathVuPrefs", Context.MODE_PRIVATE)
    }
}
