package com.pathvu.accesspath2020

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity

class OnboardingTerms : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_onboarding_terms)
    }


    /**
     * View the extended term
     */
    fun screen3(v: View?) {
        val i = Intent(this, OnboardingTermsExtended::class.java)
        startActivity(i)
    }


    /**
     * Continue to create a new account
     */
    fun screen4(v: View?) {
        val i = Intent(this, OnboardingCreateNewAccount::class.java)
        startActivity(i)
    }


    /**
     * Already have an account, continue to login
     */
    fun logIn(v: View?) {
        val i = Intent(this, OnboardingSignInOptions::class.java)
        startActivity(i)
    }
}
