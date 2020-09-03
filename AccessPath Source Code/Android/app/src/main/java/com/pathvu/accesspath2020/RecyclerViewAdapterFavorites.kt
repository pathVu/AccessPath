package com.pathvu.accesspath2020

import android.content.Context
import android.content.Intent
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.pathvu.accesspath2020.model.FavoritePlace

/**
 * This class is the adapter for the favorite places recycler view. It initializes each item in the
 * by setting their name and address text. It also handles on-touch events for when a user clicks
 * on an item in the list.
 */
class RecyclerViewAdapterFavorites(private val mContext: Context, favoritePlaces: List<FavoritePlace>, currentLoc: String, currentLat: Double, currentLng: Double) :
    RecyclerView.Adapter<RecyclerViewAdapterFavorites.ViewHolder>() {
    private val mFavoritePlaces: List<FavoritePlace> = favoritePlaces
    private val fromLoc: String = currentLoc
    private val fromLat: Double = currentLat
    private val fromLng: Double = currentLng

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.list_item_layout, parent, false)
        return ViewHolder(view)
    }

    /**
     * Sets the text and on click listener for each item in the recycler view
     * @param holder The view of the item in the recycler view
     * @param position The position of the item in the arraylist
     */
    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        Log.d(TAG, "onBindViewHolder: called")
        holder.placeName.text = mFavoritePlaces[position].fname
        holder.address.text = mFavoritePlaces[position].faddress
        holder.parentLayout.setOnClickListener {
            Log.d(TAG, "onClick: clicked on: " + mFavoritePlaces[position].fname + " " + mFavoritePlaces[position].faddress)
            MainFavoritesInformation.placeName = mFavoritePlaces[position].fname
            MainFavoritesInformation.placeAddress = mFavoritePlaces[position].faddress
            MainFavoritesInformation.lat = mFavoritePlaces[position].flat
            MainFavoritesInformation.lng = mFavoritePlaces[position].flon
            MainFavoritesInformation.fromLoc = fromLoc
            MainFavoritesInformation.fromlat = fromLat.toString()
            MainFavoritesInformation.fromlng = fromLng.toString()
            val i = Intent(mContext, MainFavoritesInformation::class.java)
            mContext.startActivity(i)
        }
    }

    override fun getItemCount(): Int {
        return mFavoritePlaces.size
    }

    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var placeName: TextView = itemView.findViewById(R.id.placeName)
        var address: TextView = itemView.findViewById(R.id.placeAddress)
        var parentLayout: RelativeLayout = itemView.findViewById(R.id.mainLayout)
    }

    companion object {
        private const val TAG = "RecViewAdapterFavs"
    }

}