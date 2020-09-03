//
//  SetNewPathMain.swift
//  Access Path
//
//  Created by Nick Sinagra on 5/17/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit
import ArcGIS
import AVFoundation
import GooglePlaces
import CoreLocation

/**
 * Allows users to search for a location for the purposes of navigating
 * from their current location to their desired location.
 */
class MainSetANewPathSearch: UIViewController, UITextFieldDelegate,CLLocationManagerDelegate {
    
    //UI Outlets
    @IBOutlet weak var startSearchView: UIView!
    @IBOutlet weak var destSearchView: UIView!
    @IBOutlet weak var startSearchBox: CustomSearch!
    @IBOutlet weak var destSearchBox: CustomSearch!
    @IBOutlet weak var startSuggestions: UITableView!
    @IBOutlet weak var startSuggestionsHeight: NSLayoutConstraint!
    @IBOutlet weak var destSuggestions: UITableView!
    @IBOutlet weak var destSuggestionsHeight: NSLayoutConstraint!
    @IBOutlet weak var startSearchCurrLocIcon: UIImageView!
    @IBOutlet weak var startSearchMagIcon: UIImageView!
    @IBOutlet weak var crossButton: UIButton!
    
    var googlePlacesToken:GMSAutocompleteSessionToken!

    //Holds search suggestions
    var destPlaceID: String?
    var destSuggestionsArray: [GMSAutocompletePrediction] = []

    //Hold start search suggestions
    var startPlaceID:String?
    var startSuggestionsArray: [GMSAutocompletePrediction] = []

    //Speech synthesizer for reading directions out loud
    let synth = AVSpeechSynthesizer()
    
    var locManager: CLLocationManager?
    var lat:Double?
    var lng:Double?
    var userLocation:CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        googlePlacesToken = GMSAutocompleteSessionToken.init()

        startSuggestions.delegate = self
        startSuggestions.dataSource = self
        destSuggestions.delegate = self
        destSuggestions.dataSource = self
        setStyles()
        //setupAddressSearchView()
        
