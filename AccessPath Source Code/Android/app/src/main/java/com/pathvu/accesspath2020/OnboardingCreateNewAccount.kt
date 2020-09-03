package com.pathvu.accesspath2020

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity

/**
 * This activity presents the user with sign up options. They can use Facebook, Google,
 * email/password, or a guest account. Each button will take the user to the respective sign up
 * activity.
 */
class OnboardingCreateNewAccount : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_onboarding_create_new_account)
    }

    fun back(v: View?) {
        onBackPressed()
    }

    fun screen5(v: View){
        val i = Intent(this, OnboardingSignUpEmail::class.java)
        startActivity(i)
    }

    fun signIn(v: View){
        val i = Intent(this, OnboardingSignInOptions::class.java)
        startActivity(i)
    }

    fun fbSignUp(v: View){
        val i = Intent(this, OnboardingSignUpFacebook::class.java)
        startActivity(i)
    }

    fun googleSignUp(v: View){
        val i = Intent(this, OnboardingSignUpGoogle::class.java)
        startActivity(i)
    }

    fun guestSignUp(v: View){
        val i = Intent(this, OnboardingSignUpGuest::class.java)
        startActivity(i)
    }
}
