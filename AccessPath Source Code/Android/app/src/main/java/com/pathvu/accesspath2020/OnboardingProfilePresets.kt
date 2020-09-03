package com.pathvu.accesspath2020

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import kotlinx.android.synthetic.main.activity_onboarding_profile_presets.*

/**
 * This activity allows the user to select a profile preset, which will automatically set their
 * comfort and alert settings based on which preset they chose.
 */
class OnboardingProfilePresets : AppCompatActivity() {
    var tid = 0
    var thw = 0
    var rsw = 0
    var csw = 0
    var row = 0
    var uacctidInt = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_onboarding_profile_presets)

        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
        uacctidInt = sharedPreferences.getInt("uacctid", 0)

        blindUserButton.setOnClickListener { v -> selectedPreset(v) }
        sightedUserButton.setOnClickListener { v -> selectedPreset(v) }
        wheelchairUserButton.setOnClickListener { v -> selectedPreset(v) }
        caneUserButton.setOnClickListener { v -> selectedPreset(v) }
    }


    private fun selectedPreset(v: View){
        blindUserButton.setBackgroundResource(R.drawable.group_btn_idle)
        sightedUserButton.setBackgroundResource(R.drawable.group_btn_idle)
        wheelchairUserButton.setBackgroundResource(R.drawable.group_btn_idle)
        caneUserButton.setBackgroundResource(R.drawable.group_btn_idle)
        v.setBackgroundResource(R.drawable.group_btn_selected)

        when(v.id){
            blindUserButton.id -> tid = 1
            sightedUserButton.id -> tid = 2
            wheelchairUserButton.id -> tid = 3
            caneUserButton.id -> tid = 4
        }

        getPresets(tid)
    }


    private fun getPresets(tid: Int){
        when (tid){
            1 -> {
                thw = 3
                rsw = 1
                csw = 1
                row = 2
            }
            2 -> {
                thw = 4
                rsw = 4
                csw = 4
                row = 4
            }
            3 -> {
                thw = 3
                rsw = 2
                csw = 2
                row = 2
            }
            4 -> {
                thw = 3
                rsw = 1
                csw = 2
                row = 2
            }
        }
    }


    fun storeTid(v: View){
        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
        with (sharedPreferences.edit()) {
            putInt("thw", thw)
            putInt("rsw", rsw)
            putInt("csw", csw)
            putInt("row", row)
            putInt("tid", tid)
            commit()
        }

        val queue = Volley.newRequestQueue(this)
        val addUserUrl = "https://pathvudata.com/api1/api/users/settype"
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
                userParams["uacctid"] = uacctidInt.toString()
                userParams["tid"] = tid.toString()
                userParams["apitoken"] = getString(R.string.pathvu_api_key)
                return userParams
            }
        }
        queue.add(stringRequest)
    }


    fun storeTidDefaults(v: View){
        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
        with (sharedPreferences.edit()) {
            putInt("thw", thw)
            putInt("rsw", rsw)
            putInt("csw", csw)
            putInt("row", row)
            putInt("tid", tid)
            commit()
        }

        val queue = Volley.newRequestQueue(this)
        val addUserUrl = "https://pathvudata.com/api1/api/users/settype"
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
                userParams.put("uacctid", uacctidInt.toString())
                userParams.put("tid", tid.toString())
                userParams.put("apitoken", getString(R.string.pathvu_api_key))
                return userParams
            }
        }
        queue.add(stringRequest)
    }


    fun storeDefaultSettings(v: View){
        val settingsQueue = Volley.newRequestQueue(this)
        val settingsUrl = "https://pathvudata.com/api1/api/users/setsettings"
        val settingsRequest = object : StringRequest(
            Method.POST, settingsUrl,
            Response.Listener<String> { response ->
                val settingsString = response.toString()
                checkSettingsResponse(settingsString)
            },
            Response.ErrorListener { println("error") }
        ){
            override fun getParams(): MutableMap<String, String> {
                val settingsParams = HashMap<String, String>()
                settingsParams["uacctid"] = uacctidInt.toString()
                settingsParams["1"] = thw.toString()
                settingsParams["2"] = rsw.toString()
                settingsParams["3"] = csw.toString()
                settingsParams["4"] = row.toString()
                settingsParams["5"] = "0"
                settingsParams["6"] = "0"
                settingsParams["7"] = "0"
                settingsParams["8"] = "0"
                settingsParams["apitoken"] = getString(R.string.pathvu_api_key)
                return settingsParams
            }
        }
        settingsQueue.add(settingsRequest)
    }


    fun checkResponse(tidResponse: String){
        with(tidResponse){
            when{
                contains("us001") -> Toast.makeText(applicationContext, R.string.account_error_contact_pathvu,
                    Toast.LENGTH_LONG).show()
                contains("us003") -> Toast.makeText(applicationContext, R.string.account_error_contact_pathvu,
                    Toast.LENGTH_LONG).show()
                contains("us002") -> Toast.makeText(applicationContext, R.string.select_user_type,
                    Toast.LENGTH_LONG).show()
                else -> goObstructionTypes()
            }
        }
    }


    fun checkSettingsResponse(settingsResponse: String){
        with(settingsResponse){
            when{
                contains("us101") -> Toast.makeText(applicationContext, R.string.account_error_contact_pathvu,
                    Toast.LENGTH_LONG).show()
                contains("us102") -> Toast.makeText(applicationContext, R.string.account_error_contact_pathvu,
                    Toast.LENGTH_LONG).show()
            }
        }
    }


    private fun goObstructionTypes(){
        val i = Intent(this, OnboardingObstructionTypes::class.java)
        startActivity(i)
    }


    private fun goMainNavigation(){
        val i = Intent(this, MainNavigationHome::class.java)
        startActivity(i)
    }


    fun back(v: View?) {
        onBackPressed()
    }
}
