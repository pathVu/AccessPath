package com.pathvu.accesspath2020

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity

class OnboardingSignInOptions : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_onboarding_sign_in_options)
    }

    /**
     * (Function called from XML)
     * Take the user to the create account screen
     */
    fun createNewAccount(v: View?) {
        val i = Intent(this, OnboardingCreateNewAccount::class.java)
        startActivity(i)
    }

    /**
     * (Function called from XML)
     * Take the user to the email sign in activity
     */
    fun signInEmail(v: View?) {
        val i = Intent(this, OnboardingSignInEmail::class.java)
        startActivity(i)
    }

    /**
     * (Function called from XML)
     * Take the user to the Google sign in activity
     */
    fun googleSignIn(v: View?) {
        val i = Intent(this, OnboardingSignInGoogle::class.java)
        startActivity(i)
    }

    /**
     * (Function called from XML)
     * Take the user to the Facebook sign in activity
     */
    fun facebookSignIn(v: View?) {
        val i = Intent(this, OnboardingSignInFacebook::class.java)
        startActivity(i)
    }

    /**
     * Use Android's stack to take user to the previous screen.
     */
    fun back(v: View?) {
        onBackPressed()
    }

    /**
     * (Function called from XML)
     * Take the user to the guest sign in activity
     */
    fun signInGuest(v: View) {
        val i = Intent(this, OnboardingSignUpGuest::class.java)
        startActivity(i)
    }
}
