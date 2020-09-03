package com.pathvu.accesspath2020

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import kotlinx.android.synthetic.main.activity_onboarding_terms.*
import kotlinx.android.synthetic.main.activity_onboarding_terms_extended.*
import java.io.BufferedReader
import java.io.IOException
import java.io.InputStreamReader


class OnboardingTermsExtended : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_onboarding_terms_extended)

        val toa = application.assets.open("toa.txt").bufferedReader().use { it.readText() }
        termsText.text = toa
    }


    /**
     * Continue to create a new account
     */
    fun screen4(v: View?) {
        val i = Intent(this, OnboardingCreateNewAccount::class.java)
        startActivity(i)
    }


    /**
     * Close the app
     */
    fun closeApp(v: View?) {
        finishAffinity()
    }


    /**
     * Go back to the last interface
     */
    fun back(v: View?) {
        onBackPressed()
    }
}
