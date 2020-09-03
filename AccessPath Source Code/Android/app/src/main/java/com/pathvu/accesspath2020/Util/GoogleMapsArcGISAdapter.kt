package com.pathvu.accesspath2020.Util

import android.content.Context
import android.graphics.BitmapFactory
import android.graphics.Color
import android.os.Build
import android.util.Base64
import android.util.Log
import androidx.annotation.RequiresApi
import com.android.volley.Cache
import com.android.volley.DefaultRetryPolicy
import com.android.volley.RequestQueue
import com.android.volley.Response
import com.android.volley.toolbox.StringRequest
import com.android.volley.toolbox.Volley
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.model.*
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import com.pathvu.accesspath2020.model.CurbRamp
import com.pathvu.accesspath2020.model.Transit
import org.json.JSONObject
import java.net.URLEncoder

/**
 * Get transit, curb ramp and sidewalk information from ArcGIS and display these three layer on the map
 */
abstract class GoogleMapsArcGISAdapter(val url: StringBuilder, val map: GoogleMap, val context: Context) {
    abstract var layerType: String
    abstract var outputField: String

    abstract fun setupAndRender()
    abstract fun queryAndRender()

    fun getQueryItems(topRight: LatLng, bottomLeft: LatLng) {
        val bound = "{xmin:" + topRight.longitude.toString() + ",ymin:" + bottomLeft.latitude.toString() + ",xmax:" + bottomLeft.longitude.toString() + ",ymax=" + topRight.latitude.toString() + "}"
        url.append("outSR=" + URLEncoder.encode("4326", "utf8"))
        url.append("&returnGeometry=" + URLEncoder.encode("true", "utf8"))
        url.append("&inSR=" + URLEncoder.encode("4326", "utf8"))
        url.append("&returnDistinctValues=" + URLEncoder.encode("false", "utf8"))
        url.append("&maxAllowableOffset=" + URLEncoder.encode("0.000000", "utf8"))
        url.append("&spatialRel=" + URLEncoder.encode("esriSpatialRelEnvelopeIntersects", "utf8"))
        url.append("&geometryType=" + URLEncoder.encode("esriGeometryEnvelope", "utf8"))
        url.append("&outFields=" + URLEncoder.encode(outputField, "utf8"))
        url.append("&geometry=" + URLEncoder.encode(bound, "utf8"))
        url.append("&f=" + URLEncoder.encode("json", "utf8"))
        url.append("&returnZ=" + URLEncoder.encode("false", "utf8"))
        url.append("&returnM=" + URLEncoder.encode("false", "utf8"))
    }
}



open class MultiMarkerLayer(url: StringBuilder, map: GoogleMap, context: Context, var queue: RequestQueue, var locationMap: HashMap<Marker, String>) : GoogleMapsArcGISAdapter(url, map, context) {
    override lateinit var layerType: String
    override lateinit var outputField: String
    var originalURL: String = url.toString()
    var markerIcon = HashMap<String, BitmapDescriptor>()

    override fun setupAndRender() {
        val transitURL = "$originalURL?f=json"
        val stringRequest = @RequiresApi(Build.VERSION_CODES.O)
        object : StringRequest(
            Method.GET, transitURL.toString(),
            Response.Listener<String> { response ->
                val responseString = response.toString()
                val resJSON = JSONObject(responseString).getJSONObject("drawingInfo").getJSONObject("renderer").getJSONArray("uniqueValueInfos")
                for(i in 0 until resJSON.length()) {
                    val imageString = resJSON.getJSONObject(i).getJSONObject("symbol").getString("imageData")
                    val imageData = Base64.decode(imageString, Base64.DEFAULT)
                    val icon = BitmapFactory.decodeByteArray(imageData, 0, imageData.size)
                    val iconDescriptor = BitmapDescriptorFactory.fromBitmap(icon)
                    markerIcon[resJSON.getJSONObject(i).getString("value")] = iconDescriptor
                    if(!icon.isRecycled) {
                        icon.recycle()
                        System.gc()
                    }
                }
                queryAndRender()
            },
            Response.ErrorListener { error ->
                println("error: $error") })
        {

        }
        stringRequest.retryPolicy = DefaultRetryPolicy(50000, DefaultRetryPolicy.DEFAULT_MAX_RETRIES, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT)
        queue.add(stringRequest)
    }


