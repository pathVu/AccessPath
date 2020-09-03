package com.pathvu.accesspath2020

import android.Manifest
import android.animation.AnimatorSet
import android.animation.ValueAnimator
import android.annotation.SuppressLint
import android.app.Activity
import android.content.*
import android.content.pm.PackageManager
import android.graphics.PorterDuff
import android.location.Location
import android.net.ConnectivityManager
import android.os.*
import android.provider.MediaStore
import android.util.Log
import android.view.GestureDetector
import android.view.GestureDetector.SimpleOnGestureListener
import android.view.MotionEvent
import android.view.View
import android.view.animation.AccelerateDecelerateInterpolator
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import com.android.volley.RequestQueue
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import com.google.android.gms.location.*
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.SupportMapFragment
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.Marker
import com.pathvu.accesspath2020.FetchAddressIntentService.Constant
import com.pathvu.accesspath2020.Util.*
import com.pathvu.accesspath2020.listener.NavigationListener
import kotlinx.android.synthetic.main.activity_main_navigation_home.*
import org.json.JSONObject
import java.io.File
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.HashMap
import kotlin.math.roundToInt

/**
 * This class is the app's main page when the user is logged in.
 * It contains navigation controls for settings, reporting, setting a new path, favorite places,
 * recent places, and destination preview. It also displays an interactive map with sidewalks and
 * optionally transit stops and curb ramps. The headers display basic location information such as
 * current address and weather. The user can close the navigation buttons by clicking on the map,
 * and open using the hamburger button displayed in the middle.
 */
class MainNavigationHome : AppCompatActivity(), OnMapReadyCallback, GoogleMap.OnMarkerClickListener, GoogleMap.OnMapLoadedCallback  {

    private lateinit var map: GoogleMap
    private lateinit var fusedLocationProviderClient: FusedLocationProviderClient
    private lateinit var lastLocation: Location
    private val LOCATION_PERMISSION_REQUEST_CODE = 1
    var mLocationPermissionGranted: Boolean = false
    var buttonsOpened: Boolean = true;
    private val animationDuration = 150
    private var buttonsCloseAnim = ValueAnimator()
    private var buttonsOpenAnim = ValueAnimator()
    private var weatherCloseAnim = ValueAnimator()
    private var weatherOpenAnim = ValueAnimator()
    private var notificationCloseAnim = ValueAnimator()
    private var notificationOpenAnim = ValueAnimator()
    private lateinit var mResultReceiver: AddressResultReceiver

    //Camera Intent Variables
    private val REQUEST_IMAGE_CAPTURE = 1
    private val REQUEST_TAKE_PHOTO = 1
    private var mCurrentPhotoPath: String? = null

    // google map update variables
    private lateinit var locationCallback: LocationCallback
    private lateinit var locationRequest: LocationRequest
    private var locationUpdateState = false
    companion object {
        private const val LOCATION_PERMISSION_REQUEST_CODE = 1
        private const val REQUEST_CHECK_SETTINGS = 2
        val MY_PERMISSIONS_REQUEST_LOCATION = 99
    }

    //UI Element Sizes
    private var oldWeatherLayoutHeight = 0
    private var oldNotificationLayoutHeight = 0
    private var oldButtonLayoutHeight = 0

    private var currentLoc: String = ""
    private var currentLat: Double = 0.0
    private var currentLng: Double = 0.0
    private var locationMap = HashMap<Marker, String>()

    //Network Changes Receiver
    private var mMessageReceiver: NetworkStateReceiver? = null

    //Shared Preferences
    private lateinit var sharedPreferences: SharedPreferences
    private lateinit var editor: SharedPreferences.Editor
    var uacctidInt = 0
    lateinit var queue: RequestQueue


    var mapFrag: SupportMapFragment? = null
    lateinit var mLocationRequest: LocationRequest
    var mLastLocation: Location? = null
    internal var mCurrLocationMarker: Marker? = null
    internal var mFusedLocationClient: FusedLocationProviderClient? = null


