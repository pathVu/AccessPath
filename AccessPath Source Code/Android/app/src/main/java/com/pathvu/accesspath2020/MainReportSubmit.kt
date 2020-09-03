package com.pathvu.accesspath2020

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Looper
import android.speech.tts.TextToSpeech
import android.util.Base64
import android.util.Log
import android.view.View
import android.widget.AdapterView
import android.widget.Toast
import androidx.annotation.RequiresApi
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import com.android.volley.RequestQueue
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import com.google.android.gms.common.api.Status
import com.google.android.gms.location.*
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.SupportMapFragment
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.Marker
import com.google.android.gms.maps.model.MarkerOptions
import com.google.android.libraries.places.api.Places
import com.google.android.libraries.places.api.net.PlacesClient
import com.google.android.libraries.places.widget.AutocompleteSupportFragment
import com.pathvu.accesspath2020.model.Place
//import com.google.android.libraries.places.api.model.Place
import com.google.android.libraries.places.widget.listener.PlaceSelectionListener
import com.pathvu.accesspath2020.Adapter.PlacesAutoCompleteAdapter
import com.pathvu.accesspath2020.listener.OnPlacesDetailsListener
import com.pathvu.accesspath2020.model.PlaceAPI
import com.pathvu.accesspath2020.model.PlaceDetails
import kotlinx.android.synthetic.main.activity_main_report_submit.*
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.IOException
import java.util.*


/**
 * This class is the final page of the reporting process. The user gets one last look at their image
 * and a map displays the location of the obstruction. If all the info is correct, they submit it
 * to the server.
 */
class MainReportSubmit : AppCompatActivity(), LocationListener, OnMapReadyCallback, GoogleMap.OnMarkerClickListener, GoogleMap.OnMapLoadedCallback, GoogleMap.OnMarkerDragListener {

    private val TAG = "MainReportSubmit"

    private lateinit var mMap: GoogleMap
    private var locationManager: LocationManager? = null
    private val MIN_TIME: Long = 0   // 400
    private val MIN_DISTANCE = 0f   // 1000f

    private lateinit var fusedLocationClient: FusedLocationProviderClient
    internal lateinit var mLocationRequest: LocationRequest
    private val FASTEST_INTERVAL: Long = 1000
    private val INTERVAL: Long = 2000
    private lateinit var currentLoc: LatLng
    var currentMarker: Marker? = null
    var uacctidInt = 0
    lateinit var googleID: String
    private val placesApi = PlaceAPI.Builder()
        .apiKey(/*removed for security purposes*/)
        .build(this)

