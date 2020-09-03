package com.pathvu.accesspath2020

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.content.Intent
import android.content.IntentFilter
import android.content.IntentSender
import android.content.pm.PackageManager
import android.graphics.BitmapFactory
import android.graphics.Color
import android.location.Location
import android.location.LocationListener
import android.os.Build
import android.os.Bundle
import android.os.CountDownTimer
import android.speech.tts.TextToSpeech
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
import com.google.android.gms.common.api.ResolvableApiException
import com.google.android.gms.location.*
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
import kotlinx.android.synthetic.main.activity_main_set_a_new_path_map.*
import org.json.JSONArray
import org.json.JSONObject
import java.util.*
import kotlin.properties.Delegates

/**
 * This activity displays a map containing the route from the current location to the specified
 * destination. The user also has the option of displaying the list view of the steps. Basic
 * controls are also presented so that the user can display the previous step, recenter the map on
 * their location, or pause the navigation. If the user has sound enabled (via the button on the
 * main navigation page), the steps will be read aloud. When the user enters a maneuver, the
 * next step will be shown.
 */
class MainSetANewPathMap : AppCompatActivity(), LocationListener, OnMapReadyCallback, GoogleMap.OnMarkerClickListener, GoogleMap.OnMapLoadedCallback {

    companion object{
        var toText: String? = null
        //If user comes from recents page, do not add place as a recent
        var recent = false
        lateinit var fromAddress: String
        lateinit var destAddress: String
        lateinit var fromLat: String
        lateinit var fromLng: String
        lateinit var toLat: String
        lateinit var toLng: String
        private const val LOCATION_PERMISSION_REQUEST_CODE = 1
        private const val REQUEST_CHECK_SETTINGS = 2
    }
    private lateinit var lastLocation: Location
    var position = 0
    var step_position = 0
    var isRepeat = 0
//    private var directionList = ArrayList<Direction>()
    private var directionList = LinkedList<Pair<Direction, Boolean>>()
    private var PATTERN_DASH_LENGTH_PX = 20;
    private var PATTERN_GAP_LENGTH_PX = 20;
    private var DOT: PatternItem = Dot()
    private var GAP: PatternItem = Gap(PATTERN_GAP_LENGTH_PX.toFloat());
    private var PATTERN_POLYGON_ALPHA: List<PatternItem> = listOf(GAP, DOT)
    private lateinit var tts: TextToSpeech

    private lateinit var mMap: GoogleMap
    private lateinit var fusedLocationClient: FusedLocationProviderClient
    var uacctidInt = 0
    var sound by Delegates.notNull<Boolean>()
    private lateinit var currentLoc: LatLng

    //Maintains the value for list/map mode.
    private var isListMode = false
    private var mRouteFinishTimer: Timer? = null

    // google map update variables
    private lateinit var locationCallback: LocationCallback
    private lateinit var locationRequest: LocationRequest
    private var locationUpdateState = false
    private val LOCATION_PERMISSION_REQUEST_CODE = 1

    //If user comes from recents page, do not add place as a recent
    var recent = false
    private var locationMap = HashMap<Marker, String>()
    lateinit var queue: RequestQueue
    var buttonsOpened: Boolean = true;
    var currentLat: Double = 0.0
    var currentLng: Double = 0.0


