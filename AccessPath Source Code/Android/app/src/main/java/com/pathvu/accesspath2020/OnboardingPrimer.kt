package com.pathvu.accesspath2020

import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity

/**
 * This is the first screen the user will see if they are signed out. They have the option to either
 * begin the onboarding process to sign up for an account or log in if they already have one. If the
 * user is already signed in, they will be taken to the main navigation page.
 */
class OnboardingPrimer : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_onboarding_primer)

        val sharedPref : SharedPreferences = this.getSharedPreferences("pathVuPrefs", 0)
        if (sharedPref.contains(getString(R.string.uacctid_key))){
            val i = Intent(this, MainNavigationHome::class.java)
            startActivity(i)
            finish()
        }

    }


    /**
     * (Function called from XML)
     * Take the user to the terms of agreement screen
     */
    fun screen2(v: View?) {
        val i = Intent(this, OnboardingTerms::class.java)
        startActivity(i)
    }


    /**
     * (Function called from XML)
     * Take the user to the sign in options screen
     */
    fun SignIn(v: View?) {
        val i = Intent(this, OnboardingSignInOptions::class.java)
        startActivity(i)
    }
}
