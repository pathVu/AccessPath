package com.pathvu.accesspath2020.Util

import android.content.Context
import android.content.res.Resources
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.drawable.BitmapDrawable
import androidx.core.content.ContextCompat
import com.android.volley.DefaultRetryPolicy
import com.android.volley.RequestQueue
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.model.*
import com.google.gson.JsonArray
import com.google.gson.JsonObject
import com.pathvu.accesspath2020.R
import com.pathvu.accesspath2020.model.Entrance
import com.pathvu.accesspath2020.model.Hazard
import com.pathvu.accesspath2020.model.Indoor
import org.json.JSONArray
import org.json.JSONObject
import java.lang.StringBuilder
import java.util.HashMap

open class ObstructionMapLayer(val url: StringBuilder, val map: GoogleMap, val context: Context, val resources: Resources, var queue: RequestQueue, var locationMap: HashMap<Marker, String>) {
    open var type: String = ""
    open var prefix: String = ""
    lateinit var icon: BitmapDescriptor

    fun queryAndRender() {
        val northWest = map.projection.visibleRegion.farLeft
        val northEast = map.projection.visibleRegion.farRight
        val southWest = map.projection.visibleRegion.nearLeft
        val southEast = map.projection.visibleRegion.nearRight
        val stringRequest = object : StringRequest(
            Method.POST, url.toString(),
            Response.Listener<String> { response ->
//                println("php response hazards: $response")
                val responseString = response.toString()
                processResponse(responseString)
            },
            Response.ErrorListener { error ->
                println("error: $error") })
        {
            override fun getParams(): MutableMap<String, String> {
                val hazardsParams = HashMap<String, String>()
                hazardsParams["p1lon"] = northWest.longitude.toString()
                hazardsParams["p1lat"] = northWest.latitude.toString()
                hazardsParams["p2lon"] = northEast.longitude.toString()
                hazardsParams["p2lat"] = northEast.latitude.toString()
                hazardsParams["p3lon"] = southWest.longitude.toString()
                hazardsParams["p3lat"] = southWest.latitude.toString()
                hazardsParams["p4lon"] = southEast.longitude.toString()
                hazardsParams["p4lat"] = southEast.latitude.toString()
                return hazardsParams
            }
        }
        stringRequest.retryPolicy = DefaultRetryPolicy(50000, DefaultRetryPolicy.DEFAULT_MAX_RETRIES, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT)
        queue.add(stringRequest)
    }


    fun processResponse(response: String) {
        val height = 50
        val width = 50
        if(!response.contains("Undefined")) {
            var resJSON = JSONArray()
            if (type == "hazards")
                resJSON = JSONObject(response).getJSONArray("hazards")
            else if (type == "indoor" && !JSONObject(response).isNull("indoor"))
                resJSON = JSONObject(response).getJSONArray("indoor")
            else if (type == "entrance" && !JSONObject(response).isNull("entrance"))
                resJSON = JSONObject(response).getJSONArray("entrance")

            val locationSet = HashSet<String>()  // avoid location duplicate
            for (i in 0 until resJSON.length()) {
                val curJson = resJSON.getJSONObject(i)
                var geometry = ""
                geometry = if (type == "hazards") curJson.getString("hgeometry") else if (type == "indoor") curJson.getString("igeometry") else curJson.getString("egeometry")
                if (!locationSet.contains(geometry)) {
                    locationSet.add(geometry)
                    val id = curJson.getString(prefix + "id")
                    val lat = curJson.getString(prefix + "lat")
                    val lng = curJson.getString(prefix + "lon")
                    val uacctid = curJson.getString("uacctid")
                    val imageName = curJson.getString((prefix + "imgname"))
                    val imagePath = curJson.getString(prefix + "imgpath")

                    if (type == "hazards") {
                        val hazardObj = Hazard(id, curJson.getString("htype"), lat, lng, uacctid, geometry, imageName, imagePath, curJson.getString(prefix + "active"))
                        val markerOptions = MarkerOptions().position(LatLng(lat.toDouble(), lng.toDouble()))
                        markerOptions.icon(BitmapDescriptorFactory.fromBitmap(BitmapFactory.decodeResource(resources, R.mipmap.hazard_icon_yellow)))
                        val marker = map.addMarker(markerOptions)
                        marker.tag = hazardObj
                        locationMap[marker] = "hazards"

                    } else if (type == "indoor") {
                        val ramp = curJson.getString("ioramp")
                        val steps = curJson.getString("iosteps")
                        val tid = curJson.getString("rtid")
                        val restroomStep = curJson.getString("iorestroomsteps")
                        val spacious = curJson.getString("iospacious")
                        val braillemu = curJson.getString("iobraillemnu")
                        val indoorObj = Indoor(curJson.getString("iaid"), curJson.getString("iaaddress"), curJson.getString("ialat"), curJson.getString("ialon"), uacctid, curJson.getString("igeometry"), imageName, imagePath, curJson.getString("iactive"), ramp, steps, tid, restroomStep, spacious, braillemu)
                        val bitmapdraw = ContextCompat.getDrawable(context, R.mipmap.indoor_accessibility_icon) as BitmapDrawable
                        val b = bitmapdraw.bitmap
                        val smallMarker = Bitmap.createScaledBitmap(b, width, height, false)

                        val markerOptions = MarkerOptions().position(LatLng(curJson.getString("ialat").toDouble(), curJson.getString("ialon").toDouble()))
                        markerOptions.icon(BitmapDescriptorFactory.fromBitmap(smallMarker))
                        val marker = map.addMarker(markerOptions)
                        marker.tag = indoorObj
                        locationMap[marker] = "indoor"

                    } else if (type == "entrance") {
                        val bitmapdraw = ContextCompat.getDrawable(context, R.mipmap.entrance_icon) as BitmapDrawable
                        val b = bitmapdraw.bitmap
                        val smallMarker = Bitmap.createScaledBitmap(b, width, height, false)

                        val markerOptions = MarkerOptions().position(LatLng(lat.toDouble(), lng.toDouble()))
                        markerOptions.icon(BitmapDescriptorFactory.fromBitmap(smallMarker))
                        val entranceObj = Entrance(id, curJson.getString("eaddress"), lat, lng, uacctid, curJson.getString("egeometry"), imageName, imagePath, curJson.getString(prefix + "active"), curJson.getString("aeramp"), curJson.getString("aesteps"), curJson.getString("eoautodoor"))
                        val marker = map.addMarker(markerOptions)
                        marker.tag = entranceObj
                        locationMap[marker] = "entrance"
                    }
                }
            }
        }
    }
}


class HazardLayer(url: StringBuilder, map: GoogleMap, context: Context, resource: Resources, queue: RequestQueue, locationMap: HashMap<Marker, String>): ObstructionMapLayer(url, map, context, resource, queue, locationMap) {
    override var type = "hazards"
    override var prefix = "h"
}


class IndoorLayer(url: StringBuilder, map: GoogleMap, context: Context, resource: Resources, queue: RequestQueue, locationMap: HashMap<Marker, String>): ObstructionMapLayer(url, map, context, resource, queue, locationMap) {
    override var type = "indoor"
    override var prefix = "ia"
}


class EntranceLayer(url: StringBuilder, map: GoogleMap, context: Context, resource: Resources, queue: RequestQueue, locationMap: HashMap<Marker, String>): ObstructionMapLayer(url, map, context, resource, queue, locationMap) {
    override var type = "entrance"
    override var prefix = "e"
}