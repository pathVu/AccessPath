package com.pathvu.accesspath2020.Util

import com.pathvu.accesspath2020.Util.CGDecoder.createPathFromCompressedGeometry

/**
 * Route Directions (REST) and Closest Facility Directions (REST) results,
 * NACompactStreetDirection(SOAP, ArcObjects) have CompressedGeometry member
 * containing encoded route polyline, using which is an efficient way to
 * deliver route geometry to the client.
 *
 * The code shows a way to decompress CompressedGeometry into an array of points.
 *
 * SAMPLE CLASS
 */
object CGDecoderClient {
    @JvmStatic
    fun main(args: Array<String>) {
        println("Compressed geometry with no Ms, no Zs:")
        createPathFromCompressedGeometry("+0+1+2+pjno0-1vvvvtl+10c6pip+0+0|+1vvvvvv+0+0").print()

        println("Compressed geometry with Ms, no Zs:")
        createPathFromCompressedGeometry("+0+1+2+pjno0-1vvvvtl+10c6pip+5qt+a04+n8+1tf-6k+29o-l0+1vr|+1vvvvvv+0+0+0+0+0").print()

        println("Compressed geometry with no Ms but with Zs:")
        createPathFromCompressedGeometry("+0+1+2+pjnpj-1vvvu6h+10c7bqe-1nk+330|+1vvvvvv+0+0").print()

        println("Compressed geometry with both Ms, Zs:")
        createPathFromCompressedGeometry("+0+1+2+pjn5e-1vvudin+10c6le3-3q8-14s-1bl3-cmp-13a-a5-1op-1f6|+1vvvvvv+0+0+0+0+0").print()
    }
}
