package com.pathvu.accesspath2020

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley.newRequestQueue
import com.facebook.AccessToken
import com.facebook.CallbackManager
import com.facebook.FacebookCallback
import com.facebook.FacebookException
import com.facebook.login.LoginManager
import com.facebook.login.LoginResult
import org.json.JSONArray

/**
 * This activity handles signing up with Facebook. After the user signs into the Facebook website,
 * we get a key which will be sent to the server to create the account.
 */
class OnboardingSignUpFacebook : AppCompatActivity() {
    var callbackManager: CallbackManager? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_onboarding_sign_up_facebook)

        callbackManager = CallbackManager.Factory.create()

        if (AccessToken.getCurrentAccessToken() == null) {
            println("Welcome to the facebook signup demo")
        } else {
            /*if your logged in then you will get access token here*/
            val accessToken = AccessToken.getCurrentAccessToken()
        }

        LoginManager.getInstance().logInWithReadPermissions(this, listOf("email", "public_profile"))
        LoginManager.getInstance().registerCallback(callbackManager, object : FacebookCallback<LoginResult>{
            override fun onSuccess(result: LoginResult?) {
                submitUser(AccessToken.getCurrentAccessToken().token)
            }

            override fun onCancel() {
                println("cancel")
                val i = Intent(this@OnboardingSignUpFacebook, OnboardingCreateNewAccount::class.java)
                startActivity(i)
            }

            override fun onError(error: FacebookException?) {
                println("onError" + error.toString())
                val i = Intent(this@OnboardingSignUpFacebook, OnboardingCreateNewAccount::class.java)
                startActivity(i)
            }
        })
    }


    /**
     * What happens when Facebook intent returns to this activity
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        callbackManager?.onActivityResult(requestCode, resultCode, data)
    }


    /**
     * Send a request to the server to store the Facebook account
     */
    fun submitUser(fbToken: String){
        val queue = newRequestQueue(this)
        val addUserUrl = "https://pathvudata.com/api1/api/users/add"
        val stringRequest = object : StringRequest(
            Method.POST, addUserUrl,
            Response.Listener<String> { response ->
                println("php response $response")
                val responseString = response.toString()
                checkResponse(responseString)
            },
            Response.ErrorListener { println("error") })
        {
            override fun getParams(): MutableMap<String, String> {
                val userParams = HashMap<String, String>()
                userParams["uisfacebook"] = "1"
                userParams["ftoken"] = fbToken
                userParams["apitoken"] = getString(R.string.pathvu_api_key)
                return userParams
            }
        }
        queue.add(stringRequest)
    }


    /**
     * Check the add Facebook user request's response
     */
    fun checkResponse(response: String){
        with(response) {
            when {
                startsWith("ua009") -> Toast.makeText(applicationContext,R.string.facebook_account_error_contact_pathvu,Toast.LENGTH_LONG).show()
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
        val userJson = JSONArray(resId)
        val userIndex = userJson.getJSONObject(0)
        val uacctid = userIndex.getString("login")
        val uacctidInt = uacctid.toInt()
        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
        with (sharedPreferences.edit()) {
            putInt("uacctid", uacctidInt)
            putInt("isGuest", 0)
            commit()
        }
        val i = Intent(this, OnboardingUsername::class.java)
        startActivity(i)
    }
}