    // passed variables
    var ctyid = 0
    var latitude: String = ""
    var longitude: String = ""
    var address: String = ""
    var currentPhotoPath: String = ""
    var description: String? = null
    private lateinit var mTts: TextToSpeech
    private var imageData: ByteArray? = null
    lateinit var markerOptions: MarkerOptions
    var textLocation: Boolean = false
    lateinit var queue: RequestQueue

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_report_submit)

        //Shared Preferences
        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
        var editor = sharedPreferences.edit()
        uacctidInt = sharedPreferences.getInt("uacctid", 0)

        queue = Volley.newRequestQueue(this)

        setupCurrentLocSearchView()


        // Create the location request to start receiving updates
        mLocationRequest = LocationRequest()
        mLocationRequest.priority = LocationRequest.PRIORITY_HIGH_ACCURACY
        mLocationRequest.interval = INTERVAL
        mLocationRequest.fastestInterval = FASTEST_INTERVAL

        // Create LocationSettingsRequest object using location request
        val builder = LocationSettingsRequest.Builder()
        builder.addLocationRequest(mLocationRequest)
        val locationSettingsRequest = builder.build()

        val settingsClient = LocationServices.getSettingsClient(this)
        settingsClient.checkLocationSettings(locationSettingsRequest)

        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
        val mapFragment = supportFragmentManager.findFragmentById(R.id.mapView) as SupportMapFragment
        mapFragment.getMapAsync(this)
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return
        }
        fusedLocationClient.requestLocationUpdates(mLocationRequest, mLocationCallback,
            Looper.myLooper())


        //Get the passed variables from the intent bundle
        val bundle = intent.extras
        currentPhotoPath = bundle?.getString("imagePath").toString()
        latitude = bundle?.getString("latitude").toString()
        if (bundle != null) {
            longitude = bundle.getString("longitude").toString()
        }
        if (bundle != null) {
            address = bundle.getString("address").toString()
        }
        if (bundle != null) {
            ctyid = bundle.getInt("type")
        }
        description = "test description"

        cancelButton.setOnClickListener { startActivity(Intent(this, MainNavigationHome::class.java)) }

        submitButton.setOnClickListener {
            if (uacctidInt != 0) {
                progress.visibility = View.VISIBLE
                when(ctyid) {
                    0 -> println("No obstruction type have passed")
                    6 -> uploadImage()
                    7 -> submitIndoor()
                    else -> submitHazards()
                }
            }
        }
    }


    override fun onMapReady(googleMap: GoogleMap) {
        mMap = googleMap

        currentLoc = LatLng(latitude.toDouble(), longitude.toDouble())
        placeMarkerOnMap(currentLoc)
        mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(currentLoc, 18.0f))

        mMap.uiSettings.isZoomControlsEnabled = true
        mMap.setOnMarkerClickListener(this)
        mMap.setOnMapLoadedCallback(this)
        mMap.setOnMarkerDragListener(onMarkerDragListener)
    }


    private fun placeMarkerOnMap(location: LatLng) {
        currentMarker?.remove()
        markerOptions = MarkerOptions().position(location).draggable(true)
//        markerOptions.icon(BitmapDescriptorFactory.fromBitmap(BitmapFactory.decodeResource(resources, R.mipmap.current_location_marker)))

        currentMarker = mMap.addMarker(markerOptions)
        if(textLocation) {
            mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(LatLng(latitude.toDouble(), longitude.toDouble()), mMap.cameraPosition.zoom))
            textLocation = false
        }
    }


    override fun onMapLoaded() {
        mMap.setOnCameraIdleListener(GoogleMap.OnCameraIdleListener {
            //placeMarkerOnMap(currentLoc)
        })

    }


    /**
     * Autocomplete location search view
     */
    private fun setupCurrentLocSearchView() {
        //Prevent auto-focusing when activity opens
        //When focused, put a thick border on the text box.
        mAddressSearchView.onFocusChangeListener = View.OnFocusChangeListener { v, hasFocus ->
            if (hasFocus) {
                addressLL.setBackgroundResource(R.drawable.text_input_focused)
            } else {
                addressLL.setBackgroundResource(R.drawable.text_input_background)
            }
        }

        mAddressSearchView.setAdapter(PlacesAutoCompleteAdapter(this, placesApi))
        mAddressSearchView.onItemClickListener = AdapterView.OnItemClickListener { parent, _, position, _ ->
                val place = parent.getItemAtPosition(position) as Place
                mAddressSearchView.setText(place.description)
                address = place.description
                placesApi.fetchPlaceDetails(place.id, object : OnPlacesDetailsListener {
                    override fun onError(errorMessage: String) {
                        println("error message: $errorMessage")
                    }
                    override fun onPlaceDetailsFetched(placeDetails: PlaceDetails) {
                        latitude = placeDetails.lat.toString()
                        longitude = placeDetails.lng.toString()
                        googleID = placeDetails.placeId
                        println("GOOGLEID " +googleID)
                        currentLoc = LatLng(latitude.toDouble(), longitude.toDouble())
                        textLocation = true
                    }
                })
            }

        // Clear button handling
        addressClear.setOnClickListener {
            mAddressSearchView.setText("")
            val prefs = getSharedPreferences("pathVuPrefs", Context.MODE_PRIVATE)
            if (prefs.getBoolean("soundKey", true)) {
                mTts = TextToSpeech(applicationContext,
                    TextToSpeech.OnInitListener { status ->
                        if (status != TextToSpeech.ERROR) {
                            mTts.language = Locale.US
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                                mTts.speak("Clear", TextToSpeech.QUEUE_FLUSH, null, null);
                            } else {
                                mTts.speak("Clear", TextToSpeech.QUEUE_FLUSH, null);
                            }
                        }
                    })
            }
        }
    }



    /**
     * Send an adding entrance report to the server
     */
    private fun uploadImage() {
        val bundle = intent.extras
        val ramp = bundle?.getInt("ramp")
        val steps = bundle?.getInt("steps")
        val autoDoor = bundle?.getInt("autoDoor")
        createImageData(Uri.fromFile(File(currentPhotoPath)))
        imageData?: return
        val splitPath = currentPhotoPath.split("/")
        val imageName = splitPath[splitPath.size - 1]
        println("IMGNAME " + imageName)
        /*val addEntranceUrl = "https://pathvudata.com/api1/api/locations/entrances/add"
        println("GOOGLEID2 " +googleID)
        val stringRequest = object : VolleyFileUploadRequest(
            Method., addEntranceUrl,
            Response.Listener { response ->
                println("php response entrance ${String(response.data)}")      // "added" but not showing
                val responseString = String(response.data)
                println(responseString)
                checkEntranceResponse(responseString)
            },
            Response.ErrorListener { println("error") })
        {
            override fun getByteData(): MutableMap<String, FileDataPart> {
                var params = HashMap<String, FileDataPart>()
                params["eimg"] = FileDataPart(imageName, imageData!!, "jpg")
                return params
            }
            override fun getParams(): MutableMap<String, String> {
                val entranceParams = HashMap<String, String>()
                entranceParams["uacctid"] = uacctidInt.toString()
                entranceParams["egoogleid"] = googleID
                entranceParams["elat"] = latitude
                entranceParams["elon"] = longitude
                entranceParams["eaddress"] = address
                entranceParams["aeramp"] = ramp.toString()
                entranceParams["aesteps"] = steps.toString()
                entranceParams["eoautodoor"] = autoDoor.toString()
                return entranceParams
            }
        }*/
        val addEntranceUrl = "https://pathvudata.com/api1/api/locations/entrances/add_android.php/*removed for security purposes*/"
        val bm: Bitmap = BitmapFactory.decodeFile(currentPhotoPath)
        val baos: ByteArrayOutputStream = ByteArrayOutputStream()
        bm.compress(Bitmap.CompressFormat.JPEG, 100, baos)
        val b = baos.toByteArray()
        val encodedImage : String = Base64.encodeToString(b, Base64.DEFAULT)
        val stringRequest = object : StringRequest(
            Method.POST, addEntranceUrl,
            Response.Listener<String> { response ->
                println("php response entrance $response")      // "added" but not showing
                val responseString = response
                println(responseString)
                checkEntranceResponse(responseString)
            },
            Response.ErrorListener { println("error") })
        {override fun getParams(): MutableMap<String, String> {
            val entranceParams = HashMap<String, String>()
            entranceParams["uacctid"] = uacctidInt.toString()
            entranceParams["egoogleid"] = googleID
            entranceParams["elat"] = latitude
            entranceParams["elon"] = longitude
            entranceParams["eaddress"] = address
            entranceParams["eimg"] = encodedImage
            entranceParams["eimgname"] = imageName
            entranceParams["aeramp"] = ramp.toString()
            entranceParams["aesteps"] = steps.toString()
            entranceParams["eoautodoor"] = autoDoor.toString()
            return entranceParams
        }}
        queue.add(stringRequest)
    }


    /**
     * Convert image url to byte array for multipart request
     */
    @Throws(IOException::class)
    private fun createImageData(uri: Uri) {
        val inputStream = contentResolver.openInputStream(uri)
        inputStream?.buffered()?.use {
            imageData = it.readBytes()
        }
    }


    /**
     * Check adding entrance request response
     */
    private fun checkEntranceResponse(response: String) {
        with(response) {
            startActivity(Intent(this@MainReportSubmit, MainNavigationHome::class.java))
        }
    }


    @RequiresApi(Build.VERSION_CODES.O)
    private fun getImageFileString(bmp: Bitmap): String {
        val baos = ByteArrayOutputStream()
        bmp.compress(Bitmap.CompressFormat.JPEG, 100, baos)
        val imageBytes = baos.toByteArray()
        return Base64.encodeToString(imageBytes, Base64.DEFAULT)
    }


    /**
     * Send an adding indoor report to the server
     */
    @RequiresApi(Build.VERSION_CODES.O)
    private fun submitIndoor() {
        val bundle = intent.extras
        val ramp = bundle?.getInt("ramp")
        val rrsteps = bundle?.getInt("steps")
        val space = bundle?.getInt("space")
        val braille = bundle?.getInt("braille")
        val rtid = bundle?.getString("rtid")
        createImageData(Uri.fromFile(File(currentPhotoPath)))
        imageData?: return
        val splitPath = currentPhotoPath.split("/")
        val imageName = splitPath[splitPath.size - 1]

        val addIndoorUrl = "https://pathvudata.com/api1/api/locations/indoor/add_android.php/*removed for security purposes*/"
        val ibm: Bitmap = BitmapFactory.decodeFile(currentPhotoPath)
        val ibaos: ByteArrayOutputStream = ByteArrayOutputStream()
        ibm.compress(Bitmap.CompressFormat.JPEG, 100, ibaos)
        val ib = ibaos.toByteArray()
        val iEncodedImage: String = Base64.encodeToString(ib, Base64.DEFAULT)
        val stringRequest = object : StringRequest(
            Method.POST, addIndoorUrl,
            Response.Listener<String> { response ->
                println("php response indoor $response")            // it is working
                val responseString = response
                checkIndoorResponse(responseString)
            },
            Response.ErrorListener { println("error") })
        {
            /*override fun getByteData(): MutableMap<String, FileDataPart> {
                val params = HashMap<String, FileDataPart>()
                params["iaimg"] = FileDataPart(imageName, imageData!!, "jpeg")
                return params
            }*/
            override fun getParams(): MutableMap<String, String> {
                val indoorParams = HashMap<String, String>()
                indoorParams["uacctid"] = uacctidInt.toString()
                indoorParams["iagoogleid"] = googleID
                indoorParams["ialat"] = latitude
                indoorParams["ialon"] = longitude
                indoorParams["iaaddress"] = address
                indoorParams["iaimg"] = iEncodedImage
                indoorParams["iaimgname"] = imageName
                indoorParams["iosteps"] = rrsteps.toString()
                indoorParams["iaspace"] = space.toString()
                indoorParams["iabraille"] = braille.toString()
                indoorParams["rtid"] = rtid.toString()
                indoorParams["ioramp"] = ramp.toString()
                return indoorParams
            }
        }
        queue.add(stringRequest)
    }


    /**
     * Check adding indoor request response
     */
    private fun checkIndoorResponse(response: String) {
        with(response) {
            startActivity(Intent(this@MainReportSubmit, MainNavigationHome::class.java))
        }
    }


    /**
     * Send an adding hazards report to the server
     */
    @RequiresApi(Build.VERSION_CODES.O)
    private fun submitHazards() {
        createImageData(Uri.fromFile(File(currentPhotoPath)))
        imageData?: return
        val splitPath = currentPhotoPath.split("/")
        val imageName = splitPath[splitPath.size - 1]
        val addHazardsUrl = "https://pathvudata.com/api1/api/locations/hazards/add_android.php/*removed for security purposes*/"
        val hbm: Bitmap = BitmapFactory.decodeFile(currentPhotoPath)
        val hbaos: ByteArrayOutputStream = ByteArrayOutputStream()
        hbm.compress(Bitmap.CompressFormat.JPEG, 100, hbaos)
        val hb = hbaos.toByteArray()
        val hEncodedImage: String = Base64.encodeToString(hb, Base64.DEFAULT)
        val stringRequest = object : StringRequest(
            Method.POST, addHazardsUrl,
            Response.Listener<String> { response ->
                println("php response hazards $response")           // it is working
                val responseString = response
                checkHazardsResponse(responseString)
            },
            Response.ErrorListener { println("error") })
        {
            /*override fun getByteData(): MutableMap<String, FileDataPart> {
                val params = HashMap<String, FileDataPart>()
                params["himg"] = FileDataPart(imageName, imageData!!, "jpeg")
                return params
            }*/
            override fun getParams(): MutableMap<String, String> {
                val hazardsParams = HashMap<String, String>()
                hazardsParams["uacctid"] = uacctidInt.toString()
                hazardsParams["hlat"] = latitude
                hazardsParams["hlon"] = longitude
                hazardsParams["himg"] = hEncodedImage
                hazardsParams["himgname"] = imageName
                hazardsParams["htype"] = ctyid.toString()
                return hazardsParams
            }
        }
        queue.add(stringRequest)
    }


    /**
     * Check adding hazard request response
     */
    private fun checkHazardsResponse(response: String) {
        println("check response: $response")
        with(response) {
            when {
                startsWith("{\"lha001") -> Toast.makeText(applicationContext, "User Account ID not posted", Toast.LENGTH_LONG).show()
                startsWith("{\"lha002") -> Toast.makeText(applicationContext, "Hazard type not posted", Toast.LENGTH_LONG).show()
                startsWith("{\"lha003") -> Toast.makeText(applicationContext, "Latitude not posted", Toast.LENGTH_LONG).show()
                startsWith("{\"lha004") -> Toast.makeText(applicationContext, "Longitude not posted", Toast.LENGTH_LONG).show()
                startsWith("{\"lha005") -> Toast.makeText(applicationContext, "Not an image file", Toast.LENGTH_LONG).show()
                startsWith("{\"lha006") -> Toast.makeText(applicationContext, "Failed to upload", Toast.LENGTH_LONG).show()
                startsWith("{\"lha007") -> Toast.makeText(applicationContext, "No file", Toast.LENGTH_LONG).show()
                else -> {
                    println("success")
                }
            }
        }
        startActivity(Intent(this@MainReportSubmit, MainNavigationHome::class.java))
    }


    /**
     * Get
     */
    private fun getGoogleId(lat: Double, lon: Double){
        val googleKey = getString(R.string.google_maps_key)
        val weatherUrl = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=$lat,$lon&key=$googleKey"
        val stringRequest = object : StringRequest(
            Method.GET, weatherUrl,
            Response.Listener<String> { response ->
                val responseString = response.toString()
                checkGoogleIdRes(responseString)
            },
            Response.ErrorListener { println("error") })
        {
            //
        }
        queue.add(stringRequest)
    }


    private fun checkGoogleIdRes(res: String) {
        val resJSON = JSONObject(res).getJSONArray("results")
        googleID = resJSON.getJSONObject(0).getString("place_id")
        latitude = currentMarker?.position?.latitude.toString()
        longitude = currentMarker?.position?.longitude.toString()
    }


    /**
     * Uses the Android stack to take the user to the previous screen
     */
    fun back(v: View?) {
        onBackPressed()
    }


    private val onMarkerDragListener = object : GoogleMap.OnMarkerDragListener {
        override fun onMarkerDragEnd(p0: Marker?) {
            currentMarker?.position?.latitude?.let { currentMarker?.position?.longitude?.let { it1 ->
                getGoogleId(it,
                    it1
                )
            } }
            mAddressSearchView.setText("")
        }

        override fun onMarkerDragStart(p0: Marker?) {

        }

        override fun onMarkerDrag(p0: Marker?) {

        }
    }

    private val mLocationCallback = object : LocationCallback() {
        override fun onLocationResult(locationResult: LocationResult) {
            // do work here
            locationResult.lastLocation
            onLocationChanged(locationResult.lastLocation)
        }
    }



    override fun onLocationChanged(p0: Location?) {
        if(textLocation) {
            mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(LatLng(latitude.toDouble(), longitude.toDouble()), mMap.cameraPosition.zoom))
            textLocation = false
            placeMarkerOnMap(LatLng(latitude.toDouble(), longitude.toDouble()))
        }

//        placeMarkerOnMap(LatLng(latitude.toDouble(), longitude.toDouble()))
        locationManager?.removeUpdates(this);
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


    override fun onMarkerClick(p0: Marker?): Boolean {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onMarkerDragEnd(p0: Marker?) {
        TODO("Not yet implemented")
    }


    override fun onMarkerDragStart(p0: Marker?) {
        TODO("Not yet implemented")
    }

    override fun onMarkerDrag(p0: Marker?) {
        TODO("Not yet implemented")
    }

}