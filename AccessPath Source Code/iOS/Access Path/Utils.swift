//
//  Utils.swift
//  Access Path
//
//  Created by Pete Georgopoulos on 12/2/19.
//  Copyright © 2019 pathVu. All rights reserved.
//

import Foundation
import GoogleMaps


class Utils {
    
    static func lngLatToXY(lng:Double, lat:Double) -> [Double] {
        let x:Double = lng * 20037508.34 / 180;
        var y:Double = log(tan((90 + lat) * Double.pi / 360)) / (Double.pi / 180);
        y = y * 20037508.34 / 180;
      return [x, y]
    }
    
    static func xYToLngLat(x:Double, y:Double) -> [Double] {
        let lng = (x / 20037508.34) * 180;
        var lat = (y / 20037508.34) * 180;
        lat = 180/Double.pi * (2 * atan(exp(lat * Double.pi / 180)) - Double.pi / 2);
        
      return [lat, lng];
    }
    
    
    static func webMercatorToLL(_ x:Double, _ y:Double){
//        var response = [x, y]
//        var smRadius = 6378136.98;
//        var smRange = smRadius * Double.pi * 2.0;
//        var smLonToX = smRange / 360.0;
//        var smRadiansOverDegrees = Double.pi / 180.0;
//
//        // compute x-map-unit
//        response[0] = response[0] * smLonToX;
//
//        y = response[1];
//
//        // compute y-map-unit
//        if (y > 86.0)
//        {
//            vertex[1] = smRange;
//        }
//        else if (y < -86.0)
//        {
//            vertex[1] = -smRange;
//        }
//        else
//        {
//            y *= smRadiansOverDegrees;
//            y = Math.Log(Math.Tan(y) + (1.0 / Math.Cos(y)), Math.E);
//            response[1] = y * smRadius;
//        }
    }
    static func lLToMercator( _ lat:Double, _ lng:Double){
        
        let projection = GMSProject(CLLocationCoordinate2D(latitude: lat, longitude: lng))
        print("x \(projection.x)")
        print("y \(projection.y)")
//        var response = [x, y]
//        var smRadius = 6378136.98;
//        var smRange = smRadius * Double.pi * 2.0;
//        var smLonToX = smRange / 360.0;
//        var smRadiansOverDegrees = Double.pi / 180.0;
//
//        // compute x-map-unit
//        response[0] = response[0] * smLonToX;
//
//        y = response[1];
//
//        // compute y-map-unit
//        if (y > 86.0)
//        {
//            vertex[1] = smRange;
//        }
//        else if (y < -86.0)
//        {
//            vertex[1] = -smRange;
//        }
//        else
//        {
//            y *= smRadiansOverDegrees;
//            y = Math.Log(Math.Tan(y) + (1.0 / Math.Cos(y)), Math.E);
//            response[1] = y * smRadius;
//        }
    }
}
