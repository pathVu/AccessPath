package com.pathvu.accesspath2020

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.BitmapFactory
import android.provider.ContactsContract
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import com.google.android.gms.maps.model.Marker
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.pathvu.accesspath2020.Util.MapLayers
import com.pathvu.accesspath2020.model.*
import kotlinx.android.synthetic.main.curbramp_layer_info.*
import kotlinx.android.synthetic.main.entrance_layer_info.*
import kotlinx.android.synthetic.main.indoor_layer_info.*
import kotlinx.android.synthetic.main.indoor_layer_info.addressValue
import kotlinx.android.synthetic.main.indoor_layer_info.restroomRampValue
import kotlinx.android.synthetic.main.indoor_layer_info.restroomStepValue
import kotlinx.android.synthetic.main.indoor_layer_info.restroomTypeValue
import kotlinx.android.synthetic.main.transit_layer_info.*
import java.io.IOException
import java.net.MalformedURLException
import java.net.URL

class AccessPathBottomSheetDialog(context: Context, theme: Int) : BottomSheetDialog(context, theme) {

    /*
     * Inflate layout for hazard information in bottom sheet dialog
     * Parse data from feature query result and set onto the views
     **/
    private fun setHazardLayerBottomSheetDialog(hazard: Hazard) {
        val sheetView = layoutInflater.inflate(R.layout.hazard_layer_info, null)
        this.setContentView(sheetView)
        val hazardType = sheetView.findViewById<TextView>(R.id.hazardType)
        val cancel = sheetView.findViewById<ImageView>(R.id.ivCancelHazard)
        val hazardPicture = sheetView.findViewById<ImageView>(R.id.imageV)
        try {
            val pictureUrl = (hazard.himgPath + hazard.himgName).replace("http", "https")
            if (pictureUrl.isNotEmpty()) {
                val url = URL(pictureUrl)
                val bmp = BitmapFactory.decodeStream(url.openConnection().getInputStream())
                if (bmp != null) {
                    hazardPicture.setImageBitmap(bmp)
                } else {
                    hazardPicture.setImageResource(R.drawable.no_img_available)
                }
            } else {
                hazardPicture.setImageResource(R.drawable.no_img_available)
            }
        } catch (e: MalformedURLException) {
            hazardPicture.setImageResource(R.drawable.no_img_available)
            e.printStackTrace()
        } catch (e: IOException) {
            hazardPicture.setImageResource(R.drawable.no_img_available)
            e.printStackTrace()
        }

        val ctyid = hazard.htype.toInt()
        when (ctyid) {
            1 -> hazardType.setText(R.string.tripping_hazard)
            2 -> hazardType.setText(R.string.no_sidewalk)
            3 -> hazardType.setText(R.string.no_curb_ramp)
            4 -> hazardType.setText(R.string.construction_btn)
            5 -> hazardType.setText(R.string.other)
        }
        cancel.setOnClickListener { hideBottomSheet() }
    }


    @SuppressLint("SetTextI18n")
    private fun setIndoorLayerBottomSheetDialog(indoor: Indoor) {
        val sheetView = layoutInflater.inflate(R.layout.indoor_layer_info, null)
        this.setContentView(sheetView)
        val cancel = sheetView.findViewById<ImageView>(R.id.ivCancelIndoor)
        val indoorPicture = sheetView.findViewById<ImageView>(R.id.imageV)
        try {
            val pictureUrl = (indoor.iaimgpath + indoor.iaimgname).replace("http", "https")
            if (pictureUrl.isNotEmpty()) {
                val url = URL(pictureUrl)
                val bmp = BitmapFactory.decodeStream(url.openConnection().getInputStream())
                if (bmp != null) {
                    indoorPicture.setImageBitmap(bmp)
                } else {
                    indoorPicture.setImageResource(R.drawable.no_img_available)
                }
            } else {
                indoorPicture.setImageResource(R.drawable.no_img_available)
            }
        } catch (e: MalformedURLException) {
            indoorPicture.setImageResource(R.drawable.no_img_available)
            e.printStackTrace()
        } catch (e: IOException) {
            indoorPicture.setImageResource(R.drawable.no_img_available)
            e.printStackTrace()
        }

        addressValue.text = indoor.iaaddress
        restroomStepValue.text = if(indoor.iorestroomsteps == "null") "" else indoor.iorestroomsteps + " steps"
        restroomRampValue.text = if(indoor.ioramp == "1") "yes" else "no"
        val restroom: String = indoor.rtid.substring(1, indoor.rtid.length - 1)
        if(restroom == "" || restroom == "-1") {
            restroomTypeValue.text = ""
        } else {
            val restroomSetting = restroom.split(",")
            val gender = if(restroomSetting[0] == "1") "yes" else "no"
            val family = if(restroomSetting[1] == "1") "yes" else "no"
            val ADA = if(restroomSetting[2] == "1") "yes" else "no"
            val lock = if(restroomSetting[3] == "1") "yes" else "no"
            restroomTypeValue.text = "Male/Female: $gender, Family: $family, ADA Accessible: $ADA, Locked Door: $lock"
        }
        brailleValue.text = if(indoor.iobraillemnu == "1") "yes" else "no"
        spaciousValue.text = if(indoor.iospacious == "1") "yes" else "no"

        cancel.setOnClickListener { hideBottomSheet() }
    }


