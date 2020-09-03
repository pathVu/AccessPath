package com.pathvu.accesspath2020

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.speech.tts.TextToSpeech.OnInitListener
import android.view.View
import android.view.View.OnFocusChangeListener
import android.widget.AdapterView
import androidx.appcompat.app.AppCompatActivity
import com.pathvu.accesspath2020.Adapter.PlacesAutoCompleteAdapter
import com.pathvu.accesspath2020.listener.OnPlacesDetailsListener
import com.pathvu.accesspath2020.model.Place
import com.pathvu.accesspath2020.model.PlaceAPI
import com.pathvu.accesspath2020.model.PlaceDetails
import kotlinx.android.synthetic.main.activity_main_destination_preview_search.*
import java.util.*

/**
 * This class allows the user to search for a location for the purpose of previewing a route from
 * their current location. The search box will provide suggestions (max 2) based on the user's
 * current query. The user can click on a suggestion and it's text will be put into the search box.
 * When the user clicks the Preview My Destination button, the text from inside the search box is
 * passed to the destination preview map activity, and will be reverse geocoded there.
 */
class MainDestinationPreviewSearch : AppCompatActivity() {

    //Logging Tag
    private val TAG = MainDestinationPreviewSearch::class.java.simpleName

    private lateinit var mTts: TextToSpeech
    private var fromLat = ""
    private var fromLng = ""
    private var toLat = ""
    private var toLng = ""
    var destAddress = ""
    var fromAddress = ""
    private val placesApi = PlaceAPI.Builder()
        .apiKey(/*removed for security purposes*/)
        .build(this)

    companion object{
        lateinit var currentLoc: String
        var currentLat: Double = 0.0
        var currentLng: Double = 0.0
    }


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_destination_preview_search)

        readDestinationHeader()

        // Setup source and destination location search view
        setupCurrentLocSearchView()
        setupDestinationLocSearchView()

        // Set the current location as default
        mAddressSearchView.setText(currentLoc)
        fromLat = currentLat.toString()
        fromLng = currentLng.toString()

        //Search: Take the user to the destination preview map
        searchButton.setOnClickListener(View.OnClickListener {
            val i = Intent(this@MainDestinationPreviewSearch, MainDestinationPreviewMap::class.java)
            MainDestinationPreviewMap.fromLat = fromLat
            MainDestinationPreviewMap.fromLng = fromLng
            MainDestinationPreviewMap.toLat = toLat
            MainDestinationPreviewMap.toLng = toLng
            MainDestinationPreviewMap.destAddress = destAddress
            MainDestinationPreviewMap.fromAddress = currentLoc
            startActivity(i)
        })

        //Cancel: Take the user to navigation home
        cancelButton.setOnClickListener(View.OnClickListener {
            val i = Intent(this@MainDestinationPreviewSearch, MainNavigationHome::class.java)
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
                OnInitListener { status ->
                    if (status != TextToSpeech.ERROR) {
                        mTts.language = Locale.US
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                            mTts.speak(bigMessage.text.toString(),TextToSpeech.QUEUE_FLUSH,null,null);
                        } else {
                            mTts.speak(bigMessage.text.toString(), TextToSpeech.QUEUE_FLUSH, null);
                        }
                    }
                })
        }
    }


    /**
     * Autocomplete source location search view
     */
    private fun setupCurrentLocSearchView() {
        //Prevent auto-focusing when activity opens
        //When focused, put a thick border on the text box.
        mAddressSearchView.onFocusChangeListener = OnFocusChangeListener { v, hasFocus ->
            if (hasFocus) {
                addressLL.setBackgroundResource(R.drawable.text_input_focused)
            } else {
                addressLL.setBackgroundResource(R.drawable.text_input_background)
            }
        }

        mAddressSearchView.setAdapter(PlacesAutoCompleteAdapter(this, placesApi))
        mAddressSearchView.onItemClickListener =
            AdapterView.OnItemClickListener { parent, _, position, _ ->
                val place = parent.getItemAtPosition(position) as Place
                mAddressSearchView.setText(place.description)
                fromAddress = place.description
                currentLoc = fromAddress
                getPlaceDetailsFrom(place.id)
            }

        // Clear button handling
        addressClear.setOnClickListener {
            mAddressSearchView.setText("")
            val prefs = getSharedPreferences("pathVuPrefs", Context.MODE_PRIVATE)
            if (prefs.getBoolean("soundKey", true)) {
                mTts = TextToSpeech(applicationContext,
                    OnInitListener { status ->
                        if (status != TextToSpeech.ERROR) {
                            mTts.language = Locale.US
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                                mTts.speak("Clear", TextToSpeech.QUEUE_FLUSH,null,null);
                            } else {
                                mTts.speak("Clear", TextToSpeech.QUEUE_FLUSH, null);
                            }
                        }
                    })
            }
        }
    }


    /**
     * Get place detail
     */
    private fun getPlaceDetailsFrom(placeId: String) {
        placesApi.fetchPlaceDetails(placeId, object :
            OnPlacesDetailsListener {
            override fun onError(errorMessage: String) {
                println("error message: $errorMessage")
            }
            override fun onPlaceDetailsFetched(placeDetails: PlaceDetails) {
                setupParaFrom(placeDetails)
            }
        })
    }


    /**
     * Get source place geo information from place details
     */
    private fun setupParaFrom(placeDetails: PlaceDetails) {
        fromLat = placeDetails.lat.toString()
        fromLng = placeDetails.lng.toString()
    }


    /**
     * Autocomplete destination search view
     */
    private fun setupDestinationLocSearchView(){
        //When focused, put a thick border on the text box.
        destAddSearchView.onFocusChangeListener =
            OnFocusChangeListener { v, hasFocus ->
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
                    OnInitListener { status ->
                        if (status != TextToSpeech.ERROR) {
                            mTts.language = Locale.US
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                                mTts.speak("Clear", TextToSpeech.QUEUE_FLUSH,null,null);
                            } else {
                                mTts.speak("Clear", TextToSpeech.QUEUE_FLUSH, null);
                            }
                        }
                    })
            }
        }
    }


    /**
     * Get destination place detail
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