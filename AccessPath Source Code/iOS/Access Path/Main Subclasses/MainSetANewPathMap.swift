//
//  TemporaryNavigation.swift
//  Access Path
//
//  Created by Nick Sinagra on 6/9/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit
import ArcGIS
import AudioToolbox
import GoogleMaps
import GooglePlaces
import SwiftyJSON

struct DataForUpdateLocation {
    var checkUpdatelatArray: [CLLocation]?
    var indexCounter: Int?
}

/**
 * Displays map and directions for navigating a user from their current
 * location to their desired location.
 */

class MainSetANewPathMap: UIViewController, CLLocationManagerDelegate, AGSGeoViewTouchDelegate, AGSCalloutDelegate, GMSMapViewDelegate {
    
    //Speech synthesizer for reading directions out loud
    let synth = AVSpeechSynthesizer()
    
    
    var counter = 0
    var hazardindex = 0
    
    // for Timer and check update point of lat and long point Source to destination
    var timer1: Timer?
    var checkCurrentLatlongUpdate = [CLLocation]()
    
    //UI Outlets
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var directionImage: UIImageView!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    //@IBOutlet weak var compassSpinner: SpinnerView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var modeButton: UIButton!
    @IBOutlet weak var modeButtonImage: UIImageView!
    @IBOutlet weak var compassLabel: UILabel!
    @IBOutlet weak var compassView: UIView!
    @IBOutlet weak var compassImage: UIImageView!
    
    //Added by Chetu
    @IBOutlet weak var lastStep_btn: UIButton!
    @IBOutlet weak var nextStep_btn: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    // add Direction Distance label
    @IBOutlet weak var directionDistanceLabel: UILabel!
    
    //Notification Information Outlets
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var notificationIcon: UIImageView!
    @IBOutlet weak var notificationText: UILabel!
    @IBOutlet weak var notificationCloseButton: UIButton!
    @IBOutlet weak var notificationViewHeight: NSLayoutConstraint!
    
    
    //Location information
    var startText:String?
    var destinationText:String?
    var locDisplayStopped = false
    var locManager: CLLocationManager?
    var lat:Double?
    var lng:Double?
    
    @IBOutlet weak var alertViewHeight: NSLayoutConstraint!
    @IBOutlet weak var alertViewLabel: UILabel!
    
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var travelModes:[AGSTravelMode]?
    var travelMode: AGSTravelMode?
    var enteredStop:CLLocationCoordinate2D?
    var fromStop:CLLocationCoordinate2D?
    var sourceLocationStop:CLLocationCoordinate2D?
    var toStop:CLLocationCoordinate2D?
    var userStartStop:CLLocationCoordinate2D?
    
    var featureModelArray = [hazardFeaturesModel]()
    var manueverArray = [manueverListModel]()
    var routeGeometryArray = [routeGeometryModel]()
    
    var currentManeuverIndex = 0
    var isModified = false
    
    //Shared Preferences
    let preferences = UserDefaults.standard
    
    //PHP calls class instance
    let pathVuPHP = PHPCalls()
    
