package com.pathvu.accesspath2020

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.PersistableBundle
import android.speech.tts.TextToSpeech
import android.view.View
import android.widget.AdapterView
import androidx.appcompat.app.AppCompatActivity
import com.pathvu.accesspath2020.Adapter.PlacesAutoCompleteAdapter
import com.pathvu.accesspath2020.listener.OnPlacesDetailsListener
import com.pathvu.accesspath2020.model.Place
import com.pathvu.accesspath2020.model.PlaceAPI
import com.pathvu.accesspath2020.model.PlaceDetails
import kotlinx.android.synthetic.main.activity_main_destination_preview_search.*
import kotlinx.android.synthetic.main.activity_main_set_a_new_path_search.*
import kotlinx.android.synthetic.main.activity_main_set_a_new_path_search.bigMessage2
import kotlinx.android.synthetic.main.activity_main_set_a_new_path_search.cancelButton
import kotlinx.android.synthetic.main.activity_main_set_a_new_path_search.destAddSearchView
import kotlinx.android.synthetic.main.activity_main_set_a_new_path_search.destAddressClear
import kotlinx.android.synthetic.main.activity_main_set_a_new_path_search.destLL
import kotlinx.android.synthetic.main.activity_main_set_a_new_path_search.mAddressSearchView
import kotlinx.android.synthetic.main.activity_main_set_a_new_path_search.searchButton
import java.util.*

/**
 * This class allows the user to search for a location for the purpose of navigating a route from
 * their current location. The search box will provide suggestions (max 2) based on the user's
 * current query. The user can click on a suggestion and it's text will be put into the search box.
 * When the user clicks the Set Path button, the text from inside the search box is passed to the
 * set a new path map activity, and will be reverse geocoded there.
 */
class MainSetANewPathMapSearch : AppCompatActivity() {

    private val placesApi = PlaceAPI.Builder()
        .apiKey(/*removed for security purposes*/)
        .build(this)
    companion object{
        lateinit var currentLoc: String
        var currentLat: Double = 0.0
        var currentLng: Double = 0.0
    }
    private var toLat = ""
    private var toLng = ""
    var destAddress = ""
    private lateinit var mTts: TextToSpeech

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_set_a_new_path_search)

        mAddressSearchView.setOnClickListener(null)

        readDestinationHeader()

        setupDestinationLocSearchView()

        //Search: Take the user to the set path map view
        searchButton.setOnClickListener(View.OnClickListener {
            val i = Intent(this, MainSetANewPathMap::class.java)
            MainSetANewPathMap.fromLat = currentLat.toString()
            MainSetANewPathMap.fromLng = currentLng.toString()
            MainSetANewPathMap.fromAddress = currentLoc
            MainSetANewPathMap.toLat = toLat
            MainSetANewPathMap.toLng = toLng
            MainSetANewPathMap.destAddress = destAddress
            startActivity(i)
        })

        //Cancel: Take the user to navigation home
        cancelButton.setOnClickListener(View.OnClickListener {
            val i = Intent(this, MainNavigationHome::class.java)
            startActivity(i)
        })
    }


    /**
     * Read search destination
     */
    private fun readDestinationHeader() {
        val prefs = getSharedPreferences("pathVuPrefs", Context.MODE_PRIVATE)
        if (prefs.getBoolean("soundKey", true)) {
            mTts = TextToSpeech(applicationContext,
                TextToSpeech.OnInitListener { status ->
                    if (status != TextToSpeech.ERROR) {
                        mTts.language = Locale.US
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                            mTts.speak(
                                bigMessage2.text.toString(),
                                TextToSpeech.QUEUE_FLUSH, null, null
                            );
                        } else {
                            mTts.speak(bigMessage2.text.toString(), TextToSpeech.QUEUE_FLUSH, null);
                        }
                    }
                })
        }
    }


    /**
     * Autocomplete search destination view through adapter
     */
    private fun setupDestinationLocSearchView(){
        //When focused, put a thick border on the text box.
        destAddSearchView.onFocusChangeListener =
            View.OnFocusChangeListener { v, hasFocus ->
                if (hasFocus) {
                    destLL.setBackgroundResource(R.drawable.text_input_focused)
                } else {
                    destLL.setBackgroundResource(R.drawable.text_input_background)
                }
            }

        destAddSearchView.setAdapter(PlacesAutoCompleteAdapter(this, placesApi))
        destAddSearchView.onItemClickListener =
            AdapterView.OnItemClickListener { parent, _, position, _ ->
                val place = parent.getItemAtPosition(position) as Place
                destAddSearchView.setText(place.description)
                destAddress = place.description
                getPlaceDetailsTo(place.id)
            }

        // Clear button handling
        destAddressClear.setOnClickListener {
            destAddSearchView.setText("")
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
     * Fetch autocomplete place detail
     */
    private fun getPlaceDetailsTo(placeId: String) {
        placesApi.fetchPlaceDetails(placeId, object :
            OnPlacesDetailsListener {
            override fun onError(errorMessage: String) {
                println("error message: $errorMessage")
            }
            override fun onPlaceDetailsFetched(placeDetails: PlaceDetails) {
                setupParaTo(placeDetails)
            }
        })
    }


    /**
     * Get destination geo information from place details
     */
    private fun setupParaTo(placeDetails: PlaceDetails) {
        toLat = placeDetails.lat.toString()
        toLng = placeDetails.lng.toString()
    }


    fun back(v: View?) {
        onBackPressed()
    }
}