        /*
         * Changed by Chetu
         * Destination voice text
         */
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            debugPrint("done")
            let description = destinationVoiceText
            let utterance = AVSpeechUtterance(string: description)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            self.synth.speak(utterance)
        })
        
        /*
         * Created by Chetu
         * add textfiledShouldEndediting method call
         */
        destSearchBox.addTarget(self, action: #selector(textFieldShouldEndEditing(_:)), for: .editingChanged)
        startSuggestionsHeight.constant = 0
        destSuggestionsHeight.constant = 0
        
        
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
    }
    
    
    
    
    //Set initial styles of text boxes
    func setStyles() {
        let boxes = [startSearchBox, destSearchBox]
        for box in boxes {
            box?.tintColor = AppColors.caretColor
            box?.layer.borderWidth = 1.5
            box?.layer.borderColor = AppColors.darkBlue.cgColor
            box?.delegate = self
        }
        startSearchMagIcon.isHidden = true
    }
    
    
    
    //Allow text boxes to be defocused by clicking off of them
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    
    //Text box on first edit
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        /* Changed by chetu
         * Adding location when user enter the text
         */
        if (textField == startSearchBox) {
            destSearchView.isHidden = true
            let keyboardHeightdest = self.view.frame.size.height * 0.4
            debugPrint(keyboardHeightdest)
            startSuggestionsHeight.constant = keyboardHeightdest
            startSearchBox.layer.borderWidth = 5
            startSearchBox.layer.borderColor = AppColors.darkBlue.cgColor
            startPlaceID = nil
        }
            
            //
        else if(textField == destSearchBox) {
            startSearchView.isHidden = true
            /* Changed by chetu
             * Change height constant value
             */
            let keyboardHeightdest = self.view.frame.size.height * 0.4
            debugPrint(keyboardHeightdest)
            destSuggestionsHeight.constant = keyboardHeightdest
            destSearchBox.layer.borderWidth = 5
            destSearchBox.layer.borderColor = AppColors.darkBlue.cgColor
            destPlaceID = nil
        }
        
        textField.text = ""
    }
    
    
    /*
     * Created by Chetu
     * autocomplete location address search manages according enter field
     */
    @objc func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let suggestParams = AGSSuggestParameters()
        suggestParams.maxResults = 4
        
        //Resets and re-adds suggestions to the suggestions array
        //Updates every time the text changes
        if(textField == destSearchBox) {
            let newText = destSearchBox.text!
            if(newText.count > 0) {
                //Changed by IQ
                //Use Google Places API
                GMSPlacesClient.shared().findAutocompletePredictions(
                    fromQuery: newText,
                    bounds: nil,
                    boundsMode: GMSAutocompleteBoundsMode.bias,
                    filter: nil,
                    sessionToken: googlePlacesToken,
                    callback: { (results, error) in
                        if let error = error {
                            debugPrint(error)
                        }
                        else {
                            self.destSuggestionsArray.removeAll()
                            self.startSuggestionsArray.removeAll()
                            if results == nil || results!.count == 0 {
                                debugPrint("Results empty")
                                self.destSuggestionsArray.removeAll()
                                self.destSuggestions.reloadData()
                            }
                            else {
                                for result in results! {
                                    if self.destSuggestionsArray.count < 4 {
                                        self.destSuggestionsArray.append(result)
                                        self.destSuggestions.reloadData()
                                        debugPrint(result.attributedFullText.string)
                                    }
                                }
                            }
                        }
                    }
                )
            }
            else if (destSearchBox.text?.isEmpty)!{
                self.destSuggestionsArray.removeAll()
                self.destSuggestions.reloadData()
                debugPrint(destSearchBox.text!)
            }
        }
            /*
             * Change by Chetu
             * Some added start location enter field with search text
             * Updates every time the text changes
             */
        else if (textField == startSearchBox) {
            let newText = startSearchBox.text!
            if(newText.count > 0) {
                //Changed by IQ
                //Use Google Places API
                GMSPlacesClient.shared().findAutocompletePredictions(
                    fromQuery: newText,
                    bounds: nil,
                    boundsMode: GMSAutocompleteBoundsMode.bias,
                    filter: nil,
                    sessionToken: googlePlacesToken,
                    callback: { (results, error) in
                        if let error = error {
                            debugPrint(error)
                        }
                        else {
                            self.destSuggestionsArray.removeAll()
                            self.startSuggestionsArray.removeAll()
                            if results == nil || results!.count == 0 {
                                debugPrint("Results empty")
                                self.startSuggestionsArray.removeAll()
                                self.startSuggestions.reloadData()
                            }
                            else {
                                for result in results! {
                                    if self.startSuggestionsArray.count < 4 {
                                        self.startSuggestionsArray.append(result)
                                        self.startSuggestions.reloadData()
                                        debugPrint(result.attributedFullText.string)
                                    }
                                }
                            }
                        }
                    }
                )
            }
            else if (startSearchBox.text?.isEmpty)!{
                self.startSuggestionsArray.removeAll()
                self.startSuggestions.reloadData()
                debugPrint(startSearchBox.text!)
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
        if(textField == destSearchBox) {
            destSuggestionsArray.removeAll()
            destSuggestions.reloadData()
            destSuggestionsHeight.constant = 0
        }
            //Change by Chetu
            //Added start location field with entered user location
        else if(textField == startSearchBox) {
            startSuggestionsArray.removeAll()
            startSuggestions.reloadData()
            startSuggestionsHeight.constant = 0
        }
        checkValues()
    }
    
    //Set up address geocoding
//    func setupAddressSearchView() {
//        mAddressGeocodeParamaters = AGSGeocodeParameters()
//        mAddressGeocodeParamaters.resultAttributeNames.append(PrefKeys.placeString)
//        mAddressGeocodeParamaters.resultAttributeNames.append(PrefKeys.stAddres)
//        mAddressGeocodeParamaters.maxResults = 1
//    }
    
    /**
     * Check values of search boxes
     */
    func checkValues() {
        
        //Reset search box if empty
        if(destSearchBox.text == "") {
            //destSearchBox.placeholder ="Search A Location Or Address"
            destSearchBox.layer.borderWidth = 1.5
        }
            // Change by Chetu
            // Added start location field text
        else if(startSearchBox.text == "") {
            startSearchBox.layer.borderWidth = 1.5
        }
        //Unhide both search boxes
        startSearchView.isHidden = false
        destSearchView.isHidden = false
        
        startSearchBox.endEditing(true)
        destSearchBox.endEditing(true)
    }
    
    
    //MARK: ******** Cross button working **********
    @IBAction func clickOnCrossButton(_ sender: UIButton) {
        destSearchBox.text?.removeAll()
        let utterance = AVSpeechUtterance(string: ReadTextVoice.textBoxClear)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        self.synth.speak(utterance)
    }
    
    
    
    /**
     * Geocode the address into a point and pass that point and address
     * to the navigation screen
     */
    @IBAction func setButton(_ sender: Any) {
        
        //Reset search box if empty
        if destSearchBox.text == "" {
            let alert = UIAlertController(title: "", message: locationAddress, preferredStyle: UIAlertControllerStyle.alert)
            self.present(alert, animated: true, completion: nil)
            
            alert.addAction(UIAlertAction(title: AlertConstant.okString, style: .default, handler: { action in
                switch action.style{
                default:
                    debugPrint("nothing")
                    
                }
            }))
        }
        else {
            let storyboard = UIStoryboard (name: StoryboardIdentifier.mainIdentifier, bundle: nil)
            let resultVC = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.TemporaryNavigation) as! MainSetANewPathMap

            //Communicate with new VC - These values are stored in the destination
            //you can set any value stored in the destination VC here

            //Changed by IQ
            //Use Google Places API
            if let destPlaceID = destPlaceID {
                GMSPlacesClient.shared().fetchPlace(
                    fromPlaceID: destPlaceID,
                    placeFields: GMSPlaceField.coordinate,
                    sessionToken: googlePlacesToken,
                    callback: { (place, error) in
                        if let error = error {
                            debugPrint(error)
                        }
                        else if let place = place {
                            debugPrint("Geocode SearchValues = ", self.destSearchBox.text!, " at ", place.coordinate.longitude, ", ", place.coordinate.latitude)

                            let point = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
                            if self.userLocation != nil {
                                resultVC.userStartStop = CLLocationCoordinate2D(
                                    latitude: self.userLocation!.coordinate.latitude,
                                    longitude: self.userLocation!.coordinate.longitude)
                            }

                            //Pass address and stop to the navigation screen
                            resultVC.destinationText = self.destSearchBox.text!
                            resultVC.enteredStop = point

                            self.present(resultVC, animated: true, completion: nil)
                        }
                    }
                )
            }
        }
    }
    
    /**
     * TODO: Change to ArcGIS location changed handler
     * Users location changed handler
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0] as CLLocation
    }
    
    //Go back to previous screen
    @IBAction func dismissView(_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

/**
 * Delegate methods for tableViews
 */
