package com.pathvu.accesspath2020

import android.Manifest
import android.annotation.SuppressLint
import android.app.Dialog
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.BitmapFactory
import android.graphics.Color
import android.graphics.Point
import android.graphics.drawable.ColorDrawable
import android.location.Location
import android.location.LocationListener
import android.os.Build
import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.SupportMapFragment
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.Marker
import com.google.android.gms.maps.model.MarkerOptions
import com.pathvu.accesspath2020.listener.CustomListener
import com.pathvu.accesspath2020.model.Address
import com.pathvu.accesspath2020.model.PlaceDetails
import kotlinx.android.synthetic.main.activity_main_around_me.*
import kotlinx.android.synthetic.main.activity_main_favorites_list.*
import kotlinx.android.synthetic.main.fragment_nearby_detail.*
import org.json.JSONObject
import java.util.*

class MainAroundMe : AppCompatActivity(), LocationListener, OnMapReadyCallback, GoogleMap.OnMarkerClickListener {

    companion object {
        lateinit var fromLat: String
        lateinit var fromLng: String
        lateinit var fromAddress: String
        lateinit var radius: String
    }
    private val nearbyPlaces = ArrayList<PlaceDetails>()

    private lateinit var mMap: GoogleMap
    private lateinit var fusedLocationClient: FusedLocationProviderClient
    var markersArray: ArrayList<MarkerOptions> = ArrayList<MarkerOptions>()

