package com.pathvu.accesspath2020.model

import com.google.android.gms.maps.model.LatLng

data class CurbRamp(
    val lat_lng: LatLng,
    val lippage: String,
    val user_slope: String,
    val overall_condition: String,
    val imageUrl: String
)