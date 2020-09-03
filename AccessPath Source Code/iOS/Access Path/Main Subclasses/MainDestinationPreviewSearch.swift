//
//  SetNewPathMain.swift
//  Access Path
//
//  Created by Nick Sinagra on 5/17/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit
import ArcGIS
import CoreLocation
import GooglePlaces

/**
 * This class allows the user to search for a location for the purposes
 * of previewing a route between their current location and destination
 */

class MainDestinationPreviewSearch: UIViewController , UITextFieldDelegate,CLLocationManagerDelegate {
    
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
    
    
    //Destination preview search x icon outlet
    @IBOutlet weak var startSearchXiconBtn: UIButton!
    @IBOutlet weak var destinationSearchXiconBtn: UIButton!
    
    var googlePlacesToken: GMSAutocompleteSessionToken!
    
    //Geocoding Variables
    var addressGeocodeParamaters:AGSGeocodeParameters!
    var locatorTask:AGSLocatorTask!
    
    var startPlaceID: String?
    var startSuggestionsArray:[GMSAutocompletePrediction] = []
    
    var locationDisplay:AGSLocationDisplay!
    
    //Change by Chetu
    //Holds search suggestions
    var destPlaceID: String?
    var destSuggestionsArray:[GMSAutocompletePrediction] = []
    
    var startText:String?
    var fromStop:CLLocationCoordinate2D?
    
    
    var locManager: CLLocationManager?
    var lat:Double?
    var lng:Double?
    var userLocation:CLLocation?
    
    //Added By Chetu
    //Speech synthesizer for reading directions out loud
    let synth = AVSpeechSynthesizer()
    
    let preferences = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googlePlacesToken = GMSAutocompleteSessionToken.init()
        startSuggestions.delegate = self
        startSuggestions.dataSource = self
        destSuggestions.delegate = self
        destSuggestions.dataSource = self
        setStyles()
        setupAddressSearchView()
        
