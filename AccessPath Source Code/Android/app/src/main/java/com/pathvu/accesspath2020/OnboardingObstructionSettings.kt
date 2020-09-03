package com.pathvu.accesspath2020

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import kotlinx.android.synthetic.main.activity_onboarding_obstruction_settings.*


/**
 * This activity set the comfort level for each obstruction type
 */
class OnboardingObstructionSettings : AppCompatActivity() {
    private var selectedSetting = ""
    private var curSettingValue = 0
    private var uacctidInt = 0
    private var newValue = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_onboarding_obstruction_settings)

        selectedSetting = intent.getStringExtra("comfortSetting")

        setHeaderText()

        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)

        curSettingValue = sharedPreferences.getInt(selectedSetting, 0)
        uacctidInt = sharedPreferences.getInt("uacctid", 0)

        veryUncomfortableButton.setOnClickListener { v -> settingClicked(v) }
        mostlyComfortableButton.setOnClickListener { v -> settingClicked(v) }
        veryComfortableButton.setOnClickListener { v -> settingClicked(v) }
        completelyComfortableButton.setOnClickListener { v -> settingClicked(v) }
    }


    private fun setHeaderText(){
        when(selectedSetting){
            "thw" -> {
                bigMessage.text = "Select the level that best matches your comfort navigating tripping hazards"
                headerText.text = "Tripping Hazard Alert"
            }
            "rsw" -> {
                headerText.text = "Running Slope Alert"
                bigMessage.text = "Select the level that best matches your comfort navigating running slopes"
                setButton.text = "Continue"}
            "csw" -> {
                headerText.text = "Cross Slope Alert"
                bigMessage.text = "Select the level that best matches your comfort navigating cross slopes"
                setButton.text = "Continue"}
            "row" -> {
                headerText.text = "Roughness Alert"
                bigMessage.text = "Select the level that best matches your comfort navigating rough sidewalks"
                setButton.text = "Continue"}
        }
        getDefaultSetting()
    }


    private fun getDefaultSetting(){
        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
        var defaultSetting = sharedPreferences.getInt(selectedSetting, 0)

        when(defaultSetting){
            1 -> veryUncomfortableButton.setBackgroundResource(R.drawable.group_btn_selected)
            2 -> mostlyComfortableButton.setBackgroundResource(R.drawable.group_btn_selected)
            3 -> veryComfortableButton.setBackgroundResource(R.drawable.group_btn_selected)
            4 -> completelyComfortableButton.setBackgroundResource(R.drawable.group_btn_selected)
        }
    }


    private fun settingClicked(v: View){
        newValue = curSettingValue
        veryUncomfortableButton.setBackgroundResource(R.drawable.group_btn_idle)
        mostlyComfortableButton.setBackgroundResource(R.drawable.group_btn_idle)
        veryComfortableButton.setBackgroundResource(R.drawable.group_btn_idle)
        completelyComfortableButton.setBackgroundResource(R.drawable.group_btn_idle)
        v.setBackgroundResource(R.drawable.group_btn_selected)

        when(v.id){
            veryUncomfortableButton.id -> newValue = 1
            mostlyComfortableButton.id -> newValue = 2
            veryComfortableButton.id -> newValue = 3
            completelyComfortableButton.id -> newValue = 4
        }
    }

//    fun goAlerts(v: View){
//        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
//        with (sharedPreferences.edit()) {
//            putInt(selectedSetting, newValue)
//            commit()
//        }
//
//        if(selectedSetting == "thw") {
//            val i = Intent(this, OnboardingAlertSettings::class.java)
//            i.putExtra("comfortSetting", selectedSetting)
//            startActivity(i)
//        } else {
//            setButton.text = "Continue"
//            val i = Intent(this, OnboardingObstructionTypes::class.java)
//            i.putExtra("comfortSetting", selectedSetting)
//            startActivity(i)
//        }
//    }


    fun goAlerts(v: View){
        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
            with (sharedPreferences.edit()) {
                putInt(selectedSetting, newValue)
                commit()
            }
        val uacctidInt = sharedPreferences.getInt("uacctid", 0)
        val thw = sharedPreferences.getInt("thw", 0)
        val rsw = sharedPreferences.getInt("rsw", 0)
        val csw = sharedPreferences.getInt("csw", 0)
        val row = sharedPreferences.getInt("row", 0)
        val thalert = sharedPreferences.getInt("thalert", 0)
        val rsalert = sharedPreferences.getInt("rsalert", 0)
        val csalert = sharedPreferences.getInt("csalert", 0)
        val roalert = sharedPreferences.getInt("roalert", 0)
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
                settingsParams["thw"] = thw.toString()
                settingsParams["rsw"] = rsw.toString()
                settingsParams["csw"] = csw.toString()
                settingsParams["row"] = row.toString()
                settingsParams["thalert"] = thalert.toString()
                settingsParams["rsalert"] = rsalert.toString()
                settingsParams["csalert"] = csalert.toString()
                settingsParams["roalert"] = roalert.toString()
                settingsParams["apitoken"] = getString(R.string.pathvu_api_key)
                return settingsParams
            }
        }
        settingsQueue.add(settingsRequest)
    }


    fun checkSettingsResponse(response: String){
        with(response){
            when{
                contains("usg001") -> Toast.makeText(applicationContext, R.string.account_error_contact_pathvu,
                    Toast.LENGTH_LONG).show()
                contains("usg003") -> Toast.makeText(applicationContext, R.string.account_error_contact_pathvu,
                    Toast.LENGTH_LONG).show()
                contains("usg002") -> Toast.makeText(applicationContext, R.string.account_error_contact_pathvu,
                    Toast.LENGTH_LONG).show()
                else -> continueSetting()
            }
        }
    }


    private fun continueSetting(){
        if(selectedSetting == "thw") {
            val i = Intent(this, OnboardingAlertSettings::class.java)
            i.putExtra("comfortSetting", selectedSetting)
            startActivity(i)
        } else {
            setButton.text = "Continue"
            val i = Intent(this, OnboardingObstructionTypes::class.java)
            i.putExtra("comfortSetting", selectedSetting)
            startActivity(i)
        }
    }


    fun back(v: View) {
        onBackPressed()
    }
}
