package com.pathvu.accesspath2020

import android.content.Context
import android.content.Intent
import android.graphics.Rect
import android.os.Bundle
import android.text.TextUtils
import android.view.MotionEvent
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import kotlinx.android.synthetic.main.activity_onboarding_sign_in_email.*
import org.json.JSONObject

/**
 * This activity handles signing up with email and password.
 */
class OnboardingSignInEmail : AppCompatActivity() {

    var emailOk = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_onboarding_sign_in_email)

        emailBox.setOnFocusChangeListener { v, hasFocus -> focusBg(v, hasFocus) }
        passwordBox.setOnFocusChangeListener { v, hasFocus -> focusBg(v, hasFocus) }
    }


    private fun focusBg(v: View, hasFocus: Boolean){
        if (hasFocus){
            v.setBackgroundResource(R.drawable.form_focus)
        } else{
            validateField(v)
        }
    }


    private fun validateField(v: View){
        val vEdit: EditText = v as EditText
        if (TextUtils.isEmpty(vEdit.text)){
            v.setBackgroundResource(R.drawable.form_idle)
            when(v.id){
                R.id.emailBox -> emailOk = 0
            }
        } else{
            if (v.id == R.id.emailBox){
                if (android.util.Patterns.EMAIL_ADDRESS.matcher(vEdit.text.toString()).matches()){
                    validBg(v)
                } else{
                    errorBg(v)
                }
            }
        }
    }


    private fun validBg(v: View){
        v.setBackgroundResource(R.drawable.form_valid)
        when(v.id){
            R.id.emailBox -> emailOk = 1
        }
    }


    private fun errorBg(v: View){
        v.setBackgroundResource(R.drawable.form_error)
        when(v.id){
            R.id.emailBox -> emailOk = 0
        }
    }


    /**
     * Send a request to the server to try and sign the user in
     * @param email The provided email address
     * @param pw The provided password
     */
    fun logInUser(v: View) {
        emailBox.clearFocus()
        passwordBox.clearFocus()
        if (emailOk == 1) {
            val queue = Volley.newRequestQueue(this)
            val signInUserUrl = "https://pathvudata.com/api1/api/users/login"
            val stringRequest = object: StringRequest(
                Method.POST, signInUserUrl,
                Response.Listener<String> { response ->
                    println("response: $response")
                    val responseString = response.toString()
                    checkResponse(responseString)
                },
                Response.ErrorListener { println("error") })
            {
                override fun getParams(): MutableMap<String, String> {
                    val userParams = HashMap<String, String>()
                    userParams["uemail"] = emailBox.text.toString()
                    userParams["upassword"] = passwordBox.text.toString()
                    userParams["apitoken"] = getString(R.string.pathvu_api_key)
                    return userParams
                }
            }
            queue.add(stringRequest)
        }
    }


    /**
     * Check sign in email response
     */
    fun checkResponse(response: String) {
        with(response) {
            when {
                startsWith("{\"ul003") -> {
                    errorBg(emailBox)
                    Toast.makeText(applicationContext, R.string.account_not_found, Toast.LENGTH_LONG).show()
                }
                startsWith("{\"ul004") -> {
                    errorBg(passwordBox)
                    Toast.makeText(applicationContext,R.string.incorrect_pwd, Toast.LENGTH_LONG).show()
                }
                else -> storeUacctid(response)
            }
        }
    }


    /**
     * Stores an account ID in Shared Preferences
     * This is needed so we can store an account ID from an inner class
     * @param accountID The account ID to store
     */
    private fun storeUacctid (resId: String){
        var uacctid = ""
        var i = Intent(this, OnboardingSignUpEmail::class.java)
        val userIndex = JSONObject(resId)
        if (userIndex.has("login")){
            uacctid = userIndex.getString("login")
            if (userIndex.getString("typeset") == "0"){
                i = Intent(this, OnboardingProfilePresets::class.java)
            } else if (userIndex.getString("settingsset") == "0"){
                i = Intent(this, OnboardingObstructionTypes::class.java)
            } else if (userIndex.getString("typeset") == "1" && userIndex.getString("settingsset") == "1") {
                i = Intent(this, MainNavigationHome::class.java)
            }
            val uacctidInt = uacctid.toInt()
            val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
            with (sharedPreferences.edit()) {
                putInt("uacctid", uacctidInt)
                putInt("isGuest", 0)
                commit()
            }
            startActivity(i)
        } else {
            startActivity(i)
            finish()
        }
    }


    /**
     * Direct to forget password screen
     */
    fun forgotPassword(v: View) {
        val i = Intent(this, OnboardingForgotPassword::class.java)
        startActivity(i)
    }


    /**
     * So that clicking outside of a TextView will defocus it
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
     * Go back to the last screen
     */
    fun back(v: View?) {
        val i = Intent(this, OnboardingSignInOptions::class.java)
        startActivity(i)
    }
}
