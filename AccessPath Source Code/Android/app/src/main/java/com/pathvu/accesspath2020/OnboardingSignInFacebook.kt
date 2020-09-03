package com.pathvu.accesspath2020

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import com.facebook.AccessToken
import com.facebook.CallbackManager
import com.facebook.FacebookCallback
import com.facebook.FacebookException
import com.facebook.login.LoginManager
import com.facebook.login.LoginResult
import org.json.JSONArray

/**
 * This activity handles signing in with Facebook.
 * After the user signs into the Facebook website, we get a key, which will be sent to the server
 * to get an account ID.
 */
class OnboardingSignInFacebook : AppCompatActivity() {

    private var callbackManager: CallbackManager? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_onboarding_sign_in_facebook)

        callbackManager = CallbackManager.Factory.create()

        LoginManager.getInstance().logInWithReadPermissions(this, listOf("public_profile"))
        LoginManager.getInstance().registerCallback(callbackManager, object :
            FacebookCallback<LoginResult> {
            override fun onSuccess(result: LoginResult?) {
                SignInWithFacebook(AccessToken.getCurrentAccessToken().token)
            }

            override fun onCancel() {
                finish()
                startActivity(
                    Intent(
                        this@OnboardingSignInFacebook,
                        OnboardingSignInOptions::class.java
                    )
                )
            }

            override fun onError(error: FacebookException?) {
                finish()
                startActivity(Intent(this@OnboardingSignInFacebook, OnboardingSignInOptions::class.java)
                )
            }
        })
    }


    /**
     * What to do when the Facebook intent returns to this activity
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        callbackManager?.onActivityResult(requestCode, resultCode, data)
    }


    /**
     * Send a request to the server to log in with a Facebook access token
     * @param accessToken The Facebook access token
     * @throws Throwable When the JSON response cannot be successfully parsed
     */
    fun SignInWithFacebook(fbToken: String){
        val queue = Volley.newRequestQueue(this)
        val addUserUrl = "https://pathvudata.com/api1/api/users/add_android.php"
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
     * Check sign in with facebook request response
     */
    fun checkResponse(response: String){
        with(response) {
            when {
                startsWith("ua009") -> Toast.makeText(applicationContext,R.string.facebook_account_error_contact_pathvu,
                    Toast.LENGTH_LONG).show()
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
        var i = Intent(this, OnboardingUsername::class.java)
        val userJson = JSONArray(resId)
        val userIndex = userJson.getJSONObject(0)
        if (userIndex.has("login")){
            uacctid = userIndex.getString("login")
            if (userIndex.getString("typeset") == "0"){
                i = Intent(this, OnboardingProfilePresets::class.java)
            } else if (userIndex.getString("settingsset") == "0"){
                i = Intent(this, OnboardingObstructionTypes::class.java)
            } else if (userIndex.getString("typeset") == "1" && userIndex.getString("settingsset") == "1") {
                i = Intent(this, MainNavigationHome::class.java)
            }
        }
        val uacctidInt = uacctid.toInt()
        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
        with (sharedPreferences.edit()) {
            putInt("uacctid", uacctidInt)
            putInt("isGuest", 0)
            commit()
        }
        startActivity(i)
    }
}
