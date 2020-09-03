package com.pathvu.accesspath2020

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View
import android.widget.Toast
import com.android.volley.Request
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import com.android.volley.toolbox.Volley.newRequestQueue
import kotlinx.android.synthetic.main.activity_onboarding_alert_settings.*
import kotlinx.android.synthetic.main.activity_onboarding_alert_settings.bigMessage
import kotlinx.android.synthetic.main.activity_onboarding_obstruction_settings.*

/**
 * This activity set turn on/off the alert
 */
class OnboardingAlertSettings : AppCompatActivity() {
    private var selectedAlert = ""
    private var alertValue = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_onboarding_alert_settings)

        selectedAlert = intent.getStringExtra("comfortSetting")

        setAlertText()

        turnOnButton.setOnClickListener { v -> alertClicked(v) }
        turnOffButton.setOnClickListener { v -> alertClicked(v) }
    }


    private fun setAlertText(){
        when(selectedAlert){
            "thw" -> {
                textView4.text = "Tripping Hazard Alert"
                bigMessage.text = "Would you like receive alerts about tripping hazards in your path?"
                turnOnButton.text = "Turn on Alerts for Tripping Hazards"
                turnOffButton.text = "Turn off Alerts for Tripping Hazards"
            }
            "rsw" -> {
                textView4.text = "Running Slope Alert"
                bigMessage.text = "Would you like receive alerts about running slopes in your path?"
                turnOnButton.text = "Turn on Alerts for Running Slopes"
                turnOffButton.text = "Turn off Alerts for Running Slopes"
            }
            "csw" -> {
                textView4.text = "Cross Slope Alert"
                bigMessage.text = "Would you like receive alerts about cross slopes in your path?"
                turnOnButton.text = "Turn on Alerts for Cross Slopes"
                turnOffButton.text = "Turn off Alerts for Cross Slopes"
            }
            "row" -> {
                textView4.text = "Roughness Alert"
                bigMessage.text = "Would you like receive alerts about roughness in your path?"
                turnOnButton.text = "Turn on Alerts for Roughness"
                turnOffButton.text = "Turn off Alerts for Roughness"
            }
        }
        getDefaultSetting()
    }


    private fun getDefaultSetting(){
        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
        var defaultSetting = sharedPreferences.getInt(selectedAlert, 0)

        when(defaultSetting){
            1 -> turnOnButton.setBackgroundResource(R.drawable.group_btn_selected)
            0 -> turnOffButton.setBackgroundResource(R.drawable.group_btn_selected)
        }
    }


    private fun alertClicked(v: View){
        turnOnButton.setBackgroundResource(R.drawable.group_btn_idle)
        turnOffButton.setBackgroundResource(R.drawable.group_btn_idle)
        v.setBackgroundResource(R.drawable.group_btn_selected)

        when(v.id){
            turnOnButton.id -> alertValue = 1
            turnOffButton.id -> alertValue = 0
        }
    }

//    fun setAlert(v: View){
//        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
//        with (sharedPreferences.edit()) {
//            putInt(selectedAlert.toString() + "Alert", alertValue)
//            commit()
//        }
//        val i = Intent(this, OnboardingObstructionTypes::class.java)
//        startActivity(i)
//    }


    /**
     * Send a set setting request to the server
     */
    fun setAlert(v: View){
        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
        with (sharedPreferences.edit()) {
            putInt(selectedAlert.toString() + "Alert", alertValue)
            commit()
        }
        val uacctidInt = sharedPreferences.getInt("uacctid", 0)
        val thw = sharedPreferences.getInt("thw", 0)
        val rsw = sharedPreferences.getInt("rsw", 0)
        val csw = sharedPreferences.getInt("csw", 0)
        val row = sharedPreferences.getInt("row", 0)
        println("approve setting: $thw $rsw $csw $row")
        val thalert = sharedPreferences.getInt("thalert", 0)
        val rsalert = sharedPreferences.getInt("rsalert", 0)
        val csalert = sharedPreferences.getInt("csalert", 0)
        val roalert = sharedPreferences.getInt("roalert", 0)
        val settingsQueue = Volley.newRequestQueue(this)
        val settingsUrl = "https://pathvudata.com/api1/api/users/setsettings"
        val settingsRequest = object : StringRequest(
            Request.Method.POST, settingsUrl,
            Response.Listener<String> { response ->
                val settingsString = response.toString()
                checkSettingsResponse(settingsString)
            },
            Response.ErrorListener { println("error") }
        ){
            override fun getParams(): MutableMap<String, String> {
                val settingsParams = HashMap<String, String>()
                settingsParams["uacctid"] = uacctidInt.toString()
                settingsParams["thw"] = thw.toString()
                settingsParams["rsw"] = rsw.toString()
                settingsParams["csw"] = csw.toString()
                settingsParams["row"] = row.toString()
                settingsParams["thalert"] = thalert.toString()
                settingsParams["rsalert"] = rsalert.toString()
                settingsParams["csalert"] = csalert.toString()
                settingsParams["roalert"] = roalert.toString()
                return settingsParams
            }
        }
        settingsQueue.add(settingsRequest)
    }


    /**
     * Check set the setting request response
     */
    fun checkSettingsResponse(response: String){
        with(response){
            when{
                contains("usg001") -> Toast.makeText(applicationContext, R.string.account_error_contact_pathvu,
                    Toast.LENGTH_LONG).show()
                contains("usg003") -> Toast.makeText(applicationContext, R.string.account_error_contact_pathvu,
                    Toast.LENGTH_LONG).show()
                contains("usg002") -> Toast.makeText(applicationContext, R.string.account_error_contact_pathvu,
                    Toast.LENGTH_LONG).show()
                else -> {goMainObstructionTypes()}
            }
        }

    }


    private fun goMainObstructionTypes(){
        val i = Intent(this, OnboardingObstructionTypes::class.java)
        startActivity(i)
    }


    fun alertCancel(v: View){

    }


    fun back(v: View?) {
        onBackPressed()
    }
}
