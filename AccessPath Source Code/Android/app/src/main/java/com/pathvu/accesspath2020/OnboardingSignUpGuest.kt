package com.pathvu.accesspath2020

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.Toast
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import kotlinx.android.synthetic.main.activity_onboarding_sign_up_guest.*
import org.json.JSONArray
import org.json.JSONObject

/**
 * This activity handles signing up a guest account. Guest accounts are like regular accounts, but
 * they are temporary and cannot report obstructions.
 */
class OnboardingSignUpGuest : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_onboarding_sign_up_guest)

        progressBar.indeterminateDrawable.setColorFilter(
            resources.getColor(R.color.button_border),
            android.graphics.PorterDuff.Mode.SRC_IN
        )

        signUp()
    }


    /**
     * Send a request to the server to sign up as a guest account
     */
    private fun signUp() {
        val queue = Volley.newRequestQueue(this)
        val addGuestUrl = "https://pathvudata.com/api1/api/users/addguestuser?apitoken=3dDJFvQf4e2hxQWncEN1"
        val stringRequest = object: StringRequest(
            Method.POST, addGuestUrl,
            Response.Listener<String> { response ->
                println("php response $response")
                val responseString = response.toString()
                checkResponse(responseString)
            },
            Response.ErrorListener { println("error") })
        {
            //
        }
        queue.add(stringRequest)
    }


    /**
     * Send a request to the server to check the guest request response
     */
    fun checkResponse(response: String){
        with(response) {
            when {
                startsWith("ua001") -> Toast.makeText(applicationContext,R.string.account_error_contact_pathvu,
                    Toast.LENGTH_LONG).show()
                else -> storeUacctid(response)
            }
        }
    }


    /**
     * Put the guest id and boolean value into sharedPreference
     */
    private fun storeUacctid (resId: String) {
        val userIndex = JSONObject(resId)
        val uacctid = userIndex.getString("new")
        val uacctidInt = uacctid.toInt()
        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
        with (sharedPreferences.edit()) {
            putInt("uacctid", uacctidInt)
            putInt("isGuest", 1)
            putBoolean("guestAccountKey", true)
            commit()
        }
        val i = Intent(this, OnboardingUsername::class.java)
        startActivity(i)
    }
}
