package com.pathvu.accesspath2020.model

data class Hazard (
    var hid: String,
    var htype: String,
    var hlat: String,
    var hlon: String,
    var uacctid: String,
    var hgeometry: String,
    var himgName: String,
    var himgPath: String,
    var hactive: String
)