package com.pathvu.accesspath2020

import android.Manifest
import android.annotation.SuppressLint
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.BitmapFactory
import android.graphics.Color
import android.location.Location
import android.location.LocationListener
import android.os.Build
import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.speech.tts.TextToSpeech.OnInitListener
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.android.volley.DefaultRetryPolicy
import com.android.volley.RequestQueue
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.SupportMapFragment
import com.google.android.gms.maps.model.*
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import com.pathvu.accesspath2020.Util.*
import com.pathvu.accesspath2020.listener.CustomListener
import com.pathvu.accesspath2020.model.Direction
import com.pathvu.accesspath2020.model.Path
import kotlinx.android.synthetic.main.activity_main_destination_preview_map.*
import org.json.JSONArray
import org.json.JSONObject
import java.util.*
import kotlin.collections.HashMap
import kotlin.properties.Delegates

/**
 * This activity displays a map containing the route from the current location to the specified
 * destination. The user also has the option of displaying the list view of the steps. Basic
 * controls are also presented so that the user can display the previous or next step, or recenter
 * the map on their location. If the user has sound enabled (via the button on the main navigation
 * page), the steps will be read aloud.
 */
class MainDestinationPreviewMap : AppCompatActivity(), LocationListener, OnMapReadyCallback, GoogleMap.OnMarkerClickListener,  GoogleMap.OnMapLoadedCallback {

    private val TAG = "MapPreview"
    private lateinit var mMap: GoogleMap
    private lateinit var fusedLocationClient: FusedLocationProviderClient
    var uacctidInt = 0
    var sound by Delegates.notNull<Boolean>()
    private lateinit var tts: TextToSpeech
    private lateinit var currentLoc: LatLng
    var position = 0
    var directionList = ArrayList<Direction>()
    // Maintains the value for list/map mode.
    private var isListMode: Boolean = false;

    private var PATTERN_DASH_LENGTH_PX = 20;
    private var PATTERN_GAP_LENGTH_PX = 20;
    private var DOT: PatternItem = Dot()
    private var GAP: PatternItem = Gap(PATTERN_GAP_LENGTH_PX.toFloat());
    private var PATTERN_POLYGON_ALPHA: List<PatternItem> = listOf(GAP, DOT)