    @SuppressLint("SetTextI18n", "RestrictedApi")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_around_me)

        NetworkManager.getInstance(this)
        initList()

        val mapFragment = supportFragmentManager.findFragmentById(R.id.mapView) as SupportMapFragment
        mapFragment.getMapAsync(this)
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)

        //Check for location permissions
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return
        }


        directionsModeButton.setOnClickListener {
            if (buttonView.visibility == View.VISIBLE) { //If list is open, close the list
                nearbyRecyclerView.visibility = View.VISIBLE
                listView.visibility = View.VISIBLE
                buttonView.visibility = View.INVISIBLE
                currentLocationButton.visibility = View.INVISIBLE
                directionsModeButton.text = "List"
                //Change the drawable to the list icon
                directionsModeButton.setCompoundDrawablesWithIntrinsicBounds(null, null, ContextCompat.getDrawable(this, R.drawable.ic_action_list_icon), null)
            } else { //If list is closed, display it on top of the map
                nearbyRecyclerView.visibility = View.INVISIBLE
                listView.visibility = View.INVISIBLE
                buttonView.visibility = View.VISIBLE
                currentLocationButton.visibility = View.VISIBLE
                directionsModeButton.text = "Map"
                //Change the drawable to the map icon
                directionsModeButton.setCompoundDrawablesWithIntrinsicBounds(null, null, ContextCompat.getDrawable(this, R.drawable.ic_action_map_icon), null)
            }
        }

        currentLocationButton.setOnClickListener {
            mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(LatLng(fromLat.toDouble(), fromLng.toDouble()), mMap.cameraPosition.zoom))
        }
    }


    override fun onMapReady(googleMap: GoogleMap) {
        mMap = googleMap

        mMap.addMarker(MarkerOptions().position(LatLng(fromLat.toDouble(), fromLng.toDouble())))
        mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(LatLng(fromLat.toDouble(), fromLng.toDouble()), 18.0f))
        mMap.uiSettings.isZoomControlsEnabled = true
        mMap.setOnMarkerClickListener(this)

    }


    private fun placeMarkerOnMap(placeInfo: PlaceDetails) {
        val markerOptions = MarkerOptions().position(LatLng(placeInfo.lat, placeInfo.lng))
        markerOptions.icon(BitmapDescriptorFactory.fromBitmap(BitmapFactory.decodeResource(resources, R.mipmap.current_location_marker)))
        val marker = mMap.addMarker(markerOptions)
        marker.tag = placeInfo
    }



    @SuppressLint("SetTextI18n", "RtlHardcoded")
    override fun onMarkerClick(marker: Marker?): Boolean {
        val placeInfo: PlaceDetails = marker?.tag as PlaceDetails
        val mDialog = Dialog(this)
        mDialog.setContentView(R.layout.fragment_nearby_detail)
        mDialog.window?.attributes?.gravity = Gravity.RIGHT
        val width = getScreenHeight(this)[0]
        val height =getScreenHeight(this)[1]
        mDialog.window?.setLayout(width * 2 / 3, height)
        mDialog.window?.setBackgroundDrawable(ColorDrawable(Color.WHITE))
        mDialog.placeName.text = placeInfo.name
        mDialog.distance.text = String.format("%.1f", placeInfo.distance) + " feet"
        mDialog.vicinity.text = placeInfo.vicinity
        val closeBtn = mDialog.findViewById<Button>(R.id.cancelButton)
        closeBtn.setOnClickListener { mDialog.dismiss() }
        mDialog.closeWindow.setOnClickListener { mDialog.dismiss() }
        mDialog.setPathButton.setOnClickListener {
            MainSetANewPathMap.fromAddress = fromAddress
            MainSetANewPathMap.fromLat = fromLat
            MainSetANewPathMap.fromLng = fromLng
            MainSetANewPathMap.destAddress = placeInfo.vicinity
            MainSetANewPathMap.toLat = placeInfo.lat.toString()
            MainSetANewPathMap.toLng = placeInfo.lng.toString()
            val i = Intent(this, MainSetANewPathMap::class.java)
            startActivity(i)
        }
        mDialog.show()
        return false
    }


    /**
     * Initialize and get the nearby places through Google Place API
     */
    private fun initList() {
        NetworkManager.getInstance()
            ?.getNearbyPlaces(getString(R.string.google_maps_key), fromLat, fromLng, radius, object : CustomListener<String?> {
                override fun getResult(result: String?) {
                    if (result != null) {
                        if (result.isNotEmpty()) {
                            try {
                                checkResponse(result)
                            } catch (t: Throwable) {
                                println("Could not get nearby")
                                noNearbyPlace.visibility = View.VISIBLE
                                noNearbyPlace.text = "No Nearby Places"
                                t.printStackTrace()
                            }
                        } else {
                            noNearbyPlace.visibility = View.VISIBLE
                            noNearbyPlace.text = "No Nearby Places"
                        }
                    }
                }
            })
    }


    /**
     * Check getting nearby places list request response
     */
    fun checkResponse(response: String) {
        with(response) {
            when {
                startsWith("{\"uf001") -> {
                    Toast.makeText(applicationContext,R.string.account_error_contact_pathvu, Toast.LENGTH_LONG).show()
                    noNearbyPlace.visibility = View.VISIBLE
                    noNearbyPlace.text = "No Nearby Places"
                }
                else -> showNearbyList(response)
            }
        }
    }


    /**
     * Display the recent list
     */
    private fun showNearbyList(response: String) {
        var resJSON = JSONObject(response).getJSONArray("results")
        try {
            for (i in 0 until resJSON.length()) {
                val curGeo = resJSON.getJSONObject(i)
                val lat = curGeo.getJSONObject("geometry").getJSONObject("location").getString("lat")
                val lng = curGeo.getJSONObject("geometry").getJSONObject("location").getString("lng")
                var id = ""
                if(!curGeo.isNull("id"))   id = curGeo.getString("id")
                val name = curGeo.getString("name")
                val placeID = curGeo.getString("place_id")
                val vicinity = curGeo.getString("vicinity")
                val distance = FloatArray(1)
                Location.distanceBetween(fromLat.toDouble(), fromLng.toDouble(), lat.toDouble(), lng.toDouble(), distance)
                nearbyPlaces.add(PlaceDetails(id, name, ArrayList<Address>(), lat.toDouble(), lng.toDouble(), placeID, "", 0, vicinity, distance[0]))
            }
            if (nearbyPlaces.isNotEmpty()) {
                nearbyPlaces.sortBy { it.distance }
                initRecyclerView()
                for(i in 0 until nearbyPlaces.size) {
                    placeMarkerOnMap(nearbyPlaces[i])
                }
            }
        } catch (t: Throwable) { // No nearby places
            println("Could not get nearby places")
            noNearbyPlace.visibility = View.VISIBLE
            noNearbyPlace.text = "No Nearby Places"
            t.printStackTrace()
        }
    }


    /**
     * Initialize the recycler (list) view on the layout to contain all name/address values
     */
    private fun initRecyclerView() {
        val recyclerView = findViewById<RecyclerView>(R.id.nearbyRecyclerView)
        val adapter = RecyclerViewAdapterNearby(this, nearbyPlaces, fromAddress, fromLat.toDouble(), fromLng.toDouble())
        recyclerView.adapter = adapter
        recyclerView.layoutManager = LinearLayoutManager(this)
    }


    private fun getScreenHeight(context: Context): IntArray {
        val layoutArr = IntArray(2)
        if (Build.VERSION.SDK_INT >= 13) {
            val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
            val display = wm.defaultDisplay
            val size = Point()
            display.getSize(size)
            layoutArr[0] = size.x
            layoutArr[1] = size.y
        } else {
            val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
            val display = wm.defaultDisplay
            layoutArr[1] = display.height // deprecated
            layoutArr[0] = display.width // deprecated
        }
        return layoutArr
    }


    /**
     * Uses the Android stack to take the user to the previous screen
     */
    fun back(v: View?) {
        onBackPressed()
    }

    override fun onLocationChanged(location: Location?) {
        TODO("Not yet implemented")
    }

    override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {
        TODO("Not yet implemented")
    }

    override fun onProviderEnabled(provider: String?) {
        TODO("Not yet implemented")
    }

    override fun onProviderDisabled(provider: String?) {
        TODO("Not yet implemented")
    }

}