    internal var mLocationCallback: LocationCallback = object : LocationCallback() {
        override fun onLocationResult(locationResult: LocationResult) {
            if (locationResult.lastLocation == null) {
                val locationList = locationResult.locations
                if (locationList.isNotEmpty()) {
                    //The last location in the list is the newest
                    val location = locationList.last()
                    mLastLocation = location
                    if (mCurrLocationMarker != null) {
                        mCurrLocationMarker?.remove()
                    }

                    //Place current location marker
                    val latLng = LatLng(location.latitude, location.longitude)
                    currentLat = location.latitude
                    currentLng = location.longitude
                    startIntentService(latLng)
                    getWeather(location.latitude, location.longitude)

                    if (buttonsOpened) {
                        //move map camera
                        map.moveCamera(CameraUpdateFactory.newLatLngZoom(latLng, 18.0F))
                    }
                }
            } else {
                super.onLocationResult(locationResult)
                lastLocation = locationResult.lastLocation
                if (mCurrLocationMarker != null) {
                    mCurrLocationMarker?.remove()
                }
                val latLng = LatLng(lastLocation.latitude, lastLocation.longitude)
                currentLat = lastLocation.latitude
                currentLng = lastLocation.longitude
                startIntentService(latLng)
                getWeather(lastLocation.latitude, lastLocation.longitude)
                if(buttonsOpened) {
                    map.moveCamera(CameraUpdateFactory.newLatLngZoom(LatLng(lastLocation.latitude, lastLocation.longitude), 18.0F))
                }
            }
        }
    }



