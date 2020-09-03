//
//  TemporaryNavigation.swift
//  Access Path
//
//  Created by Nick Sinagra on 6/9/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit
import ArcGIS
import AVFoundation
import GoogleMaps
import GooglePlaces
import SwiftyJSON

/**
 * This class displays the destination preview map. It also contains a list view of the
 * steps in the route. The user can click through the list of steps using the controls
 * at the bottom.
 */
class MainDestinationPreviewMap: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate  {
    
    var thComfortKeyValue = Int()
    var rsComfortKeyValue = Int()
    var csComfortKeyValue = Int()
    var roComfortKeyValue = Int()
    
    //UI Outlets
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var modeButton: UIButton!
    @IBOutlet weak var modeButtonImage: UIImageView!
    @IBOutlet weak var directionImage: UIImageView!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    
    // add Direction Distance label
    @IBOutlet weak var directionDistanceLabel: UILabel!
    
    // loading views while requesting routing data
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    
    //Location Information
    var startText:String?
    var destinationText:String?
    var locManager: CLLocationManager?
    var lat:Double?
    var lng:Double?
    
    
    //Route Solving
    var routeParameters:AGSRouteParameters?
    var routeResult:AGSRouteResult?
    var routeTask:AGSRouteTask?
    var routeTaskInfo:AGSRouteTaskInfo?
    var routeTaskUrl:String?
    var travelModes:[AGSTravelMode]?
    var fromStop:CLLocationCoordinate2D?   // Starting location
    var toStop:CLLocationCoordinate2D? // Ending destination
    var uLocation:AGSLocation!
    var travelMode: AGSTravelMode?
    
    //Maneuver information
    var directionManeuverList:[AGSDirectionManeuver]?
    var currentManeuverIndex = 0
    
    //Shared Preferences
    let preferences = UserDefaults.standard
    
    //PHP calls class instance
    let pathVuPHP = PHPCalls()
    
    //Speech synthesizer for reading directions out loud
    let synth = AVSpeechSynthesizer()
    
    //View controller for custom map callout
    var popupVC:PopupVC!
    var startLocationSound = false
    
    var featureModelArray = [hazardFeaturesModel]()
    var manueverArray = [manueverListModel]()
    var routeGeometryArray = [routeGeometryModel]()
    var sourceLocationStop:CLLocationCoordinate2D?
    
    // var previousPointLocation:AGSPoint?
    
    // default zoom level for Google map
    var routeData:[JSON]?
    var route:GMSPolyline?
    var routeBorder:GMSPolyline?
    var directionsJSON:JSON = JSON()
    
    var transitLayer: GoogleMapsArcGISAdapter?
    var curbrampLayer: GoogleMapsArcGISAdapter?
    var sidewalkLayer: GoogleMapsArcGISAdapter?
    var crowdsourceLayer: GoogleMapsArcGISAdapter?
    // style for removing google icons
    let kMapStyle = "[" +
    "  {" +
    "    \"featureType\": \"poi.business\"," +
    "    \"elementType\": \"all\"," +
    "    \"stylers\": [" +
    "      {" +
    "        \"visibility\": \"off\"" +
    "      }" +
    "    ]" +
    "  }," +
    "  {" +
    "    \"featureType\": \"transit\"," +
    "    \"elementType\": \"labels.icon\"," +
    "    \"stylers\": [" +
    "      {" +
    "        \"visibility\": \"off\"" +
    "      }" +
    "    ]" +
    "  }" +
    "]"
    
    enum RoutingError: Error {
        case invalidCoordinates(alertTitle:String, alertMessage:String)
        case noRoute(alertTitle:String, alertMessage:String)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//
//        routeTask = AGSRouteTask(url: RoutingUrls.routeTaskURL!)
        //Set up iPhone location manager
        
        mapView.bringSubview(toFront: blurEffect)
        mapView.bringSubview(toFront: spinner)
        blurEffect.isHidden = false
        spinner.isHidden = false
        spinner.startAnimating()
        
        locManager = CLLocationManager()
        locManager?.delegate = self
        locManager?.desiredAccuracy = kCLLocationAccuracyBest
        locManager?.requestWhenInUseAuthorization()
        locManager?.requestAlwaysAuthorization()
        locManager?.distanceFilter = 3.0
        locManager?.startUpdatingLocation()
        locManager?.allowsBackgroundLocationUpdates = true
        locManager?.pausesLocationUpdatesAutomatically = false
        
        
        if(locManager?.location != nil) {
            lat = (locManager?.location?.coordinate.latitude)!
            lng = (locManager?.location?.coordinate.longitude)!
        }
        
        do {
          // Set the map style by passing a valid JSON string.
          mapView.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
        } catch {
          NSLog("One or more of the map styles failed to load. \(error)")
        }
        self.mapView.delegate = self
        
