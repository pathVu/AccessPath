package com.pathvu.accesspath2020

import android.annotation.SuppressLint
import android.app.Dialog
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.Point
import android.graphics.drawable.ColorDrawable
import android.os.Build
import android.view.*
import android.widget.Button
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.recyclerview.widget.RecyclerView
import com.pathvu.accesspath2020.Util.Utility.convertMeterToFeet
import com.pathvu.accesspath2020.model.PlaceDetails
import kotlinx.android.synthetic.main.fragment_nearby_detail.*


class RecyclerViewAdapterNearby(private val mContext: Context, nearbyPlaces: ArrayList<PlaceDetails>, currentLoc: String, currentLat: Double, currentLng: Double) :
    RecyclerView.Adapter<RecyclerViewAdapterNearby.ViewHolder>() {
    private val mNearbyPaces: List<PlaceDetails> = nearbyPlaces
    private val fromLoc: String = currentLoc
    private val fromLat: Double = currentLat
    private val fromLng: Double = currentLng

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerViewAdapterNearby.ViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.nearby_list_item_layout, parent, false)
        val params = view.layoutParams
        val width = getScreenHeight(mContext)[0]
        params.width = width * 7 / 8
        view.layoutParams = params
        return ViewHolder(view)
    }


    override fun getItemCount(): Int {
        return mNearbyPaces.size
    }


    /**
     * Sets the text and on click listener for each item in the recycler view
     * @param holder The view of the item in the recycler view
     * @param position The position of the item in the arraylist
     */
    @SuppressLint("SetTextI18n")
    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.placeName.text = mNearbyPaces[position].name
        holder.distance.text = convertMeterToFeet(mNearbyPaces[position].distance.toDouble()).toString() + " feet"

        val mDialog = Dialog(mContext)
        mDialog.setContentView(R.layout.fragment_nearby_detail)
        mDialog.window?.attributes?.gravity  = Gravity.RIGHT
        val width = getScreenHeight(mContext)[0]
        val height =getScreenHeight(mContext)[1]
        mDialog.window?.setLayout(width * 2 / 3, height)
        mDialog.window?.setBackgroundDrawable(ColorDrawable(Color.WHITE))
        mDialog.placeName.text = mNearbyPaces[position].name
        mDialog.distance.text = String.format("%.1f", mNearbyPaces[position].distance) + " feet"
        mDialog.vicinity.text = mNearbyPaces[position].vicinity
        val closeBtn = mDialog.findViewById<Button>(R.id.cancelButton)
        closeBtn.setOnClickListener { mDialog.dismiss() }
        mDialog.closeWindow.setOnClickListener { mDialog.dismiss() }
        mDialog.setPathButton.setOnClickListener {
            MainSetANewPathMap.fromAddress = fromLoc
            MainSetANewPathMap.fromLat = fromLat.toString()
            MainSetANewPathMap.fromLng = fromLng.toString()
            MainSetANewPathMap.destAddress = mNearbyPaces[position].vicinity
            MainSetANewPathMap.toLat = mNearbyPaces[position].lat.toString()
            MainSetANewPathMap.toLng = mNearbyPaces[position].lng.toString()
            val i = Intent(mContext, MainSetANewPathMap::class.java)
            mContext.startActivity(i)
        }

        holder.parentLayout.setOnClickListener {
            mDialog.show()
        }
    }


    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var placeName: TextView = itemView.findViewById(R.id.placeName)
        var distance: TextView = itemView.findViewById(R.id.placeDistance)
        var parentLayout: RelativeLayout = itemView.findViewById(R.id.mainLayout)
    }


    private fun getScreenHeight(context: Context): IntArray {
        val layoutArr = IntArray(2)
        if (Build.VERSION.SDK_INT >= 13) {
            val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
            val display = wm.defaultDisplay
            val size = Point()
            display.getSize(size)
            layoutArr[0] = size.x
            layoutArr[1] = size.y
        } else {
            val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
            val display = wm.defaultDisplay
            layoutArr[1] = display.height // deprecated
            layoutArr[0] = display.width // deprecated
        }
        return layoutArr
    }

}