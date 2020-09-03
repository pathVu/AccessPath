package com.pathvu.accesspath2020

import android.content.Context
import android.content.Intent
import android.graphics.Rect
import android.os.Bundle
import android.text.TextUtils.isEmpty
import android.view.MotionEvent
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import kotlinx.android.synthetic.main.activity_onboarding_sign_up_email.*
import java.util.regex.Pattern

/**
 * This activity handles signing up with email and password.
 */
class OnboardingSignUpEmail : AppCompatActivity() {
    var firstOk = 0
    var lastOk = 0
    var emailOk = 0
    var passwordOk = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_onboarding_sign_up_email)

        firstNameBox.setOnFocusChangeListener { v, hasFocus -> focusBg(v, hasFocus) }
        lastNameBox.setOnFocusChangeListener { v, hasFocus -> focusBg(v, hasFocus) }
        emailAddressBox.setOnFocusChangeListener { v, hasFocus -> focusBg(v, hasFocus) }
        passwordFieldBox.setOnFocusChangeListener { v, hasFocus -> focusBg(v, hasFocus) }
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
        if (isEmpty(vEdit.text)){
            v.setBackgroundResource(R.drawable.form_idle)
            when(v.id){
                R.id.firstNameBox -> firstOk = 0
                R.id.lastNameBox -> lastOk = 0
                R.id.emailAddressBox -> emailOk = 0
                R.id.passwordFieldBox -> passwordOk = 0
            }
        } else{
            if (v.id == R.id.firstNameBox || v.id == R.id.lastNameBox){
                if (Pattern.matches("[a-zA-Z]{2,}", vEdit.text.toString())){
                    validBg(v)
                } else{
                    errorBg(v)
                }

            }
            if (v.id == R.id.emailAddressBox){
                if (android.util.Patterns.EMAIL_ADDRESS.matcher(vEdit.text.toString()).matches()){
                    validBg(v)
                } else{
                    errorBg(v)
                }
            }
            if (v.id == R.id.passwordFieldBox){
                if (Pattern.matches(".{6,}",vEdit.text.toString())){
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
            R.id.firstNameBox -> firstOk = 1
            R.id.lastNameBox -> lastOk = 1
            R.id.emailAddressBox -> emailOk = 1
            R.id.passwordFieldBox -> passwordOk = 1
        }
    }


    private fun errorBg(v: View){
        v.setBackgroundResource(R.drawable.form_error)
        when(v.id){
            R.id.firstNameBox -> firstOk = 0
            R.id.lastNameBox -> lastOk = 0
            R.id.emailAddressBox -> emailOk = 0
            R.id.passwordFieldBox -> passwordOk = 0
        }
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


    /**
     * Send a request to the server to sign up with the provided information
     * @param firstName The first name the user input
     * @param lastName The last name the user input
     * @param emailAddress The email the user input
     * @param pw The password the user input
     * @throws Throwable If the JSON response is not parsable
     */
    fun submitUser(v: View){
        firstNameBox.clearFocus()
        lastNameBox.clearFocus()
        emailAddressBox.clearFocus()
        passwordFieldBox.clearFocus()

        if (firstOk == 1 && lastOk == 1 && emailOk == 1 && passwordOk == 1) {
            val queue = Volley.newRequestQueue(this)
            val addUserUrl = "https://pathvudata.com/api1/api/users/add"

            val stringRequest = object : StringRequest(
                Method.POST, addUserUrl,
                Response.Listener<String> { response ->
                    println(response)
                    val responseString = response.toString()
                    checkResponse(responseString)
                },
                Response.ErrorListener { println("error") })
            {
                override fun getParams(): MutableMap<String, String> {
                    val userParams = HashMap<String, String>()
                    userParams["ufirstname"] = firstNameBox.text.toString()
                    userParams["ulastname"] = lastNameBox.text.toString()
                    userParams["uemail"] = emailAddressBox.text.toString()
                    userParams["upassword"] = passwordFieldBox.text.toString()
                    userParams["apitoken"] = getString(R.string.pathvu_api_key)
                    return userParams
                }
            }
            queue.add(stringRequest)
        }
    }


    /**
     * Check sign up with email response
     */
    fun checkResponse(response: String){
        with(response) {
            when {
                startsWith("{\"ua001") -> Toast.makeText(applicationContext,R.string.error_email_password,Toast.LENGTH_LONG).show()
                startsWith("{\"ua003") -> errorBg(firstNameBox)
                startsWith("{\"ua004") -> errorBg(lastNameBox)
                startsWith("{\"ua005") -> errorBg(emailAddressBox)
                startsWith("{\"ua006") -> {
                    errorBg(emailAddressBox)
                    Toast.makeText(applicationContext, R.string.already_registered_email,Toast.LENGTH_LONG).show()
                }
                startsWith("{\"ua008") -> errorBg(passwordFieldBox)
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
        val intId = resId.toInt()
        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
        with (sharedPreferences.edit()) {
            putInt("uacctid", intId)
            putInt("isGuest", 0)
            commit()
        }
        val i = Intent(this, OnboardingUsername::class.java)
        startActivity(i)
    }


    /**
     * Use Android's stack to take user to the previous screen.
     */
    fun back(v: View?) {
        onBackPressed()
    }

}