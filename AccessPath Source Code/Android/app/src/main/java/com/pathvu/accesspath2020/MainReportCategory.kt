package com.pathvu.accesspath2020

import android.content.Intent
import android.graphics.BitmapFactory
import android.os.Bundle
import android.view.View
import android.view.ViewTreeObserver
import androidx.appcompat.app.AppCompatActivity
import androidx.constraintlayout.widget.ConstraintLayout
import kotlinx.android.synthetic.main.activity_main_report_category.*
import kotlinx.android.synthetic.main.activity_main_report_confirmation.*
import kotlinx.android.synthetic.main.activity_main_report_confirmation.imagePreview
import kotlinx.android.synthetic.main.activity_main_report_confirmation.mainView

/**
 * This activity is part of the obstruction reporting process. It allows the user to select a
 * category for the obstruction are reporting.
 */
class MainReportCategory : AppCompatActivity() {

    //Passed Variables
    var address: String? = null
    var currentPhotoPath: String? = null
    var latitude: String? = null
    var longitude: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_report_category)

        //Get the passed variables from the intent bundle
        val bundle = intent.extras
        currentPhotoPath = bundle?.getString("imagePath")
        latitude = bundle?.getString("latitude")
        longitude = bundle?.getString("longitude")
        address = bundle?.getString("address")

        //Set the image preview picture when the view finishes loading
        val layout = findViewById<View>(R.id.mainView) as ConstraintLayout
        val vto = layout.viewTreeObserver
        vto.addOnGlobalLayoutListener(
            object : ViewTreeObserver.OnGlobalLayoutListener {
                override fun onGlobalLayout() {
                    layout.viewTreeObserver.removeOnGlobalLayoutListener(this);
                    setPic()
                }
            })

        /* On Click Listeners */ //Tripping Hazard: Put hazard ID 1 into intent bundle and go to submission screen
        trippingHazardButton.setOnClickListener(View.OnClickListener { toSubmitScreen(1) })

        //No Sidewalk: Put hazard ID 2 into intent bundle and go to submission screen
        noSidewalkButton.setOnClickListener(View.OnClickListener { toSubmitScreen(2) })

        //No Curb Ramp: Put hazard ID 3 into intent bundle and go to submission screen
        noCurbRampButton.setOnClickListener(View.OnClickListener { toSubmitScreen(3) })

        //Construction: Put hazard ID 4 into intent bundle and go to submission screen
        constructionButton.setOnClickListener(View.OnClickListener { toSubmitScreen(4) })

        //Other: Put hazard ID 5 into intent bundle and go to submission screen
        otherButton.setOnClickListener(View.OnClickListener { toSubmitScreen(5) })

        entranceButton.setOnClickListener {
            val i = Intent(this@MainReportCategory, MainReportEntrance::class.java)
            i.putExtra("imagePath", currentPhotoPath)
            i.putExtra("latitude", latitude)
            i.putExtra("longitude", longitude)
            i.putExtra("address", address)
            i.putExtra("type", 6)
            startActivity(i)
        }

        indoorButton.setOnClickListener {
            val i = Intent(this@MainReportCategory, MainReportIndoor::class.java)
            i.putExtra("imagePath", currentPhotoPath)
            i.putExtra("latitude", latitude)
            i.putExtra("longitude", longitude)
            i.putExtra("address", address)
            i.putExtra("type", 7)
            startActivity(i)
        }
    }


    /**
     * Decodes a bitmap from the currentPhotoPath and puts it into imagePreview
     */
    private fun setPic() { // Get the dimensions of the View
        val targetW = imagePreview.width
        val targetH = imagePreview.height
        // Get the dimensions of the bitmap
        val bmOptions = BitmapFactory.Options()
        bmOptions.inJustDecodeBounds = true
        BitmapFactory.decodeFile(currentPhotoPath, bmOptions)
        val photoW = bmOptions.outWidth
        val photoH = bmOptions.outHeight
        // Determine how much to scale down the image
        val scaleFactor = (photoW / targetW).coerceAtMost(photoH / targetH)
        // Decode the image file into a Bitmap sized to fill the View
        bmOptions.inJustDecodeBounds = false
        bmOptions.inSampleSize = scaleFactor
//        bmOptions.inPurgeable = true
        val image = BitmapFactory.decodeFile(currentPhotoPath)
        imagePreview.setImageBitmap(image)
    }


    /**
     * Puts hazard type ID into the intent and takes the user to the submission screen
     * @param type The type of hazard
     */
    private fun toSubmitScreen(type: Int) {
        val i = Intent(this@MainReportCategory, MainReportSubmit::class.java)
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