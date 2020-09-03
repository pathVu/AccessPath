package com.pathvu.accesspath2020

import android.app.Activity
import android.content.Intent
import android.graphics.BitmapFactory
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import android.view.View
import android.view.ViewTreeObserver
import androidx.appcompat.app.AppCompatActivity
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.FileProvider
import kotlinx.android.synthetic.main.activity_main_report_confirmation.*
import java.io.File
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*

/**
 * This activity asks the user of the image they took is good or not. If it is good, they move on
 * through the reporting process. If the image is bad, they can retake it.
 */
class MainReportConfirmation : AppCompatActivity() {

    //Passed Variables
    private var currentPhotoPath: String? = null
    var latitude: String? = null
    var longitude: String? = null
    var address: String? = null
    var type: Int = 0

    //Camera Intent Constants
    private val REQUEST_IMAGE_CAPTURE = 1
    private val REQUEST_TAKE_PHOTO = 1

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_report_confirmation)

        //Get the passed variables from the intent bundle

        val bundle = intent.extras
        latitude = bundle?.getString("latitude")
        longitude = bundle?.getString("longitude")
        address = bundle?.getString("address")
        currentPhotoPath = bundle?.getString("imagePath")
        if (bundle != null) {
            type = bundle.getInt("type")
        }
        

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

        /* On Click Listeners */ //Approve: Puts variables into the bundle and takes the user to the category selection screen
        approvePhotoButton.setOnClickListener {
            val i = Intent(this@MainReportConfirmation, MainReportCategory::class.java)
            i.putExtra("imagePath", currentPhotoPath)
            i.putExtra("latitude", latitude)
            i.putExtra("longitude", longitude)
            i.putExtra("address", address)
            i.putExtra("type", type)
            startActivity(i)
        }

        //Retake: Opens the camera activity
        cancelButton.setOnClickListener(View.OnClickListener { dispatchTakePictureIntent() })
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
     * What happens when the camera activity returns
     * This occurs when a user clicks the retake button
     * @param requestCode The code of the returning activity
     * @param resultCode The code of the result (success, failure, etc.)
     * @param data The data of the returning intent
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_IMAGE_CAPTURE && resultCode == Activity.RESULT_OK) {
            setPic()
        } else {
            println("Result not OK")
        }
    }


    /**
     * Opens up the camera activity for the reporting process
     * Stores data inside that intent to be pass it along the reporting process
     */
    private fun dispatchTakePictureIntent() {
        val takePictureIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        // Ensure that there's a camera activity to handle the intent
        if (takePictureIntent.resolveActivity(packageManager) != null) { // Create the File where the photo should go
            var photoFile: File? = null
            try {
                photoFile = createImageFile()
            } catch (ex: IOException) { // Error occurred while creating the File
            }
            // Continue only if the File was successfully created
            if (photoFile != null) {
                val photoURI = FileProvider.getUriForFile(
                    this,
                    "$packageName.fileprovider",
                    photoFile
                )
                takePictureIntent.putExtra("latitude", latitude)
                takePictureIntent.putExtra("longitude", longitude)
                takePictureIntent.putExtra("address", address)
                takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI)
                startActivityForResult(takePictureIntent, REQUEST_TAKE_PHOTO)
            }
        }
    }


    /**
     * Creates an image file before storing data into it
     * @throws IOException if the file creation failed
     * @returns image A file for data to be written into
     */
    @Throws(IOException::class)
    private fun createImageFile(): File? { // Create an image file name
        val timeStamp =
            SimpleDateFormat("yyyyMMdd_HHmmss").format(Date())
        val imageFileName = "JPEG_" + timeStamp + "_"
        val storageDir =
            getExternalFilesDir(Environment.DIRECTORY_PICTURES)
        val image = File.createTempFile(
            imageFileName,  /* prefix */
            ".jpg",  /* suffix */
            storageDir /* directory */
        )
        // Save a file: path for use with ACTION_VIEW intents
        currentPhotoPath = image.absolutePath
        return image
    }


    /**
     * Uses the Android stack to take the user to the previous screen
     */
    fun back(v: View?) {
        onBackPressed()
    }
}