    @SuppressLint("ClickableViewAccessibility", "RestrictedApi")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_navigation_home)

        mResultReceiver = AddressResultReceiver(Handler())
        queue = Volley.newRequestQueue(this)

        //Shared Preferences
        sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
        editor = sharedPreferences.edit()
        with (editor) {
            putBoolean("soundKey", true)
            commit()
        }
        uacctidInt = sharedPreferences.getInt("uacctid", 0)
        getSettings()

        mFusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
        mapFrag = supportFragmentManager.findFragmentById(R.id.map) as SupportMapFragment?
        mapFrag?.getMapAsync(this)


        circleHamburgerButton.setOnClickListener {
            if (!buttonsOpened) {
                val set = AnimatorSet()
                set.play(buttonsOpenAnim)
                set.play(weatherOpenAnim)
                set.interpolator = AccelerateDecelerateInterpolator()
                set.start()

                circleHamburgerButton.visibility = android.view.View.GONE
                circleSoundButton.visibility = android.view.View.GONE
                circleReportButton.visibility = android.view.View.GONE
                currentLocationButton.visibility = View.GONE
                buttonsOpened = true;
            }
        }

        //Report: Open the camera activity
        circleReportButton.setOnClickListener {
            //Check if the user is a guest account
            if (!sharedPreferences.getBoolean("guestAccountKey", false)
            ) { //If not a guest account, open the camera activity
                dispatchTakePictureIntent()
            } else { //If a guest account, alert that guest accounts cannot report
                val context = applicationContext
                val text: CharSequence = "Reporting is disabled for guest accounts. Please sign up using a non-guest account."
                val duration = Toast.LENGTH_LONG
                val toast = Toast.makeText(context, text, duration)
                toast.show()
            }
        }

        //Sound: Turns the sound on or off
        circleSoundButton.setOnClickListener {
            if (sharedPreferences.getBoolean("soundKey", true)
            ) { //If the user has sound enabled, turn it off
                editor.putBoolean("soundKey", false)
                editor.commit()
                circleSoundButton.background = resources.getDrawable(R.drawable.sound_off_icon)
            } else { //If the user has sound disabled, turn it on
                editor.putBoolean("soundKey", true)
                editor.commit()
                circleSoundButton.background = resources.getDrawable(R.drawable.sound_on_icon)
            }
        }

        mapOverlay.setOnTouchListener { v, event ->
            if (buttonsOpened) {
                val set = AnimatorSet()
                set.play(buttonsCloseAnim)
                set.play(weatherCloseAnim)
                set.interpolator = AccelerateDecelerateInterpolator()
                set.start()
                circleHamburgerButton.visibility = View.VISIBLE
                circleSoundButton.visibility = View.VISIBLE
                circleReportButton.visibility = View.VISIBLE
                currentLocationButton.visibility = View.VISIBLE
                buttonsOpened = false
                //Set the circular sound button drawable to reflect whether the user has sound enabled or not
                if (sharedPreferences.getBoolean("soundKey", false)) {
                    circleSoundButton.background =
                        ContextCompat.getDrawable(applicationContext, R.drawable.sound_on_icon)
                } else {
                    circleSoundButton.background =
                        ContextCompat.getDrawable(applicationContext, R.drawable.sound_off_icon)
                }
            }
            GestureDetector(this@MainNavigationHome, MyGestureListener()).onTouchEvent(event)
        }

        currentLocationButton.setOnClickListener {
            map.moveCamera(CameraUpdateFactory.newLatLngZoom(LatLng(currentLat, currentLng), map.cameraPosition.zoom))
            buttonsOpened = true
        }

        //Sets up the animations for the bottom buttons, weather, and notification banner
        val anims = arrayOf(buttonsCloseAnim, buttonsOpenAnim, weatherCloseAnim, weatherOpenAnim, notificationCloseAnim, notificationOpenAnim)
        for (anim in anims) {
            anim.addUpdateListener { animation ->
                val value = animation.animatedValue as Int
                buttonLayout.layoutParams.height = value
                buttonLayout.requestLayout()
            }
        }
        //Adds the animations to their respective views
        addAnimations()


        //Destination Preview: Takes the user to the destination preview search
        destinationPreviewButton.setOnClickListener {
            MainDestinationPreviewSearch.currentLoc = currentLoc
            MainDestinationPreviewSearch.currentLat = currentLat
            MainDestinationPreviewSearch.currentLng = currentLng
            val i = Intent(this@MainNavigationHome, MainDestinationPreviewSearch::class.java)
            startActivity(i)
        }

        favoritePlacesButton.setOnClickListener {
            MainFavoritesList.currentLoc = currentLoc
            MainFavoritesList.currentLat = currentLat
            MainFavoritesList.currentLng = currentLng
            val i = Intent(this@MainNavigationHome, MainFavoritesList::class.java)
            startActivity(i)
        }

        //Recent Paths: Takes the user to the recent paths page
        recentPathsButton.setOnClickListener {
            MainRecentList.fromAddress = currentLoc
            MainRecentList.fromLat = currentLat
            MainRecentList.fromLng = currentLng
            val i = Intent(this@MainNavigationHome, MainRecentList::class.java)
            startActivity(i)
        }

        //Report: Open the camera activity
        reportButton.setOnClickListener {
            //Check if the user is a guest account
            if (!sharedPreferences.getBoolean("guestAccountKey", false)) { //If not a guest account, open the camera activity
                dispatchTakePictureIntent()
            } else { //If a guest account, alert that guest accounts cannot report
                val context = applicationContext
                val text: CharSequence = "Reporting is disabled for guest accounts. Please sign up using a non-guest account."
                val duration = Toast.LENGTH_LONG
                val toast = Toast.makeText(context, text, duration)
                toast.show()
            }
        }


        //Report: Open the camera activity
        circleReportButton.setOnClickListener {
            //Check if the user is a guest account
            if (!sharedPreferences.getBoolean("guestAccountKey", false)) { //If not a guest account, open the camera activity
                dispatchTakePictureIntent()
            } else { //If a guest account, alert that guest accounts cannot report
                val context = applicationContext
                val text: CharSequence = "Reporting is disabled for guest accounts. Please sign up using a non-guest account."
                val duration = Toast.LENGTH_LONG
                val toast = Toast.makeText(context, text, duration)
                toast.show()
            }
        }


        // Set a new path
        setANewPathButton.setOnClickListener {
            MainSetANewPathMapSearch.currentLoc = currentLoc
            MainSetANewPathMapSearch.currentLat = currentLat
            MainSetANewPathMapSearch.currentLng = currentLng
            startActivity(Intent(this, MainSetANewPathMapSearch::class.java))
        }

        // Setting
        settingsButton.setOnClickListener {
            startActivity(Intent(this, MainSettings::class.java))
        }

        //Dismiss: Dismisses the notification banner
        dismissNotificationButton.setOnClickListener {
            editor.putBoolean("newNotification", false)
            editor.commit()
            val set = AnimatorSet()
            set.play(notificationCloseAnim)
            set.interpolator = AccelerateDecelerateInterpolator()
            set.start()
        }

        loadingBar.indeterminateDrawable.setColorFilter(
            resources.getColor(R.color.button_border),
            PorterDuff.Mode.SRC_IN
        )

        //Set all the views other than the map to not be able to be clicked through
        val blockingViews = arrayOf(headerView, weatherView, currentLocationView, notificationView, buttonView)
        for (view in blockingViews) {
            view.setOnTouchListener { v, event -> true }
        }

        //If the user has closed a notification, don't reopen it unless we send a new one
        //This is done so that they don't have to close it every time this activity opens
        if (sharedPreferences.getBoolean("newNotification", false)) {
            notificationLayout.visibility = View.VISIBLE
        } else {
            notificationLayout.visibility = View.INVISIBLE
        }

        //Listens for network changes and alerts the user if the phone disconnects
        mMessageReceiver = object : NetworkStateReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                val connectivityManager =
                    context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                val networkType =
                    intent.extras?.getInt(ConnectivityManager.EXTRA_NETWORK_TYPE)
                val isWiFi = networkType == ConnectivityManager.TYPE_WIFI
                val isMobile = networkType == ConnectivityManager.TYPE_MOBILE
                val networkInfo = networkType?.let { connectivityManager.getNetworkInfo(it) }
                val isConnected = networkInfo?.isConnected
                var wifiStatus = false
                var mobileStatus = false
                if (isWiFi) {
                    wifiStatus = if (isConnected!!) {
                        Log.i("APP_TAG", "Wi-Fi - CONNECTED")
                        true
                    } else {
                        Log.i("APP_TAG", "Wi-Fi - DISCONNECTED")
                        false
                    }
                } else if (isMobile) {
                    mobileStatus = if (isConnected!!) {
                        Log.i("APP_TAG", "Mobile - CONNECTED")
                        true
                    } else {
                        Log.i("APP_TAG", "Mobile - DISCONNECTED")
                        false
                    }
                } else {
                    if (isConnected!!) {
                        Log.i("APP_TAG", networkInfo.typeName + " - CONNECTED")
                    } else {
                        Log.i("APP_TAG", networkInfo.typeName + " - DISCONNECTED")
                    }
                }
                if (!wifiStatus && !mobileStatus) {
                    openNotification("Disconnected")
                    alertUser()
                }
            }
        }

        //Network checking
        val intentFilter = IntentFilter("android.net.conn.CONNECTIVITY_CHANGE")

        //Register the receiver for the network checks, so that we'll be notified if a change occurs
        this.registerReceiver(mMessageReceiver, intentFilter)

        //Network checks class instance so we can use the methods
        val networkChecks = NetworkChecks(this@MainNavigationHome)

        //Initial network check, only performed once
        //If fails, the user is alerted and onCreate stops executing
        if (!networkChecks.checkForInternet()) {
            openNotification("Disconnected")
            alertUser()
            return
        }

        //Checks server, only performed once
        //If fails, the user is alerted and onCreate stops executing
        networkChecks.checkServerStatus(object : NavigationListener<Boolean?> {
            override fun on(result: Boolean?) {
                if (!result!!) {
                    openNotification("pathVu Servers Unavailable")
                }
            }
        })


    }


    override fun onMapReady(googleMap: GoogleMap) {
        map = googleMap

        map.uiSettings.isZoomControlsEnabled = true
        map.setOnMarkerClickListener(this)
        map.setOnMapLoadedCallback(this)

        mLocationRequest = LocationRequest()
        mLocationRequest.interval = 6000 // 6 seconds interval
        mLocationRequest.fastestInterval = 6000
        mLocationRequest.priority = LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
                //Location Permission already granted
                mFusedLocationClient?.requestLocationUpdates(mLocationRequest, mLocationCallback, Looper.myLooper())
                map.isMyLocationEnabled = true
            } else {
                //Request Location Permission
                checkLocationPermission()
            }
        } else {
            mFusedLocationClient?.requestLocationUpdates(mLocationRequest, mLocationCallback, Looper.myLooper())
            map.isMyLocationEnabled = true
        }
    }



    private fun checkLocationPermission() {
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            // Should we show an explanation?
            if (ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.ACCESS_FINE_LOCATION)) {
                // Show an explanation to the user *asynchronously* -- don't block
                // this thread waiting for the user's response! After the user
                // sees the explanation, try again to request the permission.
                AlertDialog.Builder(this)
                    .setTitle("Location Permission Needed")
                    .setMessage("This app needs the Location permission, please accept to use location functionality")
                    .setPositiveButton(
                        "OK"
                    ) { _, _ ->
                        //Prompt the user once explanation has been shown
                        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION), MY_PERMISSIONS_REQUEST_LOCATION)
                    }
                    .create()
                    .show()
            } else {
                // No explanation needed, we can request the permission.
                ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION), MY_PERMISSIONS_REQUEST_LOCATION)
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        when (requestCode) {
            MY_PERMISSIONS_REQUEST_LOCATION -> {
                // If request is cancelled, the result arrays are empty.
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    // permission was granted, yay! Do the
                    // location-related task you need to do.
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
                    ) {
                        mFusedLocationClient?.requestLocationUpdates(mLocationRequest, mLocationCallback, Looper.myLooper())
                        map.isMyLocationEnabled = true
                    }

                } else {
                    // permission denied, boo! Disable the
                    // functionality that depends on this permission.
                    Toast.makeText(this, "permission denied", Toast.LENGTH_LONG).show()
                }
                return
            }
        }// other 'case' lines to check for other
        // permissions this app might request
    }



    override fun onMapLoaded() {
        showBoundingBox(map)
        map.setOnCameraIdleListener(GoogleMap.OnCameraIdleListener {
            showBoundingBox(map)
        })
    }


    /**
     * Display transit, curb ramp and sidewalk layer on the map
     */
    private fun showBoundingBox(mMap: GoogleMap) {
        if (sharedPreferences.getBoolean("trippingHazardLayer", true)) {
            val hazardMapLayer = HazardLayer(
                StringBuilder(getString(R.string.hazard_layer)),
                map,
                applicationContext,
                resources,
                queue,
                locationMap
            )
            hazardMapLayer.queryAndRender()
            val indoorMapLayer = IndoorLayer(
                StringBuilder(getString(R.string.indoor_layer)),
                map,
                applicationContext,
                resources,
                queue,
                locationMap
            )
            indoorMapLayer.queryAndRender()
            val entranceMapLayer = EntranceLayer(
                StringBuilder(getString(R.string.entrance_layer)),
                map,
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
                map,
                applicationContext,
                queue,
                locationMap
            )
            transitLayer.setupAndRender()
        }
        if (sharedPreferences.getBoolean("curbRampsLayer", true)) {
            val curbRampLayer = CurbRampLayerLayer(
                StringBuilder(getString(R.string.curb_ramps_layer)),
                map,
                applicationContext,
                queue,
                locationMap
            )
            curbRampLayer.setupAndRender()
        }
        val sidewalkLayer = SidewalkLayer(StringBuilder(getString(R.string.sidewalks_layer)), map, applicationContext, queue)
        sidewalkLayer.setupAndRender()
    }


    override fun onMarkerClick(marker: Marker?): Boolean {
        var type = ""
        if(locationMap.containsKey(marker)) {
            type = locationMap[marker].toString()
            val dialog = AccessPathBottomSheetDialog.getInstance(this@MainNavigationHome, R.style.SheetDialog, type, marker)
            dialog.setCanceledOnTouchOutside(false)
            dialog.show()

        }
        return false
    }


    /**
     * Start location search service
     */
    private fun startIntentService(latLng: LatLng) {
        val intent = Intent(this, FetchAddressIntentService::class.java)
        intent.putExtra(FetchAddressIntentService.RECEIVER, mResultReceiver)
        intent.putExtra(FetchAddressIntentService.LATLNG_DATA_EXTRA, latLng)
        startService(intent)
    }



    /**
     * Get current whether
     */
    private fun getWeather(lat: Double, lon: Double){
        val weatherUrl = "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=86297b6d659bc424d98c8805fbc540fd"
        val stringRequest = object : StringRequest(
            Method.GET, weatherUrl,
            Response.Listener<String> { response ->
                val responseString = response.toString()
                checkWeatherResponse(responseString)
            },
            Response.ErrorListener { println("error") })
        {
            //
        }
        queue.add(stringRequest)
    }


    /**
     * Check getting whether response and set the related view
     */
    fun checkWeatherResponse(response: String){
        val userWeather = JSONObject(response)
        val weatherConditions = userWeather.getJSONArray("weather").getJSONObject(0).get("main")
        val weatherTemp = userWeather.getJSONObject("main").get("temp")
        val fTemp = (9.0 / 5.0) * weatherTemp.toString().toDouble() - 459.67;
        val weatherIcon = userWeather.getJSONArray("weather").getJSONObject(0).get("icon")
        setWeather(weatherConditions.toString(), fTemp, weatherIcon.toString())
    }


    override fun onPause() {
        super.onPause()
        unregisterReceiver(mMessageReceiver)
        mFusedLocationClient?.removeLocationUpdates(mLocationCallback)
    }


    public override fun onResume() {
        super.onResume()
        val intentFilter = IntentFilter("android.net.conn.CONNECTIVITY_CHANGE")
        this.registerReceiver(mMessageReceiver, intentFilter)

        if(sharedPreferences.getString("favAlert", "0") == "1") {
            val alert = FavoritePlaceAlert(applicationContext)
            alert.initFavoritePlaceList()
        }
    }


    /**
     * Display current whether condition
     */
    private fun setWeather(weatherConditions: String, temperatureInt: Double, weatherApiIcon: String){
        temperatureText.text = temperatureInt.roundToInt().toString()
        weatherText.text = weatherConditions.toString()
        val iconName = resources.getIdentifier("pv_$weatherApiIcon", "drawable", applicationContext.packageName)
        weatherIcon.setImageResource(iconName)
    }


    /**
     * Show current address on the screen
     */
    private fun displayAddressOutput(address: String) {
        loadingBar.visibility = View.GONE
        addressText.text = address
        currentLoc = address

    }


    /**
     * Receive current address result from Receiver
     */
    inner class AddressResultReceiver(handler: Handler) : ResultReceiver(handler) {
        private lateinit var mAddressOutput: String
        override fun onReceiveResult(resultCode: Int, resultData: Bundle) {
            mAddressOutput = resultData.getString(Constant.RESULT_DATA_KEY).toString();
            if (resultCode == Constant.SUCCESS_RESULT) {
                locationUpdateState = false
                displayAddressOutput(mAddressOutput)
            }
        }
    }


    /**
     * Opens up the camera activity for the reporting process
     * Stores data inside that intent to be pass it along the reporting process
     */
    private fun dispatchTakePictureIntent() {
        val takePictureIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        // Ensure that there's a camera activity to handle the intent
        if (takePictureIntent.resolveActivity(packageManager) != null) { // Create the File where the photo should go
            var photoFile: File? = null
            try {
                photoFile = createImageFile()
            } catch (ex: IOException) { // Error occurred while creating the File
            }
            // Continue only if the File was successfully created
            if (photoFile != null) {
                val photoURI = FileProvider.getUriForFile(
                    this,
                    "$packageName.fileprovider",
                    photoFile
                )
                takePictureIntent.putExtra("latitude", currentLat.toString())
                takePictureIntent.putExtra("longitude", currentLng.toString())
                takePictureIntent.putExtra("address", addressText.text.toString())
                takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI)
                startActivityForResult(takePictureIntent, REQUEST_TAKE_PHOTO)
            }
        }
    }


    /**
     * Creates an image file before storing data into it
     * @throws IOException if the file creation failed
     * @returns image A file for data to be written into
     */
    @Throws(IOException::class)
    private fun createImageFile(): File? { // Create an image file name
        val timeStamp = SimpleDateFormat("yyyyMMdd_HHmmss").format(Date())
        val imageFileName = "JPEG_" + timeStamp + "_"
        val storageDir = getExternalFilesDir(Environment.DIRECTORY_PICTURES)
        val image = File.createTempFile(
            imageFileName,  /* prefix */
            ".jpg",  /* suffix */
            storageDir /* directory */
        )
        // Save a file: path for use with ACTION_VIEW intents
        mCurrentPhotoPath = image.absolutePath
        return image
    }


    /**
     * What happens when the camera activity returns from the reporting process
     * @param requestCode The code of the returning activity
     * @param resultCode  The code of the result (success, failure, etc.)
     * @param data        The data of the returning intent
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_IMAGE_CAPTURE && resultCode == Activity.RESULT_OK) {
            openConfirmActivity()
        } else {
//            println("Result not OK")
        }

        if (requestCode == REQUEST_CHECK_SETTINGS) {
            if (resultCode == Activity.RESULT_OK) {
//                locationUpdateState = true
//                startLocationUpdates()
            }
        }
    }


    /**
     * Opens the report confirmation activity for after a user takes a picture
     * Puts data inside of the intent to pass it along the reporting process
     */
    private fun openConfirmActivity() {
        val i = Intent(this, MainReportConfirmation::class.java)
        i.putExtra("imagePath", mCurrentPhotoPath)
        i.putExtra("latitude", currentLat.toString())
        i.putExtra("longitude", currentLng.toString())
        i.putExtra("address", addressText.text.toString())
        startActivity(i)
    }


    /**
     * This function adds the animations for the bottom buttons, weather bar, and notification banner.
     */
    private fun addAnimations() {
        val buttonsLP = buttonLayout.layoutParams as ConstraintLayout.LayoutParams
        oldButtonLayoutHeight = buttonsLP.height
        buttonsCloseAnim = ValueAnimator.ofInt(oldButtonLayoutHeight, 0).setDuration(animationDuration.toLong())
        buttonsOpenAnim = ValueAnimator.ofInt(0, oldButtonLayoutHeight).setDuration(animationDuration.toLong())
        val weatherLP = weatherLayout.layoutParams as ConstraintLayout.LayoutParams
        oldWeatherLayoutHeight = weatherLP.height
        weatherCloseAnim = ValueAnimator.ofInt(oldWeatherLayoutHeight, 0).setDuration(animationDuration.toLong())
        weatherOpenAnim = ValueAnimator.ofInt(0, oldWeatherLayoutHeight).setDuration(animationDuration.toLong())
        val notificationLP = notificationLayout.layoutParams as ConstraintLayout.LayoutParams
        oldNotificationLayoutHeight = notificationLP.height
        notificationCloseAnim = ValueAnimator.ofInt(oldNotificationLayoutHeight, 0)
            .setDuration(animationDuration.toLong())
        notificationOpenAnim = ValueAnimator.ofInt(0, oldNotificationLayoutHeight)
            .setDuration(animationDuration.toLong())
        val hazardLayerLP = notificationLayout.layoutParams as ConstraintLayout.LayoutParams
        oldNotificationLayoutHeight = notificationLP.height
        notificationCloseAnim = ValueAnimator.ofInt(oldNotificationLayoutHeight, 0)
            .setDuration(animationDuration.toLong())
        notificationOpenAnim = ValueAnimator.ofInt(0, oldNotificationLayoutHeight)
            .setDuration(animationDuration.toLong())
        buttonsCloseAnim.addUpdateListener { animation ->
            val value = animation.animatedValue as Int
            buttonLayout.layoutParams.height = value
            buttonLayout.requestLayout()
        }
        buttonsOpenAnim.addUpdateListener { animation ->
            val value = animation.animatedValue as Int
            buttonLayout.layoutParams.height = value
            buttonLayout.requestLayout()
        }
        weatherCloseAnim.addUpdateListener { animation ->
            val value = animation.animatedValue as Int
            weatherLayout.layoutParams.height = value
            weatherLayout.requestLayout()
        }
        weatherOpenAnim.addUpdateListener { animation ->
            val value = animation.animatedValue as Int
            weatherLayout.layoutParams.height = value
            weatherLayout.requestLayout()
        }
        notificationCloseAnim.addUpdateListener { animation ->
            val value = animation.animatedValue as Int
            notificationLayout.layoutParams.height = value
            notificationLayout.requestLayout()
        }
        notificationOpenAnim.addUpdateListener { animation ->
            val value = animation.animatedValue as Int
            notificationLayout.layoutParams.height = value
            notificationLayout.requestLayout()
        }
    }


    /**
     * Opens up a dialog box with the specified title and message
     */
    private fun alertUser() {
        val builder: AlertDialog.Builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            AlertDialog.Builder(
                this@MainNavigationHome,
                android.R.style.Theme_Material_Dialog_Alert
            )
        } else {
            AlertDialog.Builder(this@MainNavigationHome)
        }
        builder.setTitle("No Internet Connection")
            .setMessage(R.string.no_internet_connection)
            .setPositiveButton(android.R.string.yes,
                DialogInterface.OnClickListener { _, _ ->
                    // continue with delete
                })
            .setIcon(android.R.drawable.ic_dialog_alert)
            .show()
    }


    /**
     * Opens the yellow notification banner with the specified text.
     * @param text The message to present to the user
     */
    private fun openNotification(text: String) {
        //Make the notification visible (will still have a height of 0)
        notificationLayout.visibility = View.VISIBLE

        //Set the notification text
        notificationText.text = text

        //Set the height of the notification with an animation to open it
        val set = AnimatorSet()
        set.play(notificationOpenAnim)
        set.interpolator = AccelerateDecelerateInterpolator()
        set.start()
    }


    /**
     * Get user's current setting
     */
    private fun getSettings() {
//        val queue = Volley.newRequestQueue(this)
        val getSettingUrl = "https://pathvudata.com/api1/api/users/getsettings?/*removed for security purposes*/uacctid=$uacctidInt"
        val stringRequest = object : StringRequest(
            Method.GET, getSettingUrl,
            Response.Listener<String> { response ->
                val responseString = response.toString()
                checkResponse(responseString)
            },
            Response.ErrorListener { println("error") })
        {
            //
        }
        queue.add(stringRequest)
    }


    /**
     * Check getting setting request response
     */
    fun checkResponse(response: String) {
        with(response) {
            when {
                startsWith("{\"ugs001") -> Toast.makeText(applicationContext, "User Account ID not posted", Toast.LENGTH_LONG).show()
                startsWith("{\"ugs002") -> Toast.makeText(applicationContext, "User Account ID not found", Toast.LENGTH_LONG).show()
                startsWith("{\"ugs003") -> Toast.makeText(applicationContext, "User Type not found", Toast.LENGTH_LONG).show()
                else -> {
                    parseJsonRes(response)
                }
            }
        }
    }


    /**
     * Parse setting json result and save it into sharedPreference
     */
    private fun parseJsonRes(response: String) {
        var settingJson = JSONObject(response).getJSONArray("settings")
        var thw = settingJson.getJSONObject(1).getString("1")
        var rsw = settingJson.getJSONObject(2).getString("2")
        var csw = settingJson.getJSONObject(3).getString("3")
        var row = settingJson.getJSONObject(4).getString("4")
        var thwAlert = settingJson.getJSONObject(5).getString("5")
        var rswAlert = settingJson.getJSONObject(6).getString("6")
        var cswAlert = settingJson.getJSONObject(7).getString("7")
        var rowAlert = settingJson.getJSONObject(8).getString("8")
//        println("get settings: $thw $rsw $csw $row $thwAlert $rswAlert $cswAlert $rowAlert")
        editor.putInt("thw", thw.toInt())
        editor.putInt("rsw", rsw.toInt())
        editor.putInt("csw", csw.toInt())
        editor.putInt("row", row.toInt())
        editor.putInt("thalert", thwAlert.toInt())
        editor.putInt("rsalert", rswAlert.toInt())
        editor.putInt("csalert", cswAlert.toInt())
        editor.putInt("roalert", rowAlert.toInt())
        editor.commit()
    }


    /**
     * What's around me?
     */
    fun aroundMe(v: View) {
        var radius = 100
        MainAroundMe.fromLat = currentLat.toString()
        MainAroundMe.fromLng = currentLng.toString()
        MainAroundMe.radius = radius.toString()
        MainAroundMe.fromAddress = currentLoc
        startActivity(Intent(this, MainAroundMe::class.java))
    }


    /**
     * Uses the Android stack to take the user to the previous screen
     */
    fun back(v: View?) {
        onBackPressed()
    }
}


/**
 * Allows elements to be clicked through
 * This is part of the hack that prevents users from controlling the map through other elements.
 */
internal class MyGestureListener : SimpleOnGestureListener() {
    override fun onDown(event: MotionEvent): Boolean {
//        Log.d("TAG", "onDown: ")
        return false
    }

    override fun onSingleTapConfirmed(e: MotionEvent): Boolean {
//        Log.i("TAG", "onSingleTapConfirmed: ")
        return false
    }

    override fun onLongPress(e: MotionEvent) {
//        Log.i("TAG", "onLongPress: ")
    }

    override fun onDoubleTap(e: MotionEvent): Boolean {
//        Log.i("TAG", "onDoubleTap: ")
        return false
    }

    override fun onScroll(
        e1: MotionEvent, e2: MotionEvent,
        distanceX: Float, distanceY: Float
    ): Boolean {
//        Log.i("TAG", "onScroll: ")
        return false
    }

    override fun onFling(
        event1: MotionEvent, event2: MotionEvent,
        velocityX: Float, velocityY: Float
    ): Boolean {
//        Log.d("TAG", "onFling: ")
        return false
    }
}
