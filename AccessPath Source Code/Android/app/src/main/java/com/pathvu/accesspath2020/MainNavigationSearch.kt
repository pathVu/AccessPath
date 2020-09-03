package com.pathvu.accesspath2020

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.ListView
import android.widget.TextView
import com.android.volley.Request
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley.newRequestQueue
import kotlinx.android.synthetic.main.activity_main_navigation_search.*
import kotlinx.android.synthetic.main.search_layout.*
import org.json.JSONObject

class MainNavigationSearch : AppCompatActivity() {
    private lateinit var descList: ListView
    private lateinit var searchWatcher: TextWatcher

    override fun onCreate(savedInstanceState: Bundle?){
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_navigation_search)

        descList = findViewById<ListView>(R.id.searchList)

        searchListeners()
    }

    private fun searchListeners(){
         searchWatcher = object : TextWatcher{
            override fun afterTextChanged(s: Editable?) {
                getSearch()
            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
                //
            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                //
            }
        }

        searchField.addTextChangedListener(searchWatcher)
    }

    fun getSearch(){
        var myaddr = searchField.text.toString()

        if (myaddr != "") {

            val queue = newRequestQueue(this)
            val getUserUrl =
                "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$myaddr&inputtype=textquery/*removed for security purposes*/"
            val stringRequest = object : StringRequest(
                Request.Method.GET, getUserUrl,
                Response.Listener<String> { response ->
                    //println("php response" + response)
                    val responseString = response.toString()
                    //checkReponse(responseString)
                    //println(responseString)
                    showSearch(responseString)
                },
                Response.ErrorListener { println("error") }) {
                /*override fun getParams(): MutableMap<String, String> {
                val userParams = HashMap<String, String>()
                userParams.put("uacctid", idInt.toString())
                return userParams
            }*/
            }
            queue.add(stringRequest)
        }
    }

    fun showSearch(searchString: String){
        val descArray = arrayOfNulls<String>(5)
        val searchJson = JSONObject(searchString)
        val searchArray = searchJson.getJSONArray("predictions")
        for (i in 0 until searchArray.length()){
            val searchDescription = searchArray.getJSONObject(i).get("description")
            println(searchDescription)
            descArray[i] = searchDescription.toString()
        }
        showList(descArray as Array<String>)
    }

    private fun showList(descArray: Array<String>){
        searchList.setOnItemClickListener{parent, view, position, id ->
            descClicked(descArray, id)
        }
        val adapter = ArrayAdapter(this, R.layout.search_layout, descArray)
        descList.adapter = adapter
    }

    private fun descClicked(descArray: Array<String>, c: Long){
        val cint = c.toInt()
        println(descArray[cint])

        searchField.removeTextChangedListener(searchWatcher)

        searchField.setText(descArray[cint])

        searchListeners()
    }


}