    companion object{
        lateinit var fromAddress: String
        lateinit var destAddress: String
        lateinit var fromLat: String
        lateinit var fromLng: String
        lateinit var toLat: String
        lateinit var toLng: String
    }
    private var locationMap = java.util.HashMap<Marker, String>()
    lateinit var queue: RequestQueue


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_destination_preview_map)

        queue = Volley.newRequestQueue(this)
        NetworkManager.getInstance(this)

        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
        uacctidInt = sharedPreferences.getInt("uacctid", 0)
        sound = sharedPreferences.getBoolean("soundKey", true)
        headerText.text = destAddress.split(",")[0]


        val mapFragment = supportFragmentManager.findFragmentById(R.id.mapView) as SupportMapFragment
        mapFragment.getMapAsync(this)
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)

        //Check for location permissions
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return
        }

        getRoute(fromLat, fromLng, toLat, toLng)


        //Cancel: Take user to navigation home screen
        cancelButton.setOnClickListener(View.OnClickListener {
            startActivity(Intent(this@MainDestinationPreviewMap, MainNavigationHome::class.java))
        })

        //Map/List: Swap between the map and the list views
        directionsModeButton.setOnClickListener {
            if (listView.visibility == View.VISIBLE) { //If list is open, close the list
                directionText.visibility = View.INVISIBLE
                streetText.visibility = View.INVISIBLE
                lengthText.visibility = View.INVISIBLE
                listView.visibility = View.INVISIBLE
                directionImage.visibility = View.INVISIBLE
                directionsModeButton.text = "List"
                //Change the drawable to the list icon
                directionsModeButton.setCompoundDrawablesWithIntrinsicBounds(null, null, ContextCompat.getDrawable(this@MainDestinationPreviewMap, R.drawable.ic_action_list_icon), null)
            } else { //If list is closed, display it on top of the map
                directionText.visibility = View.VISIBLE
                streetText.visibility = View.VISIBLE
                lengthText.visibility = View.VISIBLE
                listView.visibility = View.VISIBLE
                directionImage.visibility = View.VISIBLE
                directionsModeButton.text = "Map"
                //Change the drawable to the map icon
                directionsModeButton.setCompoundDrawablesWithIntrinsicBounds(null, null, ContextCompat.getDrawable(this@MainDestinationPreviewMap, R.drawable.ic_action_map_icon), null)
            }
        }

        //Re-enter: get back to the source locationg
        reCenterButton.setOnClickListener {
            position = 0
            currentLoc = LatLng(fromLat.toDouble(), fromLng.toDouble())
            placeMarkerOnMap(currentLoc)
            mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(currentLoc, mMap.cameraPosition.zoom))
            displayManeuver()
        }

        // Next step
        nextStepButton.setOnClickListener {
            nextStep()
        }

        // Last step
        lastStepButton.setOnClickListener {
            lastStep()
        }
    }


    @SuppressLint("SetTextI18n")
    override fun onMapReady(googleMap: GoogleMap) {
        mMap = googleMap

        currentLoc = LatLng(fromLat.toDouble(), fromLng.toDouble())
        placeMarkerOnMap(currentLoc)
        mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(currentLoc, 18.0f))

        mMap.uiSettings.isZoomControlsEnabled = true
        mMap.setOnMarkerClickListener(this)
        mMap.setOnMapLoadedCallback(this)

        val resourceId: Int = applicationContext.resources.getIdentifier("current_location_marker", "drawable", applicationContext.packageName)
        directionImage.setBackgroundResource(resourceId)
        directionText.text = "Start at $fromAddress"
    }


    private fun placeMarkerOnMap(location: LatLng) {
        val markerOptions = MarkerOptions().position(location)
        markerOptions.icon(BitmapDescriptorFactory.fromBitmap(BitmapFactory.decodeResource(resources, R.mipmap.current_location_marker)))
        mMap.addMarker(markerOptions)
    }



    override fun onMapLoaded() {
        showBoundingBox(mMap)
        mMap.setOnCameraIdleListener(GoogleMap.OnCameraIdleListener {
            showBoundingBox(mMap)
        })
    }


    /**
     * Display transit, curb ramp and sidewalk layer on the map
     */
    private fun showBoundingBox(mMap: GoogleMap) {
        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
        if (sharedPreferences.getBoolean("trippingHazardLayer", true)) {
            val hazardMapLayer = HazardLayer(
                StringBuilder(getString(R.string.hazard_layer)),
                mMap,
                applicationContext,
                resources,
                queue,
                locationMap
            )
            hazardMapLayer.queryAndRender()
            val indoorMapLayer = IndoorLayer(
                StringBuilder(getString(R.string.indoor_layer)),
                mMap,
                applicationContext,
                resources,
                queue,
                locationMap
            )
            indoorMapLayer.queryAndRender()
            val entranceMapLayer = IndoorLayer(
                StringBuilder(getString(R.string.entrance_layer)),
                mMap,
                applicationContext,
                resources,
                queue,
                locationMap
            )
            entranceMapLayer.queryAndRender()
        }

        if (sharedPreferences.getBoolean("transitStopsLayer", true)) {
            val transitLayer = TransitLayer(
                StringBuilder(getString(R.string.transit_layer)),
                mMap,
                applicationContext,
                queue,
                locationMap
            )
            transitLayer.setupAndRender()
        }
        if (sharedPreferences.getBoolean("curbRampsLayer", true)) {
            val curbRampLayer = CurbRampLayerLayer(
                StringBuilder(getString(R.string.curb_ramps_layer)),
                mMap,
                applicationContext,
                queue,
                locationMap
            )
            curbRampLayer.setupAndRender()
        }
        val sidewalkLayer = SidewalkLayer(StringBuilder(getString(R.string.sidewalks_layer)), mMap, applicationContext, queue)
        sidewalkLayer.setupAndRender()
    }



    override fun onMarkerClick(marker: Marker?): Boolean {
        var type = ""
        if(locationMap.containsKey(marker)) {
            type = locationMap[marker].toString()
            val dialog = AccessPathBottomSheetDialog.getInstance(this, R.style.SheetDialog, type, marker)
            dialog.setCanceledOnTouchOutside(false)
            dialog.show()

        }
        return false
    }



    /**
     * Send a routing request to the server given source location and destination
     */
    private fun getRoute(fromLat: String, fromLon: String, toLat: String, toLon: String) {
        NetworkManager.getInstance()
            ?.getRoute(uacctidInt.toString(), fromLat, fromLng, toLat, toLon, object : CustomListener<String?> {
                override fun getResult(result: String?) {
                    if (result != null) {
                        if (result.isNotEmpty()) {
                            try {
                                checkResponse(result)
                            } catch (t: Throwable) {
                                println("Could not get route")
                                t.printStackTrace()
                            }
                        } else {
//                            println("Added recent place")
                        }
                    }
                }
            })
    }


    /**
     * Check routing api response
     */
    fun checkResponse(response: String) {
        with(response) {
            when {
                startsWith("{error\":\"r001}") -> Toast.makeText(applicationContext, "From latitude is not set", Toast.LENGTH_LONG).show()
                startsWith("{error\":\"r002}") -> Toast.makeText(applicationContext, "From longitude is not set", Toast.LENGTH_LONG).show()
                startsWith("{error\":\"r003}") -> Toast.makeText(applicationContext, "To latitude is not set", Toast.LENGTH_LONG).show()
                startsWith("{error\":\"r004}") -> Toast.makeText(applicationContext, "To longitude is not set", Toast.LENGTH_LONG).show()
                startsWith("{error\":\"r005}") -> Toast.makeText(applicationContext, "uaactid and tid combination was not found", Toast.LENGTH_LONG).show()
                startsWith("{error\":\"r006}") -> Toast.makeText(applicationContext, "uacctid was set, but tid was not set", Toast.LENGTH_LONG).show()
                startsWith("{error\":\"r007}") -> Toast.makeText(applicationContext, "Route not found due to one of the following:\n" +
                        "• Point was not found\n" +
                        "• Missing data in sidewalk network", Toast.LENGTH_LONG).show()
                else -> {
//                    toPrettyFormat(response)
                    val pathJSON = getPathsCoordinate(response)
                    if (pathJSON != null) {
                        showRoute(pathJSON)
                    }
                    val directionJSON = getDirections(response)
                    if (directionJSON != null) {
                        storeDirections(directionJSON)
                    }
//                    displayManeuver()
                }
            }
        }
    }


    /**
     * Reorganize the json result with proper indent
     */
    private fun toPrettyFormat(jsonString: String) {
        val parser = JsonParser()
        val json: JsonObject = parser.parse(jsonString).asJsonObject;
        val gson: Gson = GsonBuilder().setPrettyPrinting().create();
        val prettyJson: String = gson.toJson(json);
        println(prettyJson)
    }


    /**
     * Get all coordinates latitude and longitude information along the route from the json result
     */
    private fun getPathsCoordinate(response: String): JSONArray? {
        val routesJsonObj = JSONObject(response).getJSONObject("routes")
        val featureArray = routesJsonObj.getJSONArray("features").getJSONObject(0)
        return featureArray.getJSONObject("geometry").getJSONArray("paths").getJSONArray(0)
    }


    /**
     * Get all direction information along the route from the json result
     */
    private fun getDirections(response: String): JSONArray? {
        val directionsJsonObj = JSONObject(response).getJSONArray("directions").getJSONObject(0)
        return directionsJsonObj.getJSONArray("features")
    }


    /**
     * Store all coordinates geo information along the route into an arrayList
     * and return this arrayList
     */
    private fun storePathList(pathArr: JSONArray): ArrayList<LatLng> {
        val pathList = ArrayList<LatLng>()
        for (i in 0 until pathArr.length()) {
            val curPath = pathArr[i].toString()
            val curPathInfo = curPath.substring(1, curPath.length - 1).split(',')
            pathList.add(LatLng(curPathInfo[1].toDouble(), curPathInfo[0].toDouble()))
        }
        return pathList
    }


    /**
     * Store all direction text information along the roue into an arrayList
     */
    private fun storeDirections(directionArr: JSONArray) {
        var street = ""
        for (i in 0 until directionArr.length()) {
            val curJSON = directionArr.getJSONObject(i)
            val curAttr = curJSON.getJSONObject("attributes")           // get attributes json obj
            val curGeom = curJSON.getString("compressedGeometry")       // get compressedGeometry string
            if (curJSON.has("strings")) {
                street = curJSON.getJSONArray("strings").getJSONObject(0).getString("string")  // first json in strings value
            }
            val newDirection = Direction(curAttr.getString("text"), curAttr.getString("length"), street, CGDecoder.createPathFromCompressedGeometry(curGeom)[0].y, CGDecoder.createPathFromCompressedGeometry(curGeom)[0].x)
            directionList.add(newDirection)
        }
    }


    /**
     * Draw the route on the map with dotted polyline
     */
    private fun showRoute(pathArr: JSONArray) {
        val pathList = storePathList(pathArr)
        mMap.addPolyline(
            PolylineOptions()
                .addAll(pathList)
                .width(30f)
                .pattern(PATTERN_POLYGON_ALPHA)
                .color(Color.parseColor("#ff9500"))
        )
    }


    /**
     * Direct to the next step along the route
     */
    private fun nextStep() {
        if (position < directionList.size) {
            position++
            if (position > directionList.size)
                position = directionList.size - 1
            val curDirection = directionList[position]
            currentLoc = LatLng(curDirection.lat, curDirection.lon)
//        placeMarkerOnMap(currentLoc)
            mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(currentLoc, mMap.cameraPosition.zoom))
            displayManeuver()
        }
    }


    /**
     * Direct to the last step along the route
     */
    private fun lastStep() {
        if (position >= 0) {
            position--
            if (position < 0)
                position = 0
            val curDirection = directionList[position]
            currentLoc = LatLng(curDirection.lat, curDirection.lon)
//        placeMarkerOnMap(currentLoc)
            mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(currentLoc, mMap.cameraPosition.zoom))
            displayManeuver()
        }
    }


    /**
     * Display the direction, distance and street information in a list format
     */
    @SuppressLint("SetTextI18n")
    private fun displayManeuver() {
        val textDirection = directionList[position].text
        val lengthDirection = directionList[position].length
        val streetDirection = directionList[position].street

        //If the user has the app sound enabled, read the maneuver using text-to-speech
        if (sound) {
            tts = TextToSpeech(applicationContext,
                OnInitListener { status ->
                    if (status != TextToSpeech.ERROR) {
                        tts.language = Locale.US
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                            tts.speak(textDirection,TextToSpeech.QUEUE_FLUSH,null,null);
                        } else {
                            tts.speak(textDirection, TextToSpeech.QUEUE_FLUSH, null);
                        }
                    }
                })
        }
        if (lengthDirection == "0")
            lengthText.text = ""
        else
            lengthText.text = Utility.convertMeterToFeet(lengthDirection.toDouble()).toString() + " " + getString(R.string.feet)

        if (streetDirection == "")
            streetText.text = ""
        else
            streetText.text = streetDirection

        if (textDirection.contains("toward")) {
            val resourceId: Int = applicationContext.resources.getIdentifier("head_straight", "drawable", applicationContext.packageName)
            directionImage.setBackgroundResource(resourceId)
            directionText.text = textDirection
        } else if (textDirection.contains("Finish")) {
            directionText.text = textDirection
            streetText.text = ""
            val resourceId: Int = applicationContext.resources.getIdentifier("thumbs_up", "drawable", applicationContext.packageName)
            directionImage.setBackgroundResource(resourceId)
        } else if (textDirection.contains("left")) {
            val resourceId: Int = applicationContext.resources.getIdentifier("turn_right", "drawable", applicationContext.packageName)
            directionImage.setBackgroundResource(resourceId)
            directionText.text = textDirection
        } else if (textDirection.contains("right")) {
            val resourceId: Int = applicationContext.resources.getIdentifier("turn_left", "drawable", applicationContext.packageName)
            directionImage.setBackgroundResource(resourceId)
            directionText.text = textDirection
        } else if (textDirection.contains("Continue")) {
            val resourceId: Int = applicationContext.resources.getIdentifier("head_straight", "drawable", applicationContext.packageName)
            directionImage.setBackgroundResource(resourceId)
            directionText.text = textDirection
        } else if (textDirection.contains("Start")) {
            val street = ""
            val resourceId: Int = applicationContext.resources.getIdentifier("current_location_marker", "drawable", applicationContext.packageName)
            directionImage.setBackgroundResource(resourceId)
            directionText.text = "Start at $fromAddress"
            streetText.text = street
        } else if (textDirection.contains("west")) {
            directionText.text = textDirection
        } else if (textDirection.contains("east")) {
            directionText.text = textDirection
        } else if (textDirection.contains("north")) {
            directionText.text = textDirection
        } else if (textDirection.contains("north-east")) {
            directionText.text = textDirection
        } else if (textDirection.contains("north-west")) {
            directionText.text = textDirection
        } else if (textDirection.contains("south")) {
            directionText.text = textDirection
        } else if (textDirection.contains("south-east")) {
            directionText.text = textDirection
        } else if (textDirection.contains("south-west")) {
            directionText.text = textDirection
        }

    }


    fun back(v: View?) {
        onBackPressed()
    }




    override fun onLocationChanged(p0: Location?) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onStatusChanged(p0: String?, p1: Int, p2: Bundle?) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onProviderEnabled(p0: String?) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onProviderDisabled(p0: String?) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

}