extension MainSetANewPathSearch: UITableViewDelegate, UITableViewDataSource {
    
    //Returns how many rows to create
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*
         Changed By Chetu
         check for count of destination sugession array crash some times
         */
        if destSuggestionsArray.count > 0{
            return destSuggestionsArray.count
        }
            // Change bu chetu
            // Added start location array for count
        else if startSuggestionsArray.count > 0{
            return startSuggestionsArray.count
        }
        return 0
    }
    
    //Set labels inside of
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell!
        
        if(tableView == destSuggestions) {
            cell = destSuggestions.dequeueReusableCell(withIdentifier: StoryboardIdentifier.customCellIdentifier, for: indexPath)
            debugPrint(destSuggestionsArray.count)
            if destSuggestionsArray.count > 0 {
                cell.textLabel?.text = destSuggestionsArray[indexPath.item].attributedFullText.string
            }
        }
            // Change By chetu
            // Added table view cell for start location field
        else  if(tableView == startSuggestions) {
            cell = startSuggestions.dequeueReusableCell(withIdentifier: StoryboardIdentifier.customCellIdentifier, for: indexPath)
            if startSuggestionsArray.count > 0 {
                cell.textLabel?.text = startSuggestionsArray[indexPath.item].attributedFullText.string
            }
        }
        return cell
    }
    
    //Cell on click event
    //Put address from cell into search box then clear the suggestions
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let currentCell = tableView.cellForRow(at: indexPath)
        if(tableView == destSuggestions) {
            destSearchBox.text = currentCell?.textLabel?.text!
            destPlaceID = destSuggestionsArray[indexPath.item].placeID
            destSuggestionsArray.removeAll()
            destSuggestions.reloadData()
            destSuggestionsHeight.constant = 0
            checkValues()
        }
            //Change by Chetu
            //Added start location text selected when user enter in start field
        else if(tableView == startSuggestions) {
            startSearchBox.text = currentCell?.textLabel?.text!
            startPlaceID = startSuggestionsArray[indexPath.item].placeID
            startSuggestionsArray.removeAll()
            startSuggestions.reloadData()
            startSuggestionsHeight.constant = 0
            checkValues()
        }
    }
}
