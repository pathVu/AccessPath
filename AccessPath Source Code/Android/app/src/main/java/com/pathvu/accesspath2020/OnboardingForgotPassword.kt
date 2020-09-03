package com.pathvu.accesspath2020

import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import android.util.Patterns
import android.view.View
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import com.google.android.material.snackbar.Snackbar
import kotlinx.android.synthetic.main.activity_onboarding_forgot_password.*
import kotlinx.android.synthetic.main.activity_onboarding_sign_in_email.*
import kotlinx.android.synthetic.main.activity_onboarding_sign_in_email.emailBox

/**
 * This activity allows the user to enter their email and request a password change.
 */
class OnboardingForgotPassword : AppCompatActivity() {

    var emailOk = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_onboarding_forgot_password)

        emailBox.setOnFocusChangeListener{ v, hasFocus -> focusBg(v, hasFocus) }
    }


    private fun focusBg(v: View, hasFocus: Boolean) {
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
            if (v.id.equals(R.id.emailBox)){
                if (Patterns.EMAIL_ADDRESS.matcher(vEdit.text.toString()).matches()){
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


    fun submitForgotEmail (v: View) {
        if (emailBox.text.toString().isEmpty()) {
            Snackbar.make(submitButton, R.string.forgot_pwd_error, Snackbar.LENGTH_SHORT).show()
        } else {
            processForgotPassword (emailBox.text.toString())
        }
    }


    /**
     * Submit a forget password request to the server
     */
    private fun processForgotPassword (emailAddress: String) {
        emailBox.clearFocus()
        if (emailOk == 1) {
            val queue = Volley.newRequestQueue(this)
            val resetPasswordUrl = "https://pathvudata.com/accesspathweb/forgotpassword_v2.php"
            val stringRequest = object: StringRequest(
                Method.POST, resetPasswordUrl,
                Response.Listener<String> { response ->
                    println("response: $response")
                    val responseString = response.toString()
                    checkResponse(responseString)
                },
                Response.ErrorListener { println("error") })
            {
                override fun getParams(): MutableMap<String, String> {
                    val userParams = HashMap<String, String>()
                    userParams.put("uemail", emailBox.text.toString())
                    return userParams
                }
            }
            queue.add(stringRequest)
        }
    }


    /**
     * Check forget password request response
     */
    fun checkResponse(response: String) {
        with(response) {
            when {
                startsWith("ua001") -> Toast.makeText(applicationContext,R.string.error_email_password,
                    Toast.LENGTH_LONG).show()
                startsWith("ua005") -> errorBg(emailBox)
                startsWith("ua006") -> errorBg(emailBox)
                startsWith("sent") -> Toast.makeText(applicationContext, R.string.reset_pwd_link_sent, Toast.LENGTH_LONG).show()
                else -> Toast.makeText(applicationContext, R.string.unregistered_email, Toast.LENGTH_LONG).show()
            }
        }
    }

    fun back(v: View) {
        var i = Intent(this, OnboardingSignInEmail::class.java)
        startActivity(i)
    }
}