    override fun queryAndRender() {
        val topRight = map.projection.visibleRegion.farRight
        val bottomLeft = map.projection.visibleRegion.nearLeft

        url.append("/query?")
        getQueryItems(topRight, bottomLeft)

        val stringRequest = @RequiresApi(Build.VERSION_CODES.O)
        object : StringRequest(
            Method.GET, url.toString(),
            Response.Listener<String> { response ->
                val responseString = response.toString()
                val resJSON = JSONObject(responseString).getJSONArray("features")
                for(i in 0 until resJSON.length()) {
                    val curJson = resJSON.getJSONObject(i)
                    val coord = LatLng(curJson.getJSONObject("geometry").getString("y").toDouble(), curJson.getJSONObject("geometry").getString("x").toDouble())
                    val attr = curJson.getJSONObject("attributes")
                    val stopType = attr.getString("stop_type")
                    val stopName = attr.getString("stop_name")
                    val direction = attr.getString("direction")
                    val shelter = attr.getString("shelter")
                    val routes = attr.getString("routes")
                    val transit = Transit(stopName, stopType, coord, direction, routes, shelter)
                    val markerOptions = MarkerOptions().position(coord)
                    markerOptions.icon(markerIcon[stopType])
                    val marker = map.addMarker(markerOptions)
                    marker.tag =transit
                    locationMap[marker] = MapLayers.transitType
                }
            },
            Response.ErrorListener { error ->
                println("error: $error") })
        {

        }
        stringRequest.retryPolicy = DefaultRetryPolicy(50000, DefaultRetryPolicy.DEFAULT_MAX_RETRIES, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT)
        queue.add(stringRequest)
    }
}



open class SingleMarkerLayer(url: StringBuilder, map: GoogleMap, context: Context, var queue: RequestQueue, var locationMap: java.util.HashMap<Marker, String>) : GoogleMapsArcGISAdapter(url, map, context) {
    override lateinit var layerType: String
    override lateinit var outputField: String
    var originalURL: String = url.toString()
    lateinit var markerIcon: BitmapDescriptor

    override fun setupAndRender() {
        val transitURL = "$originalURL?f=json"
        val stringRequest = @RequiresApi(Build.VERSION_CODES.O)
        object : StringRequest(
            Method.GET, transitURL,
            Response.Listener<String> { response ->
                val responseString = response.toString()
                val imageString = JSONObject(responseString).getJSONObject("drawingInfo").getJSONObject("renderer").getJSONObject("symbol").getString("imageData")
                val imageData = Base64.decode(imageString, Base64.DEFAULT)
                val icon = BitmapFactory.decodeByteArray(imageData, 0, imageData.size)
                markerIcon = BitmapDescriptorFactory.fromBitmap(icon)
                queryAndRender()
                if(!icon.isRecycled) {
                    icon.recycle()
                    System.gc()
                }
            },
            Response.ErrorListener { error ->
                println("error: $error") })
        {

        }
        stringRequest.retryPolicy = DefaultRetryPolicy(50000, DefaultRetryPolicy.DEFAULT_MAX_RETRIES, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT)
        queue.add(stringRequest)
    }


    override fun queryAndRender() {
        val topRight = map.projection.visibleRegion.farRight
        val bottomLeft = map.projection.visibleRegion.nearLeft

        url.append("/query?")
        getQueryItems(topRight, bottomLeft)

        val stringRequest = @RequiresApi(Build.VERSION_CODES.O)
        object : StringRequest(
            Method.GET, url.toString(),
            Response.Listener<String> { response ->
                val responseString = response.toString()
//                println("single part " + toPrettyFormat(responseString))
                val resJSON = JSONObject(responseString).getJSONArray("features")
                for(i in 0 until resJSON.length()) {
                    val curJson = resJSON.getJSONObject(i)
                    val coord = LatLng(curJson.getJSONObject("geometry").getString("y").toDouble(), curJson.getJSONObject("geometry").getString("x").toDouble())
                    val markerOptions = MarkerOptions().position(coord)
                    val attr = curJson.getJSONObject("attributes")
                    val lippage = attr.getString("lippage")
                    val userSlope = attr.getString("user_slope")
                    val overallCondition = attr.getString("overall_condition")
                    val imaeUrl = attr.getString("imageurl")
                    val curbRamp = CurbRamp(coord, lippage, userSlope, overallCondition, imaeUrl)
                    markerOptions.icon(markerIcon)
                    val marker = map.addMarker(markerOptions)
                    marker.tag = curbRamp
                    locationMap[marker] = MapLayers.curbRampType
                }
            },
            Response.ErrorListener { error ->
                println("error: $error") })
        {

        }
        stringRequest.retryPolicy = DefaultRetryPolicy(50000, DefaultRetryPolicy.DEFAULT_MAX_RETRIES, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT)
        queue.add(stringRequest)
    }
}



open class PathMarkerLayer(url: StringBuilder, map: GoogleMap, context: Context, var queue: RequestQueue) : GoogleMapsArcGISAdapter(url, map, context) {
    override lateinit var layerType: String
    override lateinit var outputField: String
    var originalURL: String = url.toString()
    var colorVal = HashMap<String, Float>()

