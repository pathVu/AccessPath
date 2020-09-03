//
//  ViewController.swift
//  Access Path
//
//  Created by Nick Sinagra on 3/28/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit
import CoreLocation
import ArcGIS
import Reachability

class MainNavigationHome: UIViewController, CLLocationManagerDelegate, AGSGeoViewTouchDelegate,
    UIImagePickerControllerDelegate,
UINavigationControllerDelegate  {
    
    //Main View Sections
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var notificationView: UIView!

    //Main View Section Heights
    @IBOutlet weak var buttonViewHeight: NSLayoutConstraint!
    @IBOutlet weak var weatherHeight: NSLayoutConstraint!
    @IBOutlet weak var notificationViewHeight: NSLayoutConstraint!
    var originalButtonViewHeight:CGFloat!
    
    @IBOutlet weak var topReportButton: UIButton!
    @IBOutlet weak var topReportButtonIcon: UIImageView!
    
    //Buttons on Map
    @IBOutlet weak var hamburgerButton: UIButton!
    @IBOutlet weak var obstructionButton: UIButton!
    @IBOutlet weak var soundButton: UIButton!
    
    //Bottom Navigation View
    @IBOutlet weak var destPrevBtn: UIButton!
    @IBOutlet weak var favPlacesBtn: UIButton!
    @IBOutlet weak var recentPathsBtn: UIButton!
    @IBOutlet weak var setNewPathBtn: UIButton!
    @IBOutlet weak var destPrevIcon: UIImageView!
    @IBOutlet weak var favPlacesIcon: UIImageView!
    @IBOutlet weak var recentPathsIcon: UIImageView!
    @IBOutlet weak var setNewPathIcon: UIImageView!
    
    //Weather Information
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var conditions: UILabel!
    @IBOutlet weak var precipitationNumber: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var precipitationLabel: UILabel!
    
    //Current Location
    @IBOutlet weak var addressLabel: UILabel!
    
    //Notification Information
    @IBOutlet weak var notificationIcon: UIImageView!
    @IBOutlet weak var notificationText: UILabel!
    @IBOutlet weak var notificationCloseBtn: UIButton!
    var originalNotificationViewHeight:CGFloat!
    
    //This variable holds whether the navigation buttons are expanded or not
    var expanded:Bool = false
    
    //Initialize empty arrays for holding navigation buttons and their icons
    var navButtons: [UIButton] = [UIButton]()
    var btnIcons: [UIImageView] = [UIImageView]()
    
    //PHP Calls class instance
    let pathVuPHP = PHPCalls()
    
    //Preferences Storage
    let preferences = UserDefaults.standard
    
    //iPhone Location Manager and Coordinates
    var locManager = CLLocationManager()
    var locationDisplay:AGSLocationDisplay!
    var latitude: Double = 0
    var longitude: Double = 0
    
    //ArcGIS Location Tasks for reverse geocode (getting address)
    var locatorTask: AGSLocatorTask!
    var reverseGeocodeParameters: AGSReverseGeocodeParameters!
    var cancelable: AGSCancelable!
    let locatorURL = "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"
    let overlay = AGSGraphicsOverlay()

    var serviceFeatureTables:[AGSServiceFeatureTable] = [AGSServiceFeatureTable]()
    
    let network:NetworkChecks = NetworkChecks.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(preferences.object(forKey: PrefKeys.notificationKey) == nil) {
            preferences.set(false, forKey: PrefKeys.notificationKey)
        }
        
        //By default, the weather info and navigation buttons are hidden.
        navButtons = [destPrevBtn, favPlacesBtn, recentPathsBtn, setNewPathBtn]
        btnIcons = [destPrevIcon, favPlacesIcon, recentPathsIcon, setNewPathIcon]
        
        hideNavButtons()
        hideWeatherInfo()
        
        if(!preferences.bool(forKey: PrefKeys.notificationKey)) {
            notificationViewHeight.constant = 0
            notificationText.isHidden = true
            notificationIcon.isHidden = true
            notificationCloseBtn.isHidden = true
        }
        
        if(preferences.bool(forKey: PrefKeys.soundKey)) {
            soundButton.setImage(UIImage(named: "sound-on-icon"), for: .normal)
        } else {
            soundButton.setImage(UIImage(named: "sound-off-icon"), for: .normal)
        }
        
        originalNotificationViewHeight = notificationView.frame.size.height
        originalButtonViewHeight = buttonView.frame.size.height
        self.buttonViewHeight.constant = 0
        self.weatherHeight.constant = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(preferences.object(forKey: PrefKeys.signedInKey) == nil) {
            firstBoot()
            return
        }
        
        do {
            let result = try AGSArcGISRuntimeEnvironment.setLicenseKey("runtimelite,1000,rud4860087466,none,5H80TK8EL9GP6XCFK121")
            print("License Result : \(result.licenseStatus)")
        }
        catch let error as NSError {
            print("error: \(error)")
        }
        
        //Gesture to be added to the mapView to allow the user to hide the navigation buttons
        //in order to use the map.
        let gesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        
        //Add that gesture to the mapView
        mapView.addGestureRecognizer(gesture)
        self.mapView.touchDelegate = self
        
        //Set the style of the navigation buttons
        setStyles()

        //Check for network connection
        //If no connection found, stop this function from continuing to avoid crashes
        if(!checkForConnection()) {
            return
        } else {
            //Check server status
            if(!network.checkServerStatus()) {
                showNotification(text: "Unable to connect to pathVu servers")
            }
        }
        
        //Ask for location permissions if they haven't been granted already
        self.locManager.requestWhenInUseAuthorization()
        self.locManager.requestAlwaysAuthorization()
        
        //Set up the location manager to auto-update
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.requestAlwaysAuthorization()
        locManager.startUpdatingLocation()
        
        if(locManager.location != nil) {
            latitude = (locManager.location?.coordinate.latitude)!
            longitude = (locManager.location?.coordinate.longitude)!
        }
        
        let map = AGSMap(basemapType: AGSBasemapType.streetsVector, latitude: latitude, longitude: longitude, levelOfDetail: 10)
        
        //Map Layers
        //Sidewalk layer is non-optional
        let sidewalkLayerURL:URL = URL(string: "https://services7.arcgis.com/lCps1TIE7mFpTJoN/arcgis/rest/services/Deliverable_1/FeatureServer/4")!
        let serviceFeatureTable = AGSServiceFeatureTable(url: sidewalkLayerURL)
        serviceFeatureTables.append(serviceFeatureTable)
        let featureLayer0:AGSFeatureLayer = AGSFeatureLayer(featureTable: serviceFeatureTable)
        map.operationalLayers.add(featureLayer0)
        
        if(preferences.bool(forKey: "transitStopsLayer")) {
            let transitStopsLayerURL:URL = URL(string: "https://services7.arcgis.com/lCps1TIE7mFpTJoN/arcgis/rest/services/Transit_Stops_Deliverable1/FeatureServer/0")!
            let serviceFeatureTable = AGSServiceFeatureTable(url: transitStopsLayerURL)
            serviceFeatureTables.append(serviceFeatureTable)
            let featureLayer1:AGSFeatureLayer = AGSFeatureLayer(featureTable: serviceFeatureTable)
            map.operationalLayers.add(featureLayer1)
        }
        
        if(preferences.bool(forKey: "curbRampsLayer")) {
            let curbRampsLayerURL:URL = URL(string: "https://services7.arcgis.com/lCps1TIE7mFpTJoN/arcgis/rest/services/Curb_Ramps2/FeatureServer/0")!
            let serviceFeatureTable = AGSServiceFeatureTable(url: curbRampsLayerURL)
            serviceFeatureTables.append(serviceFeatureTable)
            let featureLayer2:AGSFeatureLayer = AGSFeatureLayer(featureTable: serviceFeatureTable)
            map.operationalLayers.add(featureLayer2)
        }
            
        self.mapView.map = map
        
        //Display user location on map
        locationDisplay = self.mapView.locationDisplay
        locationDisplay.autoPanMode = AGSLocationDisplayAutoPanMode.navigation
        locationDisplay.navigationPointHeightFactor = 0.5
        locationDisplay.showAccuracy = true
        locationDisplay.showPingAnimationSymbol = true
        
        locationDisplay.start { (error:Error?) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        
        if self.mapView.callout.isHidden {
            
            let tolerance = 1.5
            let mapTolerance = tolerance * self.mapView.unitsPerPoint
            let envelope:AGSEnvelope = AGSEnvelope(xMin: mapPoint.x - mapTolerance, yMin: mapPoint.y - mapTolerance , xMax: mapPoint.x + mapTolerance, yMax: mapPoint.y + mapTolerance, spatialReference: self.mapView.spatialReference)
            
            let query = AGSQueryParameters()
            query.geometry = envelope
            
            var calloutDetail:String = ""
            for table in serviceFeatureTables {
                table.queryFeatures(with: query) { (result:AGSFeatureQueryResult?, error:Error?) in
                    if let features = result?.featureEnumerator().allObjects {
                        features.forEach {(feature) in
                            guard let arcgisFeature = feature as? AGSArcGISFeature else {
                                return
                            }
                            
                            let attributes = arcgisFeature.attributes
                            let enumerator = attributes.keyEnumerator()
                            while let key = enumerator.nextObject() {
                                if let keyString = key as? String {
                                    let valueString = attributes.object(forKey: keyString)
                                    calloutDetail.append(keyString + ": " + "\(valueString!)" + "\n")
                                }
                            }
                            
                            print(calloutDetail)
                            
                            let storyboard = UIStoryboard (name: "Main", bundle: nil)
                            let popupVC = storyboard.instantiateViewController(withIdentifier: "PopupVC") as! PopupVC
                            popupVC.objDescription = calloutDetail
                            popupVC.view.frame = CGRect(x: 0, y: 0, width: 150, height: 75)
                            self.mapView.callout.customView = popupVC.view
                            self.mapView.callout.show(at: mapPoint, screenOffset: CGPoint.zero, rotateOffsetWithMap: false, animated: true)

                        }
                    }
                }
            }
            
            
        } else {
            self.mapView.callout.dismiss()
        }
    }
    
    func checkForConnection() -> Bool {
        
        var connectionStatus:Bool = false
        NetworkChecks.isReachable { _ in
            print("Network Connected")
            connectionStatus = true
        }
        
        network.reachability.whenReachable = { _ in
            print("Network Connected")
            connectionStatus = true
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "NavigationHome") as UIViewController
            self.present(vc, animated: true, completion: nil)
        }
        
        NetworkChecks.isUnreachable { _ in
            print("Network is Unavailable")
            
            self.weatherIcon.image = nil
            self.temperature.text = ""
            self.conditions.text = "Weather Unavailable"
            
            self.showNotification(text: "No Internet Connection")
            self.preferences.set(false, forKey: PrefKeys.notificationKey)
            
            let alert = UIAlertController(title: "No Internet Connection", message: "You are offline, please connect to the internet and try again.", preferredStyle: UIAlertControllerStyle.alert)
            self.present(alert, animated: true, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
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
            print("Network is Unavailable")
            
            self.weatherIcon.image = nil
            self.temperature.text = ""
            self.conditions.text = "Weather Unavailable"
            
            self.showNotification(text: "No Internet Connection")
            self.preferences.set(false, forKey: PrefKeys.notificationKey)
            
            let alert = UIAlertController(title: "No Internet Connection", message: "You are offline, please connect to the internet and try again.", preferredStyle: UIAlertControllerStyle.alert)
            self.present(alert, animated: true, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
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
    
    @IBAction func reportButtonPressed(_ sender: Any) {
        if(!preferences.bool(forKey: PrefKeys.guestAccountKey)) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Reporting Not Available", message: "Guest accounts are not permitted to report obstructions. Please sign up with a non-guest account.", preferredStyle: UIAlertControllerStyle.alert)
            self.present(alert, animated: true, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                    default:
                        break
                }
            }))
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        dismiss(animated:true, completion: nil)
        
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let resultVC = storyboard.instantiateViewController(withIdentifier: "ConfirmationScreen") as! MainReportConfirmation
        
        resultVC.lat = latitude
        resultVC.lng = longitude
        resultVC.address = addressLabel.text
        resultVC.image = image
        
        self.present(resultVC, animated: true, completion: nil)
        //imagePicked.image = image
    }
    
    
    @IBAction func soundButtonPressed(_ sender: Any) {
        if(preferences.object(forKey: PrefKeys.soundKey) != nil) {
            if(preferences.bool(forKey: PrefKeys.soundKey)) {
                soundButton.setImage(UIImage(named: "sound-off-icon"), for: .normal)
                preferences.set(false, forKey: PrefKeys.soundKey)
            } else {
                soundButton.setImage(UIImage(named: "sound-on-icon"), for: .normal)
                preferences.set(true, forKey: PrefKeys.soundKey)
            }
        } else {
            soundButton.setImage(UIImage(named: "sound-off-icon"), for: .normal)
            preferences.set(false, forKey: PrefKeys.soundKey)
        }
    }
    
    /**
     * This function executes whenever the device location is updated, about once every second
     * This is used for updating the current address and the weather
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Updating location...")
        
        self.latitude = (manager.location?.coordinate.latitude)!
        self.longitude = (manager.location?.coordinate.longitude)!
        
        print("Coordinates: " + String(latitude) + " " + String(longitude))
        
        updateWeather(latitude: latitude, longitude: longitude)
        updateLocation(latitude: latitude, longitude: longitude)
    }

    /**
     * Helper function which calls the getCurrentTemp function inside the WeatherAPICalls class
     * Changes the icon, temperature label, and conditions label
     */
    func updateWeather(latitude: Double, longitude: Double) {
    
        let (temp, cond, iconCode) = pathVuPHP.getCurrentTemp(lat: latitude, lon: longitude)
        let degreesF:Int = Int(Double(temp) * 1.8 - 459.67)
        
        temperature.text = String(degreesF) + "°"
        conditions.text = cond
        weatherIcon.image = UIImage(named: iconCode)
    }
 
    /**
     * Helper function which calls the reverseGeocode function inside this class
     */
    func updateLocation(latitude: Double, longitude: Double) {
            self.locatorTask = AGSLocatorTask(url: URL(string: self.locatorURL)!)
        
            print("Updating location for " + String(latitude) + ", " + String(longitude))
        
            self.reverseGeocodeParameters = AGSReverseGeocodeParameters()
            self.reverseGeocodeParameters.maxResults = 1
        
            let point = AGSPointMakeWGS84(latitude, longitude)
            reverseGeocode(point)
    }
    
    /**
     * ArcGIS function which uses coordinates to get an address
     * This function updates the current address label
     */
    private func reverseGeocode(_ point:AGSPoint) {
        if(self.cancelable != nil) {
            self.cancelable.cancel()
        }
        
        let normalizedPoint = AGSGeometryEngine.normalizeCentralMeridian(of: point) as! AGSPoint
        
        self.cancelable = self.locatorTask.reverseGeocode(withLocation: normalizedPoint, parameters: self.reverseGeocodeParameters) { [weak self] (results: [AGSGeocodeResult]?, error: Error?) -> Void in
            if let error = error as NSError? {
                if error.code != NSUserCancelledError { //user canceled error
                    print(error.localizedDescription)
                }
            } else {
                if let results = results, results.count > 0 {
                    self?.addressLabel.text = results.first!.attributes!["Address"]! as? String
                    print(results.first!.attributes!["Address"]!)
                    return
                } else {
                    print("No address found")
                }
            }
        }
    }
    
    /**
     * This is a button on-click event
     * Expand the four navigation bars at the bottom of the screen
     */
    @IBAction func expandNavButtons(_ sender: Any) {
        buttonViewHandler()
    }
    
    /**
     * This is a button on-click event
     * Removes the yellow notification bar from the view
     */
    @IBAction func dismissNotification(_ sender: Any) {
        preferences.set(false, forKey: PrefKeys.notificationKey)
        self.notificationView.layoutIfNeeded()
        
        self.notificationIcon.isHidden = true
        self.notificationText.isHidden = true
        self.notificationCloseBtn.isHidden = true
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, animations: {() -> Void in
            self.notificationViewHeight.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    func showNotification(text:String) {
        preferences.set(true, forKey: PrefKeys.notificationKey)
        
        self.notificationView.layoutIfNeeded()
        notificationText.text = text
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, animations: {() -> Void in
            self.notificationViewHeight.constant = self.originalNotificationViewHeight
            self.view.layoutIfNeeded()
        })

        print(originalButtonViewHeight)
        
        notificationIcon.isHidden = false
        notificationText.isHidden = false
        notificationCloseBtn.isHidden = false
    }
    
    /**
     * This is a mapView on-click event (gesture)
     * If the four navigation buttons are expanded, clicking
     * on the map will close the navigation buttons.
     * Nothing happens when the navigation buttons are hidden,
     * and the user will be able to use the map as usual.
     */
    @objc func mapTapped() {
        if(expanded) {
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
        if(expanded) {
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
                    self.soundButton.isHidden = false
                    self.obstructionButton.isHidden = false
                    self.view.layoutIfNeeded()
            })
            
            //Hide weather info and navigation buttons
            self.hideWeatherInfo()
            self.hideNavButtons()
            
        } else {
            buttonView.layoutIfNeeded()
            
            //Set and execute the animation for opening navigation buttons and weather info
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, animations: {() -> Void in
                    self.weatherHeight.constant = 50
                    self.buttonViewHeight.constant = self.originalButtonViewHeight
                    self.view.layoutIfNeeded()
            }, completion:
                {(value: Bool) in
                    self.showNavButtons()
                    self.showWeatherInfo()
            })
            
            //Set and execute the animation for hiding map buttons
            UIButton.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5,     animations: {() -> Void in
                    self.hamburgerButton.isHidden = true
                    self.soundButton.isHidden = true
                    self.obstructionButton.isHidden = true
                    self.view.layoutIfNeeded()
                })
        }
        //Change the expanded boolean to its opposite
        expanded = !expanded
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
     * This function hides the four navigation buttons and their
     * respective icons.
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
     * This function unhides the weather information
     */
    func showWeatherInfo() {
        weatherIcon.isHidden = false
        temperature.isHidden = false
        conditions.isHidden = false
        //precipitationNumber.isHidden = false
        //percentLabel.isHidden = false
        //precipitationLabel.isHidden = false
    }
    
    /**
     * This function hides the weather information
     */
    func hideWeatherInfo() {
        weatherIcon.isHidden = true
        temperature.isHidden = true
        conditions.isHidden = true
        //precipitationNumber.isHidden = true
        //percentLabel.isHidden = true
        //precipitationLabel.isHidden = true
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
    
    /**
     * This function runs when the user is not signed in
     * The onboarding process will be resumed wherever they left off
     */
    func firstBoot() {
        var signedIn:Bool

        if(preferences.object(forKey: PrefKeys.signedInKey) != nil){
            signedIn = preferences.bool(forKey: PrefKeys.signedInKey)
        } else {
            signedIn = false
        }
        
        if(!signedIn) {
            let storyboard = UIStoryboard(name: "GettingStarted1", bundle: nil)
            var screenName = ""
            switch preferences.integer(forKey: PrefKeys.onboardProgKey) {
            case 1:
                screenName = "TermsOfAgreement"
                break
            case 2:
                screenName = "FullTermsOfAgreement"
                break
            case 3:
                screenName = "CreateNewAccount"
                break
            case 4:
                screenName = "NameAndEmailSignUp"
                break
            case 5:
                screenName = "UsernameScreen"
                break
            case 6:
                screenName = "ComfortSettingsMain"
                break
            case 7:
                screenName = "ObstructionList"
                break
            case 8:
                screenName = "RunInBackground"
                break
            case 9:
                screenName = "LogInMain"
                break
            default:
                screenName = "GetStarted1"
                break
            }
            
            let vc = storyboard.instantiateViewController(withIdentifier: screenName) as UIViewController
            self.present(vc, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        
        self.removeFromParentViewController()
    }
}

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}
