package com.pathvu.accesspath2020

import android.annotation.SuppressLint
import android.content.Context
import android.content.DialogInterface
import android.content.Intent
import android.content.SharedPreferences
import android.content.SharedPreferences.Editor
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import com.pathvu.accesspath2020.Util.Utility
import kotlinx.android.synthetic.main.activity_main_settings.*
import org.json.JSONObject

/**
 * This class contains the list of setting subpages. The user can also sign out from here.
 */
class MainSettings : AppCompatActivity() {

    var uacctidInt = 0

    @SuppressLint("CommitPrefEdits")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_settings)

        //Shared Preferences
        val prefs = this.getSharedPreferences("pathVuPrefs", Context.MODE_PRIVATE)
        uacctidInt = prefs.getInt("uacctid", 0)

        favAlertsButton.setOnClickListener {
            startActivity((Intent(this, MainSettingsFavoriteAlerts::class.java)))
        }
    }


    /**
     * (Function called from XML)
     * Take the user to the comfort settings
     */
    fun comfortAlertSettings(v: View) {
        startActivity((Intent(this, OnboardingObstructionTypes::class.java)))
    }


    /**
     * (Function called from XML)
     * Take the user to map settings
     */
    fun mapSettings(v: View) {
        startActivity((Intent(this, MainSettingsMap::class.java)))
    }


    /**
     * (Function called from XML)
     * Take the user to account settings
     */
    fun accountSettings(v: View) {
        startActivity((Intent(this, MainSettingsAccount::class.java)))
    }


    /**
     * (Function called from XML)
     * Take the user to the email support screen
     */
    fun support(v: View) {
        startActivity((Intent(this, MainSettingsSupport::class.java)))
    }


    /**
     * Take the user to about page
     */
    fun showTerms(v: View) {
        startActivity((Intent(this, MainSettingsAbout::class.java)))
    }


    fun signOut(v: View) {
        val prefs = getSharedPreferences("pathVuPrefs", Context.MODE_PRIVATE)
        val editor = prefs.edit()
        Utility.showDialog(this@MainSettings, getString(R.string.signout), getString(R.string.signout_message), getString(R.string.signout), getString(R.string.cancel),
            object: Utility.OnAlertButtonClickListener {
                override fun onPositiveButtonClick(dialogInterface: DialogInterface?) {
                    editor.clear()
                    editor.commit()
                    val i = Intent(this@MainSettings, OnboardingPrimer::class.java)
                    i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
                    startActivity(i)
                }

                override fun onNegativeButtonClick(dialogInterface: DialogInterface?) {
                    dialogInterface?.dismiss()
                }
            })
    }


//    private fun getSettings() {
//        println("user id $uacctidInt")
//        val queue = Volley.newRequestQueue(this)
//        val getSettingUrl = "https://pathvudata.com/api1/api/users/getsettings?uacctid=$uacctidInt"
//        val stringRequest = object : StringRequest(
//            Method.GET, getSettingUrl,
//            Response.Listener<String> { response ->
//                println("php response: $response")
//                val responseString = response.toString()
//                checkResponse(responseString)
//            },
//            Response.ErrorListener { println("error") })
//        {
//              //
//        }
//        queue.add(stringRequest)
//    }
//
//
//    fun checkResponse(response: String) {
//        with(response) {
//            when {
//                startsWith("{\"ugs001") -> Toast.makeText(applicationContext, "User Account ID not posted", Toast.LENGTH_LONG).show()
//                startsWith("{\"ugs002") -> Toast.makeText(applicationContext, "User Account ID not found", Toast.LENGTH_LONG).show()
//                startsWith("{\"ugs003") -> Toast.makeText(applicationContext, "User Type not found", Toast.LENGTH_LONG).show()
//                else -> {
//                    println("response: $response")
//                    parseJsonRes(response)
//                }
//            }
//        }
//    }
//
//
//    private fun parseJsonRes(response: String) {
//        var settingJson = JSONObject(response).getJSONArray("settings")
//        var thw = settingJson.getJSONObject(1).getString("1")
//        var rsw = settingJson.getJSONObject(2).getString("2")
//        var csw = settingJson.getJSONObject(3).getString("3")
//        var row = settingJson.getJSONObject(4).getString("4")
//        var thwAlert = settingJson.getJSONObject(5).getString("5")
//        var rswAlert = settingJson.getJSONObject(6).getString("6")
//        var cswAlert = settingJson.getJSONObject(7).getString("7")
//        var rowAlert = settingJson.getJSONObject(8).getString("8")
//        println("get settings: $thw $rsw $csw $row $thwAlert $rswAlert $cswAlert $rowAlert")
//        editor.putInt("thw", thw.toInt())
//        editor.putInt("rsw", rsw.toInt())
//        editor.putInt("csw", csw.toInt())
//        editor.putInt("row", row.toInt())
//        editor.putInt("thalert", thwAlert.toInt())
//        editor.putInt("rsalert", rswAlert.toInt())
//        editor.putInt("csalert", cswAlert.toInt())
//        editor.putInt("roalert", rowAlert.toInt())
//        editor.commit()
//    }


    /**
     * Uses the Android stack to take the user to the previous screen
     */
    fun back(v: View?) {
        onBackPressed()
    }
}