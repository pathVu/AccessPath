package com.pathvu.accesspath2020

import android.annotation.SuppressLint
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.graphics.Rect
import android.os.Bundle
import android.view.MotionEvent
import android.view.View
import android.view.View.OnFocusChangeListener
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import kotlinx.android.synthetic.main.activity_main_settings_account.*
import org.json.JSONObject

/**
 * This page contains information about the user's account. The user can change their username from
 * this page as well. Their account ID is shown at the bottom of the page.
 */
class MainSettingsAccount : AppCompatActivity() {

    //User Account Information
    var uniqueID: Int = 0
    var defaultUserName: String? = null
    //Shared Preferences
    private lateinit var prefs: SharedPreferences
    private lateinit var editor: SharedPreferences.Editor

    @SuppressLint("SetTextI18n", "CommitPrefEdits")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_settings_account)

        prefs = getSharedPreferences("pathVuPrefs", Context.MODE_PRIVATE)
        editor = prefs.edit()

        //Set the account ID label
        if (prefs.getInt("uacctid", 0) != 0) {
            idLabel.text = "ID: " + prefs.getInt("uacctid", 0)
        } else {
            idLabel.text = "Error Getting ID"
        }

        //Get the username from the unique ID
        uniqueID = prefs.getInt("uacctid", 0)
        var isGuest = prefs.getInt("isGuest", 0)
        getUsername(uniqueID, isGuest)

        //De-focus the username text box
        usernameBox.clearFocus()

        //Change the username text box depending on focus
        usernameBox.onFocusChangeListener = OnFocusChangeListener { v, hasFocus ->
            if (hasFocus) {
                usernameBox.setBackgroundResource(R.drawable.text_input_focused)
                descriptionText.setTextColor(Color.parseColor("#292440"))
                descriptionText.text = ""
                usernameClearButton.visibility = View.VISIBLE
                usernameStatusIcon.visibility = View.INVISIBLE
            } else {
                usernameClearButton.visibility = View.INVISIBLE
                usernameBox.setBackgroundResource(R.drawable.text_input_background)
            }
        }

        /* On Click Listeners */
        //Accept: Validate username and send it to PHP
        acceptButton.setOnClickListener {
            val username = usernameBox.text.toString()
            usernameBox.clearFocus()
            if (usernameBox.text.toString() != defaultUserName) {
                if (username.length >= 2) {
                    updateUsername(uniqueID.toString(), username)
                } else {
                    descriptionText.text = "Username must have 2 or more Characters"
                    descriptionText.setTextColor(Color.parseColor("#eb6262"))
                    usernameBox.setBackgroundResource(R.drawable.text_input_wrong)
                    usernameStatusIcon.visibility = View.VISIBLE
                }
            }
        }
    }


    /**
     * (Function called from XML)
     * Clears the username text box
     */
    fun clearUsername(v: View?) {
        usernameBox.setText("")
    }

    /**
     * Gets the username of the account id specified
     * @param id The unique ID of the account
     */
    private fun getUsername(idInt: Int, isGuest: Int){
        val queue = Volley.newRequestQueue(this)
        var getUserUrl = ""
        if (isGuest == 1) {
            getUserUrl = "https://pathvudata.com/api1/api/users/guestusername/*removed for security purposes*/"
            val stringRequest = object : StringRequest(
                Method.POST, getUserUrl,
                Response.Listener<String> { response ->
                    println("php response $response")
                    val responseString = response.toString()
                    changeUsernameBox(responseString, isGuest)
                },
                Response.ErrorListener { println("error") })
            {
                override fun getParams(): MutableMap<String, String> {
                    val userParams = HashMap<String, String>()
                    userParams["uacctid"] = idInt.toString()
                    return userParams
                }
            }
            queue.add(stringRequest)
        } else {
            getUserUrl = "https://pathvudata.com/api1/api/users/?/*removed for security purposes*/uacctid=$idInt"
            val stringRequest = object : StringRequest(
                Method.GET, getUserUrl,
                Response.Listener<String> { response ->
                    println("php response $response")
                    val responseString = response.toString()
                    changeUsernameBox(responseString, isGuest)
                },
                Response.ErrorListener { println("error") })
            {
                //
            }
            queue.add(stringRequest)
        }
    }


    /**
     * Sets the text inside the username box
     * The PHP returns the username in quotes so we have to get rid of those
     */
    private fun changeUsernameBox(resId: String, isGuest: Int) {
        val userJson = JSONObject(resId)
        var uusername = ""
        uusername = if (isGuest == 1) {
            userJson.getString("username")
        } else {
            userJson.getString("uusername")
        }
        defaultUserName = uusername
        usernameBox.setText(uusername)
    }


    /**
     * Send an updating username request to the server
     */
    private fun updateUsername(uid: String, username: String){
        if (username != ""){
            val queue = Volley.newRequestQueue(this)
            val getUserUrl = "https://pathvudata.com/api1/api/users/updateusername"
            val stringRequest = object : StringRequest(
                Method.POST, getUserUrl,
                Response.Listener<String> { response ->
                    println("php response $response")
                    val responseString = response.toString()
                    checkUsernameResponse(responseString)
                },
                Response.ErrorListener { println("error") })
            {
                override fun getParams(): MutableMap<String, String> {
                    val userParams = HashMap<String, String>()
                    userParams["uacctid"] = uid
                    userParams["uusername"] = username
                    userParams["apitoken"] = getString(R.string.pathvu_api_key)
                    return userParams
                }
            }
            queue.add(stringRequest)
        }

    }


    /**
     * Check the update username request response
     */
    fun checkUsernameResponse(response: String){
        with(response){
            when {
                contains("{\"uuu001") -> Toast.makeText(applicationContext,R.string.account_error_contact_pathvu,
                    Toast.LENGTH_LONG).show()
                contains("{\"uuu002") -> usernameBox.setBackgroundResource(R.drawable.form_error)
                contains("{\"uuu003") -> Toast.makeText(applicationContext,R.string.account_error_contact_pathvu,
                    Toast.LENGTH_LONG).show()
                contains("{\"uuu004") -> {
                    usernameBox.setBackgroundResource(R.drawable.form_error)
                    Toast.makeText(applicationContext, R.string.username_in_use,
                        Toast.LENGTH_LONG).show()
                }
                else -> {
                    usernameBox.setBackgroundResource(R.drawable.text_input_correct)
                    descriptionText.text = "Username Set"
                    descriptionText.setTextColor(Color.parseColor("#C8DC5C"))
                }
            }
        }
    }


    /**
     * De-focuses a textbox when clicked outside of the textbox
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