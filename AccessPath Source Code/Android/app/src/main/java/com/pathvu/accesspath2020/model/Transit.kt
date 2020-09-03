package com.pathvu.accesspath2020.model

import com.google.android.gms.maps.model.LatLng

data class Transit(
    val stop_name: String,
    val stop_type: String,
    val lat_lng: LatLng,
    val direction: String,
    val routes: String,
    val shelter: String
)