    private fun setEntranceLayerBottomSheetDialog(entrance: Entrance) {
        val sheetView = layoutInflater.inflate(R.layout.entrance_layer_info, null)
        this.setContentView(sheetView)
        val indoorPicture = sheetView.findViewById<ImageView>(R.id.imageV)
        try {
            val pictureUrl = (entrance.eimgPath + entrance.eimgName).replace("http", "https")
            if (pictureUrl.isNotEmpty()) {
                val url = URL(pictureUrl)
                val bmp = BitmapFactory.decodeStream(url.openConnection().getInputStream())
                if (bmp != null) {
                    indoorPicture.setImageBitmap(bmp)
                } else {
                    indoorPicture.setImageResource(R.drawable.no_img_available)
                }
            } else {
                indoorPicture.setImageResource(R.drawable.no_img_available)
            }
        } catch (e: MalformedURLException) {
            indoorPicture.setImageResource(R.drawable.no_img_available)
            e.printStackTrace()
        } catch (e: IOException) {
            indoorPicture.setImageResource(R.drawable.no_img_available)
            e.printStackTrace()
        }

        addressValue.text = entrance.eaddress
        automaticValue.text = if(entrance.eactive == "1") "yes" else "no"
        stepValue.text = if(entrance.aesteps == "2") "2+ steps" else entrance.aesteps + " steps"
        rampValue.text = if(entrance.aeramp == "1") "yes" else "no"

        ivCancelHazard.setOnClickListener { hideBottomSheet() }
    }


    private fun setCurbRampLayerBottomSheetDialog(curbRamp: CurbRamp) {
        val sheetView = layoutInflater.inflate(R.layout.curbramp_layer_info, null)
        this.setContentView(sheetView)
        val cancel = sheetView.findViewById<ImageView>(R.id.ivCancelCurb)
        val curbImage = sheetView.findViewById<ImageView>(R.id.curbrampImage)
        try {
            var pictureUrl = ""
            pictureUrl = if(curbRamp.imageUrl.contains("https")) {
                curbRamp.imageUrl
            } else {
                (curbRamp.imageUrl).replace("http", "https")
            }
            if (pictureUrl.isNotEmpty()) {
                val url = URL(pictureUrl)
                val bmp = BitmapFactory.decodeStream(url.openConnection().getInputStream())
                if (bmp != null) {
                    curbImage.setImageBitmap(bmp)
                } else {
                    curbImage.setImageResource(R.drawable.no_img_available)
                }
            } else {
                curbImage.setImageResource(R.drawable.no_img_available)
            }
        } catch (e: MalformedURLException) {
            curbImage.setImageResource(R.drawable.no_img_available)
            e.printStackTrace()
        } catch (e: IOException) {
            curbImage.setImageResource(R.drawable.no_img_available)
            e.printStackTrace()
        }

        when(curbRamp.user_slope) {
            "1" -> slopeValue.text = "Poor"
            "2" -> slopeValue.text = "Moderate"
            "3" -> slopeValue.text = "Good"
        }
        when(curbRamp.overall_condition) {
            "1" -> qualityValue.text = "Poor"
            "2" -> qualityValue.text = "Moderate"
            "3" -> qualityValue.text = "Good"
        }
        when(curbRamp.lippage) {
            "1" -> lippageValue.text = "Poor"
            "2" -> lippageValue.text = "Moderate"
            "3" -> lippageValue.text = "Good"
        }

        cancel.setOnClickListener { hideBottomSheet() }
    }


    private fun setTransitLayerBottomSheetDialog(transit: Transit) {
        val sheetView = layoutInflater.inflate(R.layout.transit_layer_info, null)
        this.setContentView(sheetView)
        val cancel = sheetView.findViewById<ImageView>(R.id.ivCancelTransit)
        stopType.text = transit.stop_type
        stopNameValue.text = transit.stop_name
        directionValue.text = transit.direction
        routeValue.text = transit.routes
        shelterValue.text = transit.shelter

        cancel.setOnClickListener { hideBottomSheet() }
    }


    private fun hideBottomSheet() {
        dismiss()
    }


    companion object {
        private var mLayerType: String? = null
        private var mMarker: Marker? = null
        private var mContext: Context? = null
        fun getInstance(context: Context, theme: Int, layerType: String?, marker: Marker?): AccessPathBottomSheetDialog {
            mLayerType = layerType
            mMarker = marker
            mContext = context
            return AccessPathBottomSheetDialog(context, theme)
        }
    }

    init {
        if (mLayerType == "hazards") {
            setHazardLayerBottomSheetDialog(mMarker?.tag as Hazard)
        } else if (mLayerType == "indoor") {
            setIndoorLayerBottomSheetDialog(mMarker?.tag as Indoor)
        } else if (mLayerType == "entrance") {
            setEntranceLayerBottomSheetDialog(mMarker?.tag as Entrance)
        } else if(mLayerType == MapLayers.transitType) {
            setTransitLayerBottomSheetDialog(mMarker?.tag as Transit)
        } else if(mLayerType == MapLayers.curbRampType) {
            setCurbRampLayerBottomSheetDialog(mMarker?.tag as CurbRamp)
        }
    }
}
