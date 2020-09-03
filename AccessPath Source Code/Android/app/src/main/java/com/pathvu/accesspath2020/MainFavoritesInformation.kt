package com.pathvu.accesspath2020

import android.annotation.SuppressLint
import android.content.Intent
import android.graphics.BitmapFactory
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.android.volley.DefaultRetryPolicy
import com.android.volley.RequestQueue
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.GoogleMap.OnCameraIdleListener
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.SupportMapFragment
import com.google.android.gms.maps.model.*
import kotlinx.android.synthetic.main.activity_main_favorites_information.*

/**
 * This class displays information about a favorite place the user selected from the list. A map
 * displays the location of the favorite place, while a view below the map displays the name and
 * address. The card below the map has an option for the use to edit the favorite place, or set a
 * path from the current location to the favorite place.
 */
class MainFavoritesInformation: AppCompatActivity(), OnMapReadyCallback, GoogleMap.OnMarkerClickListener, GoogleMap.OnMapLoadedCallback,
    GoogleMap.OnCameraMoveStartedListener,
    GoogleMap.OnCameraMoveListener,
    GoogleMap.OnCameraMoveCanceledListener,
    GoogleMap.OnCameraIdleListener {

    private lateinit var mMap: GoogleMap
    private lateinit var fusedLocationClient: FusedLocationProviderClient

    companion object {
        lateinit var placeName: String
        lateinit var placeAddress: String
        lateinit var lat: String
        lateinit var lng: String
        lateinit var fromlat: String
        lateinit var fromlng: String
        lateinit var fromLoc: String
    }
    lateinit var queue: RequestQueue

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_favorites_information)

        queue = Volley.newRequestQueue(this)

        val mapFragment = supportFragmentManager.findFragmentById(R.id.map) as SupportMapFragment
        mapFragment.getMapAsync(this)
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)

        //Cancel: Take the user back to the favorites list
        /* On Click Listeners */ //Cancel: Take the user back to the favorites list
        cancelButton.setOnClickListener {
            val i = Intent(this@MainFavoritesInformation, MainFavoritesList::class.java)
            startActivity(i)
        }

        //Edit: Open the edit favorite activity
        editFavoriteButton.setOnClickListener {
            MainFavoritesEdit.placeAddress = placeAddress
            MainFavoritesEdit.placeName = placeName
            val i = Intent(this@MainFavoritesInformation, MainFavoritesEdit::class.java)
            startActivity(i)
        }

        //Set Path To: Set a path from the current location to the favorite place
        setPathToButton.setOnClickListener {
            MainSetANewPathMap.toText = placeAddress
            MainSetANewPathMap.fromLat = fromlat
            MainSetANewPathMap.fromLng = fromlng
            MainSetANewPathMap.toLat = lat
            MainSetANewPathMap.toLng = lng
            MainSetANewPathMap.fromAddress = fromLoc
            val i = Intent(this@MainFavoritesInformation, MainSetANewPathMap::class.java)
            startActivity(i)
        }
    }


    override fun onMapReady(googleMap: GoogleMap) {
        mMap = googleMap

        val currentLoc = LatLng(lat.toDouble(), lng.toDouble())
        placeMarkerOnMap(currentLoc)
        mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(currentLoc, 16.0f))

        mMap.uiSettings.isZoomControlsEnabled = true
        mMap.setOnMarkerClickListener(this)
        mMap.setOnMapLoadedCallback(this)
    }


    private fun placeMarkerOnMap(location: LatLng) {
        val markerOptions = MarkerOptions().position(location)
        markerOptions.icon(BitmapDescriptorFactory.fromBitmap(BitmapFactory.decodeResource(resources, R.mipmap.current_location_marker)))
        mMap.addMarker(markerOptions)
    }



    @SuppressLint("SetTextI18n")
    override fun onResume() {
        super.onResume()
        headerSubText.text = placeName
        cardPlaceName.text = placeName
        cardPlaceAddress.text = placeAddress
        setPathToButton.text = "Set Path To " + placeName
    }


    override fun onMapLoaded() {
        showBoundingBox(mMap)
        mMap.setOnCameraIdleListener(OnCameraIdleListener {
            Toast.makeText(this, "The camera has stopped moving.",
                Toast.LENGTH_SHORT).show()
            showBoundingBox(mMap)
        })
    }


    /**
     * Get hazards, indoor, entrance information of this square area from the server
     */
    private fun showBoundingBox(mMap: GoogleMap) {
        var curBound = mMap.projection.visibleRegion

        val hazardsUrl = "https://pathvudata.com/api1/api/locations/hazards/"
        val stringRequest = object : StringRequest(
            Method.POST, hazardsUrl,
            Response.Listener<String> { response ->
                println("php response hazards: $response")
                val responseString = response.toString()
                checkHazardsResponse(responseString)
            },
            Response.ErrorListener { error ->
                println("error: $error") })
        {
            override fun getParams(): MutableMap<String, String> {
                val hazardsParams = HashMap<String, String>()
                hazardsParams["p1lon"] = curBound.farLeft.longitude.toString()
                hazardsParams["p1lat"] = curBound.farLeft.latitude.toString()
                hazardsParams["p2lon"] = curBound.farRight.longitude.toString()
                hazardsParams["p2lat"] = curBound.farRight.latitude.toString()
                hazardsParams["p3lon"] = curBound.nearLeft.longitude.toString()
                hazardsParams["p3lat"] = curBound.nearLeft.latitude.toString()
                hazardsParams["p4lon"] = curBound.nearRight.longitude.toString()
                hazardsParams["p4lat"] = curBound.nearRight.latitude.toString()
                return hazardsParams
            }
        }
        stringRequest.retryPolicy = DefaultRetryPolicy(50000, DefaultRetryPolicy.DEFAULT_MAX_RETRIES, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT)
        queue.add(stringRequest)

        val entranceUrl = "https://pathvudata.com/api1/api/locations/entrances/"
        val stringRequestEntrance = object : StringRequest(
            Method.POST, entranceUrl,
            Response.Listener<String> { response ->
                println("php response entrance: $response")
                val responseString = response.toString()
                checkHazardsResponse(responseString)
            },
            Response.ErrorListener { error ->
                println("error: $error") })
        {
            override fun getParams(): MutableMap<String, String> {
                val entranceParams = HashMap<String, String>()
                entranceParams["p1lon"] = curBound.farLeft.longitude.toString()
                entranceParams["p1lat"] = curBound.farLeft.latitude.toString()
                entranceParams["p2lon"] = curBound.farRight.longitude.toString()
                entranceParams["p2lat"] = curBound.farRight.latitude.toString()
                entranceParams["p3lon"] = curBound.nearLeft.longitude.toString()
                entranceParams["p3lat"] = curBound.nearLeft.latitude.toString()
                entranceParams["p4lon"] = curBound.nearRight.longitude.toString()
                entranceParams["p4lat"] = curBound.nearRight.latitude.toString()
                return entranceParams
            }
        }
        stringRequestEntrance.retryPolicy = DefaultRetryPolicy(50000, DefaultRetryPolicy.DEFAULT_MAX_RETRIES, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT)
        queue.add(stringRequestEntrance)

        val indoorUrl = "https://pathvudata.com/api1/api/locations/indoor/"
        val stringRequestIndoor = object : StringRequest(
            Method.POST, indoorUrl,
            Response.Listener<String> { response ->
                println("php response indoor: $response")
                val responseString = response.toString()
                checkHazardsResponse(responseString)
            },
            Response.ErrorListener { error ->
                println("error: $error") })
        {
            override fun getParams(): MutableMap<String, String> {
                val indoorParams = HashMap<String, String>()
                indoorParams["p1lon"] = curBound.farLeft.longitude.toString()
                indoorParams["p1lat"] = curBound.farLeft.latitude.toString()
                indoorParams["p2lon"] = curBound.farRight.longitude.toString()
                indoorParams["p2lat"] = curBound.farRight.latitude.toString()
                indoorParams["p3lon"] = curBound.nearLeft.longitude.toString()
                indoorParams["p3lat"] = curBound.nearLeft.latitude.toString()
                indoorParams["p4lon"] = curBound.nearRight.longitude.toString()
                indoorParams["p4lat"] = curBound.nearRight.latitude.toString()
                return indoorParams
            }
        }
        stringRequestIndoor.retryPolicy = DefaultRetryPolicy(50000, DefaultRetryPolicy.DEFAULT_MAX_RETRIES, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT)
        queue.add(stringRequestIndoor)
    }


    /**
     * Check getting hazards request response
     */
    fun checkHazardsResponse(response: String) {
        with(response) {
            when {
                    //
                else -> {
                    // TODO: else do what
                    println("response: $response")
                    }
                }
            }
    }


    /**
     * Uses the Android stack to take the user to the previous screen
     */
    fun back(v: View?) {
        onBackPressed()
    }


    override fun onMarkerClick(p0: Marker?): Boolean {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onCameraMoveStarted(p0: Int) {

    }

    override fun onCameraMove() {
        Toast.makeText(this, "The camera is moving.",
            Toast.LENGTH_SHORT).show();
    }

    override fun onCameraMoveCanceled() {
        Toast.makeText(this, "Camera movement canceled.",
            Toast.LENGTH_SHORT).show();
    }

    override fun onCameraIdle() {
        Toast.makeText(this, "The camera has stopped moving.",
            Toast.LENGTH_SHORT).show();
    }
}


//private fun placeMarkerOnMap(location: LatLng) {
//    val markerOptions = MarkerOptions().position(location)
//    val height = 100
//    val width = 100
////        val bitmapdraw = ContextCompat.getDrawable(applicationContext, R.drawable.current_location_marker) as BitmapDrawable
////        val b = bitmapdraw.bitmap
////        val smallMarker = Bitmap.createScaledBitmap(b, width, height, false)
////        val b = BitmapFactory.decodeResource(resources, R.drawable.current_location_marker)
////        val smallMarker = Bitmap.createScaledBitmap(b, width, height, false)
//    markerOptions.icon(BitmapDescriptorFactory.fromBitmap(BitmapFactory.decodeResource(resources, R.drawable.current_location_marker)))
////        markerOptions.icon(BitmapDescriptorFactory.fromBitmap(smallMarker))
//    mMap.addMarker(markerOptions)
//}