    @SuppressLint("ClickableViewAccessibility")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_set_a_new_path_map)

        queue = Volley.newRequestQueue(this)

        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
        var editor = sharedPreferences.edit()
        uacctidInt = sharedPreferences.getInt("uacctid", 0)
        sound = sharedPreferences.getBoolean("soundKey", true)

        //Network manager instance for PHP calls
        NetworkManager.getInstance(this)

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
            startActivity(Intent(this, MainNavigationHome::class.java))
        })


        //Map/List: Swap between the map and the list views
        directionsModeButton.setOnClickListener {
            cancelTimer()
            if (listView.visibility == View.VISIBLE) {  // map mode
                isListMode = false
                directionText.visibility = View.INVISIBLE
                streetText.visibility = View.INVISIBLE
                lengthText.visibility = View.INVISIBLE
                listView.visibility = View.INVISIBLE
                directionImage.visibility = View.INVISIBLE
                directionsModeButton.text = "List"
                lastStepButton.text = "Last Step"
                repeatButton.text = "Repeat"
                //Change the drawable to the list icon
                directionsModeButton.setCompoundDrawablesWithIntrinsicBounds(null, null, ContextCompat.getDrawable(this, R.drawable.ic_action_list_icon), null)
            } else { //If list is closed, display it on top of the map
                isListMode = true
                directionText.visibility = View.VISIBLE
                streetText.visibility = View.VISIBLE
                lengthText.visibility = View.VISIBLE
                listView.visibility = View.VISIBLE
                directionImage.visibility = View.VISIBLE
                directionsModeButton.text = "Map"
                lastStepButton.text = "Repeat"
                repeatButton.text = "Mute"
                //Change the drawable to the map icon
                directionsModeButton.setCompoundDrawablesWithIntrinsicBounds(null, null, ContextCompat.getDrawable(this, R.drawable.ic_action_map_icon), null)
            }
        }

        if(isListMode) {
            if (sharedPreferences.getBoolean("soundKey", true)) {
                repeatButton.text = "Mute"
            } else {
                repeatButton.text = "Unmute"
            }
        }

        repeatButton.setOnClickListener {
            if (!isListMode) {
                repeatButton.text = "Repeat"
                cancelTimer()
                repeatDirection()
            } else { // button content is mute/unmute
                if (sharedPreferences.getBoolean("soundKey", false)) {
                    editor.putBoolean("soundKey", false)
                    editor.commit()
                    repeatButton.text = "Unmute"
                } else {
                    editor.putBoolean("soundKey", true)
                    editor.commit()
                    repeatButton.text = "Mute"
                }
            }
        }

        // Next step
        nextStepButton.setOnClickListener {
            nextStep()
        }

        // Last step
        lastStepButton.setOnClickListener {
            if(!isListMode) {    // map mode
                cancelTimer()
                if(position > 0)
                    lastStep()
            } else {
                repeatDirection()
            }
        }


        currentLocationButton.setOnClickListener {
            mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(LatLng(currentLat, currentLng), mMap.cameraPosition.zoom))
            buttonsOpened = true
        }

        // update location as user moves
        locationCallback = object : LocationCallback() {
            override fun onLocationResult(p0: LocationResult) {
                super.onLocationResult(p0)
                lastLocation = p0.lastLocation
                currentLat = lastLocation.latitude
                currentLng = lastLocation.longitude
                if(buttonsOpened) {
                    mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(LatLng(lastLocation.latitude, lastLocation.longitude), mMap.cameraPosition.zoom))
                }
                updateCurrentRoute(lastLocation.latitude, lastLocation.longitude)
            }
        }

        createLocationRequest()
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
     * check if user is within bounds of the a route location
     */
    private fun updateCurrentRoute(curLat: Double, curLng: Double) {
        val bias: Double = 0.00014
        for(i in 1 until directionList.size) {
            val idxDirection = directionList[i].first
            val isReached = directionList[i].second
//            val idxPath: Path = CGDecoder.createPathFromCompressedGeometry(idxDirection.geometry)
//            val curIdxPoint = idxPath[0]
            val idxLat = idxDirection.lat
            val idxLng = idxDirection.lon

            val bound1 = LatLng(idxLat - bias, idxLng - bias)
            val bound2 = LatLng(idxLat + bias, idxLng - bias)
            val bound3 = LatLng(idxLat - bias, idxLng + bias)
            val bound4 = LatLng(idxLat + bias, idxLng + bias)

            if(curLat > bound1.latitude && curLng > bound1.longitude) {
                if(curLat < bound2.latitude && curLng > bound2.longitude) {
                    if(curLat > bound3.latitude && curLng < bound3.longitude) {
                        if(curLat < bound4.latitude && curLng < bound4.longitude) {
                            if(!isReached) {
                                position = i
                                displayManeuver(i, true)
                                if(i == directionList.size - 1) {
                                    val timer = object: CountDownTimer(3000, 1000) {
                                        override fun onTick(millisUntilFinished: Long) {   }

                                        override fun onFinish() {
                                            val i = Intent(this@MainSetANewPathMap, MainNavigationHome::class.java)
                                            startActivity(i)
                                        }
                                    }
                                    timer.start()
                                }
                            }
                        }
                    }
                }
            }
        }
    }



    @SuppressLint("SetTextI18n")
    override fun onMapReady(googleMap: GoogleMap) {
        mMap = googleMap
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED){
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION), LOCATION_PERMISSION_REQUEST_CODE)
            return
        }
        mMap.isMyLocationEnabled = true

        currentLoc = LatLng(fromLat.toDouble(), fromLng.toDouble())
        placeMarkerOnMap(currentLoc)
