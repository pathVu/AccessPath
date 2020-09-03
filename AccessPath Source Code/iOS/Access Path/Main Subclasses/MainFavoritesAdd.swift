//
//  AddFavoritePlace.swift
//  Access Path
//
//  Created by Nick Sinagra on 5/16/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit
import ArcGIS
import GooglePlaces

/**
 * This class allows the user to search for a place to add to their favorites,
 * and give it a custom name if they want
 */
class MainFavoritesAdd : UIViewController {
    
    //UI Outlets
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var favoriteView: UIView!
    @IBOutlet weak var searchBox: CustomSearch!
    @IBOutlet weak var addFavoritePlaceButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var customNameBox: CustomTextBox!
    @IBOutlet weak var currentLocationIcon: UIImageView!
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var suggestionsTable: UITableView!
    @IBOutlet weak var suggestionsTableHeight: NSLayoutConstraint!

    var googlePlacesToken:GMSAutocompleteSessionToken!

    //ArcGIS Variables
    var mAddressGeocodeParamaters:AGSGeocodeParameters!
    var mLocatorTask:AGSLocatorTask!

    var selectedPlaceID: String?
    var searchSuggestionsArray: [GMSAutocompletePrediction] = []
    
    let preferences = UserDefaults.standard
    let pathVuPHP = PHPCalls()
    
    //Place Info Flags
    var useCurrentLocation = true
    var useCustomName = false
    
    //Speech synthesizer for reading directions out loud
    let synth = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        googlePlacesToken = GMSAutocompleteSessionToken.init()

        setUpStyles()
        mLocatorTask = AGSLocatorTask(url: RoutingUrls.locatorTaskURL!)
        searchBox.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchBox.delegate = self
        customNameBox.delegate = self
        suggestionsTable.delegate = self
        suggestionsTable.dataSource = self
        setupAddressSearchView()
        
