//
//  PathVuMapLayer.swift
//  Access Path
//
//  Created by Pete Georgopoulos on 2/24/20.
//  Copyright © 2020 pathVu. All rights reserved.
//

import Foundation
import GoogleMaps
import SwiftyJSON

class EntranceLayer : PathVuMapLayer {
    override var type: String { MapLayers.entranceType }
    override var prefix: String { "e" }
    override var popupMessage: String { "Does this entrance still exist?" }
    init(map: GMSMapView) {
        super.init(url: URL(string: APIURL.getEntranceURL)!, map: map)
        self.icon = self.resizeImage(image: UIImage(named: entrance_icon)!, targetSize: CGSize(width: 40.0, height:40.0))
    }
}

class IndoorLayer : PathVuMapLayer {
    override var type: String { MapLayers.indoorType }
    override var prefix: String { "ia" }
    override var popupMessage: String { "Does this accessibility still exist?" }
    init(map: GMSMapView) {
        super.init(url: URL(string: APIURL.getIndoorURL)!, map: map)
        self.icon = self.resizeImage(image: UIImage(named: indoor_icon)!, targetSize: CGSize(width: 40.0, height:40.0))
    }
}

class PathVuMapLayer {
    var icon: UIImage?
    var coordinates = CLLocationCoordinate2D()
    var url: URL
    var map: GMSMapView
    var type: String { "" }
    var prefix: String { "" }
    var popupMessage: String { "" }
    init(url: URL, map: GMSMapView) {
        self.url = url
        self.map = map
    }
    
    func queryAndRender() {
        // get and store corners of map being displayed
        let northWest = self.map.projection.visibleRegion().farLeft
        let northEast = self.map.projection.visibleRegion().farRight
        let southWest = self.map.projection.visibleRegion().nearLeft
        let southEast = self.map.projection.visibleRegion().nearRight
        let group = DispatchGroup()
        let parameters = [
            [
                "key": "p1lat",
                "value": String(northWest.latitude),
                "type": "text"
            ],
            [
                "key": "p1lon",
                "value": String(northWest.longitude),
                "type": "text"
            ],
            [
                "key": "p2lat",
                "value": String(northEast.latitude),
                "type": "text"
            ],
            [
                "key": "p2lon",
                "value": String(northEast.longitude),
                "type": "text"
            ],
            [
                "key": "p3lat",
                "value": String(southEast.latitude),
                "type": "text"
            ],
            [
                "key": "p3lon",
                "value": String(southEast.longitude),
                "type": "text"
            ],
            [
                "key": "p4lat",
                "value": String(southWest.latitude),
                "type": "text"
            ],
            [
                "key": "p4lon",
                "value": String(southWest.longitude),
                "type": "text"
            ]] as [[String : Any]]

        let boundary = "Boundary-\(UUID().uuidString)"
        var body = ""
        for param in parameters {
            if param["disabled"] == nil {
                let paramName = param["key"]!
                body += "--\(boundary)\r\n"
                body += "Content-Disposition:form-data; name=\"\(paramName)\""
                let paramType = param["type"] as! String
                if paramType == "text" {
                    let paramValue = param["value"] as! String
                    body += "\r\n\r\n\(paramValue)\r\n"
                } else {
                    let paramSrc = param["src"] as! String
                    var fileData = Data()
                    do {
                        fileData = try NSData(contentsOfFile:paramSrc, options:[]) as Data
                    }
                    catch {
                        print("Error posting favorites")
                    }
                    let fileContent = String(data: fileData, encoding: .utf8)!
                    body += "; filename=\"\(paramSrc)\"\r\n"
                      + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
                }
            }
        }
        body += "--\(boundary)--\r\n";
        let postData = body.data(using: .utf8)

        var request = URLRequest(url: self.url)
        request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData
        var res:Data?
        
        // get points of interest
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data else {
                print(String(describing: error))
                return
            }
            
            // store data in map markers
            res = data
            let json = JSON(data)
            if json != nil {
                DispatchQueue.main.async {
                    if error != nil {
                        return
                    }
                    
                    for item in json[self.type].arrayValue {
                        if item["iactive"] == "1" || item["eactive"] == "1" {
                            let coord = CLLocationCoordinate2D(latitude: item[self.prefix + "lat"].doubleValue, longitude: item[self.prefix + "lon"].doubleValue)
                            // only add coordinates to property for hazard layer
                            let marker = GMSMarker(position: coord)
                            var userData = [String:Any]()
                            userData["type"] = self.type
                            userData["address"] = item[self.prefix + "address"].stringValue
                            userData["imgURL"] = item[self.prefix + "imgpath"].stringValue + item[self.prefix + "imgname"].stringValue
                            if self.type == MapLayers.entranceType {
                                userData["isAutomatic"] = Int(item["eoautodoor"].stringValue)
                                userData["entranceSteps"] = Int(item["aesteps"].stringValue)
                                userData["entranceRamp"] = Int(item["aeramp"].stringValue)
                            }
                            else if self.type == MapLayers.indoorType {
                                userData["steps"] = Int(item["iosteps"].stringValue)
                                userData["ramp"] = Int(item["ioramp"].stringValue)
                                let indoorTypes = item["rtid"].stringValue.replacingOccurrences(of: "[{}]", with: "", options: .regularExpression)
                                let array = indoorTypes.split(separator: ",")
                                userData["indoorType"] = array.map { String($0) }
                                userData["hasBraille"] = Int(item["iobraillemnu"].stringValue)
                                userData["isSpacious"] = Int(item["iospacious"].stringValue)
                            }
                            marker.title = userData["address"] as? String ?? ""
                            marker.icon = self.icon
                            marker.userData = userData
                            marker.map = self.map
                        }
                    }
                }
            }
            else {
                print("Pathvu \(self.type) layer error: \(String(data: data, encoding: String.Encoding.utf8))")
            }
            group.leave()
        }
        group.enter()
        task.resume()
        group.wait()
        return
    }
    //Use for resizing obstruction icon on map
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
