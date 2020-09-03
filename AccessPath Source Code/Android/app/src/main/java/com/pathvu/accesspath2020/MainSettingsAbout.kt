package com.pathvu.accesspath2020

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity

/**
 * This is a settings subpage which contains information about the application. The user can
 * open the full terms of agreement from this page.
 */
class MainSettingsAbout : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_settings_about)
    }


    /**
     * (Function called from XML)
     * Take the user to the full terms of agreement page
     */
    fun termsPage(v: View?) {
        val i = Intent(this@MainSettingsAbout, MainSettingsTerms::class.java)
        startActivity(i)
    }

    /**
     * Use Android's stack to take user to the previous screen.
     */
    fun back(v: View?) {
        onBackPressed()
    }
}