package com.pathvu.accesspath2020

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity

/**
 * This activity is the primer/intro screen for the hazard and alert settings.
 */
class OnboardingComfortSettingsPrimer : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_onboarding_comfort_settings_primer)

        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)

        with (sharedPreferences.edit()) {
            putInt("thalert", 0)
            putInt("rsalert", 0)
            putInt("csalert", 0)
            putInt("roalert", 0)
            commit()
        }
    }


    /**
     * Take the user to the obstruction types list
     */
    fun screen8(v: View?) {
        val i = Intent(this, OnboardingProfilePresets::class.java)
        startActivity(i)
    }


    /**
     * Use Android's stack to take user to the previous screen.
     */
    fun back(v: View?) {
        onBackPressed()
    }
}
