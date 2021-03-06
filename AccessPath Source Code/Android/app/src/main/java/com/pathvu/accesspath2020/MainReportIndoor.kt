package com.pathvu.accesspath2020

import android.content.Intent
import android.os.Bundle
import android.os.PersistableBundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import kotlinx.android.synthetic.main.activity_main_report_submit_indoor.*

/**
 * This activity allows the user to choose the indoor report options
 */
class MainReportIndoor : AppCompatActivity() {

    var ramp: Int = 0
    var rrsteps: Int = 0
    var rtid: String = ""
    var brialle: Int = 0
    var space: Int = 0

    private var currentPhotoPath: String? = null
    var latitude: String? = null
    var longitude: String? = null
    var address: String? = null
    var type: Int = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_report_submit_indoor)

        if (!switch1.isPressed) {
            switch1.setThumbResource(R.drawable.sw_idle)
        }
        switch1.setOnClickListener {
            if (switch1.isPressed)
                switch1.setThumbResource(R.drawable.sw_thumb)
            if (switch1.isChecked) {
                if (rtid == "")
                    rtid = "1"
                else
                    rtid += ",1"
            } else {
                //
            }
        }

        if (!switch2.isPressed) {
            switch2.setThumbResource(R.drawable.sw_idle)
        }
        switch2.setOnClickListener {
            if (switch2.isPressed)
                switch2.setThumbResource(R.drawable.sw_thumb)
            if (switch2.isChecked) {
                if (rtid == "")
                    rtid = "2"
                else
                    rtid += ",2"
            } else {
                //
            }
        }

        if (!switch3.isPressed) {
            switch3.setThumbResource(R.drawable.sw_idle)
        }
        switch3.setOnClickListener {
            if (switch3.isPressed)
                switch3.setThumbResource(R.drawable.sw_thumb)
            if (switch3.isChecked) {
                if (rtid == "")
                    rtid = "3"
                else
                    rtid += ",3"
            } else {
                //
            }
        }

        if (!switch4.isPressed) {
            switch4.setThumbResource(R.drawable.sw_idle)
        }
        switch4.setOnClickListener {
            if (switch4.isPressed)
                switch4.setThumbResource(R.drawable.sw_thumb)
            if (switch4.isChecked) {
                if (rtid == "")
                    rtid = "4"
                else
                    rtid += ",4"
            } else {
                //
            }
        }

        if (!switch5.isPressed) { switch5.setThumbResource(R.drawable.sw_idle) }
        switch5.setOnClickListener {
            if (switch5.isPressed)
                switch5.setThumbResource(R.drawable.sw_thumb)
            ramp = if (switch5.isChecked) { 1 } else { 0 }
        }

        if (!switch6.isPressed) { switch6.setThumbResource(R.drawable.sw_idle) }
        switch6.setOnClickListener {
            if (switch6.isPressed)
                switch6.setThumbResource(R.drawable.sw_thumb)
            brialle = if (switch6.isChecked) { 1 } else { 0 }
        }

        if (!switch7.isPressed) { switch7.setThumbResource(R.drawable.sw_idle) }
        switch7.setOnClickListener {
            if (switch7.isPressed)
                switch7.setThumbResource(R.drawable.sw_thumb)
            space = if (switch7.isChecked) { 1 } else { 0 }
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
            zeroStep.id -> rrsteps = 0
            oneStep.id -> rrsteps = 1
            twoStep.id -> rrsteps = 2
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
        i.putExtra("ramp", ramp)
        i.putExtra("steps", rrsteps)
        i.putExtra("space", space)
        i.putExtra("braille", brialle)
        i.putExtra("rtid", rtid)
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