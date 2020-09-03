package com.pathvu.accesspath2020

import android.content.Context
import android.content.Intent
import android.graphics.Rect
import android.os.Bundle
import android.view.MotionEvent
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley.newRequestQueue
import kotlinx.android.synthetic.main.activity_onboarding_username.*
import org.json.JSONObject

/**
 * This class is used to get the default username and update it
 */
class OnboardingUsername : AppCompatActivity() {
    var uacctidInt = 0
    var isGuest = 0
    lateinit var default_username: String

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_onboarding_username)

        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
        uacctidInt = sharedPreferences.getInt("uacctid", 0)
        isGuest = sharedPreferences.getInt("isGuest", 0)

        getUsername(uacctidInt, isGuest)
    }


    /**
     * Get username from API
    */
    private fun getUsername(idInt: Int, isGuest: Int){
        val queue = newRequestQueue(this)
        var getUserUrl = ""
        if (isGuest == 1) {
            getUserUrl = "https://pathvudata.com/api1/api/users/guestusername"
            val stringRequest = object : StringRequest(
                Method.POST, getUserUrl,
                Response.Listener<String> { response ->
                    val responseString = response.toString()
                    checkResponse(responseString, isGuest)
                },
                Response.ErrorListener { println("error") })
            {
                override fun getParams(): MutableMap<String, String> {
                    val userParams = HashMap<String, String>()
                    userParams["uacctid"] = idInt.toString()
                    userParams["apitoken"] = getString(R.string.pathvu_api_key)
                    return userParams
                }
            }
            queue.add(stringRequest)
        } else {
            getUserUrl = "https://pathvudata.com/api1/api/users/?apitoken=3dDJFvQf4e2hxQWncEN1&uacctid=$idInt"
            val stringRequest = object : StringRequest(
                Method.GET, getUserUrl,
                Response.Listener<String> { response ->
                    val responseString = response.toString()
                    checkResponse(responseString, isGuest)
                },
                Response.ErrorListener { println("error") })
            {
                /*override fun getParams(): MutableMap<String, String> {
                    val userParams = HashMap<String, String>()
                    userParams.put("uacctid", idInt.toString())
                    return userParams
                }*/
            }
            queue.add(stringRequest)
        }
    }


    /**
     * Check get username response
    */
    fun checkResponse(response: String, isGuest: Int){
        with(response) {
            when {
                startsWith("error") -> Toast.makeText(applicationContext, R.string.account_error_contact_pathvu,
                    Toast.LENGTH_LONG).show()
                else -> showUsername(response, isGuest)
            }
        }
    }


    /**
     * Show username in the view
     */
    private fun showUsername(resId: String, isGuest: Int){
        val userJson = JSONObject(resId)
        var uusername = ""
        if (isGuest == 1) {
            uusername = userJson.getString("username")
            default_username = uusername
        } else {
            uusername = userJson.getString("uusername")
            default_username = uusername
        }
        usernameBox.setText(uusername)
    }


    /**
     * Clear username
     */
    fun clearUsername(v: View?) {
        usernameBox.setText("")
    }


    /**
     * Go back to the last interface
     */
    fun back(v: View?) {
        onBackPressed()
    }


    /**
     * Update current username
     */
    fun updateUsername(v: View){
        val uusername = usernameBox.text.toString()
        if(!default_username.equals(uusername)) {
            if (!uusername.equals("")) {
                val queue = newRequestQueue(this)
                val getUserUrl = "https://pathvudata.com/api1/api/users/updateusername"
                val stringRequest = object : StringRequest(
                    Method.POST, getUserUrl,
                    Response.Listener<String> { response ->
                        val responseString = response.toString()
                        checkUsernameResponse(responseString)
                    },
                    Response.ErrorListener { println("error") }) {
                    override fun getParams(): MutableMap<String, String> {
                        val userParams = HashMap<String, String>()
                        userParams["uacctid"] = uacctidInt.toString()
                        userParams["uusername"] = uusername.toString()
                        userParams["apitoken"] = getString(R.string.pathvu_api_key)
                        return userParams
                    }
                }
                queue.add(stringRequest)
            }
        } else {
            goComfortSettings()
        }
    }


    /**
     * Check update username response
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
                else -> goComfortSettings()
            }
        }
    }


    /**
     * Direct to the comfort setting page
     */
    private fun goComfortSettings(){
        val i = Intent(this, OnboardingComfortSettingsPrimer::class.java)
        startActivity(i)
    }


    //Defocus text box when clicked outside
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

}
