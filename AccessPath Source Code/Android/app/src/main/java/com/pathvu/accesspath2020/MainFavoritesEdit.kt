package com.pathvu.accesspath2020

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.android.volley.RequestQueue
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import com.pathvu.accesspath2020.listener.CustomListener
import kotlinx.android.synthetic.main.activity_main_favorites_edit.*

/**
 * This activity allows the user to edit the name of a favorite place or delete the favorite place
 * altogether.
 */
class MainFavoritesEdit : AppCompatActivity() {

    companion object {
        //Place information
        lateinit var placeName: String
        lateinit var placeAddress: String
    }
    var uacctidInt = 0
    lateinit var queue: RequestQueue


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_favorites_edit)

        queue = Volley.newRequestQueue(this)

        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
        uacctidInt = sharedPreferences.getInt("uacctid", 0)

        placeNameBox.setText(placeName)
        placeAddressLabel.text = placeAddress


        /* On Click Listeners */
        renameFavoriteButton.setOnClickListener {
            val newName = placeNameBox.text.toString()
            if (placeName != newName) {
                updateFavorite(newName)
            }
        }

        removeFavoriteButton.setOnClickListener {
            removeFavorite()
        }

        cancelButton.setOnClickListener { onBackPressed() }
    }


    /**
     * Update favorite place's name
     */
    private fun updateFavorite(newName: String) {
        val updateFavoriteUrl = "https://pathvudata.com/accesspathweb/updatefavorite.php"
        val stringRequest = object : StringRequest(
            Method.POST, updateFavoriteUrl,
            Response.Listener<String> { response ->
                println("php response $response")
                val responseString = response.toString()
                checkUpdateResponse(responseString, newName)
            },
            Response.ErrorListener { println("error") })
        {
            override fun getParams(): MutableMap<String, String> {
                val params = HashMap<String, String>()
                params["acctid"] = uacctidInt.toString()
                params["fname"] = placeName
                params["fnewname"] = newName
                params["apitoken"] = getString(R.string.pathvu_api_key)
                return params
            }
        }
        queue.add(stringRequest)
    }


    /**
     * Check updating favorite place name response
     */
    fun checkUpdateResponse(response: String, newName: String) {
        println("check response $response")
        with(response) {
            when {
                startsWith("{\"error") -> Toast.makeText(applicationContext, response, Toast.LENGTH_LONG).show()
                else -> {
                    MainFavoritesInformation.placeName = newName
                    Toast.makeText(this@MainFavoritesEdit, "Updated favorite place", Toast.LENGTH_LONG).show()
                }
            }
        }
    }


    /**
     * Remove this favorite place from server
     */
    private fun removeFavorite() {
        val removeFavoriteUrl = "https://pathvudata.com/accesspathweb/removefavorite.php"
        val stringRequest = object : StringRequest(
            Method.POST, removeFavoriteUrl,
            Response.Listener<String> { response ->
                println("php response $response")
                val responseString = response.toString()
                checkRemoveResponse(responseString)
            },
            Response.ErrorListener { println("error") })
        {
            override fun getParams(): MutableMap<String, String> {
                val params = HashMap<String, String>()
                params["acctid"] = uacctidInt.toString()
                params["fname"] = placeName
                return params
            }
        }
        queue.add(stringRequest)
    }


    /**
     * Check remove request response
     */
    fun checkRemoveResponse(response: String) {
        println("check response $response")
        with(response) {
            when {
                startsWith("error") -> Toast.makeText(applicationContext, response, Toast.LENGTH_LONG).show()
                else -> {
                    val intent = Intent(this@MainFavoritesEdit, MainFavoritesList::class.java)
                    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                }
            }
        }
    }


    fun back(v: View?) {
        onBackPressed()
    }
}