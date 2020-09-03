package com.pathvu.accesspath2020.Util

import com.pathvu.accesspath2020.model.Path
import com.pathvu.accesspath2020.model.Point
//import sun.font.LayoutPathImpl.getPath
//import sun.text.normalizer.UTF16.append


/**
 * Route Directions (REST) and Closest Facility Directions (REST) results,
 * NACompactStreetDirection(SOAP, ArcObjects) have CompressedGeometry member
 * containing encoded route polyline, using which is an efficient way to deliver
 * route geometry to the client.
 *
 * The code shows a way to decompress CompressedGeometry into an array of
 * points.
 */
object CGDecoder {
    fun createPathFromCompressedGeometry(cgString: String): Path {
        val path = Path()
        var flags = 0
        val nIndex_XY = intArrayOf(0)
        val nIndex_Z = intArrayOf(0)
        val nIndex_M = intArrayOf(0)
        var dMultBy_XY = 0
        var dMultBy_Z = 0
        var dMultBy_M = 0
        val firstElement = extractInt(cgString, nIndex_XY)
        if (firstElement == 0) { // 10.0+ format
            val version = extractInt(cgString, nIndex_XY)
            require(version == 1) { "Compressed geometry: Unexpected version." }
            flags = extractInt(cgString, nIndex_XY)
            require(-0x4 and flags == 0) { "Compressed geometry: Invalid flags." }
            dMultBy_XY = extractInt(cgString, nIndex_XY)
        } else dMultBy_XY = firstElement
        var nLength = cgString.length
        if (flags != 0) {
            nLength = cgString.indexOf('|')
            if (flags and 1 == 1) {
                nIndex_Z[0] = nLength + 1
                dMultBy_Z = extractInt(cgString, nIndex_Z)
            }
            if (flags and 2 == 2) {
                nIndex_M[0] = cgString.indexOf('|', nIndex_Z[0]) + 1
                dMultBy_M = extractInt(cgString, nIndex_M)
            }
        }
        var nLastDiffX = 0
        var nLastDiffY = 0
        var nLastDiffZ = 0
        var nLastDiffM = 0
        while (nIndex_XY[0] < nLength) { // X
            val nDiffX = extractInt(cgString, nIndex_XY)
            val nX = nDiffX + nLastDiffX
            nLastDiffX = nX
            val dX = nX.toDouble() / dMultBy_XY
            // Y
            val nDiffY = extractInt(cgString, nIndex_XY)
            val nY = nDiffY + nLastDiffY
            nLastDiffY = nY
            val dY = nY.toDouble() / dMultBy_XY
            path.append(Point(dX, dY))
            if (flags and 1 == 1) { // has Zs
                val nDiffZ = extractInt(cgString, nIndex_Z)
                val nZ = nDiffZ + nLastDiffZ
                nLastDiffZ = nZ
                val dZ = nZ.toDouble() / dMultBy_Z
                path.path[path.path.size - 1].z = dZ
            }
            if (flags and 2 == 2) { // has Ms
                val nDiffM = extractInt(cgString, nIndex_M)
                val nM = nDiffM + nLastDiffM
                nLastDiffM = nM
                val dM = nM.toDouble() / dMultBy_M
                path.path[path.path.size - 1].m = dM
            }
        }
        return path
    }

    private fun extractInt(cgString: String, index: IntArray): Int {
        /**
         * Read one integer from compressed geometry string by using passed
         * position Returns extracted integer, and re-writes nStartPos for the
         * next integer
         */
        var i = index[0] + 1
        while (i < cgString.length && cgString[i] != '-' && cgString[i] != '+' && cgString[i] != '|'
        ) i++
        val sr32 = cgString.substring(index[0], i)
        index[0] = i
        return sr32.replace("+", "").toInt(32)
    }
}