        //Set up popup view controller, size must match the view controller's size
        let storyboard = UIStoryboard(name: StoryboardIdentifier.mainIdentifier, bundle: nil)
        popupVC = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.popUpIdentifier) as? PopupVC
        popupVC.view.frame = CGRect(x: 0, y: 0, width: 300, height: 250)
        
        listView.isHidden = true
        // comment client code
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Center camera on start position
        if let start = self.fromStop {
            self.mapView.camera = GMSCameraPosition(target: start, zoom: defaultZoomLevel)
        }
        // render feature layers
        if mapView.camera.zoom > 15.0 {
            if preferences.bool(forKey: transitStoplayerString) {
                transitLayer = TransitLayer(map: mapView)
                transitLayer!.setupAndRender()
            }
            if preferences.bool(forKey: curbRamplayerString) {
                curbrampLayer = CurbrampLayer(map: mapView)
                curbrampLayer!.setupAndRender()
            }
            if preferences.bool(forKey: sidewalkStringKey) {
                sidewalkLayer = SidewalkLayer(map: mapView)
                sidewalkLayer!.setupAndRender()
            }
            if preferences.bool(forKey: crowdSourceString) {
                crowdsourceLayer = CrowdsourceLayer(map: mapView)
                crowdsourceLayer!.setupAndRender()
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var alertTitle:String?
        var alertMessage:String?
        
        do{
            try routeMe()
            showRoute()
            nextButtonManeuverRead()
            // Add address to recent paths
            let acctid = self.preferences.string(forKey: PrefKeys.aidKey)
            if let latitude = self.locManager?.location?.coordinate.latitude, let longitude = self.locManager?.location?.coordinate.longitude {
                if(self.pathVuPHP.newRecent(acctid: acctid!, address: self.destinationText ?? "", lat: latitude, lng: longitude)) {
                    debugPrint("Successfully added recent path")
                } else {
                    debugPrint("Error adding recent path")
                }

                //Set header information
                self.headerLabel.text = "\(navigateString) \(self.destinationText ?? "")"
            }
        }
        catch RoutingError.invalidCoordinates(let title, let message) {
            alertTitle = title
            alertMessage = message
        }
        catch RoutingError.noRoute(let title, let message) {
            alertTitle = title
            alertMessage = message
        }
        catch {
            print("Unexpected Error")
        }
        
        if let title = alertTitle, let message = alertMessage {
            //Show an alert if a route cannot be found
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            self.present(alert, animated: true, completion: nil)
            alert.addAction(UIAlertAction(title: AlertConstant.okString, style: .default, handler: { action in
                switch action.style{
                default:
                    self.dismiss(animated: true, completion: nil)
                }
            }))
            return
        }
        
        if let routeData = routeData {
            let startPosition = GMSCameraPosition(latitude: routeData[0].arrayValue[1].doubleValue, longitude: routeData[0].arrayValue[0].doubleValue, zoom: defaultZoomLevel)
            self.mapView.camera = startPosition
        }
    }
    
    func routeMe() throws {
        if let start = self.fromStop, let stop = self.toStop{
            let params = RouteParameters(
                uacctid: self.preferences.integer(forKey: PrefKeys.aidKey),
                tid: self.preferences.integer(forKey: PrefKeys.uTypeKey),
                thw: self.preferences.integer(forKey: PrefKeys.thComfortKeyValue),
                rsw: self.preferences.integer(forKey: PrefKeys.rsComfortKeyValue),
                csw: self.preferences.integer(forKey: PrefKeys.csComfortKeyValue),
                row: self.preferences.integer(forKey: PrefKeys.rComfortKeyValue),
                from: start,
                to: stop)
            let responseData = try? self.pathVuPHP.getRoute(with: params)
            let res:JSON = JSON(responseData!)
            if res != nil && !res["error"].exists() {
                if res["routes"]["features"].exists(){
                    // set path data for map view
                    self.routeData = res["routes"]["features"][0]["geometry"]["paths"][0].arrayValue
                    if self.routeData?.count == 0 {
                        throw RoutingError.noRoute(alertTitle: AlertConstant.notRouteAvailable, alertMessage: AlertConstant.notRouteDisplay)
                    }
                    //set directions data for list view
                    self.directionsJSON = res["directions"].arrayValue[0]["features"]
                }
            }
            else{
                throw RoutingError.noRoute(alertTitle: AlertConstant.notRouteAvailable, alertMessage: AlertConstant.notRouteDisplay)
            }
        }
        else {
            throw RoutingError.invalidCoordinates(alertTitle: "Error", alertMessage: "Error getting route data")
        }
    }
    
    func showRoute() {
        if let routeData = routeData {
            let path = GMSMutablePath()
            for item in routeData {
                path.add(CLLocationCoordinate2D(latitude: item[1].doubleValue, longitude: item[0].doubleValue))
            }
            
            self.route = GMSPolyline(path: path)
            route?.strokeWidth = 10
            route?.strokeColor = UIColor.orange
            route?.zIndex = 2
            
            self.routeBorder = GMSPolyline(path: path)
            routeBorder?.strokeWidth = 15
            routeBorder?.strokeColor = UIColor.black
            routeBorder?.zIndex = 1
            
            routeBorder?.map = self.mapView
            route?.map = self.mapView
            
            // remove loading view
            self.spinner.isHidden = true
            self.blurEffect.isHidden = true
            self.spinner.stopAnimating()
            self.checkRoute()
        }
    }
    
    func checkRoute() {
        let decoder = CGDecoder()
        // directionManeuverList = curRoute.directionManeuvers
        let maneuverList = directionsJSON.arrayValue
        var totalLength = 0.0
        guard let currentUserPoints = locManager?.location?.coordinate else {
            return
        }
        //Changed By Chetu new changes feb 14
        //Calculate manuever length and points
        for (i, maneuver) in maneuverList.enumerated() {
            if i < directionsJSON.arrayValue.count {
                print(maneuver["compressedGeometry"].stringValue)
                guard let path = decoder.CreatePathFromCG(cgString: maneuver["compressedGeometry"].stringValue) else {
                    return
                }
                guard let currentManeuver = path.first, let nextManeuver = path.last
                    else { return }
                    
                let currentManeuverLocation = CLLocationCoordinate2D(
                    latitude: currentManeuver.y,
                    longitude: currentManeuver.x
                )
                let nextManeuverLocation = CLLocationCoordinate2D(
                    latitude: nextManeuver.y,
                    longitude: nextManeuver.x
                )
                
                let totalDist = GMSGeometryDistance(currentManeuverLocation, nextManeuverLocation) * 3.28084
                
                let dist = totalDist.rounded()
                let doubleStr = String(format: "%.0f", dist)
                
                if i == 0 {
                    let distanceText = dist > 0 ?
                        "\(maneuverList[i+1]["attributes"]["text"].stringValue) in \(doubleStr) \(feetString)" :
                        "\(maneuverList[i+1]["attributes"]["text"].stringValue)"
                    let manueverModel = manueverListModel(
                        directionText: distanceText,
                        manueverLength: dist,
                        manueverStatus: false,
                        manueverLatt: currentManeuverLocation.latitude,
                        manueverLong: currentManeuverLocation.longitude,
                        nextDescription: "", manueverIndex: i)
                    self.manueverArray.append(manueverModel)
                }

                else {
                    if i < directionsJSON.arrayValue.count - 1 {
                        let currentLength = totalDist
                        /// logic length greater than 100
                        if (totalDist > 100) {
                            let nextManueverDist = totalDist.rounded()
                            let doubleStr = String(format: "%.0f", nextManueverDist)
                            let manueverModel = manueverListModel(
                            directionText: "\(maneuverList[i+1]["attributes"]["text"].stringValue) in \(doubleStr) \(feetString)",
                            manueverLength: dist,
                            manueverStatus: false,
                            manueverLatt: currentManeuverLocation.latitude,
                            manueverLong: currentManeuverLocation.longitude,
                            nextDescription: "", manueverIndex: i)
                            self.manueverArray.append(manueverModel)
                        }
                        totalLength = totalLength + currentLength

                        //updated model
                        if var modelObject = self.geometryManueverPoint(index: i, geometry: path, length: currentLength) {
                            modelObject.manueverStatus = false
                            modelObject.directionText = "\(maneuverList[i+1]["attributes"]["text"].stringValue) \(nowString)"
                            modelObject.manueverIndex = i
                            self.manueverArray.append(modelObject)
                        }
                    }
                    else{
                        let manueverModel = manueverListModel(
                            directionText: "\(maneuverList[i]["attributes"]["text"].stringValue) in \(doubleStr) \(feetString)",
                            manueverLength: totalLength,
                            manueverStatus: false,
                            manueverLatt: currentManeuverLocation.latitude,
                            manueverLong: currentManeuverLocation.longitude,
                            nextDescription: "", manueverIndex: i)
                        self.manueverArray.append(manueverModel)
                    }
                }
            }
        }
    }
    
    func navigateGeofenceLocation() {
        guard let routeLength = self.routeData?.last?.arrayValue[2].doubleValue else {
            print("Error getting geofence")
            return
        }
        for (Index,directionsValue) in self.manueverArray.enumerated() {

            //let stepsString = String((self.manueverArray.count)) + " \(maneuverString), "
            let feet = String((routeLength/0.3048).rounded()) + " \(feetString)"
            self.infoLabel.text = feet

            let lattvalue = directionsValue.manueverLatt ?? 0.0
            let longValue = directionsValue.manueverLong ?? 0.0
            let offset = 0.00014


            //Single point display
            /*
             let BoundaryPoint = AGSPoint(x: longValue, y: lattvalue, spatialReference: AGSSpatialReference.wgs84())
             let pointSymbol = AGSSimpleMarkerSymbol(style: .circle, color: .red, size: 15.0)
             let pointGraphic = AGSGraphic(geometry: BoundaryPoint, symbol: pointSymbol, attributes: nil)
             self.routeOverlay?.graphics.add(pointGraphic)
             self.mapView.graphicsOverlays.add(self.routeOverlay!)
             */

            //Set fake geofence around current maneuver
            let bound1 = CLLocationCoordinate2D(latitude: lattvalue - offset, longitude: longValue - offset)
            let bound2 = CLLocationCoordinate2D(latitude: lattvalue + offset, longitude: longValue - offset)
            let bound3 = CLLocationCoordinate2D(latitude: lattvalue - offset, longitude: longValue + offset)
            let bound4 = CLLocationCoordinate2D(latitude: lattvalue + offset, longitude: longValue + offset)

            /*
             let boundGeometri1 = AGSGeometryEngine.projectGeometry(bound1, to: AGSSpatialReference.wgs84())
             let boundGeometri2 = AGSGeometryEngine.projectGeometry(bound2, to: AGSSpatialReference.wgs84())
             let boundGeometri3 = AGSGeometryEngine.projectGeometry(bound3, to: AGSSpatialReference.wgs84())
             let boundGeometri4 = AGSGeometryEngine.projectGeometry(bound4, to: AGSSpatialReference.wgs84())

             let routeSymbol = AGSSimpleMarkerSymbol(style: .circle, color: .red, size: 10)
             let graphic1 = AGSGraphic(geometry: boundGeometri1, symbol: routeSymbol, attributes: nil)
             let graphic2 = AGSGraphic(geometry: boundGeometri2, symbol: routeSymbol, attributes: nil)
             let graphic3 = AGSGraphic(geometry: boundGeometri3, symbol: routeSymbol, attributes: nil)
             let graphic4 = AGSGraphic(geometry: boundGeometri4, symbol: routeSymbol, attributes: nil)

             self.routeOverlay?.graphics.add(graphic1)
             self.routeOverlay?.graphics.add(graphic2)
             self.routeOverlay?.graphics.add(graphic3)
             self.routeOverlay?.graphics.add(graphic4)
             self.mapView.graphicsOverlays.add(self.routeOverlay!)
             */

            // comment the user location position
            guard let locationUser = locManager?.location?.coordinate else{
                return
            }
            // let userPoint:AGSPoint = locationUser

            if(locationUser.longitude > bound1.longitude && locationUser.latitude > bound1.latitude) {
                if(locationUser.longitude > bound2.longitude && locationUser.latitude < bound2.latitude) {
                    if(locationUser.longitude < bound3.longitude && locationUser.latitude > bound3.latitude) {
                        if(locationUser.longitude < bound4.longitude && locationUser.latitude < bound4.latitude) {

                            if directionsValue.manueverStatus == false {
                                //Read the maneuver description out loud if the user has that
                                self.currentManeuverIndex = directionsValue.manueverIndex ?? 0
                                self.manueverArray[Index].manueverStatus = true
                                nextButtonManeuverRead()
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func geometryManueverPoint(index:Int, geometry:[CGPoint], length:Double) -> manueverListModel? {
        var modelGeofence : manueverListModel? = manueverListModel()
        if length > 5 {
            guard let lat = geometry.first?.y, let lng = geometry.first?.x else {
                return nil
            }
            modelGeofence?.manueverLong = lng
            modelGeofence?.manueverLatt = lat
            modelGeofence?.manueverLength = length
            return modelGeofence
        }
        return nil
    }
    
    func nextButtonManeuverRead() {
        self.updateTimeLabels()
        if currentManeuverIndex < self.manueverArray.count{
            debugPrint(currentManeuverIndex)
            let maneuver = self.manueverArray[currentManeuverIndex]
            let maneuverDescription = maneuver.directionText

            //Read the maneuver description out loud if the user has that enabled
            let utterance = AVSpeechUtterance(string: maneuverDescription ?? "")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            synth.stopSpeaking(at: AVSpeechBoundary.immediate)
            synth.speak(utterance)

            self.menueverTurnDirection(maneuverDescription:maneuverDescription ?? "")

            //Change by  By Chetu
            //Get the point of that maneuver
//            let transformation = AGSGeographicTransformation(step: AGSGeographicTransformationStep.init(wkid: 108336)!)
//            let maneuverPoint = AGSGeometryEngine.projectGeometry(directionManeuverList![maneuver.manueverIndex ?? 0].geometry!, to: AGSSpatialReference.webMercator(), datumTransformation: transformation)
            if (currentManeuverIndex < manueverArray.count - 1) {
                guard let lat = manueverArray[currentManeuverIndex + 1].manueverLatt, let lng = manueverArray[currentManeuverIndex + 1].manueverLong else {
                    debugPrint("Error getting maneuver location")
                    return
                }
                let maneuverPoint = CLLocationCoordinate2D(latitude: lat, longitude: lng)

                //Set the map to be centered on the maneuver
                self.mapView.animate(toLocation: maneuverPoint)
            }
        }
    }
    
    /**
     * TODO: Change to ArcGIS location changed handler
     * Users location changed handler
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let position = manager.location?.coordinate {
//            self.mapView.camera = GMSCameraPosition(target: position, zoom: self.mapView.camera.zoom)
//            self.navigateGeofenceLocation()
//        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        //Sidewalk Layer alert
        let storyboard = UIStoryboard(name: StoryboardIdentifier.mainIdentifier, bundle: nil)
        let sidewalkStorybaord = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.sidewalkPopUpIdentifier) as! SidewalkPopAlert
        var query = URLComponents(string: MapLayers.sidewalkLayerURL!.absoluteString)
        if let overlay = overlay as? GMSPolyline {
            let first = overlay.path?.coordinate(at: 0)
            let second = overlay.path?.coordinate(at: (overlay.path?.count())!-1)
            let lat = (Double(first?.latitude ?? 0.0) + Double(first?.latitude ?? 0.0)) / 2
            let lng = (Double(second?.longitude ?? 0.0) + Double(second?.longitude ?? 0.0)) / 2
            query!.path += "/query"
            query!.queryItems = [
                URLQueryItem(name: "outSR", value: "4326"),
                URLQueryItem(name: "returnGeometry", value: "true"),
                URLQueryItem(name: "inSR", value: "4326"),
                URLQueryItem(name: "returnDistinctValues", value: "false"),
                URLQueryItem(name: "maxAllowableOffset", value: "0.000000"),
                URLQueryItem(name: "spatialRel", value: "esriSpatialRelEnvelopeIntersects"),
                URLQueryItem(name: "geometryType", value: "esriGeometryEnvelope"),
                URLQueryItem(name: "resultRecordCount", value: "1"),
                URLQueryItem(name: "outFields", value: "*"),
                URLQueryItem(name: "geometry", value: "{xmin:\(lng),ymin:\(lat),xmax:\(lng),ymax=\(lat)}"),
                URLQueryItem(name: "f", value: "json"),
                URLQueryItem(name: "returnZ", value: "true"),
                URLQueryItem(name: "returnM", value: "false")
            ]
            URLSession.shared.dataTask(with: query!.url!, completionHandler: { data, response, error in
                let json = JSON(data!)
                let attrs = json["features"].arrayValue.first!["attributes"]
                sidewalkStorybaord.street = attrs["street_name"].stringValue
                let imageUrl = attrs["picture_url"].stringValue
                if imageUrl == "" {
                    sidewalkStorybaord.defaultImage = UIImage(named: "no_image")
                }
                else {
                    sidewalkStorybaord.imageUrl = imageUrl
                    sidewalkStorybaord.downloadImageFromServer()
                }
                    
                }).resume()
            sidewalkStorybaord.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            sidewalkStorybaord.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            self.present(sidewalkStorybaord, animated: true, completion: nil)

        }
    }
    
    /**
     * Handle map stops moving
     */
    func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition) {
        self.mapView.clear()
        showRoute()
        if mapView.camera.zoom > 15.0 {
            if let transitLayer = transitLayer {
                transitLayer.queryAndRender()
            }
            if let curbrampLayer = curbrampLayer {
                curbrampLayer.queryAndRender()
            }
            if let sidewalkLayer = sidewalkLayer {
                sidewalkLayer.queryAndRender()
            }
            if let crowdsourceLayer = crowdsourceLayer {
                crowdsourceLayer.queryAndRender()
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        // TODO: handle no userData unwrap error
        switch JSON(marker.userData!)["type"].stringValue {
        /* =================== TRANSIT CASE ============================ */
        case MapLayers.transitType:
            //Transit Layer Alert
            let storyboard = UIStoryboard(name: StoryboardIdentifier.mainIdentifier, bundle: nil)
            let transitStoryboard = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.transitionPopUpIdentifier) as! TransitPopUpAlert
            
            let point = marker.position
            var query = URLComponents(string: MapLayers.transitLayerURL!.absoluteString)
            query!.path += "/query"
            query!.queryItems = [
                URLQueryItem(name: "outSR", value: "4326"),
                URLQueryItem(name: "returnGeometry", value: "true"),
                URLQueryItem(name: "inSR", value: "4326"),
                URLQueryItem(name: "returnDistinctValues", value: "false"),
                URLQueryItem(name: "maxAllowableOffset", value: "0.000000"),
                URLQueryItem(name: "spatialRel", value: "esriSpatialRelEnvelopeIntersects"),
                URLQueryItem(name: "geometryType", value: "esriGeometryEnvelope"),
                URLQueryItem(name: "resultRecordCount", value: "1"),
                URLQueryItem(name: "outFields", value: "*"),
                URLQueryItem(name: "geometry", value: "{xmin:\(point.longitude),ymin:\(point.latitude),xmax:\(point.longitude),ymax=\(point.latitude)}"),
                URLQueryItem(name: "f", value: "json"),
                URLQueryItem(name: "returnZ", value: "true"),
                URLQueryItem(name: "returnM", value: "false")
            ]
            URLSession.shared.dataTask(with: query!.url!, completionHandler: { data, response, error in
                let json = JSON(data!)
                let attrs = json["features"].arrayValue.first!["attributes"]
                transitStoryboard.sheltorNameValue = attrs["shelter"].stringValue
                transitStoryboard.stopNameValue = attrs["stop_name"].stringValue
                transitStoryboard.directionValue = attrs["direction"].stringValue
                transitStoryboard.stopTypeValue = attrs["stop_type"].stringValue
                transitStoryboard.routesValue = attrs["routes"].stringValue
                DispatchQueue.main.async {
                    transitStoryboard.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    transitStoryboard.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    self.present(transitStoryboard, animated: true, completion: nil)
                }
            }).resume()

        /* =================== CURBLAYER CASE ============================ */
        case MapLayers.curbrampType:
            //Curb Ramp Alert
            let storyboard = UIStoryboard(name: StoryboardIdentifier.mainIdentifier, bundle: nil)
            let curbRampStoryboard = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.curbRampPopUpIdentifier) as! CurbRampPopupVC
            let point = marker.position
            var query = URLComponents(string: MapLayers.curbRampsLayerURL!.absoluteString)
            query!.path += "/query"
            query!.queryItems = [
                URLQueryItem(name: "outSR", value: "4326"),
                URLQueryItem(name: "returnGeometry", value: "true"),
                URLQueryItem(name: "inSR", value: "4326"),
                URLQueryItem(name: "returnDistinctValues", value: "false"),
                URLQueryItem(name: "maxAllowableOffset", value: "0.000000"),
                URLQueryItem(name: "spatialRel", value: "esriSpatialRelEnvelopeIntersects"),
                URLQueryItem(name: "geometryType", value: "esriGeometryEnvelope"),
                URLQueryItem(name: "resultRecordCount", value: "1"),
                URLQueryItem(name: "outFields", value: "*"),
                URLQueryItem(name: "geometry", value: "{xmin:\(point.longitude),ymin:\(point.latitude),xmax:\(point.longitude),ymax=\(point.latitude)}"),
                URLQueryItem(name: "f", value: "json"),
                URLQueryItem(name: "returnZ", value: "true"),
                URLQueryItem(name: "returnM", value: "false")
            ]
            URLSession.shared.dataTask(with: query!.url!, completionHandler: { data, response, error in
                let json = JSON(data!)
                let attrs = json["features"].arrayValue.first!["attributes"]
                let imageUrl = attrs["imageurl"].stringValue
                let trimmedString = imageUrl.trimmingCharacters(in: .whitespaces)
                if trimmedString == "" {
                    curbRampStoryboard.defaultImage = UIImage(named: "no_image")
                }
                else {
                    curbRampStoryboard.imageUrl = imageUrl
                    curbRampStoryboard.downloadImageCurbRamp()
                }
                
                //Switch case for slop type
                let slopValue = attrs["user_slope"].intValue
                let slop = slopValue
                switch slop {
                case 1:
                    curbRampStoryboard.slopValue = CurbRampType.Poor
                case 2:
                    curbRampStoryboard.slopValue = CurbRampType.Moderate
                case 3:
                    curbRampStoryboard.slopValue = CurbRampType.Good
                default:
                    debugPrint("nothing")
                }

                //Switch case for overall quality condition
                let qualityType = attrs["overall_condition"].intValue

                switch qualityType {
                case 1:
                    curbRampStoryboard.qualityValue = CurbRampType.Poor
                case 2:
                    curbRampStoryboard.qualityValue = CurbRampType.Moderate
                case 3:
                    curbRampStoryboard.qualityValue = CurbRampType.Good
                default:
                    debugPrint("nothing")
                }

                //Switch case for lippage type
                let lippageType = attrs["lippage"].intValue
                switch lippageType {
                case 1:
                    curbRampStoryboard.lippageValue = CurbRampType.Poor
                case 2:
                    curbRampStoryboard.lippageValue = CurbRampType.Moderate
                case 3:
                    curbRampStoryboard.lippageValue = CurbRampType.Good

                default :
                    debugPrint("nothing")
                }
                DispatchQueue.main.async {
                    curbRampStoryboard.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    curbRampStoryboard.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    self.present(curbRampStoryboard, animated: true, completion: nil)
                }
                }).resume()
        /* =================== CROWDSOURCE CASE ============================ */
        case MapLayers.crowdsourceType:
            let storyboard = UIStoryboard(name: StoryboardIdentifier.mainIdentifier, bundle: nil)
            let hazardStoryboard = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.hazardPopUpIdentifier) as? CustomHazardPopUpVC
            var query = URLComponents(string: MapLayers.crowdsourcingLayerURL!.absoluteString)
            query!.path += "/query"
            query!.queryItems = [
                URLQueryItem(name: "outSR", value: "4326"),
                URLQueryItem(name: "returnGeometry", value: "true"),
                URLQueryItem(name: "inSR", value: "4326"),
                URLQueryItem(name: "returnDistinctValues", value: "false"),
                URLQueryItem(name: "maxAllowableOffset", value: "0.000000"),
                URLQueryItem(name: "spatialRel", value: "esriSpatialRelEnvelopeIntersects"),
                URLQueryItem(name: "geometryType", value: "esriGeometryEnvelope"),
                URLQueryItem(name: "resultRecordCount", value: "1"),
                URLQueryItem(name: "outFields", value: "*"),
                URLQueryItem(name: "geometry", value: "{xmin:\(marker.position.longitude),ymin:\(marker.position.latitude),xmax:\(marker.position.longitude),ymax=\(marker.position.latitude)}"),
                URLQueryItem(name: "f", value: "json"),
                URLQueryItem(name: "returnZ", value: "true"),
                URLQueryItem(name: "returnM", value: "false")
            ]
            URLSession.shared.dataTask(with: query!.url!, completionHandler: { data, response, error in
                let json = JSON(data!)
                let attrs = json["features"].arrayValue.first!["attributes"]
                let ctypeValue = attrs["ctyid"].int
                let ctype = ctypeValue
                switch ctype {
                case 1:
                    hazardStoryboard?.hazardTypeValue = TrippingHazradsType.trippingHazard
                case 2:
                    hazardStoryboard?.hazardTypeValue = TrippingHazradsType.noSidewalk
                case 3:
                    hazardStoryboard?.hazardTypeValue = TrippingHazradsType.noCurbRamp
                case 4:
                    hazardStoryboard?.hazardTypeValue = TrippingHazradsType.construction
                case 5:
                    hazardStoryboard?.hazardTypeValue = TrippingHazradsType.othersType
                default:
                    print("nothing")
                }
                // image url
                var imageUrl = attrs["cpath"].string
                imageUrl = imageUrl?.replacingOccurrences(of: "\\", with: "", options: NSString.CompareOptions.literal, range: nil)
                if imageUrl == "" || imageUrl == nil{
                    hazardStoryboard?.defaultImage = UIImage(named: "no_image")
                }
                else {
                    hazardStoryboard?.imageUrl = imageUrl
                    hazardStoryboard?.downloadImage()
                }
                let cidValue = attrs["cid"].intValue
                let uacctID = attrs["uacctid"].intValue

                self.preferences.set(uacctID, forKey: "uacctID")
                self.preferences.set(cidValue, forKey: "cidValue")
                DispatchQueue.main.async {
                    hazardStoryboard?.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    hazardStoryboard?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    self.present(hazardStoryboard!, animated: true, completion: nil)
                }
            }).resume()
        default:
            debugPrint("No layer types found")
        }
        return true
    }
    
    /**
     * TODO: Maneuver turn direction images
     * Changed By Chetu
     */
    func menueverTurnDirection(maneuverDescription:String){
        //We have to parse the maneuver description manually
        //to change images and text appropriately.
        if(maneuverDescription.contains(menueverDirectionText.startDirection)) {
            directionImage.image = UIImage(named: currentLocationImg)
            directionLabel.text = String(maneuverDescription)
        }
        else if(maneuverDescription.contains(menueverDirectionText.towardsDirection)) {
            directionLabel.text = maneuverDescription
            directionImage.image = UIImage(named: head_straightImg)
        }
        else if(maneuverDescription.contains(menueverDirectionText.leftdirection)) {
            directionLabel.text = maneuverDescription
            directionImage.image = UIImage(named: turn_rightImg)
        }
        else if(maneuverDescription.contains(menueverDirectionText.rightDirection)) {
            directionImage.image = UIImage(named: turn_leftImg)
            directionLabel.text = maneuverDescription
        }
        else if(maneuverDescription.contains(menueverDirectionText.continueDirection)) {
            directionImage.image = UIImage(named: head_straightImg)
            directionLabel.text = maneuverDescription
        }
        else if(maneuverDescription.contains(menueverDirectionText.slightLeft)) {
            directionImage.image = UIImage(named:"") // not getting slight left  image
            directionLabel.text = String(maneuverDescription)
        }
        else if(maneuverDescription.contains(menueverDirectionText.slightRight)) {
            directionImage.image = UIImage(named:"") // not getting slight right image
            directionLabel.text = String(maneuverDescription)
        }
        else if(maneuverDescription.contains(menueverDirectionText.westDirection)) {
            directionImage.image = UIImage(named:"")
            directionLabel.text = String(maneuverDescription)
        }
        else if(maneuverDescription.contains(menueverDirectionText.eastDirection)) {
            directionImage.image = UIImage(named:"")
            directionLabel.text = String(maneuverDescription)
        }
        else if(maneuverDescription.contains(menueverDirectionText.northDirection)) {

            directionImage.image = UIImage(named:"")
            directionLabel.text = String(maneuverDescription)
        }
        else if(maneuverDescription.contains(menueverDirectionText.northEastDirection)) {
            directionImage.image = UIImage(named:"")
            directionLabel.text = String(maneuverDescription)
        }
        else if(maneuverDescription.contains(menueverDirectionText.northWestDirection)) {
            directionImage.image = UIImage(named:"")
            directionLabel.text = String(maneuverDescription)
        }
        else if(maneuverDescription.contains(menueverDirectionText.southDirection)) {
            directionImage.image = UIImage(named:"")
            directionLabel.text = String(maneuverDescription)
        }
        else if(maneuverDescription.contains(menueverDirectionText.southEastDirection)) {
            directionImage.image = UIImage(named:"")
            directionLabel.text = String(maneuverDescription)
        }
        else if(maneuverDescription.contains(menueverDirectionText.southWestDirection)) {
            directionImage.image = UIImage(named:"")
            directionLabel.text = String(maneuverDescription)
        }
        else if(maneuverDescription.contains(menueverDirectionText.uturnDirection)) {
            directionImage.image = UIImage(named:"")
            directionLabel.text = String(maneuverDescription)
        }
        else if(maneuverDescription.contains(menueverDirectionText.finishDirection)) {
            directionLabel.text = maneuverDescription
            directionImage.image = UIImage(named: thumbs_upImg)
        }
        else{

        }
    }
 
    
    
    
    /**
     * Increment the current manuever index and display the maneuver on the map
     */
    @IBAction func nextStepButtonPressed(_ sender: Any) {
        // next button working
        if(currentManeuverIndex < (manueverArray.count)) {
            currentManeuverIndex = currentManeuverIndex + 1
            nextButtonManeuverRead()
        }
        else{
            debugPrint("nothing")
        }
    }
    
    
    /**
     * Decrement the current manuever index and display the maneuver on the map
     */
    @IBAction func lastStepButtonPressed(_ sender: Any) {
        // next button working
        if(currentManeuverIndex < (manueverArray.count)) {
            currentManeuverIndex = currentManeuverIndex - 1
            nextButtonManeuverRead()
        }
        else{
            debugPrint("nothing")
        }
    }
    
    /**
     * Center the map on the user's position
     * Changed By Chetu
     */
    @IBAction func reCenterButtonPressed(_ sender: Any) {
        if let lat = fromStop?.latitude, let lng = fromStop?.longitude {
            self.mapView.animate(toLocation: CLLocationCoordinate2D(latitude: lat, longitude: lng))
        }
        else {
            debugPrint("Error getting start location")
        }
    }
    
    /**
     * Opens or closes the directions list view
     */
    @IBAction func modeButtonPressed(_ sender: Any) {
        if(self.listView.isHidden == false) {
            modeButton.setTitle(list, for: .normal)
            modeButtonImage.image = UIImage(named: list_iconImg)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.listView.alpha = 0
            }, completion:  {
                (value: Bool) in
                self.listView.isHidden = true
                self.mapView.bringSubview(toFront: self.mapView)
            })
        } else {
            modeButton.setTitle(Map, for: .normal)
            modeButtonImage.image = UIImage(named: map_iconImg)
            self.listView.isHidden = false
            self.mapView.bringSubview(toFront: self.listView)
            UIView.animate(withDuration: 0.3, animations: {
                self.listView.alpha = 1
            }, completion:  nil)
        }
    }

    /**
     * Go back to navigation home screen
     */
    @IBAction func goBackToOneButtonTapped(_ sender: Any) {
        //stopTimer()
        //self.locationDisplay.stop()
        self.stopLocationUpdateMethod()
        performSegue(withIdentifier: StoryboardIdentifier.unwindSegueToVC1, sender: self)
    }
    
    
    /**
     * Go back to search screen
     */
    @IBAction func dismissView(_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /* Changed by Chetu
     * func Update minutes time interval
     */
    func updateTimeLabels() {
//        if self.route != nil {
//            guard let routeLength = self.routeData?.last?.arrayValue[2].doubleValue else {
//                print("Error getting geofence")
//                return
//            }
//            let feetString = String((routeLength/0.3048).rounded()) + "feet"
//            self.directionDistanceLabel.text = "(\(feetString))"
//        }
    }
    
    // to stop location update
    func stopLocationUpdateMethod(){
        locManager?.stopUpdatingLocation()
    }
}
