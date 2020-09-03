package com.pathvu.accesspath2020.model

class Point {
    var x = 0.0
    var y = 0.0
    var z = 0.0
    var m = 0.0

    constructor(x: Double, y: Double, z: Double, m: Double) {
        this.x = x
        this.y = y
        this.z = z
        this.m = m
    }

    constructor(x: Double, y: Double) {
        this.x = x
        this.y = y
    }

}