//        drawCircle(currentLoc)
        mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(currentLoc, 18.0f))

        mMap.uiSettings.isZoomControlsEnabled = true
        mMap.setOnMarkerClickListener(this)
        mMap.setOnMapLoadedCallback(this)

        val resourceId: Int = applicationContext.resources.getIdentifier("current_location_marker", "drawable", applicationContext.packageName)
        directionImage.setBackgroundResource(resourceId)
        directionText.text = "Start at $fromAddress"
    }


    /**
     * Place Google map marker
     */
    private fun placeMarkerOnMap(location: LatLng) {
        val markerOptions = MarkerOptions().position(location)
        markerOptions.icon(BitmapDescriptorFactory.fromBitmap(BitmapFactory.decodeResource(resources, R.mipmap.current_location_marker)))
        mMap.addMarker(markerOptions)
    }


    /**
     * Update location info as user moves
     */
    private fun startLocationUpdates() {
        if (ActivityCompat.checkSelfPermission(this, android.Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, arrayOf(android.Manifest.permission.ACCESS_FINE_LOCATION), LOCATION_PERMISSION_REQUEST_CODE)
            return
        }
        fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback, null /* Looper */)
    }


    /**
     * Set location update time intervals and listener
     */
    private fun createLocationRequest() {
        locationRequest = LocationRequest()
        locationRequest.interval = 10000
        locationRequest.fastestInterval = 5000
        locationRequest.priority = LocationRequest.PRIORITY_HIGH_ACCURACY
        val builder = LocationSettingsRequest.Builder().addLocationRequest(locationRequest)
        val client = LocationServices.getSettingsClient(this)
        val task = client.checkLocationSettings(builder.build())

        task.addOnSuccessListener {
            locationUpdateState = true
            startLocationUpdates()
        }
        task.addOnFailureListener { e ->
            if (e is ResolvableApiException) {
                // Location settings are not satisfied, but this can be fixed
                // by showing the user a dialog.
                try {
                    // Show the dialog by calling startResolutionForResult(),
                    // and check the result in onActivityResult().
                    e.startResolutionForResult(this, REQUEST_CHECK_SETTINGS)
                } catch (sendEx: IntentSender.SendIntentException) {
                    // Ignore the error.
                }
            }
        }
    }


    /**
     * Return from location update intent
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CHECK_SETTINGS) {
            if (resultCode == Activity.RESULT_OK) {
                locationUpdateState = true
                startLocationUpdates()
            }
        }
    }


    override fun onPause() {
        super.onPause()
        fusedLocationClient.removeLocationUpdates(locationCallback)
    }


    public override fun onResume() {
        super.onResume()
        if (!locationUpdateState) {
            startLocationUpdates()
        }
    }


    /**
     * repeat current location
     */
    private fun repeatDirection() {
        isRepeat = 1
        if (position < directionList.size - 1) {
            //Change the text/image on the list view
            if(position == 0) {
                displayManeuver(1, false)
            }
            else {
                displayManeuver(position, false)
            }
        }
    }


    /**
     * Send a routing request to the server given source location and destination
     */
    private fun getRoute(fromLat: String, fromLon: String, toLat: String, toLon: String) {
        val routeUrl = "https://pathvudata.com/api1/api/routing/"
        val stringRequest = object : StringRequest(
            Method.POST, routeUrl,
            Response.Listener<String> { response ->
                val responseString = response.toString()
                checkResponse(responseString)
            },
            Response.ErrorListener { error ->
                println("error: $error") })
        {
            override fun getParams(): MutableMap<String, String> {
                val routeParams = HashMap<String, String>()
                routeParams["fromlat"] = fromLat
                routeParams["fromlon"] = fromLon
                routeParams["tolat"] = toLat
                routeParams["tolon"] = toLon
                routeParams["uacctid"] = uacctidInt.toString()
                routeParams["apitoken"] = getString(R.string.pathvu_api_key)
                return routeParams
            }
        }
        stringRequest.retryPolicy = DefaultRetryPolicy(50000, DefaultRetryPolicy.DEFAULT_MAX_RETRIES, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT)
        queue.add(stringRequest)
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
                    val directionJSON = getDirections(response)
                    if (directionJSON != null) {
                        storeDirections(directionJSON)
                    }

                    val pathJSON = getPathsCoordinate(response)
                    if (pathJSON != null) {
                        showRoute(pathJSON)
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
        var totalLength = 0.0
        for (i in 0 until directionArr.length()) {
            val curJSON = directionArr.getJSONObject(i)
            val curAttr = curJSON.getJSONObject("attributes")           // get attributes json obj
            val curGeom = curJSON.getString("compressedGeometry")       // get compressedGeometry string
            if (curJSON.has("strings")) {
                street = curJSON.getJSONArray("strings").getJSONObject(0).getString("string")  // first json in strings value
            }
            val path: Path = CGDecoder.createPathFromCompressedGeometry(curGeom)
            val curPoint = path[0]
            val nextPoint = path[1]
            val distance = FloatArray(1)
            Location.distanceBetween(curPoint.y, curPoint.x, nextPoint.y, nextPoint.x, distance)
            val totalDistance = distance[0] * 3.28084

            if(i == 0) {
                val newDirection = Direction(curAttr.getString("text"), curAttr.getString("length"), street, curPoint.y, curPoint.x)
                directionList.add(Pair(newDirection, false))  // haven't sound text
            } else if(i < directionArr.length() - 1) {
//                if(totalDistance > 100) {
                    val lastPoint = CGDecoder.createPathFromCompressedGeometry(directionArr.getJSONObject(i - 1).getString("compressedGeometry"))[1]
                    val nextManueverDist = String.format("%.0f", totalDistance)
                    val newDirection = Direction((curAttr.getString("text") + " in " + nextManueverDist + " feet"), nextManueverDist, street, (lastPoint.y + curPoint.y) / 2, (lastPoint.x + curPoint.x) / 2)
                    directionList.add(Pair(newDirection, false))

                    val newDirectionNow = Direction((curAttr.getString("text") + " now"), nextManueverDist, street, curPoint.y, curPoint.x)
                    directionList.add(Pair(newDirectionNow, false))
//                }
                totalLength += totalDistance
            } else {
                val newDirectionDest = Direction("You have reached your destination on the $street", totalLength.toString(), street, curPoint.y, curPoint.x)
                directionList.add(Pair(newDirectionDest, false))
            }
        }
    }


    /**
     * Draw the route on the map with dotted polyline
     */
    @SuppressLint("SetTextI18n")
    private fun showRoute(pathArr: JSONArray) {
        //Add to recent places
        if (!recent) {
            addRecent(destAddress)
        }
        try {
            headerText.text = "Navigating to " + destAddress!!.split(",".toRegex()).toTypedArray()[0]
        } catch (e: IndexOutOfBoundsException) {
            headerText.text = "Navigating to $destAddress"
        }

        val pathList = storePathList(pathArr)
        mMap.addPolyline(
            PolylineOptions()
                .addAll(pathList)
                .width(30f)
                .pattern(PATTERN_POLYGON_ALPHA)
                .color(Color.parseColor("#ff9500"))
        )

        //If the user has the app sound enabled, read the maneuver using text-to-speech
        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
        if (sharedPreferences.getBoolean("soundKey", false)) {
            tts = TextToSpeech(applicationContext,
                TextToSpeech.OnInitListener { status ->
                    if (status != TextToSpeech.ERROR) {
                        tts.language = Locale.US
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                            tts.speak(directionList[1].first.text, TextToSpeech.QUEUE_FLUSH, null, null);
                        } else {
                            tts.speak(directionList[1].first.text, TextToSpeech.QUEUE_FLUSH, null);
                        }
                    }
                })
        }
    }


    /**
     * Direct to the next step along the route
     */
    private fun nextStep() {
        if (step_position < directionList.size) {
            step_position++
            if (step_position > directionList.size)
                step_position = directionList.size - 1
            val curDirection = directionList[step_position].first
            currentLoc = LatLng(curDirection.lat, curDirection.lon)
            mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(currentLoc, mMap.cameraPosition.zoom))
            displayManeuver(step_position, false)
        } else {
            closeRouteScreen()
        }
    }


    /**
     * Direct to the last step along the route
     */
    private fun lastStep() {
        if (step_position >= 0) {
            step_position--
            if (step_position < 0)
                step_position = 0
            val curDirection = directionList[step_position].first
            currentLoc = LatLng(curDirection.lat, curDirection.lon)
            mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(currentLoc, mMap.cameraPosition.zoom))
            isRepeat = 1
            displayManeuver(step_position, false)
        }
    }


    /**
     * Display the direction, distance and street information in a list format
     */
    private fun displayManeuver(position: Int, update: Boolean) {
        val textDirection = directionList[position].first.text
        val lengthDirection = directionList[position].first.length
        val streetDirection = directionList[position].first.street
        var isSound = directionList[position].second

        if(!isSound || isRepeat == 1) {
            if(update) directionList[position] = Pair(directionList[position].first, true)
            isRepeat = 0
            val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
            if (sharedPreferences.getBoolean("soundKey", false)) {
                tts = TextToSpeech(applicationContext,
                    TextToSpeech.OnInitListener { status ->
                        if (status != TextToSpeech.ERROR) {
                            tts.language = Locale.US
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                                tts.speak(textDirection, TextToSpeech.QUEUE_FLUSH, null, null);
                            } else {
                                tts.speak(textDirection, TextToSpeech.QUEUE_FLUSH, null);
                            }
                        }
                    })
            }
        }


        if (lengthDirection == "0")
            lengthText.text = ""
        else
            lengthText.text = Utility.convertMeterToFeet(lengthDirection.toDouble()).toString() + " feet"

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


    /**
     * Add this place as a recent searched place
     */
    private fun addRecent(address: String) {
        NetworkManager.getInstance()
            ?.newRecent(uacctidInt.toString(), address, toLat, toLng, object : CustomListener<String?> {
                override fun getResult(result: String?) {
                    if (result != null) {
                        if (result.isNotEmpty()) {
                            try {
                            } catch (t: Throwable) {
                                println("Could not add recent")
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
     * stops the timer for closing the map screen after reahing the destination location.
     */
    private fun cancelTimer() {
        mRouteFinishTimer?.cancel()
    }


    /**
     * close the route screen after reaching to the destination location.
     */
    private fun closeRouteScreen() {
        val timerTask: TimerTask = object : TimerTask() {
            override fun run() {
                finish()
            }
        }
        mRouteFinishTimer = Timer()
        mRouteFinishTimer!!.schedule(timerTask, 10000)
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