package com.pathvu.accesspath2020

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import com.google.gson.Gson
import kotlinx.android.synthetic.main.activity_favorite_alerts.*

/**
 * This activity sets the favorite alert
 */
class MainSettingsFavoriteAlerts : AppCompatActivity() {

    //Shared Preferences
    private lateinit var prefs: SharedPreferences
    private lateinit var editor: SharedPreferences.Editor
    private val currentKey: String = "favoritesAlert"
    private var mAlert: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_favorite_alerts)

        turnOnButton.setOnClickListener{ v -> onClickButton(v) }
        turnOffButton.setOnClickListener{ v -> onClickButton(v) }
        setButton.setOnClickListener{ v -> onClickButton(v) }
        cancelButton.setOnClickListener{ v -> onClickButton(v) }

        prefs = getSharedPreferences("pathVuPrefs", Context.MODE_PRIVATE)
        editor = prefs.edit()

        mAlert = prefs.getString(currentKey, "0")

        recolor()
    }


    private fun recolor() {
        if (mAlert == "1") {
            turnOnButton.background = resources.getDrawable(R.drawable.setting_button_selected)
            turnOnCheck.visibility = View.VISIBLE
            turnOffButton.background = resources.getDrawable(R.drawable.setting_button_blue)
            turnOffCheck.visibility = View.INVISIBLE
            //We'll figure out border color later...
        } else if (mAlert == "0") {
            turnOnButton.background = resources.getDrawable(R.drawable.setting_button_blue)
            turnOnCheck.visibility = View.INVISIBLE
            turnOffButton.background = resources.getDrawable(R.drawable.setting_button_selected)
            turnOffCheck.visibility = View.VISIBLE
            //We'll figure out border color later...
        }
    }


    private fun onClickButton(v: View) {
        when (v.id) {
            R.id.turnOnButton -> {
                mAlert = "1"
                recolor()
            }
            R.id.turnOffButton -> {
                mAlert = "0"
                recolor()
            }
            R.id.setButton -> {
                editor.putString(currentKey, mAlert)
                editor.commit()
                finish()
            }
            R.id.cancelButton -> onBackPressed()
        }
    }


    /**
     * (Function called from XML)
     * Return to the obstruction list
     */
    fun screen9(v: View?) {
        setResult(Activity.RESULT_OK, Intent().putExtra(currentKey, mAlert))
        finish()
    }


    /**
     * Uses the Android stack to take the user to the previous screen
     */
    fun back(v: View?) {
        onBackPressed()
    }
}