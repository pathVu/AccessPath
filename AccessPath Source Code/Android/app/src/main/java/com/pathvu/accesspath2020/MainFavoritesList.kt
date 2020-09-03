package com.pathvu.accesspath2020

import android.content.Intent
import android.content.SharedPreferences
import android.graphics.PorterDuff
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import com.google.gson.Gson
import com.pathvu.accesspath2020.listener.CustomListener
import com.pathvu.accesspath2020.model.FavoritePlace
import kotlinx.android.synthetic.main.activity_main_favorites_list.*
import org.json.JSONObject

/**
 * This activity displays a list of the user's favorite places. The user can click on a place to
 * view the place's information. The user also has the option of adding a place to the list. If
 * the user has no favorites (i.e. the list is empty), the favorites primer activity is displayed.
 */
class MainFavoritesList : AppCompatActivity(), View.OnClickListener {

    private val TAG = "MainFavoritesList"
    companion object{
        lateinit var currentLoc: String
        var currentLat: Double = 0.0
        var currentLng: Double = 0.0
    }

    private lateinit var prefs: SharedPreferences

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_favorites_list)

        NetworkManager.getInstance(this)

        hideFavoritesPrimer()
        loadingBar.visibility = View.VISIBLE
        loadingBar.indeterminateDrawable.setColorFilter(
            ContextCompat.getColor(applicationContext, R.color.button_border),
            PorterDuff.Mode.SRC_IN
        )
        prefs = this.getSharedPreferences("pathVuPrefs", android.content.Context.MODE_PRIVATE)

        /* On Click Listeners */ //Add Favorite: Take the user to the add favorite activity
        addFavoriteButton.setOnClickListener(this)
        cancelButton.setOnClickListener(this)
        addFirstFavoritePlaceButton.setOnClickListener(this)

        initList()
    }


    override fun onClick(p0: View?) {
        if (p0 != null) {
            when (p0.id) {
                R.id.addFavoriteButton -> {
                    val intent = Intent(this@MainFavoritesList, MainFavoritesAdd::class.java)
                    startActivity(intent)
                }
                R.id.cancelButton -> {
                    val i = Intent(this@MainFavoritesList, MainNavigationHome::class.java)
                    startActivity(i)
                    finish()
                }
                R.id.addFirstFavoritePlaceButton -> {
                    val addFavIntent = Intent(this@MainFavoritesList, MainFavoritesAdd::class.java)
                    startActivity(addFavIntent)
                }
            }
        }
    }


    /**
     * Hide the views for primer screen and shows the list for favorite places.
     * */
    private fun hideFavoritesPrimer() {
        favoritesRecyclerView.visibility = View.VISIBLE
        redHeartImage.visibility = View.GONE
        bigMessage.visibility = View.GONE
        addFirstFavoritePlaceButton.visibility = View.GONE
        addFirstFavoritePlaceButtonImage.visibility = View.GONE
    }


    /**
     * Hide the view for list for favorite places and shows the primer screen.
     * */
    private fun showFavoritesPrimer() {
        favoritesRecyclerView.visibility = View.GONE
        redHeartImage.visibility = View.VISIBLE
        bigMessage.visibility = View.VISIBLE
        addFirstFavoritePlaceButton.visibility = View.VISIBLE
        addFirstFavoritePlaceButtonImage.visibility = View.VISIBLE
    }


    /**
     * Initialize the recycler (list) view on the layout to contain all name/address values
     */
    private fun initRecyclerView(favoritePlaces: List<FavoritePlace>) {
        Log.d(TAG, "initRecyclerView: started")
        val adapter = RecyclerViewAdapterFavorites(this, favoritePlaces, currentLoc, currentLat, currentLng)
        adapter.notifyDataSetChanged()
        favoritesRecyclerView.adapter = adapter
        favoritesRecyclerView.layoutManager = LinearLayoutManager(this)
        loadingBar.visibility = View.INVISIBLE
    }


    /**
     * Get user's favorite list from server
     */
    private fun initList() {
        NetworkManager.getInstance()
            ?.getFavorite(prefs, object : CustomListener<String?> {
                override fun getResult(result: String?) {
                    if (result != null) {
                        if (result.isNotEmpty()) {
                            try {
                                loadingBar.visibility = View.INVISIBLE
                                println(result)
                                checkResponse(result)
                            } catch (t: Throwable) {
                                println("Could not get recent")
                                t.printStackTrace()
                            }
                        } else {
//                            println("Added recent place")
                        }
                    }
                }
            })
    }


    /**
     * Check getting favorite list request response
     */
    fun checkResponse(response: String) {
        with(response) {
            when {
                startsWith("{\"uf001") -> Toast.makeText(applicationContext,R.string.account_error_contact_pathvu, Toast.LENGTH_LONG).show()
                startsWith("{\"uf002") -> Toast.makeText(applicationContext, R.string.no_favorites, Toast.LENGTH_LONG).show()
                else -> showFavoritesList(response)
            }
        }
    }


    /**
     * Show user's favorite place list
     */
    private fun showFavoritesList(response: String) {
        loadingBar.visibility = View.INVISIBLE
        if (response.isNotEmpty()) {
            try {
                val favoriteJson = JSONObject(response)
                val favoriteList = favoriteJson.getString("favorites")
                val favoritePlaces = listOf<FavoritePlace>(*Gson().fromJson<Array<FavoritePlace>>(favoriteList, Array<FavoritePlace>::class.java))
                //If there are no favorite places navigate to Favorites Primer screen
                if (favoritePlaces.isNotEmpty()) {
                    hideFavoritesPrimer()
                    initRecyclerView(favoritePlaces)
                } else {
                    showFavoritesPrimer()
                }
            } catch (t: Throwable) { //If no favorite places, take to the primer page to ask them to add their first
                showFavoritesPrimer()
                println("Could not get favorites")
                t.printStackTrace()
            }
        } else {
            showFavoritesPrimer()
            println(response)
            println("Could not get favorites2")
        }
    }


    /**
     * (Function called from XML)
     * Use Android's stack to take user to the previous screen.
     */
    fun back(v: View?) {
        onBackPressed()
    }
}
