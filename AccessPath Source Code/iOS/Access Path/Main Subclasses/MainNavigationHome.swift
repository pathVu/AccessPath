//
//  ViewController.swift
//  Access Path
//
//  Created by Nick Sinagra on 3/28/18.
//  Copyright © 2018 pathVu. All rights reserved.
//
import Foundation
import UIKit
import CoreLocation
import ArcGIS
import Reachability
import NotificationCenter
import AVFoundation
import AudioToolbox
import GoogleMaps
import SwiftyJSON
import GooglePlaces

let delegate = UIApplication.shared.delegate as! AppDelegate


class MainNavigationHome: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate,
    UIImagePickerControllerDelegate,
UINavigationControllerDelegate  {
    
    @IBOutlet weak var whatsAroundMeButton: UIButton!
    
    //View Section Outlets
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    
    //View Section Height Outlets
    @IBOutlet weak var buttonViewHeight: NSLayoutConstraint!
    @IBOutlet weak var weatherHeight: NSLayoutConstraint!
    @IBOutlet weak var notificationViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var topReportButton: UIButton!
    @IBOutlet weak var topReportButtonIcon: UIImageView!
    
    //Map Button Outlets
    @IBOutlet weak var hamburgerButton: UIButton!
    @IBOutlet weak var obstructionButton: UIButton!
    
    //Navigation Button/Icon Outlets
    @IBOutlet weak var destinationPreviewButton: UIButton!
    @IBOutlet weak var destinationPreviewIcon: UIImageView!
    @IBOutlet weak var favoritePlacesButton: UIButton!
    @IBOutlet weak var favoritePlacesIcon: UIImageView!
    @IBOutlet weak var recentPathsButton: UIButton!
    @IBOutlet weak var recentPathsIcon: UIImageView!
    @IBOutlet weak var setANewPathButton: UIButton!
    @IBOutlet weak var setANewPathIcon: UIImageView!
    
    //Weather Information Outlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionsLabel: UILabel!
    
    //Current Location Information Outlets
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var loadingSpinner: SpinnerView!
    
    //Notification Information Outlets
    @IBOutlet weak var notificationIcon: UIImageView!
    @IBOutlet weak var notificationText: UILabel!
    @IBOutlet weak var notificationCloseButton: UIButton!
    
    //Height values needed for animations
    var originalNotificationViewHeight:CGFloat!
    var originalButtonViewHeight:CGFloat!
    
    //Holds whether the navigation buttons are expanded or not
    var navButtonsExpanded:Bool = false
    
    //Initialize empty arrays for holding navigation buttons and their icons
    //Makes styling and hiding/showing easier
    var navButtons: [UIButton] = [UIButton]()
    var btnIcons: [UIImageView] = [UIImageView]()
    
    //Location Information
    var currentLocationText:String?
    var googleLocationID:String?
    var latitude:Double = 0
    var longitude:Double = 0
    
    //Map Layers
    var transitLayer: GoogleMapsArcGISAdapter?
    var curbrampLayer: GoogleMapsArcGISAdapter?
    var sidewalkLayer: GoogleMapsArcGISAdapter?
    var crowdsourceLayer: GoogleMapsArcGISAdapter?
    var entranceLayer: PathVuMapLayer?
    var indoorLayer: PathVuMapLayer?

    //ArcGIS Location Tasks for reverse geocode (getting address)
    var locatorTask: AGSLocatorTask!
    var reverseGeocodeParameters: AGSReverseGeocodeParameters!
    var cancelable: AGSCancelable!
    
    //PHP Calls class instance
    let pathVuPHP = PHPCalls()
    
    //Network checking class instance
    let network:NetworkChecks = NetworkChecks.sharedInstance
    
    //Preferences Storage
    let preferences = UserDefaults.standard
    
    //View controller for map callouts
    var popupVC:PopupVC!
    
    //Speech synthesizer for reading directions out loud
    let synth = AVSpeechSynthesizer()
    
    var locManager: CLLocationManager?
    var lat:Double?
    var lng:Double?
    var routeOverlay:AGSGraphicsOverlay?
    var favoriteAddressArray = [FavoriteCoordinateListModel]()
    var favoriteAlertRepeat:Bool = false
    var previousPosition = CLLocationCoordinate2D()
    
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

    // store array of additional layer for google map
    var featureTables = [String:Array<CLLocationCoordinate2D>]()
    enum LayerKeys: String {
        case TRANSIT_LAYER_KEY = "transit"
        case CURBRAMP_LAYER_KEY = "curbRamp"
        case SIDEWALK_LAYER_KEY = "sidewalk"
        case CROWDSOURCE_LAYER_KEY = "crowdsource"
    }
    
    // store nearby locations
    var nearbyPlacesArray:[GooglePlace]?
    
    var bannerView: UIView?
    
    //MARK:  View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.bringSubview(toFront: hamburgerButton)
        mapView.bringSubview(toFront: whatsAroundMeButton)
        
        locManager = CLLocationManager()
        locManager?.requestWhenInUseAuthorization()
        locManager?.requestAlwaysAuthorization()
        locManager?.delegate = self
        locManager?.desiredAccuracy = kCLLocationAccuracyBest
        locManager?.requestWhenInUseAuthorization()
        locManager?.distanceFilter = 5.0
        locManager?.requestAlwaysAuthorization()
        locManager?.startUpdatingLocation()
        locManager?.allowsBackgroundLocationUpdates = false
        
        //Both layers are checked by default
        if(preferences.object(forKey: sidewalkStringKey) == nil) {
            preferences.set(true, forKey: sidewalkStringKey)
        }
        //Register ArcGIS License
        do {
            let result = try AGSArcGISRuntimeEnvironment.setLicenseKey(ArcGISLicenceKey.licenceKey)
            debugPrint("License Result : \(result.licenseStatus)")
        } catch let error as NSError {
            debugPrint("error: \(error)")
        }
        
        //If the user dismissed the last notification, close it on load
        if(!preferences.bool(forKey: PrefKeys.notificationKey)) {
            closeNotification(animated: false)
        }
        
        //Set styles for buttons/icons
        navButtons = [destinationPreviewButton, favoritePlacesButton, recentPathsButton, setANewPathButton]
        btnIcons = [destinationPreviewIcon, favoritePlacesIcon, recentPathsIcon, setANewPathIcon]
        setStyles()
        
        //Needed for navigation button and weather info animations
        originalNotificationViewHeight = notificationView.frame.size.height
        originalButtonViewHeight = buttonView.frame.size.height
        buttonViewHandler()
        
        //Gesture to be added to the mapView to allow the user to hide the navigation buttons
        //in order to use the map.
        let gesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        
        //Add that gesture to the mapView
        mapView.addGestureRecognizer(gesture)
        do {
          // Set the map style by passing a valid JSON string.
          mapView.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
        } catch {
          NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.mapView.delegate = self
        let camera = GMSCameraPosition(
            target: locManager?.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0),
            zoom: defaultZoomLevel)
        self.mapView.settings.myLocationButton = true
        self.mapView.isMyLocationEnabled = true
        self.mapView.camera = camera
        favoriteAddressArray = []
        showFavoritesPlacesAPI()
        
        entranceLayer = EntranceLayer(map: self.mapView)
        entranceLayer!.queryAndRender()
        
        indoorLayer = IndoorLayer(map: self.mapView)
        indoorLayer!.queryAndRender()
        
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
            //print("yes")
        }
        if preferences.bool(forKey: crowdSourceString) {
            crowdsourceLayer = CrowdsourceLayer(map: mapView)
            crowdsourceLayer!.setupAndRender()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.mapView.camera.zoom != defaultZoomLevel {
            if let loc = locManager?.location?.coordinate {
                self.mapView.camera = GMSCameraPosition(target: loc, zoom: defaultZoomLevel)
            }
        }
        //Check for network connection
        //If no connection found, stop the view from loading
        if(!checkForConnection()) {
            return
        } else {
            //If internet connection found, check server status
            if(!network.checkServerStatus()) {
                showNotification(text: AlertConstant.unableToConnectPathServer)
            }
        }

        if let lat = locManager?.location?.coordinate.latitude, let lng = locManager?.location?.coordinate.longitude {
            updateWeather(latitude: lat, longitude: lng)
        }
        
        //Load previous weather data (if found) in case weather doesn't update
        if(preferences.object(forKey: PrefKeys.lastWeatherTemp) != nil) {
            temperatureLabel.text = preferences.string(forKey: PrefKeys.lastWeatherTemp)
        }
        
        if(preferences.object(forKey: PrefKeys.lastWeatherConditions) != nil) {
            conditionsLabel.text = preferences.string(forKey: PrefKeys.lastWeatherConditions)
        }
        
        if(preferences.object(forKey: PrefKeys.lastWeatherIcon) != nil) {
            weatherIcon.image = UIImage(named: preferences.string(forKey: PrefKeys.lastWeatherIcon)!)
        }
    }
    
    /**
     * Pause the location display whenever this view is not visible
     */
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
    }
    
   
    /**
     * Location manager delegate method
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let position = manager.location?.coordinate  else {
            debugPrint("error getting user position")
            return
        }
        self.mapView.animate(toLocation: position)
        // Compare user location vs favorites places location
        callFavoritePoints(lattitude: position.latitude, longitude: position.longitude)
        
        // Update weather in minimum 10 minute intervals
        let currentTime = Date()
        
        let distance = GMSGeometryDistance(position, previousPosition)
        if  distance > 20 {
            print("\nUpdating location\n")
            updateLocationInfo()
            let nextWeatherUpdate = preferences.object(forKey: PrefKeys.nextWeatherUpdate)
            if(nextWeatherUpdate == nil || currentTime > nextWeatherUpdate as! Date) {
                if let lat = locManager?.location?.coordinate.latitude, let lng = locManager?.location?.coordinate.longitude {
                    updateWeather(latitude: lat, longitude: lng)
                    //Set next weather update time 10 mins from now
                    preferences.set(currentTime.addingTimeInterval(600), forKey: PrefKeys.nextWeatherUpdate)
                }
            } else {
                debugPrint("Did not update weather")
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        mapTapped()
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        //Sidewalk Layer alert
        /*let storyboard = UIStoryboard(name: StoryboardIdentifier.mainIdentifier, bundle: nil)
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

        }*/
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
        
        if mapView.camera.zoom > 15.0 {
            
            entranceLayer!.queryAndRender()
            indoorLayer!.queryAndRender()
            
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
        /* =================== TRANSIT LAYER ============================ */
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
            break
            
        case MapLayers.sidewalkType:
            let storyboard = UIStoryboard(name: StoryboardIdentifier.mainIdentifier, bundle: nil)
            let sidewalkStoryboard = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.transitionPopUpIdentifier) as! TransitPopUpAlert
            
            let point = marker.position
            var query = URLComponents(string: MapLayers.sidewalkLayerURL!.absoluteString)
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
                sidewalkStoryboard.sheltorNameValue = attrs["shelter"].stringValue
                sidewalkStoryboard.stopNameValue = attrs["stop_name"].stringValue
                sidewalkStoryboard.directionValue = attrs["direction"].stringValue
                sidewalkStoryboard.stopTypeValue = attrs["stop_type"].stringValue
                sidewalkStoryboard.routesValue = attrs["routes"].stringValue
                DispatchQueue.main.async {
                    sidewalkStoryboard.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    sidewalkStoryboard.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    self.present(sidewalkStoryboard, animated: true, completion: nil)
                }
            }).resume()
            break

        /* =================== CURBLAYER LAYER ============================ */
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
            break
        /* =================== CROWDSOURCE HAZARD LAYER ============================ */
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
            break
        /* =================== ENTRANCE LAYER ============================ */
        case MapLayers.entranceType :
            let storyboard = UIStoryboard(name: StoryboardIdentifier.mainIdentifier, bundle: nil)
            let entranceStoryboard = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.EntrancePopupIdentifier) as? EntrancePopupVC
            if let userData = marker.userData as? [String:Any] {
                var imageUrl = userData["imgURL"]  as? String ?? ""
                imageUrl = imageUrl.replacingOccurrences(of: "\\", with: "", options: NSString.CompareOptions.literal, range: nil)
                if imageUrl == ""{
                    entranceStoryboard?.defaultImage = UIImage(named: "no_image")
                }
                else {
                    entranceStoryboard?.imageUrl = imageUrl
                    entranceStoryboard?.downloadImage()
                    entranceStoryboard?.address = userData["address"] as? String ?? ""
                    entranceStoryboard?.entranceSteps = userData["entranceSteps"] as? Int
                    entranceStoryboard?.isAutomatic = userData["isAutomatic"] as? Int
                    entranceStoryboard?.entranceRamp = userData["entranceRamp"] as? Int
                }
                DispatchQueue.main.async {
                    entranceStoryboard?.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    entranceStoryboard?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    self.present(entranceStoryboard!, animated: true, completion: nil)
                }
            }
            break;
        /* =================== INDOOR LAYER ============================ */
        case MapLayers.indoorType:
            let storyboard = UIStoryboard(name: StoryboardIdentifier.mainIdentifier, bundle: nil)
            let indoorStoryboard = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.IndoorPopupIdentifier) as? IndoorPopupVC
            if let userData = marker.userData as? [String:Any] {
                var imageUrl = userData["imgURL"] as? String ?? ""
                imageUrl = imageUrl.replacingOccurrences(of: "\\", with: "", options: NSString.CompareOptions.literal, range: nil)
                if imageUrl == "" {
                    indoorStoryboard?.defaultImage = UIImage(named: "no_image")
                }
                else {
                    indoorStoryboard?.imageUrl = imageUrl
                    indoorStoryboard?.address = userData["address"] as? String ?? ""
                    indoorStoryboard?.indoorType = userData["indoorType"] as? [String] ?? []
                    indoorStoryboard?.indoorSteps = userData["steps"] as? Int
                    indoorStoryboard?.indoorRamp = userData["ramp"] as? Int
                    indoorStoryboard?.hasBraille = userData["hasBraille"] as? Int
                    indoorStoryboard?.isSpacious = userData["isSpacious"] as? Int
                    indoorStoryboard?.downloadImage()
                }
                DispatchQueue.main.async {
                    indoorStoryboard?.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    indoorStoryboard?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    self.present(indoorStoryboard!, animated: true, completion: nil)
                }
            }
            break;
        default:
            debugPrint("No layer types found")
        }
        return true
    }

    /**
     * Performs initial network and server checks and adds listeners in case
     * the network/server is unreachable after loading this view controller.
     */
    func checkForConnection() -> Bool {

        var connectionStatus:Bool = false

        NetworkChecks.isReachable { _ in
            debugPrint("Network Connected")
            connectionStatus = true
        }

        network.reachability.whenReachable = { _ in
            debugPrint("Network Connected")
            connectionStatus = true

            let storyboard = UIStoryboard(name: StoryboardIdentifier.mainIdentifier, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.navigationHomeIdentifier) as UIViewController
            self.present(vc, animated: true, completion: nil)
        }

        NetworkChecks.isUnreachable { _ in

            self.weatherIcon.image = nil
            self.temperatureLabel.text = ""
            self.conditionsLabel.text = AlertConstant.weatherUnavailable

            self.showNotification(text: AlertConstant.noInternetConnection)
            self.preferences.set(false, forKey: PrefKeys.notificationKey)

            let alert = UIAlertController(title: AlertConstant.noInternetConnection, message: AlertConstant.offlineConnectInternet, preferredStyle: UIAlertControllerStyle.alert)
            self.present(alert, animated: true, completion: nil)

            alert.addAction(UIAlertAction(title: AlertConstant.okString, style: .default, handler: { action in
                switch action.style{
                case .default:
                    return
                case .cancel:
                    return
                case .destructive:
                    return
                }
            }))
        }

        network.reachability.whenUnreachable = { _ in
            debugPrint("Network is Unavailable")

            self.weatherIcon.image = nil
            self.temperatureLabel.text = ""
            self.conditionsLabel.text = AlertConstant.weatherUnavailable

            self.showNotification(text: AlertConstant.noInternetConnection)
            self.preferences.set(false, forKey: PrefKeys.notificationKey)

            let alert = UIAlertController(title: AlertConstant.noInternetConnection, message: AlertConstant.offlineConnectInternet, preferredStyle: UIAlertControllerStyle.alert)
            self.present(alert, animated: true, completion: nil)

            alert.addAction(UIAlertAction(title: AlertConstant.okString, style: .default, handler: { action in
                switch action.style{
                case .default:
                    return
                case .cancel:
                    return
                case .destructive:
                    return
                }
            }))
        }
        return connectionStatus
    }
    
    /**
     * Sets up the camera (image picker) and then opens it.
     * Guest accounts are not allowed to report obstructions.
     */
    @IBAction func reportButtonPressed(_ sender: Any) {
        //Set debug to true to bypass image picker
        //Used for phones/simulators without camera
        let debugging = false
        if debugging {
            let image = UIImage(named: "no_image")
            dismiss(animated:true, completion: nil)
            let storyboard = UIStoryboard (name: StoryboardIdentifier.mainIdentifier, bundle: nil)
            let resultVC = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.ConfirmationScreen) as! MainReportConfirmation
            
            resultVC.lat = locManager?.location?.coordinate.latitude
            resultVC.lng = locManager?.location?.coordinate.longitude
            resultVC.address = addressLabel.text
            resultVC.image = image
            resultVC.googleLocationID = self.googleLocationID
            self.present(resultVC, animated: true, completion: nil)
        }
        else {
            if(!preferences.bool(forKey: PrefKeys.guestAccountKey)) {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .camera;
                    imagePicker.allowsEditing = false
                    self.present(imagePicker, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: AlertConstant.reportingNotAvailable, message: AlertConstant.guestAccountNotPermitted, preferredStyle: UIAlertControllerStyle.alert)
                self.present(alert, animated: true, completion: nil)

                alert.addAction(UIAlertAction(title: AlertConstant.okString, style: .default, handler: { action in
                    switch action.style{
                    default:
                        break
                    }
                }))
            }
        }
    }
    
    /**
     * Called when the camera returns to this activity.
     * Passes location info to the report confirmation screen and then opens it.
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismiss(animated:true, completion: nil)
        let storyboard = UIStoryboard (name: StoryboardIdentifier.mainIdentifier, bundle: nil)
        let resultVC = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.ConfirmationScreen) as! MainReportConfirmation
        
        resultVC.lat = locManager?.location?.coordinate.latitude
        resultVC.lng = locManager?.location?.coordinate.longitude
        resultVC.address = addressLabel.text
        resultVC.image = image
        resultVC.googleLocationID = self.googleLocationID
        self.present(resultVC, animated: true, completion: nil)
    }

    /**
     * Helper function which calls the getCurrentTemp function inside the WeatherAPICalls class
     * Changes the icon, temperature label, and conditions label
     */
    func updateWeather(latitude: Double, longitude: Double) {
        
        let (temp, cond, iconCode) = pathVuPHP.getCurrentTemp(lat: latitude, lon: longitude)
        let degreesF:Int = Int(Double(temp) * 1.8 - 459.67)
        
        let fullTemperature = String(degreesF) + "°"
        
        DispatchQueue.main.async {
            self.temperatureLabel.text = fullTemperature
            self.conditionsLabel.text = cond
            self.weatherIcon.image = UIImage(named: iconCode)
        }
        
        preferences.set(fullTemperature, forKey: PrefKeys.lastWeatherTemp)
        preferences.set(cond, forKey: PrefKeys.lastWeatherConditions)
        preferences.set(iconCode, forKey: PrefKeys.lastWeatherIcon)
    }
    
    /**
     * Helper function which calls the reverseGeocode function inside this class
     */
    func updateLocationInfo() {
        if let coordinates = self.locManager?.location?.coordinate {
            self.previousPosition = coordinates
            reverseGeocode(coordinates)
            self.loadingSpinner.isHidden = true
        }
    }
    
    /**
     * ArcGIS function which uses coordinates to get an address
     * This function updates the current address label
     */
    private func reverseGeocode(_ point:CLLocationCoordinate2D) {
        GMSPlacesClient.shared().currentPlace(callback: { (placeLikelihoodList, error) in
            if error != nil {
                return
            }
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    self.currentLocationText = place.formattedAddress
                    self.addressLabel.text = self.currentLocationText
                    self.googleLocationID = place.placeID
                }
            }
        })
    }
    
    /**
     * Expand the four navigation bars at the bottom of the screen
     */
    @IBAction func expandNavButtons(_ sender: Any) {
        buttonViewHandler()
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
                self.notificationViewHeight.constant = 0
                self.view.layoutIfNeeded()
            })
        } else {
            notificationViewHeight.constant = 0
        }
        preferences.set(false, forKey: PrefKeys.notificationKey)
    }
    
    /**
     * Shows a yellow notification at the top of the map
     */
    func showNotification(text:String) {
        preferences.set(true, forKey: PrefKeys.notificationKey)
        
        self.notificationView.layoutIfNeeded()
        notificationText.text = text
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, animations: {() -> Void in
            self.notificationViewHeight.constant = self.originalNotificationViewHeight
            self.view.layoutIfNeeded()
        })
        notificationIcon.isHidden = false
        notificationText.isHidden = false
        notificationCloseButton.isHidden = false
    }
    
    /**
     * If the four navigation buttons are expanded, clicking
     * on the map will close the navigation buttons.
     * Nothing happens when the navigation buttons are hidden.
     * The user will be able to use the map as usual.
     */
    @objc func mapTapped() {
        if(navButtonsExpanded) {
            buttonViewHandler()
        }
    }
    
    /**
     * This function opens/closes the navigation buttons and weather
     * information and allows the mapView to fill that space. The three
     * map icons will appear/disappear based on if the navigation buttons are
     * open or not. Animations with completion events are used for smooth
     * opening and closing of navigation and weather views.
     */
    func buttonViewHandler() {
        if(navButtonsExpanded) {
            //Wait for view to complete any actions before closing
            buttonView.layoutIfNeeded()
            
            //Set and execute the animation for the navigation button view and weather view
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, animations: {() -> Void in
                self.buttonViewHeight.constant = 0
                self.weatherHeight.constant = 0
                self.view.layoutIfNeeded()
            }, completion: {(value:Bool) in
                
            })
            
            //Set and execute the animation for the map buttons
            UIButton.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, animations: {() -> Void in
                self.hamburgerButton.isHidden = false
                self.obstructionButton.isHidden = false
                self.view.layoutIfNeeded()
            })
            
            //Hide weather info and navigation buttons
            self.hideWeatherInfo()
            self.hideNavButtons()
            
        } else {
            buttonView.layoutIfNeeded()
            self.weatherHeight.constant = 50
            self.buttonViewHeight.constant = self.originalButtonViewHeight
            self.view.layoutIfNeeded()
            self.showNavButtons()
            self.showWeatherInfo()
            
            //Set and execute the animation for hiding map buttons
            UIButton.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5,     animations: {() -> Void in
                self.hamburgerButton.isHidden = true
                self.obstructionButton.isHidden = true
                self.view.layoutIfNeeded()
            })
        }
        navButtonsExpanded = !navButtonsExpanded
    }
    
    /**
     * This function unhides the four navigation buttons and their
     * respective icons.
     */
    func showNavButtons() {
        for btn in self.navButtons {
            btn.isHidden = false
        }
        for icon in self.btnIcons {
            icon.isHidden = false
        }
    }
    
    /**
     * Hide the nav buttons and their icons
     */
    func hideNavButtons() {
        for btn in self.navButtons {
            btn.isHidden = true
        }
        for icon in self.btnIcons {
            icon.isHidden = true
        }
    }
    
    /**
     * Show the weather information
     */
    func showWeatherInfo() {
        weatherIcon.isHidden = false
        temperatureLabel.isHidden = false
        conditionsLabel.isHidden = false
    }
    
    /**
     * Hide the weather information
     */
    func hideWeatherInfo() {
        weatherIcon.isHidden = true
        temperatureLabel.isHidden = true
        conditionsLabel.isHidden = true
    }
    
    /**
     * Sets the style of the navigation buttons
     */
    func setStyles() {
        for btn in navButtons {
            btn.layer.cornerRadius = 30
            btn.layer.borderWidth = 1.5
            btn.layer.borderColor = AppColors.darkBlue.cgColor
        }
    }
    
    //Needed to unwind back to this screen from multiple screens
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) { }
    
    /**
     * Call handler action for background local notification
     * Changed By Chetu
     */
    func handleEvent(address:String) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        //delegate.displayLocalNotification()
        delegate.displayLocalNotification(PlaceText: "\(address)", TextIdentifier: "Approaching")
    }
    
    /**
     * Call handler action for foreground notification
     * Changed By Chetu
     */
    func handleForgroundEvent(address: String) {
        
        if bannerView != nil {
            self.bannerView?.removeFromSuperview()
        }
        
        //XIb nib load for banner alert
        bannerView =    UINib(nibName: "BannerAlertVC", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? BannerAlertVC
        bannerView?.frame = CGRect(x: 0, y: 58, width: SCREEN_WIDTH, height: 64)
        
        let addresslbl = bannerView?.viewWithTag(101) as? UILabel
        let closeButton = bannerView?.viewWithTag(102) as? UIButton
        addresslbl?.text = "Approaching \(address)"
        closeButton?.addTarget(self, action: #selector(CloseButton), for: .touchUpInside)
        
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
            self.bannerView!.center.y += 114
            
            let utterance = AVSpeechUtterance(string: "Approaching \(address)")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            self.synth.speak(utterance)
        }, completion: {_ in
        })
        self.view.addSubview(bannerView!)
    }
    
    //MARK: Close banner alert
    @objc func CloseButton(sender: UIButton) {
        UIView.animate(withDuration: 1, animations: {
            self.bannerView!.center.y -= 104
        }, completion: { (_) in
            self.bannerView?.removeFromSuperview()
        })
    }
    
    @IBAction func whatsAroundMeButtonPressed(_ sender: Any) {
        let radiusInMeters = 100
        if let userLocation = self.locManager?.location?.coordinate {
            // build places array with data from Google API request
            self.nearbyPlacesArray = self.pathVuPHP.getNearbyPlaces(near: userLocation, radius: radiusInMeters)
            let storyboard = UIStoryboard (name: StoryboardIdentifier.mainIdentifier, bundle: nil)
            let placesVC = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.NearbyPlacesTableVC) as! MainNearbyPlacesViewController
            placesVC.placesArray = self.nearbyPlacesArray
            placesVC.userLocation = locManager?.location?.coordinate
            self.present(placesVC, animated: true, completion: nil)
        }
        else
        {
            debugPrint("Could not get user location when requesting near by places")
            let alert = UIAlertController(title: AlertConstant.failed, message: "Failed to get near by places.", preferredStyle: UIAlertControllerStyle.alert)
            self.present(alert, animated: true, completion: nil)

            alert.addAction(UIAlertAction(title: AlertConstant.okString, style: .default, handler: { action in
                switch action.style{
                default:
                    break
                }
            }))
        }
    }
    
    /**
     * Show favorites places using favorite list api
     * Changed By Chetu
     */
    func showFavoritesPlacesAPI() {
        //Get the favorites for this account
        
        if preferences.string(forKey: PrefKeys.aidKey) != nil {
            
            let acctid = preferences.string(forKey: PrefKeys.aidKey)
            let responseData = pathVuPHP.getFavorites(acctid: acctid!)
            
            //If there is any error loading favorites, show the add first favorite view
            if let responseData = responseData {
                //Iterate through response and add to name and address arrays
                let jsonArray = JSON(responseData)
                for item in jsonArray["favorites"].arrayValue {
                    let favLattitude = item["flat"].doubleValue
                    let favLongitude = item["flon"].doubleValue
                    
                    self.favoriteAddressArray = []
                    
                    let favModelArray = FavoriteCoordinateListModel.init(favName: item["fname"].stringValue, favAddress: item["faddress"].stringValue, favoritePlaceLattitude: favLattitude, favoritePlacelongitude: favLongitude, favPlacesStatus: false, favPlaceIndex: 0)
                    self.favoriteAddressArray.append(favModelArray)
                }
            }
            else {
                return
            }
        }
    }
    
    //MARK: *********  Favorite place alert  *********
    func callFavoritePoints(lattitude:Double, longitude:Double) {
        
        if self.favoriteAddressArray.count != 0 {
            for (Index,favoriteDetails) in self.favoriteAddressArray.enumerated() {
                let favoriteLatt = favoriteDetails.favoritePlaceLattitude ?? 0.0
                let favoriteLong = favoriteDetails.favoritePlacelongitude ?? 0.0
                let offset = 0.00040
                
                //Set fake geofence around current maneuver
                let bound1 = CLLocationCoordinate2D(latitude: favoriteLatt - offset, longitude: favoriteLong - offset)
                let bound2 = CLLocationCoordinate2D(latitude: favoriteLatt + offset, longitude: favoriteLong - offset)
                let bound3 = CLLocationCoordinate2D(latitude: favoriteLatt - offset, longitude: favoriteLong + offset)
                let bound4 = CLLocationCoordinate2D(latitude: favoriteLatt + offset, longitude: favoriteLong + offset)
                //Commented code display dot icons on map
                /*
                let boundGeometri1 = AGSGeometryEngine.projectGeometry(bound1, to: AGSSpatialReference.wgs84())
                let boundGeometri2 = AGSGeometryEngine.projectGeometry(bound2, to: AGSSpatialReference.wgs84())
                let boundGeometri3 = AGSGeometryEngine.projectGeometry(bound3, to: AGSSpatialReference.wgs84())
                let boundGeometri4 = AGSGeometryEngine.projectGeometry(bound4, to: AGSSpatialReference.wgs84())
                
                let routeSymbol = AGSSimpleMarkerSymbol(style: .circle, color: .red, size: 20)
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
                
                
                guard let locationUser = locManager?.location?.coordinate else {
                    print("error getting user location while checking favorites")
                    return
                }
                let favoriteLocation = CLLocationCoordinate2D(latitude: favoriteLatt, longitude: favoriteLong) //current location
                
                //Calculate distance between favorite point and user location
                
                let meterDistance = GMSGeometryDistance(locationUser, favoriteLocation)
                print("******** meterDistance \(meterDistance)")
                
                //Repeat Favorite Alert condition
                if  favoriteAlertRepeat == true {
                    if meterDistance > 100.0 {
                        self.favoriteAddressArray[Index].favPlacesStatus = false
                        favoriteAlertRepeat = false
                    }
                }
                
                if(locationUser.longitude > bound1.longitude && locationUser.latitude > bound1.latitude) {
                    if(locationUser.longitude > bound2.longitude && locationUser.latitude < bound2.latitude) {
                        if(locationUser.longitude < bound3.longitude && locationUser.latitude > bound3.latitude) {
                            if(locationUser.longitude < bound4.longitude && locationUser.latitude < bound4.latitude) {
                                
                                //thAlert value for check status on/off
                                let FAvalue =  preferences.value(forKey:PrefKeys.favoritePlaceAlertKey) // ?? "1"
                                let favoriteAlertON = FAvalue as? Int ?? 0
                                //for turn on
                                if favoriteAlertON == 1 {
                                    
                                    //Background process alert
                                    if favoriteDetails.favPlacesStatus == false {
                                        let state = UIApplication.shared.applicationState
                                        if state == .background {
                                        self.favoriteAddressArray[Index].favPlacesStatus = true
                                        guard let FavAddress = favoriteDetails.favName else {
                                                return
                                        }
                                        favoriteAlertRepeat = true //Repeat alert value
                                        handleEvent(address: FavAddress)
                                        }
                                            // Foreground Alert
                                    else {
                                        if favoriteDetails.favPlacesStatus == false {
                                            self.favoriteAddressArray[Index].favPlacesStatus = true
                                            guard let FavAddress = favoriteDetails.favName else {
                                                    return
                                            }
                                            favoriteAlertRepeat = true
                                            handleForgroundEvent(address: FavAddress)
                                            }
                                        }
                                    }
                                }
                                //Fav alert off
                                // }
                                print("outside the index with remove observer")
                            }
                        }
                    }
                }
            }
        }
    }
}

extension UIImageView {
    public func imageFromURL(urlString: String) {
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        activityIndicator.startAnimating()
        if self.image == nil{
            self.addSubview(activityIndicator)
        }
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error ?? "No Error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                activityIndicator.removeFromSuperview()
                self.image = image
            })
            
        }).resume()
    }
}
