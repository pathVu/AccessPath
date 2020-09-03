package com.pathvu.accesspath2020

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import kotlinx.android.synthetic.main.activity_main_settings_terms.*

/**
 * This activity displays the full terms and conditions of the app.
 */
class MainSettingsTerms : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_settings_terms)
        termsText.text = applicationContext.resources.getString(R.string.toa)
    }

    /**
     * Use Android's stack to take user to the previous screen.
     */
    fun back(v: View?) {
        onBackPressed()
    }
}