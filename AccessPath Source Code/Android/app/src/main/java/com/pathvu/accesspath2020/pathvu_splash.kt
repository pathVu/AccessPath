package com.pathvu.accesspath2020

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.os.Handler

class pathvu_splash : AppCompatActivity() {
    private val splashTime:Long = 3000
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_pathvu_splash)

        Handler().postDelayed( {
            runOnUiThread {
                val i = Intent(this, OnboardingPrimer::class.java)
                startActivity(i)
                finish()
            }
        }, splashTime)
    }
}
