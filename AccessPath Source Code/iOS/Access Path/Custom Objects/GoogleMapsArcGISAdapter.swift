//
//  GoogleMapsArcGISAdapter.swift
//  Access Path
//
//  Created by Alan Barker on 12/11/19.
//  Copyright © 2019 pathVu. All rights reserved.
//

import Foundation
import GoogleMaps
import SwiftyJSON

protocol GoogleMapsArcGISAdapter {
    var coordinates: [CLLocationCoordinate2D] { get set }
    func setupAndRender()
    func queryAndRender()
}

class TransitLayer : MultiMarkerLayer {
    override var type: String { MapLayers.transitType }
    override var outputFields: String { "objectid,stop_name,stop_type" }
    init(map: GMSMapView) {
        super.init(url: MapLayers.transitLayerURL!, map: map)
    }
}

class CurbrampLayer : SingleMarkerLayer {
    override var type: String { MapLayers.curbrampType }
    override var outputFields: String { "detectable_warning,globalid,objectid" }
    init(map: GMSMapView) {
        super.init(url: MapLayers.curbRampsLayerURL!, map: map)
    }
}

class SidewalkLayer : PathLayer {
    override var type: String { MapLayers.sidewalkType }
    override var outputFields: String { "objectid,segment_rai,street_name" }
    init(map: GMSMapView) {
        super.init(url: MapLayers.sidewalkLayerURL!, map: map)
    }
}

class CrowdsourceLayer : SingleMarkerLayer {
    override var type: String { MapLayers.crowdsourceType }
    override var outputFields: String { "cid,cname" }
    init(map: GMSMapView) {
        super.init(url: MapLayers.crowdsourcingLayerURL!, map: map)
    }
}

class BaseLayer : GoogleMapsArcGISAdapter {
    var coordinates = [CLLocationCoordinate2D]()
    var url: URL
    var map: GMSMapView
    var type: String { "" }
    var outputFields: String { "" }
    
    init(url: URL, map: GMSMapView) {
        self.url = url
        self.map = map
    }
    
    func getQueryItems(topRight: CLLocationCoordinate2D, bottomLeft: CLLocationCoordinate2D) -> [URLQueryItem] {
        return [
            URLQueryItem(name: "outSR", value: "4326"),
            URLQueryItem(name: "returnGeometry", value: "true"),
            URLQueryItem(name: "inSR", value: "4326"),
            URLQueryItem(name: "returnDistinctValues", value: "false"),
            URLQueryItem(name: "maxAllowableOffset", value: "0.000000"),
            URLQueryItem(name: "spatialRel", value: "esriSpatialRelEnvelopeIntersects"),
            URLQueryItem(name: "geometryType", value: "esriGeometryEnvelope"),
            URLQueryItem(name: "outFields", value: outputFields),
            URLQueryItem(name: "geometry", value: "{xmin:\(topRight.longitude),ymin:\(bottomLeft.latitude),xmax:\(bottomLeft.longitude),ymax=\(topRight.latitude)}"),
            URLQueryItem(name: "f", value: "json"),
            URLQueryItem(name: "returnZ", value: "false"),
            URLQueryItem(name: "returnM", value: "false")
        ]
    }

    func setupAndRender() {
    }
    
    func queryAndRender() {
    }
}
class MultiMarkerLayer : BaseLayer {
    var markerIcons = [String:UIImage]()
    override func setupAndRender() {
        var query = URLComponents(string: url.absoluteString)!
        query.queryItems = [URLQueryItem(name: "f", value: "json")]
        URLSession.shared.dataTask(with: query.url!, completionHandler: { data, response, error in
            if error != nil {
                return
            }
            let json = JSON(data!)
            for item in json["drawingInfo"]["renderer"]["uniqueValueInfos"].arrayValue {
                let imageString = item["symbol"]["imageData"].stringValue
                if let itemData = Data(base64Encoded: imageString, options:[]){
                    let icon = UIImage(data: itemData, scale: 0.8)
                    self.markerIcons[item["value"].stringValue] = icon
                }
            }
            self.queryAndRender()
        }).resume()
    }
    
    override func queryAndRender() {
        DispatchQueue.main.async {
            let topRight = self.map.projection.visibleRegion().farRight
            let bottomLeft = self.map.projection.visibleRegion().nearLeft
            
            var query = URLComponents(string: self.url.absoluteString)!
            query.path += "/query"
            query.queryItems = self.getQueryItems(topRight: topRight, bottomLeft: bottomLeft)
            URLSession.shared.dataTask(with: query.url!, completionHandler: { data, response, error in
                DispatchQueue.main.async {
                    if error != nil {
                        return
                    }
                    let json = JSON(data!)
                    for item in json["features"].arrayValue {
                        let coord = CLLocationCoordinate2D(latitude:item["geometry"]["y"].doubleValue, longitude: item["geometry"]["x"].doubleValue)
                        let marker = GMSMarker(position: coord)
                        marker.icon = self.markerIcons[item["attributes"]["stop_type"].stringValue]
                        var userData = item["attributes"]
                        userData["type"].stringValue = self.type
                        marker.userData = userData
                        marker.map = self.map
                    }
                }
            }).resume()
        }
    }
}

