//
//  CGDecoder.swift
//  Access Path
//
//  Created by Alan Barker on 1/15/20.
//  Copyright © 2020 pathVu. All rights reserved.
//

import Foundation

struct CGPoint {
    private(set) var x: Double = 0
    private(set) var y: Double = 0
    var z: Double = 0
    var m: Double = 0
    
    init(x: Double, y: Double, z: Double = 0, m: Double = 0) {
        self.x = x
        self.y = y
        self.z = z
        self.m = m
    }
}

class CGDecoder {
    func CreatePathFromCG(cgString: String) -> [CGPoint]? {
        var points = [CGPoint]()
        
        var flags: UInt32 = 0
        var nIndex_XY: Int = 0
        var nIndex_Z: Int = 0
        var nIndex_M: Int = 0
        var dMultBy_XY: Double = 0
        var dMultBy_Z: Double = 0
        var dMultBy_M: Double = 0
        
        guard let firstElement = ExtractInt(cgString: cgString, index: &nIndex_XY) else {
            debugPrint("Compressed geometry: Parse int failure")
            return nil
        }
        
        if firstElement == 0 { // 10.0 format
            guard let version = ExtractInt(cgString: cgString, index: &nIndex_XY) else {
                debugPrint("Compressed geometry: Parse int failure")
                return nil
            }
            if version != 1 {
                debugPrint("Compressed geometry: Unexpected version")
                return nil
            }
            
            if let val = ExtractInt(cgString: cgString, index: &nIndex_XY) {
                flags = UInt32(val)
            }
            else {
                debugPrint("Compressed geometry: Parse int failure")
                return nil
            }
            if 0xfffffffc & flags != 0 {
                debugPrint("Compressed geometry: Invalid flags")
                return nil
            }
            
            if let val = ExtractInt(cgString: cgString, index: &nIndex_XY) {
                dMultBy_XY = Double(val)
            }
            else {
                debugPrint("Compressed geometry: Parse int failure")
                return nil
            }
        }
        else {
            dMultBy_XY = Double(firstElement)
        }
        
        var nLength = cgString.count
        if flags != 0 {
            guard let firstBarIndex = cgString.firstIndex(of: "|") else {
                debugPrint("Compressed geometry: Flags parse error")
                return nil
            }
            nLength = firstBarIndex.encodedOffset
            
            if flags & 1 == 1 {
                nIndex_Z = nLength + 1
                if let val = ExtractInt(cgString: cgString, index: &nIndex_Z) {
                    dMultBy_Z = Double(val)
                }
                else {
                    debugPrint("Compressed geometry: Parse int failure")
                    return nil
                }
            }
            if flags & 2 == 2 {
                guard let secondBarIndex = cgString[cgString.index(cgString.startIndex, offsetBy: nIndex_Z)...].firstIndex(of: "|") else {
                    debugPrint("Compressed geometry: Flags parse error")
                    return nil
                }
                nIndex_M = secondBarIndex.encodedOffset + 1
                if let val = ExtractInt(cgString: cgString, index: &nIndex_M) {
                    dMultBy_M = Double(val)
                }
                else {
                    debugPrint("Compressed geometry: Parse int failure")
                    return nil
                }
            }
        }
        
        var nLastDiffX: Int = 0
        var nLastDiffY: Int = 0
        var nLastDiffZ: Int = 0
        var nLastDiffM: Int = 0
        
        while nIndex_XY < nLength {
            // X
            guard let nDiffX = ExtractInt(cgString: cgString, index: &nIndex_XY) else {
                debugPrint("Compressed geometry: Parse int failure")
                return nil
            }
            let nX = nDiffX + nLastDiffX
            nLastDiffX = nX
            let dX = Double(nX) / dMultBy_XY
            
            // Y
            guard let nDiffY = ExtractInt(cgString: cgString, index: &nIndex_XY) else {
                debugPrint("Compressed geometry: Parse int failure")
                return nil
            }
            let nY = nDiffY + nLastDiffY
            nLastDiffY = nY
            let dY = Double(nY) / dMultBy_XY
            
            var point = CGPoint(x: dX, y: dY)
            
            if flags & 1 == 1 { // has Zs
                guard let nDiffZ = ExtractInt(cgString: cgString, index: &nIndex_Z) else {
                    debugPrint("Compressed geometry: Parse int failure")
                    return nil
                }
                let nZ = nDiffZ + nLastDiffZ
                nLastDiffZ = nZ
                let dZ = Double(nZ) / dMultBy_Z
                point.z = dZ
            }
            
            if flags & 2 == 2 { // has Ms
                guard let nDiffM = ExtractInt(cgString: cgString, index: &nIndex_M) else {
                    debugPrint("Compressed geometry: Parse int failure")
                    return nil
                }
                let nM = nDiffM + nLastDiffM
                nLastDiffM = nM
                let dM = Double(nM) / dMultBy_M
                point.m = dM
            }
            
            points.append(point)
        }
        
        return points
    }
    
    private func ExtractInt(cgString: String, index: inout Int) -> Int? {
        var i = index + 1
        while i < cgString.count {
            let curChar = cgString[cgString.index(cgString.startIndex, offsetBy: i)]
            if curChar != "-" && curChar != "+" && curChar != "|" {
                i += 1
            }
            else {
                break
            }
        }
        let sr32 = cgString[cgString.index(cgString.startIndex, offsetBy: index)..<cgString.index(cgString.startIndex, offsetBy: i)]
        index = i
        return Int(sr32, radix: 32)
    }
}
