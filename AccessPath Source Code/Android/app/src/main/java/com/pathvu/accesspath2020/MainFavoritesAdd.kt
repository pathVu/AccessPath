package com.pathvu.accesspath2020

//import com.pathvu.accesspath2020.Adapter.PlaceAutoSuggestAdapter
import android.content.Context
import android.content.Intent
import android.graphics.Rect
import android.os.Bundle
import android.view.MotionEvent
import android.view.View
import android.view.View.OnFocusChangeListener
import android.view.inputmethod.InputMethodManager
import android.widget.AdapterView
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.android.volley.RequestQueue
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import com.google.android.material.snackbar.Snackbar
import com.pathvu.accesspath2020.Adapter.PlacesAutoCompleteAdapter
import com.pathvu.accesspath2020.listener.OnPlacesDetailsListener
import com.pathvu.accesspath2020.model.Place
import com.pathvu.accesspath2020.model.PlaceAPI
import com.pathvu.accesspath2020.model.PlaceDetails
import kotlinx.android.synthetic.main.activity_main_favorites_add.*

/**
 * This activity allows the user to add a favorite place to their account. A search box provides
 * suggestions to allow the user to easily search for a place. A user can also specify a custom name
 * for their favorite place.
 */
class MainFavoritesAdd : AppCompatActivity() {

    //UI Element Sizes
    private var searchLayoutHeight = 0
    private var searchLayoutWidth = 0

    var uacctidInt = 0

    var street = ""
    var city = ""
    var state = ""
    var country = ""
    var zipCode = ""
    var lat = ""
    var lng = ""
    val placesApi = PlaceAPI.Builder()
        .apiKey(/*removed for security purposes*/)
        .build(this)
    lateinit var queue: RequestQueue

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_favorites_add)

        queue = Volley.newRequestQueue(this)

        //UI Element Sizes
        searchLayoutHeight = searchLayout.layoutParams.height
        searchLayoutWidth = searchLayout.layoutParams.width
        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
        uacctidInt = sharedPreferences.getInt("uacctid", 0)

        setupAddressSearchView()

        addFavoriteButton.setOnClickListener {
            val address = mAddressSearchView.text.toString()
            val name = customNameBox.text.toString()
            val accountID: Int = uacctidInt

            if (address.isEmpty()) {
                Snackbar.make(addFavoriteButton, R.string.fav_place_add_error, Snackbar.LENGTH_SHORT).show()
            } else if (name.isEmpty()) {
                Snackbar.make(addFavoriteButton, R.string.fav_place_name_error, Snackbar.LENGTH_SHORT).show()
            } else {
                println("favorites add else: $address")
                addFavorite(accountID, name, address, lat, lng)
            }
        }

        cancelButton.setOnClickListener {
            val i = Intent(this@MainFavoritesAdd, MainNavigationHome::class.java)
            startActivity(i)
        }

        customNameBox.onFocusChangeListener = OnFocusChangeListener { v, hasFocus ->
            if (hasFocus) {
                customNameBox.setBackgroundResource(R.drawable.text_input_focused)
            } else {
                customNameBox.setBackgroundResource(R.drawable.text_input_background)
            }
        }
    }


    /**
     * Add a place as favorite to the server
     */
    private fun addFavorite(uacctid: Int, fName: String, fAddress: String, fLat: String, fLon: String) {
        progress.visibility = View.VISIBLE
        val addUserUrl = "https://pathvudata.com/api1/api/users/addfavorite"
        val stringRequest = object : StringRequest(
            Method.POST, addUserUrl,
            Response.Listener<String> { response ->
                println("php response $response")
                val responseString = response.toString()
                checkResponse(responseString)
            },
            Response.ErrorListener { println("error") })
        {
            override fun getParams(): MutableMap<String, String> {
                val userParams = HashMap<String, String>()
                userParams["uacctid"] = uacctid.toString()
                userParams["fname"] = fName
                userParams["faddress"] = fAddress
                userParams["flat"] = fLat
                userParams["flon"] = fLon
                userParams["apitoken"] = getString(R.string.pathvu_api_key)
                return userParams
            }
        }
        queue.add(stringRequest)
    }


    /**
     * Check adding favorite response
     */
    fun checkResponse(response: String) {
        println("check response $response")
        with(response) {
            when {
                startsWith("{\"uaf001}") -> Toast.makeText(applicationContext, R.string.account_error_contact_pathvu, Toast.LENGTH_LONG).show()
                startsWith("{\"uaf002}") -> Toast.makeText(applicationContext, R.string.account_error_contact_pathvu, Toast.LENGTH_LONG).show()
                startsWith("{\"uaf003}") -> Toast.makeText(applicationContext, "Favorite name not posted", Toast.LENGTH_LONG).show()
                startsWith("{\"uaf004}") -> Toast.makeText(applicationContext, "Favorite address not posted", Toast.LENGTH_LONG).show()
                startsWith("{\"uaf005}") -> Toast.makeText(applicationContext, "Latitude not posted", Toast.LENGTH_LONG).show()
                startsWith("{\"uaf006}") -> Toast.makeText(applicationContext, "Longitude not posted", Toast.LENGTH_LONG).show()
                else -> {
                    progress.visibility = View.GONE
//                    finish()
                    val i = Intent(this@MainFavoritesAdd, MainFavoritesList::class.java)
                    startActivity(i)
                }
            }
        }
    }


    /**
     * Autocomplete address search view
     */
    private fun setupAddressSearchView() {
        //When focused, put a thick border on the text box.
        //TODO: This doesn't work because it doesn't behave like a normal TextView
        mAddressSearchView.onFocusChangeListener = OnFocusChangeListener { v, hasFocus ->
            if (hasFocus) {
                customNameBox.setBackgroundResource(R.drawable.text_input_focused)
            } else {
                customNameBox.setBackgroundResource(R.drawable.text_input_background)
            }
        }

        mAddressSearchView.setAdapter(PlacesAutoCompleteAdapter(this, placesApi))
        mAddressSearchView.onItemClickListener =
            AdapterView.OnItemClickListener { parent, _, position, _ ->
                val place = parent.getItemAtPosition(position) as Place
                mAddressSearchView.setText(place.description)
                getPlaceDetails(place.id)
            }
    }


    /**
     * Fetch place detail
     */
    private fun getPlaceDetails(placeId: String) {
        placesApi.fetchPlaceDetails(placeId, object :
            OnPlacesDetailsListener {
            override fun onError(errorMessage: String) {
                println("error message: $errorMessage")
            }

            override fun onPlaceDetailsFetched(placeDetails: PlaceDetails) {
                setupPara(placeDetails)
            }
        })
    }


    /**
     * Get geo information from place detail
     */
    private fun setupPara(placeDetails: PlaceDetails) {
        val address = placeDetails.address
        lat = placeDetails.lat.toString()
        lng = placeDetails.lng.toString()
    }


    /**
     * If user clicks outside the email window, close it
     */
    override fun dispatchTouchEvent(event: MotionEvent): Boolean {
        if (event.action == MotionEvent.ACTION_DOWN) {
            val v = currentFocus
            if (v is EditText) {
                val outRect = Rect()
                v.getGlobalVisibleRect(outRect)
                if (!outRect.contains(event.rawX.toInt(), event.rawY.toInt())) {
                    v.clearFocus()
                    val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                    imm.hideSoftInputFromWindow(v.getWindowToken(), 0)
                }
            }
        }
        return super.dispatchTouchEvent(event)
    }


    /**
     * Use Android's stack to take user to the previous screen.
     */
    fun back(v: View?) {
        onBackPressed()
    }
}
