package com.pathvu.accesspath2020

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.Toast
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.tasks.Task
import org.json.JSONArray

/**
 * This activity handles signing in with Google.
 * The user will be presented with a list of Google accounts signed in on the phone, and the user
 * can select an account to use to sign up. We then get a key to send to the server, which will
 * return an account ID.
 */
class OnboardingSignInGoogle : AppCompatActivity() {
    val RC_SIGN_IN = 9001
    var uGoogleIdInt : Int = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_onboarding_sign_in_google)

        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestIdToken(getString(R.string.google_client_id))
            .requestEmail()
            .build()

        val gsoClient = GoogleSignIn.getClient(this, gso)

        val gSignInIntent = gsoClient.signInIntent
        startActivityForResult(gSignInIntent, RC_SIGN_IN)
    }


    /**
     * What to do with Google sign in intent returns
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == RC_SIGN_IN) {
            val task =
                GoogleSignIn.getSignedInAccountFromIntent(data)
            handleSignInResult(task)
        }
    }


    /**
     * Handle the result from the sign in
     * @param completedTask The completed Google sign in task
     * @throws ApiException When the Google API has an error
     */
    private fun handleSignInResult(completedTask: Task<GoogleSignInAccount>){
        println("HANDLESIGNINRESULT")
        try {
            val account = completedTask.getResult(ApiException::class.java)
            println(account.toString())
            val gToken = account?.idToken.toString()
            submitUser(gToken)
        } catch (e: ApiException){
            println("APIEXCEPTION")
            println(e.message)
            println(e.cause)
        }
    }


    /**
     * Send a request to the server to store the Google account
     */
    private fun submitUser(uGToken: String){
        println("SUBMITUSER")
        val queue = Volley.newRequestQueue(this)
        val addUserUrl = "https://pathvudata.com/api1/api/users/add_android.php"
        println(uGToken)
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
                userParams["uisgoogle"] = "1"
                userParams["gtoken"] = uGToken
                userParams["apitoken"] = getString(R.string.pathvu_api_key)
                return userParams
            }
        }
        queue.add(stringRequest)
    }


    /**
     * Check the add Google user request's response
     */
    fun checkResponse(response: String){
        with(response) {
            when {
                startsWith("ua010") -> Toast.makeText(applicationContext,R.string.google_account_error_contact_pathvu,
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
        if (userIndex.has("new")){
            uacctid = userIndex.getString("new")
        }
        val uacctidInt = uacctid.toInt()
        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
        with (sharedPreferences.edit()) {
            putInt("uacctid", uacctidInt)
            commit()
        }
        startActivity(i)
    }
}
