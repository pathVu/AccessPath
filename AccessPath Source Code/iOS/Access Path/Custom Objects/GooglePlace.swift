//
//  GooglePlace.swift
//  Access Path
//
//  Created by Pete Georgopoulos on 1/29/20.
//  Copyright © 2020 pathVu. All rights reserved.
//

import Foundation
import GoogleMaps
import SwiftyJSON

class GooglePlace {
    var id:String
    var name:String
    var address:String
    var coordinate:CLLocationCoordinate2D
    var iconString:String
    var types:[String]
    var distance:Double
    
    init(){
        self.id = String()
        self.name = String()
        self.address = String()
        self.coordinate = CLLocationCoordinate2D()
        self.iconString = String()
        self.types = [String]()
        self.distance = 0.0
    }
    
    init(with json: JSON, userLocation: CLLocationCoordinate2D){
        self.id = json["id"].stringValue
        self.name = json["name"].stringValue
        self.address = json["vicinity"].stringValue
        self.coordinate = CLLocationCoordinate2D(
            latitude: json["geometry"]["location"]["lat"].doubleValue,
            longitude: json["geometry"]["location"]["lng"].doubleValue)
        self.iconString = json["icon"].stringValue
        let typeArray = json["types"].arrayObject
        self.types = [String]()
        if let typeArray = typeArray {
            for type in typeArray {
                types.append(type as! String)
            }
        }
        self.distance = GMSGeometryDistance(userLocation, self.coordinate)
    }
}