        //Destination voice text
        if(preferences.bool(forKey: PrefKeys.soundKey)) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                let utterance = AVSpeechUtterance(string: enterfavoritePlace)
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                self.synth.speak(utterance)
            })
        }
    }
    
    
    /**
     * Allow text boxes to defocus when clicked off of
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    
    /**
     * Set default styles for ui elements
     */
    func setUpStyles() {
        addFavoritePlaceButton.layer.borderColor = AppColors.darkBlue.cgColor
        cancelButton.layer.borderColor = AppColors.darkBlue.cgColor
        
        searchBox.tintColor = AppColors.caretColor
        searchBox.layer.borderWidth = 1.5
        searchBox.layer.borderColor = AppColors.darkBlue.cgColor
        
        customNameBox.tintColor = AppColors.caretColor
        customNameBox.layer.borderWidth = 1.5
        customNameBox.layer.borderColor = AppColors.darkBlue.cgColor
        searchIcon.isHidden = true
    }
    
    
    func setupAddressSearchView() {
        mAddressGeocodeParamaters = AGSGeocodeParameters()
        mAddressGeocodeParamaters.resultAttributeNames.append(PrefKeys.placeString)
        mAddressGeocodeParamaters.resultAttributeNames.append(PrefKeys.stAddres)
        mAddressGeocodeParamaters.maxResults = 1
    }
    
    
    func checkValues() {
        if(searchBox.text == "") {
            useCurrentLocation = true
            // hide textfield search box text
            // searchBox.text = "Search A Location Or Address"
            searchBox.layer.borderWidth = 1.5
        }
        
        if(customNameBox.text == "") {
            useCustomName = false
            customNameBox.layer.borderWidth = 1.5
        }
        else {
            useCustomName = true
        }
        searchBox.endEditing(true)
    }
    
    
    //Submit the favorite to the server
    @IBAction func addFavoriteButtonPressed(_ sender: Any) {
        checkValues()
        
        if searchBox.text == "" {
            // hide code of text on texfield
            // startSearchBox.placeholder = "Enter Your Destination"
            let alert = UIAlertController(title: "", message: locationAddress, preferredStyle: UIAlertControllerStyle.alert)
            self.present(alert, animated: true, completion: nil)
            
            alert.addAction(UIAlertAction(title: AlertConstant.okString, style: .default, handler: { action in
                switch action.style{
                default:
                    print("nothing")
                }
            }))
        }
        else {
            if customNameBox.text == ""{
                let alert = UIAlertController(title: "", message: favouriteString, preferredStyle: UIAlertControllerStyle.alert)
                self.present(alert, animated: true, completion: nil)
                
                alert.addAction(UIAlertAction(title: AlertConstant.okString, style: .default, handler: { action in
                    switch action.style{
                    default:
                        print("nothing")
                        
                    }
                }))
                
            }
            else {
                let accountid = preferences.string(forKey: PrefKeys.aidKey)
                let address = searchBox.text ?? ""
                var customName = ""
                
                //Determine if a custom name is to be used
                if useCustomName {
                    debugPrint("Using custom name")
                    customName = customNameBox.text ?? ""
                }
                else {
                    //If not using custom name, split by commas and choose first part
                    if String(address.split(separator: ",")[0]) != "" {
                        customName = String(address.split(separator: ",")[0])
                    }
                    else {
                        //If no commas found, use entire address
                        customName = address
                    }
                }

                if let selectedPlaceID = selectedPlaceID {
                    GMSPlacesClient.shared().fetchPlace(
                        fromPlaceID: selectedPlaceID,
                        placeFields: GMSPlaceField.coordinate,
                        sessionToken: googlePlacesToken,
                        callback: { (place, error) in
                            if let error = error {
                                debugPrint(error)
                            }
                            else if let place = place {
                                let flongitude = place.coordinate.longitude
                                let flattitude = place.coordinate.latitude

                                debugPrint("\(flattitude) \(flongitude)")

                                if self.pathVuPHP.newFavorite(
                                    acctid: accountid!,
                                    faddress: address,
                                    fname: customName,
                                    flat: flattitude,
                                    flon: flongitude
                                ) {
                                    self.dismiss(animated: true, completion: nil)
                                }
                                else {
                                    debugPrint("ERROR ADDING FAVORITE")
                                }
                            }
                        }
                    )
                }
            }
        }
    }

    //Return to the previous view
    @IBAction func dismissView(_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension MainFavoritesAdd: UITextFieldDelegate {
    //Clear the text box and set its style on edit
    func textFieldDidBeginEditing(_ textField: UITextField) {

        if textField == searchBox {
            favoriteView.isHidden = true
            currentLocationIcon.isHidden = true
            searchIcon.isHidden = false

            selectedPlaceID = nil
            searchSuggestionsArray.removeAll()
            suggestionsTable.reloadData()
        }
        
        if textField == customNameBox {
            useCustomName = true
        }
        
        textField.layer.borderWidth = 10
        textField.layer.borderColor = AppColors.darkBlue.cgColor
        textField.layer.backgroundColor = UIColor.white.cgColor
        textField.text = ""
    }
    
    //Handle the text boxes default styles and set text if empty
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if textField == searchBox && selectedPlaceID == nil {
            searchBox.text = ""
        }

        if searchBox.text?.count == 0 {
            // add placehoder text
            searchBox.placeholder = AlertConstant.searchLocationAddress
            currentLocationIcon.isHidden = false
            searchIcon.isHidden = true
            useCurrentLocation = true
        }
        else {
            useCurrentLocation = false
        }
        
        if customNameBox.text?.count == 0 {
            useCustomName = false
        }
        else {
            useCustomName = true
        }
        checkValues()
        suggestionsTableHeight.constant = 0
        favoriteView.isHidden = false
        textField.layer.borderWidth = 1.5
    }
    
    
    //Provide suggestions to the user as they type in the search box
    @objc func textFieldDidChange(_ textField:UITextField) {
        if textField == searchBox {
            let newText = searchBox.text!
            if (newText.count > 0) {
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
                            self.searchSuggestionsArray.removeAll()
                            if results == nil || results!.count == 0 {
                                self.suggestionsTable.reloadData()
                            }
                            else {
                                for result in results! {
                                    if self.searchSuggestionsArray.count < 4 {
                                        self.searchSuggestionsArray.append(result)
                                        self.suggestionsTable.reloadData()
                                        debugPrint(result.attributedFullText.string)
                                    }
                                }
                            }
                        }
                    }
                )
            }
        }
    }
}

/**
 * Delegate methods for tableViews
 */
extension MainFavoritesAdd: UITableViewDataSource, UITableViewDelegate {
    //How many rows in the table to create, should be the size of the suggestions array
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchSuggestionsArray.count > 0{
            return searchSuggestionsArray.count
        }
        return 0
        
    }
    
    //Set the data inside of the tableView cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell!
        
        cell = suggestionsTable.dequeueReusableCell(withIdentifier: StoryboardIdentifier.customCellIdentifier, for: indexPath)
        cell.textLabel?.text = searchSuggestionsArray[indexPath.item].attributedFullText.string

        return cell
    }
    
    //What happens when the user clicks on a cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Deselect the row the user clicked on
        tableView.deselectRow(at: indexPath, animated: true)
        
        let currentCell = tableView.cellForRow(at: indexPath)
        //Empty the suggestions array and put the address of the cell into the search box
        if(tableView == suggestionsTable) {
            searchBox.text = currentCell?.textLabel?.text!
            selectedPlaceID = searchSuggestionsArray[indexPath.item].placeID
            searchSuggestionsArray.removeAll()
            suggestionsTable.reloadData()
            checkValues()
        }
    }
}
