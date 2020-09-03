package com.pathvu.accesspath2020.model

import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName


//class FavoritePlace {
//    @SerializedName("name")
//    @Expose
//    var name: String? = null
//    @SerializedName("address")
//    @Expose
//    var address: String? = null
//    @SerializedName("lat")
//    @Expose
//    var lat: String? = null
//    @SerializedName("lon")
//    @Expose
//    var lon: String? = null
//    var isNotified = false
//}

data class FavoritePlace (
    @SerializedName("fname")
    @Expose
    var fname: String,
    @SerializedName("faddress")
    @Expose
    var faddress: String,
    @SerializedName("flat")
    @Expose
    var flat: String,
    @SerializedName("flon")
    @Expose
    var flon: String,
    var isNotified: Boolean
)