    //View controller for custom map callout
    var popupVC:PopupVC!
    
    
    var activityIndicator = UIActivityIndicatorView()
    var startLocationSound = false
    var previousPointLocation:CLLocationCoordinate2D?
    
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
        case emptyRoute(alertTitle:String, alertMessage:String)
    }
    
    var bannerNotfication: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.notificationView.isHidden = true
        
        mapView.bringSubview(toFront: blurEffect)
        mapView.bringSubview(toFront: spinner)
        blurEffect.isHidden = false
        spinner.isHidden = false
        spinner.startAnimating()
        
        //Set up iPhone location manager
        locManager = CLLocationManager()
        locManager?.requestWhenInUseAuthorization()
        locManager?.requestAlwaysAuthorization()
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
        
        //Store current location for hazard points
        previousPointLocation = CLLocationCoordinate2D(latitude: self.lat ?? 0.0, longitude: self.lng ?? 0.0)
        
        
        do {
          // Set the map style by passing a valid JSON string.
          mapView.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
        } catch {
          NSLog("One or more of the map styles failed to load. \(error)")
        }
        self.mapView.delegate = self
        if let location = locManager?.location?.coordinate {
            mapView.settings.myLocationButton = true
            mapView.isMyLocationEnabled = true
            mapView.camera = GMSCameraPosition(target: location, zoom: defaultZoomLevel)
        }
        
        listView.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool){
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
                if (self.pathVuPHP.newRecent(acctid: acctid!, address: self.destinationText ?? "", lat: latitude, lng: longitude)) {
                    debugPrint("Successfully added recent path")
                }
                else {
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
    
    override func viewDidDisappear(_ animated: Bool) { }
    
    func routeMe() throws {
        if let start = locManager?.location?.coordinate, let stop = self.enteredStop {
            //TODO: check which const is for account id key
            let params = RouteParameters(
                uacctid: self.preferences.integer(forKey: PrefKeys.aidKey),
                tid: self.preferences.integer(forKey: PrefKeys.uTypeKey),
                thw: self.preferences.integer(forKey: PrefKeys.thComfortKeyValue),
                rsw: self.preferences.integer(forKey: PrefKeys.rsComfortKeyValue),
                csw: self.preferences.integer(forKey: PrefKeys.csComfortKeyValue),
                row: self.preferences.integer(forKey: PrefKeys.rComfortKeyValue),
                from: start,
                to: stop)
            let responseData = try self.pathVuPHP.getRoute(with: params)
            let res = JSON(responseData!)
            
            // parse data from reponse
            // populate route Data array and drections array
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
    
    /**
     * This function is responsible for getting a route based on certain route parameters
     * and displaying it on the map.
     */
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
    
    /**
     * This function was supposed to check if the user is on the route
     * but currently only passes the route and maneuver to navigateMe
     */
    func checkRoute() {
        let decoder = CGDecoder()
        self.manueverArray.removeAll()
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
    
    
    /**
     * Changed By Chetu
     * TODO: Location updated
     * Create all geofence for navigate direction
     */
    
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
            
            //Set fake geofence around current maneuver
            let bound1 = CLLocationCoordinate2D(latitude: lattvalue - offset, longitude: longValue - offset)
            let bound2 = CLLocationCoordinate2D(latitude: lattvalue + offset, longitude: longValue - offset)
            let bound3 = CLLocationCoordinate2D(latitude: lattvalue - offset, longitude: longValue + offset)
            let bound4 = CLLocationCoordinate2D(latitude: lattvalue + offset, longitude: longValue + offset)

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
    
    
    /**
     * Increments the maneuver and displays it
     Changed By Chetu
     Change Next Maneuver
     */
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
    
    
    // Created  By Chetu
    //add call menuever direcion
    func menueverTurnDirection(maneuverDescription:String){
        // We have to parse the maneuver description manually
        // to change images and text appropriately.
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

            //startLoading() // call for interact Event
            //Change by  By Chetu
            //Wait a 4 seconds with the thumbs up then back to pop view controller
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
                self.popFinishDirection()
            })
        }
        else{

        }
    }
    
    //MARK: Finish Direction
    func  popFinishDirection()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     // ADD method for Ignor Interct Event for UI
     */
    func startLoading(){
        activityIndicator.center = self.view.center;
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white;
        view.addSubview(activityIndicator);
        activityIndicator.startAnimating();
        UIApplication.shared.beginIgnoringInteractionEvents();
    }
    func stopLoading(){
        activityIndicator.stopAnimating();
        UIApplication.shared.endIgnoringInteractionEvents();
    }
    
    
    /**
     * TODO: Change to ArcGIS location changed handler
     * Users location changed handler
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let position = manager.location?.coordinate {
            self.mapView.camera = GMSCameraPosition(target: position, zoom: self.mapView.camera.zoom)
            self.navigateGeofenceLocation()
            if (self.preferences.bool(forKey: crowdSourceString)) {
                updateHazardDistances()
            }
        }
    }
    
    
    //Center the map on the user's position
    // Changed by Chetu
    // Change next Step button By Chetu
    //MARK: ******  Next step button work **** 
    
    @IBAction func reCenterButtonPressed(_ sender: Any) {
        // next button working
        if(currentManeuverIndex < (manueverArray.count)) {
            currentManeuverIndex = currentManeuverIndex + 1
            nextButtonManeuverRead()
        }
        else{
            debugPrint("nothing")
        }
    }
    
    //
    //Read the last step out loud if the user has that enabled
    @IBAction func lastStepButtonPressed(_ sender: UIButton) {
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
     * Opens or closes the directions list view
     */
    @IBAction func modeButtonPressed(_ sender: Any) {
        if(!listView.isHidden) {
            modeButton.setTitle(list, for: .normal)
            modeButtonImage.image = UIImage(named: list_iconImg)
            lastStep_btn.setTitle(lastStep, for: .normal)
            pauseButton.setTitle(Repeat, for: .normal)
            UIView.animate(withDuration: 0.3/*Animation Duration second*/, animations: {
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
            lastStep_btn.setTitle(Repeat, for: .normal)
            
            if(preferences.bool(forKey: PrefKeys.soundKey)) {
                pauseButton.setTitle(Mute, for: .normal)
                preferences.set(true, forKey: PrefKeys.soundKey)
            } else {
                pauseButton.setTitle(Unmute, for: .normal)
                preferences.set(false, forKey: PrefKeys.soundKey)
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.listView.alpha = 1
            }, completion:  nil)
        }
    }
    
    // Changed By Chetu
    //MARK: Repeat Button working - Repeats current direction when on list page
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        
        //List mode -> Display Repeat button
        if sender.titleLabel?.text == Repeat {
            nextButtonManeuverRead()
        }
        // map mode-> Display Mute title
        //Mute and Unmute
        else{
            if(preferences.bool(forKey: PrefKeys.soundKey)) {
                pauseButton.setTitle(Unmute, for: .normal)
                preferences.set(false, forKey: PrefKeys.soundKey)
            } else {
                pauseButton.setTitle(Mute, for: .normal)
                preferences.set(true, forKey: PrefKeys.soundKey)
                
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
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
    
    func mapView(_ mapView: GMSMapView, didTapMyLocation location: CLLocationCoordinate2D) {
        if let location = locManager?.location?.coordinate {
            mapView.animate(to: GMSCameraPosition(target: location, zoom: defaultZoomLevel))
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
     * This function gets the distances from the user to the hazard
     * If the hazard is less than 50 feet away, the user is notifed
     */
    func updateHazardDistances() {
  
        // comment the user location position
        guard let locationUser = locManager?.location?.coordinate else{
            return
        }
        let userPoint:CLLocationCoordinate2D = locationUser
        
        let distanceMeter = GMSGeometryDistance(userPoint, previousPointLocation!)
        let meterDistance = distanceMeter.rounded()
        
        if meterDistance >= 0.0 {
            previousPointLocation = locationUser

            //thAlert value for check status on/off
            if let thvalue =  preferences.value(forKey:PrefKeys.thAlertKeyValue) {
                let trippingHazardON = thvalue as? Int ?? 0
                //for turn on
                if trippingHazardON == 1 {
                    checkUpdateLocation()
                }
            }
        }
    }
    
    //created hazard boundary points
    func checkUpdateLocation() {
        guard let hazardArray = crowdsourceLayer?.coordinates else {
            print("error getting hazard coordinates")
            return
        }
        for (index,hazard) in hazardArray.enumerated() {
            let lat = hazard.latitude
            let lng = hazard.longitude

            let offset = 0.00040

            //Set fake geofence around current maneuver
            let bound1 = CLLocationCoordinate2D(latitude: lat - offset, longitude: lng - offset)
            let bound2 = CLLocationCoordinate2D(latitude: lat + offset, longitude: lng - offset)
            let bound3 = CLLocationCoordinate2D(latitude: lat - offset, longitude: lng + offset)
            let bound4 = CLLocationCoordinate2D(latitude: lat + offset, longitude: lng + offset)

            // comment the user location position
            guard let locationUser = locManager?.location?.coordinate else {
                return
            }
            if(locationUser.longitude > bound1.longitude && locationUser.latitude > bound1.latitude) {
                if(locationUser.longitude > bound2.longitude && locationUser.latitude < bound2.latitude) {
                    if(locationUser.longitude < bound3.longitude && locationUser.latitude > bound3.latitude) {
                        if(locationUser.longitude < bound4.longitude && locationUser.latitude < bound4.latitude) {
                            //Background process alert
                            let state = UIApplication.shared.applicationState
                            if state == .background {
                                handleEvent()
                            }
                            //Foreground Alert
                            else{
                                handleForgroundEvent()
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    /**
     * Call handler action for background local notification
     * Changed By Chetu
     */
    func handleEvent() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.displayLocalNotification(PlaceText: FavoriteAlertType.hazart_placeApproaching, TextIdentifier: FavoriteAlertType.hazard_identifier)
    }
    
    
    
    
    /**
     * Call handler action for foreground notification
     * Changed By Chetu
     * Hazard alert foreground
     */
    func handleForgroundEvent() {
        
        if bannerNotfication != nil {
            self.bannerNotfication?.removeFromSuperview()
        }
        
        //XIb nib load for banner alert
        bannerNotfication =    UINib(nibName: "BannerAlertVC", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? BannerAlertVC
        bannerNotfication?.frame = CGRect(x: 0, y: 58, width: self.view.frame.width , height: 64)
        
        let addresslbl = bannerNotfication?.viewWithTag(101) as? UILabel
        let bannerCloseBtn = bannerNotfication?.viewWithTag(102) as? UIButton
        addresslbl?.text = FavoriteAlertType.hazart_placeApproaching
        bannerCloseBtn?.addTarget(self, action: #selector(clickOnCloseButton), for: .touchUpInside)
        
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
            self.bannerNotfication!.center.y += 114
            
            let utterance = AVSpeechUtterance(string: FavoriteAlertType.hazart_placeApproaching)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            self.synth.speak(utterance)
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }, completion: {_ in
        })
        self.view.addSubview(bannerNotfication!)
    }
    
    
    
    //MARK: Close banner alert
    @objc func clickOnCloseButton(sender: UIButton) {
        UIView.animate(withDuration: 1, animations: {
            self.bannerNotfication!.center.y -= 104
        }, completion: { (_) in
            self.bannerNotfication?.removeFromSuperview()
        })
    }
    
    
    
    
    /**
     * Removes the yellow notification bar from the view
     */
    @IBAction func dismissNotification(_ sender: Any) {
        closeNotification(animated: true)
    }
    
    func closeNotification(animated:Bool) {
        self.notificationView.layoutIfNeeded()
        self.notificationIcon.isHidden = true
        self.notificationText.isHidden = true
        self.notificationCloseButton.isHidden = true
        
        if(animated) {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, animations: {() -> Void in
                self.notificationView.isHidden = true
                self.notificationViewHeight.constant = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    /**
     * Shows a yellow notification at the top of the map
     */
    func showNotification(text:String) {
        self.notificationView.isHidden = false
        self.notificationIcon.isHidden = false
        self.notificationView.layoutIfNeeded()
        notificationText.text = text
        
        //speech and vibrate phone
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synth.stopSpeaking(at: AVSpeechBoundary.immediate)
        synth.speak(utterance)
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, animations: {() -> Void in
            self.notificationViewHeight.constant = 40
        })
        notificationText.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            self.closeNotification(animated: true)
        }
    }
    
    
    /**
     * Go back to search screen
     */
    @IBAction func dismissView(_ sender:Any) {
        //self.locationDisplay.stop()
        self.stopLocationUpdateMethod()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /**
     * Go back to navigation home screen
     */
    @IBAction func goBackToOneButtonTapped(_ sender: Any) {
        self.stopLocationUpdateMethod()
        performSegue(withIdentifier: StoryboardIdentifier.unwindSegueToVC1, sender: self)
    }
    
    
    // func for Stop timer
    func stopTimer(){
        self.timer1?.invalidate()
        self.timer1 = nil
    }
    
    /* Changed by Chetu
     // func Update minutes time interval
     */
    func updateTimeLabels() {
//        if self.route != nil {
//            guard let routeLength = self.routeData?.last?.arrayValue[2].doubleValue else {
//                print("Error getting geofence")
//                return
//            }
//            let feetString = String((routeLength/0.3048).rounded()) + "feet"
//            // self.directionDistanceLabel.text = "(\(feetString))"
//        }
    }
    
    /**
     Changed BY CHETU
     // to stop location update
     */
    func stopLocationUpdateMethod(){
        locManager?.stopUpdatingLocation()
    }
}


//struct contain true and false
struct hazardFeaturesModel {
    var featureObject:AGSFeature
    //var hazardIndex:Int
    var hazardStatus:Bool
}

//store response geometry
struct routeGeometryModel {
    var geometryList: NSArray
}


//Save directionManuever List model from response direction
struct manueverListModel {
    var directionText : String?
    var manueverLength: Double?
    var manueverStatus :Bool?
    var manueverLatt:Double?
    var manueverLong:Double?
    var nextDescription:String?
    var manueverIndex:Int?
}