class SingleMarkerLayer : BaseLayer {
    var icon: UIImage?
    override func setupAndRender() {
        var query = URLComponents(string: url.absoluteString)!
        query.queryItems = [URLQueryItem(name: "f", value: "json")]
        URLSession.shared.dataTask(with: query.url!, completionHandler: { data, response, error in
            if error != nil {
                return
            }
            let json = JSON(data!)
            let imageString = json["drawingInfo"]["renderer"]["symbol"]["imageData"].stringValue
            if let imageData = Data(base64Encoded: imageString, options:[]) {
                self.icon = UIImage(data: imageData, scale: 0.8)
            }
            self.queryAndRender()
        }).resume()
    }
    
    override func queryAndRender() {
        if let icon = self.icon {
            DispatchQueue.main.async {
                let topRight = self.map.projection.visibleRegion().farRight
                let bottomLeft = self.map.projection.visibleRegion().nearLeft
                
                var query = URLComponents(string: self.url.absoluteString)!
                query.path += "/query"
                query.queryItems = self.getQueryItems(topRight: topRight, bottomLeft: bottomLeft)
                
                URLSession.shared.dataTask(with: query.url!, completionHandler: { data, response, error in
                    DispatchQueue.main.async {
                        if error != nil {
                            return
                        }
                        let json = JSON(data!)
                        for item in json["features"].arrayValue {
                            let coord = CLLocationCoordinate2D(latitude: item["geometry"]["y"].doubleValue, longitude: item["geometry"]["x"].doubleValue)
                            // only add coordinates to property for hazard layer
                            if self.type == MapLayers.crowdsourceType {
                                self.coordinates.append(coord)
                            }
                            let marker = GMSMarker(position: coord)
                            var userData = item["attributes"]
                            userData["type"].stringValue = self.type
                            marker.userData = userData
                            marker.icon = icon
                            marker.map = self.map
                        }
                    }
                }).resume()
            }
        }
    }
}

class PathLayer : BaseLayer {
    var colorValues = [String:Float]()
    var lines = [Any]()
    override func setupAndRender() {
        var query = URLComponents(string: url.absoluteString)!
        query.queryItems = [URLQueryItem(name: "f", value: "json")]
        URLSession.shared.dataTask(with: query.url!, completionHandler: { data, response, error in
            if error != nil {
                return
            }
            let json = JSON(data!)

            for info in json["drawingInfo"]["renderer"]["classBreakInfos"].arrayValue {
                self.colorValues[info["label"].stringValue] = info["classMaxValue"].floatValue
            }
            self.queryAndRender()
        }).resume()
    }
    
    override func queryAndRender() {
        DispatchQueue.main.async {
            let topRight = self.map.projection.visibleRegion().farRight
            let bottomLeft = self.map.projection.visibleRegion().nearLeft
            
            var query = URLComponents(string: self.url.absoluteString)!
            query.path += "/query"
            query.queryItems = self.getQueryItems(topRight: topRight, bottomLeft: bottomLeft)
            
            URLSession.shared.dataTask(with: query.url!, completionHandler: { data, response, error in
                DispatchQueue.main.async {
                    if error != nil {
                        return
                    }
                    self.lines.removeAll()
                    let json = JSON(data!)
                    for item in json["features"].arrayValue {
                        for path in item["geometry"]["paths"].arrayValue {
                            let p = GMSMutablePath()
                            for points in path.arrayValue {
                                let pArr = points.arrayValue
                                p.add(CLLocationCoordinate2D(latitude: pArr[1].doubleValue, longitude:pArr[0].doubleValue))
                            }
                            let polyline = GMSPolyline(path: p)
                            
                            guard let greenVal = self.colorValues["0.000000 - 1.000000"],
                                let yellowVal = self.colorValues["1.000001 - 3.000000"],
                                let redVal = self.colorValues["3.000001 - 224.500000"]
                                //let blackVal = self.colorValues["Unrated"]
                            else {
                                return
                            }
                            
                            if item["attributes"]["segment_rai"].floatValue == 0.0 {
                                //continue
                                polyline.strokeColor = UIColor.black
                            }
                            else if item["attributes"]["segment_rai"].floatValue < greenVal {
                                polyline.strokeColor = UIColor.green
                            }
                            else if item["attributes"]["segment_rai"].floatValue < yellowVal {
                                polyline.strokeColor = UIColor.yellow
                            }
                            else if item["attributes"]["segment_rai"].floatValue < redVal {
                                polyline.strokeColor = UIColor.red
                            }
                            /*else if item["attributes"].label == "Unrated" {
                                polyline.strokeColor = UIColor.black
                            }*/
                            var userData = item["attributes"]
                            userData["type"].stringValue = self.type
                            polyline.userData = userData
                            polyline.strokeWidth = 3
                            polyline.isTappable = true
                            polyline.map = self.map
                            
                        }
                    }
                }
            }).resume()
        }
    }
}
