package com.pathvu.accesspath2020

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.android.volley.Request
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import kotlinx.android.synthetic.main.activity_onboarding_obstruction_types.*


/**
 * This class displays the different types of obstructions so that the user can set their comfort
 * and alert settings. Obstructions which have nothing set will be red, while those that
 * are set will be white. The can also go to the preset screen using the button.
 */
class OnboardingObstructionTypes : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_onboarding_obstruction_types)

        trippingHazardButton.setOnClickListener{v -> goObstructionSettings(v, "thw")}
        runningSlopeButton.setOnClickListener { v -> goObstructionSettings(v, "rsw") }
        crossSlopeButton.setOnClickListener { v -> goObstructionSettings(v, "csw") }
        roughnessButton.setOnClickListener { v -> goObstructionSettings(v, "row") }
    }


    fun presetScreen(v: View){
        val i = Intent(this, OnboardingProfilePresets::class.java)
        startActivity(i)
    }


    private fun goObstructionSettings(v: View, whichObstruction: String){
        val i = Intent(this, OnboardingObstructionSettings::class.java)
        i.putExtra("comfortSetting", whichObstruction)
        startActivity(i)
    }

//    fun approveSettings(v: View){
//        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
//        val uacctidInt = sharedPreferences.getInt("uacctid", 0)
//        val thw = sharedPreferences.getInt("thw", 0)
//        val rsw = sharedPreferences.getInt("rsw", 0)
//        val csw = sharedPreferences.getInt("csw", 0)
//        val row = sharedPreferences.getInt("row", 0)
//        println("approve setting: $thw $rsw $csw $row")
//        val thalert = sharedPreferences.getInt("thalert", 0)
//        val rsalert = sharedPreferences.getInt("rsalert", 0)
//        val csalert = sharedPreferences.getInt("csalert", 0)
//        val roalert = sharedPreferences.getInt("roalert", 0)
//        val settingsQueue = Volley.newRequestQueue(this)
//        val settingsUrl = "https://pathvudata.com/api1/api/users/setsettings"
//        val settingsRequest = object : StringRequest(
//            Request.Method.POST, settingsUrl,
//            Response.Listener<String> { response ->
//                val settingsString = response.toString()
//                checkSettingsResponse(settingsString)
//            },
//            Response.ErrorListener { println("error") }
//        ){
//            override fun getParams(): MutableMap<String, String> {
//                val settingsParams = HashMap<String, String>()
//                settingsParams["uacctid"] = uacctidInt.toString()
//                settingsParams["thw"] = thw.toString()
//                settingsParams["rsw"] = rsw.toString()
//                settingsParams["csw"] = csw.toString()
//                settingsParams["row"] = row.toString()
//                settingsParams["thalert"] = thalert.toString()
//                settingsParams["rsalert"] = rsalert.toString()
//                settingsParams["csalert"] = csalert.toString()
//                settingsParams["roalert"] = roalert.toString()
//                return settingsParams
//            }
//        }
//        settingsQueue.add(settingsRequest)
//    }
//
//    fun checkSettingsResponse(response: String){
//        with(response){
//            when{
//                contains("usg001") -> Toast.makeText(applicationContext, R.string.account_error_contact_pathvu,
//                    Toast.LENGTH_LONG).show()
//                contains("usg003") -> Toast.makeText(applicationContext, R.string.account_error_contact_pathvu,
//                    Toast.LENGTH_LONG).show()
//                contains("usg002") -> Toast.makeText(applicationContext, R.string.account_error_contact_pathvu,
//                    Toast.LENGTH_LONG).show()
//                else -> goMainNavigation()
//            }
//        }
//    }


    fun approveSettings(v: View){
        val i = Intent(this, MainNavigationHome::class.java)
        startActivity(i)
    }


    fun back(v: View) {
        onBackPressed()
    }
}
