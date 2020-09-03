package com.pathvu.accesspath2020.model

import java.util.*


class Path {
    val path = ArrayList<Point>()

    fun append(point: Point) {
        path.add(point)
    }

    fun print() {
        for (p in path) println("(" + p.x + ", " + p.y + ", " + p.z + ", " + p.m + ")")
    }

    operator fun get(i: Int): Point {
        return path[i]
    }
}