    override fun setupAndRender() {
        val transitURL = "$originalURL?f=json"
        val stringRequest = @RequiresApi(Build.VERSION_CODES.O)
        object : StringRequest(
            Method.GET, transitURL,
            Response.Listener<String> { response ->
                val responseString = response.toString()
                val resJson = JSONObject(responseString).getJSONObject("drawingInfo").getJSONObject("renderer").getJSONArray("classBreakInfos")
                for(i in 0 until resJson.length()) {
                    val curJson = resJson.getJSONObject(i)
                    colorVal[curJson.getString("label")] = curJson.getString("classMaxValue").toFloat()
                }
                queryAndRender()
            },
            Response.ErrorListener { error ->
                println("error: $error") })
        {

        }
        stringRequest.retryPolicy = DefaultRetryPolicy(50000, DefaultRetryPolicy.DEFAULT_MAX_RETRIES, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT)
        queue.add(stringRequest)
    }


    override fun queryAndRender() {
        val topRight = map.projection.visibleRegion.farRight
        val bottomLeft = map.projection.visibleRegion.nearLeft

        url.append("/query?")
        getQueryItems(topRight, bottomLeft)

        val stringRequest = @RequiresApi(Build.VERSION_CODES.O)
        object : StringRequest(
            Method.GET, url.toString(),
            Response.Listener<String> { response ->
                val responseString = response.toString()
                val resJSON = JSONObject(responseString).getJSONArray("features")
                for(i in 0 until resJSON.length()) {
                    val curJson = resJSON.getJSONObject(i)
                    val paths = curJson.getJSONObject("geometry").getJSONArray("paths")
                    for(j in 0 until paths.length()) {
                        val curPath = paths.getJSONArray(j)
                        val p = PolylineOptions()
                        for(k in 0 until curPath.length()) {
                            val path = curPath[k].toString()
                            val curPathInfo = path.substring(1, path.length - 1).split(',')
                            p.add(LatLng(curPathInfo[1].toDouble(), curPathInfo[0].toDouble()))
                        }
                        val greenVal = colorVal["0.000000 - 1.000000"]
                        val yellowVal = colorVal["1.000001 - 3.000000"]
                        val redVal = colorVal["3.000001 - 224.500000"]
                        if(!curJson.getJSONObject("attributes").isNull("segment_rai")) {
                            if (curJson.getJSONObject("attributes").getString("segment_rai").toFloat() == 0.0.toFloat()) {
//                                p.color(Color.parseColor("#000000"))
//                                p.width(3.0f)
//                                map.addPolyline(p)
                            }
                            else if (curJson.getJSONObject("attributes").getString("segment_rai").toFloat() < greenVal!!) {
                                p.color(Color.parseColor("#00ff00"))
                                p.width(3.0f)
                                map.addPolyline(p)
                            }
                            else if (curJson.getJSONObject("attributes").getString("segment_rai").toFloat() < yellowVal!!) {
                                p.color(Color.parseColor("#ffff00"))
                                p.width(3.0f)
                                map.addPolyline(p)
                            }
                            else if (curJson.getJSONObject("attributes").getString("segment_rai").toFloat() < redVal!!) {
                                p.color(Color.parseColor("#ff0000"))
                                p.width(3.0f)
                                map.addPolyline(p)
                            }
                        } else {
                            p.color(Color.parseColor("#000000"))
                            p.width(3.0f)
                            map.addPolyline(p)
                        }
                    }
                }
            },
            Response.ErrorListener { error ->
                println("error: $error") })
        {

        }
        stringRequest.retryPolicy = DefaultRetryPolicy(50000, DefaultRetryPolicy.DEFAULT_MAX_RETRIES, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT)
        queue.add(stringRequest)
    }
}


class TransitLayer(url: StringBuilder, map: GoogleMap, context: Context, queue: RequestQueue, locationMap: java.util.HashMap<Marker, String>) : MultiMarkerLayer(url, map, context, queue, locationMap) {
    override var layerType: String = MapLayers.transitType
    override var outputField: String = "objectid,stop_name,stop_type,direction,shelter,routes"
}

class CurbRampLayerLayer(url: StringBuilder, map: GoogleMap, context: Context, queue: RequestQueue, locationMap: java.util.HashMap<Marker, String>) : SingleMarkerLayer(url, map, context, queue, locationMap) {
    override var layerType: String = MapLayers.curbRampType
    override var outputField: String = "detectable_warning,globalid,objectid,lippage,user_slope,overall_condition,imageurl"
}

class SidewalkLayer(url: StringBuilder, map: GoogleMap, context: Context, queue: RequestQueue) : PathMarkerLayer(url, map, context, queue) {
    override var layerType: String = MapLayers.sidewalkType
    override var outputField: String = "segment_rai,objectid,street_name"
}
