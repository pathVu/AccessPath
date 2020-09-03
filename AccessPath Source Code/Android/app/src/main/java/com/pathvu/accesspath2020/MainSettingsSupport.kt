package com.pathvu.accesspath2020

import android.annotation.SuppressLint
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Rect
import android.net.Uri
import android.os.Bundle
import android.view.MotionEvent
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import kotlinx.android.synthetic.main.activity_main_settings_support.*

/**
 * This activity allows the user to send an email to pathVu for support.
 */
class MainSettingsSupport : AppCompatActivity() {

    //Shared Preferences
    private lateinit var prefs: SharedPreferences
    private lateinit var editor: SharedPreferences.Editor

    @SuppressLint("CommitPrefEdits")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_settings_support)

        prefs = getSharedPreferences("pathVuPrefs", Context.MODE_PRIVATE)
        editor = prefs.edit()

        /* On Click Listeners */
        sendEmailButton.setOnClickListener(View.OnClickListener { sendEmail() })
    }


    /**
     * Creates an email intent which will allow open the user's default email application or allow them to choose one.
     * The to address and subject will already be filled in for the user.
     * @throws android.content.ActivityNotFoundException If the user has no email applications installed
     */
    private fun sendEmail() {
        //Information to include in the email
        val TO = arrayOf("nick.sinagra@pathvu.com")
        val CC = arrayOf("")
        val subject = "Access Path Android Support (" + prefs.getInt("uacctid", 0) + ")"
        val emailIntent = Intent(Intent.ACTION_SEND)
        emailIntent.data = Uri.parse("mailto:")
        emailIntent.type = "text/plain"

        //Put the information inside the intent
        emailIntent.putExtra(Intent.EXTRA_EMAIL, TO)
        emailIntent.putExtra(Intent.EXTRA_CC, CC)
        emailIntent.putExtra(Intent.EXTRA_SUBJECT, subject)
        emailIntent.putExtra(Intent.EXTRA_TEXT, "")

        //Start the intent
        try {
            startActivity(Intent.createChooser(emailIntent, "Send mail..."))
        } catch (ex: ActivityNotFoundException) {
            Toast.makeText(this@MainSettingsSupport, "There is no email client installed.", Toast.LENGTH_SHORT).show()
        }
    }

    /**
     * If user clicks outside the email window, close it
     */
    override fun dispatchTouchEvent(event: MotionEvent): Boolean {
        if (event.action == MotionEvent.ACTION_DOWN) {
            val v = currentFocus
            if (v is EditText) {
                val outRect = Rect()
                v.getGlobalVisibleRect(outRect)
                if (!outRect.contains(event.rawX.toInt(), event.rawY.toInt())) {
                    v.clearFocus()
                    val imm =
                        getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                    imm.hideSoftInputFromWindow(v.getWindowToken(), 0)
                }
            }
        }
        return super.dispatchTouchEvent(event)
    }

    /**
     * Use Android's stack to take user to the previous screen.
     */
    fun back(v: View?) {
        onBackPressed()
    }
}