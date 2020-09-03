package com.pathvu.accesspath2020

import android.graphics.PorterDuff
import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import com.google.gson.Gson
import com.pathvu.accesspath2020.model.Address
import com.pathvu.accesspath2020.model.PlaceDetails
import kotlinx.android.synthetic.main.activity_main_recent_list.*
import org.json.JSONObject
import java.util.*
import kotlin.properties.Delegates

/**
 * This activity displays the user's 5 most recent paths. The user can click on a place to set
 * a path from the current destination to that place.
 */
class MainRecentList : AppCompatActivity() {

    private val mAddresses = ArrayList<PlaceDetails>()
    companion object {
        var fromLat by Delegates.notNull<Double>()
        var fromLng by Delegates.notNull<Double>()
        lateinit var fromAddress: String
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_recent_list)

        loadingBar.visibility = View.VISIBLE
        loadingBar.indeterminateDrawable.setColorFilter(
            ContextCompat.getColor(applicationContext, R.color.button_border),
            PorterDuff.Mode.SRC_IN
        )

        initList()
    }


    /**
     * Initialize and get the recent list
     */
    private fun initList() {
        val sharedPreferences = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)
        var uacctidInt = sharedPreferences.getInt("uacctid", 0)

        val queue = Volley.newRequestQueue(this)
        val getRecentUrl = "https://pathvudata.com/api1/api/users/recents?/*removed for security purposes*/uacctid=$uacctidInt"
        val stringRequest = object : StringRequest(
            Method.GET, getRecentUrl,
            Response.Listener<String> { response ->
//                println("php response: $response")
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
     * Check getting recent list request response
     */
    fun checkResponse(response: String) {
        with(response) {
            when {
                startsWith("{\"uf001") -> Toast.makeText(applicationContext,R.string.account_error_contact_pathvu, Toast.LENGTH_LONG).show()
                startsWith("{\"uf002") -> Toast.makeText(applicationContext, R.string.no_recent, Toast.LENGTH_LONG).show()
                else -> showRecentList(response)
            }
        }
    }


    /**
     * Display the recent list
     */
    private fun showRecentList(response: String) {
        loadingBar.visibility = View.INVISIBLE
        if (response.isNotEmpty()) {
            try {
                println(response)
                var recentJson = JSONObject(response)
                var recentList = recentJson.getJSONArray("recents")
                for (i in 0 until recentList.length()) {
                    val toAddress = recentList.getJSONObject(i).getString("raddress")
                    val toLat =  recentList.getJSONObject(i).getString("rlat")
                    val toLng =  recentList.getJSONObject(i).getString("rlon")
                    mAddresses.add(PlaceDetails("", toAddress, ArrayList<Address>(), toLat.toDouble(), toLng.toDouble(), "", "", 0, "", 0.toFloat()))
                }
                if (mAddresses.isNotEmpty()) {
                    initRecyclerView()
                } else {
                    noRecentPathsText.visibility = View.VISIBLE
                }
            } catch (t: Throwable) { //If no favorite places, take to the primer page to ask them to add their first
                println("Could not get recent")
                t.printStackTrace()
            }
        } else {
            noRecentPathsText.visibility = View.VISIBLE
            loadingBar.visibility = View.INVISIBLE
            println(response)
            println("Could not get favorites")
        }
    }


    /**
     * Initialize the recycler (list) view on the layout to contain all name/address values
     */
    private fun initRecyclerView() {
        val recyclerView = findViewById<RecyclerView>(R.id.recentRecyclerView)
        val adapter = RecyclerViewAdapterRecent(this, mAddresses, fromAddress, fromLat, fromLng)
        recyclerView.adapter = adapter
        recyclerView.layoutManager = LinearLayoutManager(this)
        loadingBar.visibility = View.INVISIBLE
    }


    fun back(v: View?) {
        onBackPressed()
    }
}