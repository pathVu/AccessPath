package com.pathvu.accesspath2020

import android.content.Context
import android.content.Intent
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.google.android.libraries.places.api.model.Place
import com.pathvu.accesspath2020.model.PlaceDetails

/**
 * This class is the adapter for the recent paths recycler view. It initializes each item in the
 * by setting their address text. It also handles on-touch events for when a user clicks on an item
 * in the list.
 */
class RecyclerViewAdapterRecent(private val mContext: Context, recentAddresses: List<PlaceDetails>, currentLoc: String, currentLat: Double, currentLng: Double) :
    RecyclerView.Adapter<RecyclerViewAdapterRecent.ViewHolder>() {

    private val mRecentPlaces: List<PlaceDetails> = recentAddresses
    private val fromLoc: String = currentLoc
    private val fromLat: Double = currentLat
    private val fromLng: Double = currentLng


    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.recent_list_item_layout,  parent, false)
        return ViewHolder(view)
    }


    override fun getItemCount(): Int {
        return mRecentPlaces.size
    }


    /**
     * Sets the text and on click listener for each item in the recycler view
     * @param holder The view of the item in the recycler view
     * @param position The position of the item in the arraylist
     */
    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.address.text = mRecentPlaces[position].name
        holder.parentLayout.setOnClickListener(View.OnClickListener {
            MainSetANewPathMap.recent = true
            MainSetANewPathMap.fromAddress = fromLoc
            MainSetANewPathMap.fromLat = fromLat.toString()
            MainSetANewPathMap.fromLng = fromLng.toString()
            MainSetANewPathMap.destAddress = mRecentPlaces[position].name
            MainSetANewPathMap.toLat = mRecentPlaces[position].lat.toString()
            MainSetANewPathMap.toLng = mRecentPlaces[position].lng.toString()
            val i = Intent(mContext, MainSetANewPathMap::class.java)
            mContext.startActivity(i)
        })
    }


    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var address: TextView = itemView.findViewById(R.id.placeAddress)
        var parentLayout: RelativeLayout = itemView.findViewById(R.id.mainLayout)

    }
}