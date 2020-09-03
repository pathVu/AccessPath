package com.pathvu.accesspath2020

import android.content.Intent
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Bundle
import android.os.PersistableBundle
import android.view.View
import androidx.annotation.RequiresApi
import androidx.appcompat.app.AppCompatActivity
import kotlinx.android.synthetic.main.activity_main_report_submit_entrance.*

/**
 * This activity allows the user to choose the entrance report options
 */
class MainReportEntrance : AppCompatActivity() {

    var steps: Int = 0
    var ramp: Int = 0
    var autoDoor: Int = 0

    private var currentPhotoPath: String? = null
    var latitude: String? = null
    var longitude: String? = null
    var address: String? = null
    var type: Int = 0

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_report_submit_entrance)

        switch1.isChecked = false
        println(switch1.isPressed)
        if (!switch1.isPressed) {
            switch1.setThumbResource(R.drawable.sw_idle)
        }
        switch1.setOnClickListener {
            if (switch1.isPressed)
                switch1.setThumbResource(R.drawable.sw_thumb)
            autoDoor = if (switch1.isChecked) {
                println("yes")
                1
            } else {
                println("no")
                0
            }
        }

        if (!switch2.isPressed) {
            switch2.setThumbResource(R.drawable.sw_idle)
        }
        switch2.setOnClickListener {
            if (switch2.isPressed)
                switch2.setThumbResource(R.drawable.sw_thumb)
            ramp = if (switch2.isChecked) {
                println("yes")
                1
            } else {
                println("no")
                0
            }
        }

        zeroStep.setOnClickListener { v -> selectedPreset(v) }
        oneStep.setOnClickListener { v -> selectedPreset(v) }
        twoStep.setOnClickListener { v -> selectedPreset(v) }

        submitButton.setOnClickListener { submitOptions() }

        cancelButton.setOnClickListener { startActivity(Intent(this, MainReportCategory::class.java)) }
    }


    private fun selectedPreset(v: View){
        zeroStep.setBackgroundResource(R.drawable.steps_btn_idle)
        oneStep.setBackgroundResource(R.drawable.steps_btn_idle)
        twoStep.setBackgroundResource(R.drawable.steps_btn_idle)
        v.setBackgroundResource(R.drawable.steps_btn_selected)

        when(v.id){
            zeroStep.id -> steps = 0
            oneStep.id -> steps = 1
            twoStep.id -> steps = 2
        }
    }

    /**
     * Pass the report parameter to the next screen
     */
    private fun submitOptions() {
        var i = Intent(this, MainReportSubmit::class.java)
        val bundle = intent.extras
        latitude = bundle?.getString("latitude")
        longitude = bundle?.getString("longitude")
        address = bundle?.getString("address")
        currentPhotoPath = bundle?.getString("imagePath")
        if (bundle != null) {
            type = bundle.getInt("type")
        }
        i.putExtra("autoDoor", autoDoor)
        i.putExtra("ramp", ramp)
        i.putExtra("steps", steps)
        i.putExtra("imagePath", currentPhotoPath)
        i.putExtra("latitude", latitude)
        i.putExtra("longitude", longitude)
        i.putExtra("address", address)
        i.putExtra("type", type)
        startActivity(i)
    }


    /**
     * Uses the Android stack to take the user to the previous screen
     */
    fun back(v: View?) {
        onBackPressed()
    }
}