        /* Changed By Chetu
         * Add call of texshouldEnd Editing method
         */
        startSearchBox.addTarget(self, action: #selector(textFieldShouldEndEditing(_:)), for: .editingChanged)
        destSearchBox.addTarget(self, action: #selector(textFieldShouldEndEditing(_:)), for: .editingChanged)
        startSuggestionsHeight.constant = 0
        destSuggestionsHeight.constant = 0
        
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
        
        
        /* Changed By Chetu
         * Destination voice text
         */
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            let utterance = AVSpeechUtterance(string: beginVoiceText)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            self.synth.speak(utterance)
        })
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        GMSPlacesClient.shared().currentPlace(callback: { (placeLikelihoodList, error) in
            print("destination preview did appear")
            if error != nil {
                return
            }
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    self.startSearchBox.text = place.formattedAddress
                    self.startPlaceID = place.placeID
                }
            }
        })
    }
    
    
    /**
     * So that textViews can be unfocused whenever we click off of them
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    
    /**
     * Set styles of UI elements
     */
    func setStyles() {
        let boxes = [startSearchBox, destSearchBox]
        for box in boxes {
            box?.tintColor = AppColors.caretColor
            box?.layer.borderWidth = 1.5
            box?.layer.borderColor = AppColors.darkBlue.cgColor
            box?.delegate = self
        }
    }
    
    /* Changed by chetu
     * Created Text box on first edit
     * Adding location when user enter the text
     */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if (textField == startSearchBox) {
            destSearchView.isHidden = true
            let keyboardHeightdest = self.view.frame.size.height * 0.4
            startSuggestionsHeight.constant = keyboardHeightdest
            startSearchBox.layer.borderWidth = 5
            startSearchBox.layer.borderColor = AppColors.darkBlue.cgColor
            startSearchXiconBtn.isHidden = false
            startPlaceID = nil
        }
            
        else if(textField == destSearchBox) {
            startSearchView.isHidden = true
            let keyboardHeightdest = self.view.frame.size.height * 0.4
            destSuggestionsHeight.constant = keyboardHeightdest
            destSearchBox.layer.borderWidth = 5
            destSearchBox.layer.borderColor = AppColors.darkBlue.cgColor
            destinationSearchXiconBtn.isHidden = false
            destPlaceID = nil
        }
        
        textField.text = ""
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
        if(textField == destSearchBox) {
            destSuggestions.reloadData()
            destSuggestionsHeight.constant = 0
        }
            // Change by Chetu
            //Added start location field with entered user location
        else if(textField == startSearchBox) {
            startSuggestions.reloadData()
            startSuggestionsHeight.constant = 0
        }
        checkValues()
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
                                self.destSuggestionsArray.removeAll()
                                self.destSuggestions.reloadData()
                            }
                            else {
                                for result in results! {
                                    if self.destSuggestionsArray.count < 4 {
                                        self.destSuggestionsArray.append(result)
                                        self.destSuggestions.reloadData()
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
            }
        }
            /*
             * Change by Chetu
             * Some added start location enter field with search text
             */
            //Updates every time the text changes
        else if (textField == startSearchBox) {
            let newText = startSearchBox.text!
            if(newText.count > 0) {
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
                                self.startSuggestionsArray.removeAll()
                                self.startSuggestions.reloadData()
                            }
                            else {
                                for result in results! {
                                    if self.startSuggestionsArray.count < 4 {
                                        self.startSuggestionsArray.append(result)
                                        self.startSuggestions.reloadData()
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
            }
        }
        return true
    }
    
    
    
    /**
     * Changed by Chetu
     * Set up X icon for deleted search records
     */
    @IBAction func clickOnStartSearchXicon(_ sender: UIButton) {
        startSearchBox.text?.removeAll() //
        let utterance = AVSpeechUtterance(string: ReadTextVoice.textBoxClear)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        self.synth.speak(utterance)
    }
    
    
    /**
     * Added by Chetu
     * Set up X icon for deleted search records
     */
    @IBAction func clickOnDestinationSearchXicon(_ sender: UIButton) {
        destSearchBox.text?.removeAll()
        let utterance = AVSpeechUtterance(string: ReadTextVoice.textBoxClear)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        self.synth.speak(utterance)
    }
    
    
    /**
     * Set up geocoding parameters for suggestions
     */
    func setupAddressSearchView() {
        addressGeocodeParamaters = AGSGeocodeParameters()
        addressGeocodeParamaters.resultAttributeNames.append(PrefKeys.placeString)
        addressGeocodeParamaters.resultAttributeNames.append(PrefKeys.stAddres)
        addressGeocodeParamaters.maxResults = 1
    }
    
    
    /**
     * Changed By Chetu
     //Add current location auto detect when click on location button
     */
    @IBAction func detectCurrentLocation(_ sender: UIButton) {
        
        if(preferences.bool(forKey: PrefKeys.soundKey)) {
            let utterance = AVSpeechUtterance(string: ReadTextVoice.currentLocationRead)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            self.synth.speak(utterance)
        }
        
        GMSPlacesClient.shared().currentPlace(callback: { (placeLikelihoodList, error) in
            print("destination preview decent current")
            if error != nil {
                return
            }
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    self.startSearchBox.text = place.formattedAddress
                    self.startPlaceID = place.placeID
                }
            }
        })
    }
    
    
    /**
     * TODO: Change to ArcGIS location changed handler
     * Users location changed handler
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0] as CLLocation
    }
    
    
    /**
     * Check values of search boxes
     */
    func checkValues() {
        
        //Reset search box if empty
        if(destSearchBox.text == "") {
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
    
    
    
    /**
     * Handles the reverse geocoding of the address into a point and passes it
     * to the MainDestinationPreviewMap view controller.
     */
    @IBAction func setButton(_ sender: Any) {
        if(destSearchBox.text == "") {
            // hide code of text on texfield
            let alert = UIAlertController(title: "", message: locationAddress, preferredStyle: UIAlertControllerStyle.alert)
            self.present(alert, animated: true, completion: nil)
            
            alert.addAction(UIAlertAction(title: AlertConstant.okString, style: .default, handler: { action in
                switch action.style{
                default:
                    print("nothing")
                    
                }
            }))
        }
        else{
            let storyboard = UIStoryboard (name: StoryboardIdentifier.mainIdentifier, bundle: nil)
            let resultVC = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.tempDestninationPreviewIdentifer) as! MainDestinationPreviewMap
            if let startPlaceID = startPlaceID {
                GMSPlacesClient.shared().fetchPlace(
                    fromPlaceID: startPlaceID,
                    placeFields: GMSPlaceField.coordinate,
                    sessionToken: googlePlacesToken,
                    callback: { (place, error) in
                        if let error = error {
                            debugPrint(error)
                        }
                        else if let place = place {
                            let point = CLLocationCoordinate2D(
                                latitude: place.coordinate.latitude,
                                longitude: place.coordinate.longitude
                            )
                            
                            //Put address and it's location into the map view controller
                            resultVC.startText = self.startSearchBox.text ?? ""
                            resultVC.fromStop = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)

                            self.secondSearchTargetCall(resultVC: resultVC)
                        }
                    }
                )
            }
        }
    }
    
    func secondSearchTargetCall(resultVC: MainDestinationPreviewMap)  {
        //Destination search text field
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
                        let point = CLLocationCoordinate2D(
                            latitude: place.coordinate.latitude,
                            longitude: place.coordinate.longitude
                        )
                        
                        if self.fromStop?.latitude != nil {
                            resultVC.fromStop = CLLocationCoordinate2D(latitude: self.fromStop?.latitude ?? 0.0, longitude: self.fromStop?.longitude ?? 0.0)
                        }
                        
                        //Put address and it's location into the map view controller
                        resultVC.destinationText = self.destSearchBox.text ?? ""
                        resultVC.toStop = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)

                        resultVC.startText = self.startText

                        self.present(resultVC, animated: true, completion: nil)
                    }
                }
            )
        }
    }
    /**
     * Return to the navigation home screen
     */
    @IBAction func goBackToOneButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: StoryboardIdentifier.unwindSegueToVC1, sender: self)
    }
    
    @IBAction func goBackapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


/**
 * Delegate methods for tableViews
 */
extension MainDestinationPreviewSearch: UITableViewDelegate, UITableViewDataSource {
    
    //Returns how many rows to create
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*
         Changed By Chetu
         check for count of destination sugession array crash some times
         */
        if destSuggestionsArray.count > 0{
            return destSuggestionsArray.count
        }
            // Change by Chetu
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
            cell = destSuggestions.dequeueReusableCell(withIdentifier:  StoryboardIdentifier.customCellIdentifier, for: indexPath)
            if destSuggestionsArray.count > 0 {
                cell.textLabel?.text = destSuggestionsArray[indexPath.item].attributedFullText.string
            }
        }
            // Change By Chetu
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
            // Added start location text selected when user enter in start field
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
