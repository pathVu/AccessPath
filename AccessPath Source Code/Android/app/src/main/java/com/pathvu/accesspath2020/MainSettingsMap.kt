package com.pathvu.accesspath2020

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.ImageView
import androidx.appcompat.app.AppCompatActivity
import kotlinx.android.synthetic.main.activity_main_settings_map.*

/**
 * This activity allows the user to change their map settings. Currently, only map layers can be
 * changed.
 */
class MainSettingsMap : AppCompatActivity() {

    //Array of shared preference keys for loops
    private lateinit var keys: Array<String>

    private lateinit var buttons: Array<Button>
    private lateinit var checks: Array<ImageView>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_settings_map)

        val prefs = getSharedPreferences("pathVuPrefs", Context.MODE_PRIVATE)

        //Keys must line up with their respective button and checkmark
        keys = arrayOf<String>(
            "curbRampsLayer",
            "transitStopsLayer",
            "trippingHazardLayer"
        )
        checks = arrayOf(
            findViewById(R.id.curbRampsCheck),
            findViewById(R.id.transitStopsCheck),
            findViewById(R.id.trippingHazardCheck)
        )
        buttons = arrayOf(
            curbRampsButton,
            transitStopsButton,
            trippingHazardButton
        )

        setButtonStyles()

        /* On Click Listeners */
        //Curb Ramps: Turn the curb ramps layer on or off
        curbRampsButton.setOnClickListener(View.OnClickListener {
            if (prefs.getBoolean("curbRampsLayer", true)) {
                //If user has curb ramps turned on, turn them off
                with (prefs.edit()) {
                    putBoolean("curbRampsLayer", false)
                    commit()
                }
            } else {
                //If user has curb ramps turned off, turn them on
                with (prefs.edit()) {
                    putBoolean("curbRampsLayer", true)
                    commit()
                }
            }
            setButtonStyles()
        })

        //Transit Stops: Turn the transit stops layer on or off
        transitStopsButton.setOnClickListener(View.OnClickListener {
            if (prefs.getBoolean("transitStopsLayer", true)) {
                //If user has transit stops turned on, turn them off
                with (prefs.edit()) {
                    putBoolean("transitStopsLayer", false)
                    commit()
                }
            } else {
                //If user has transit stops turned off, turn them on
                with (prefs.edit()) {
                    putBoolean("transitStopsLayer", true)
                    commit()
                }
            }
            setButtonStyles()
        })

        //Tripping Hazards: Turn the tripping hazard layer on or off
        trippingHazardButton.setOnClickListener(View.OnClickListener {
            if (prefs.getBoolean("trippingHazardLayer", true)) {
                //If user has transit stops turned on, turn them off
                with (prefs.edit()) {
                    putBoolean("trippingHazardLayer", false)
                    commit()
                }
            } else {
                //If user has transit stops turned off, turn them on
                with (prefs.edit()) {
                    putBoolean("trippingHazardLayer", true)
                    commit()
                }
            }
            setButtonStyles()
        })
    }


    /**
     * Set the style of the buttons depending on if the user turned the setting on or off
     */
    private fun setButtonStyles() {
        val prefs = getSharedPreferences("pathVuPrefs", Context.MODE_PRIVATE)
        for (i in keys.indices) {
            if (prefs.getBoolean(keys[i], true)) {
                checks[i].visibility = View.VISIBLE
                buttons[i].setBackgroundResource(applicationContext.resources.getIdentifier("setting_button_selected", "drawable", applicationContext.packageName))
            } else {
                checks[i].visibility = View.INVISIBLE
                buttons[i].setBackgroundResource(applicationContext.resources.getIdentifier("setting_button_blue", "drawable", applicationContext.packageName))
            }
        }
    }

    /**
     * Use Android's stack to take user to the previous screen.
     */
    fun back(v: View?) {
        onBackPressed()
//        startActivity(Intent(this, MainSettings::class.java))
    }
}