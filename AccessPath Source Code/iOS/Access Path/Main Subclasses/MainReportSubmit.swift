//
//  SubmissionScreen.swift
//  Access Path
//
//  Created by Nick Sinagra on 7/10/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit
import ArcGIS
import Alamofire
import GoogleMaps
import GooglePlaces

class MainReportSubmit: UIViewController, GMSMapViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    //UI Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var imageCaptured: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var searchBox: CustomSearch!
    @IBOutlet weak var suggestionsTable: UITableView!
    
    //location information (passed from previous screen)
    var address:String!
    var lat:Double!
    var lng:Double!
    var type:Int!
    var image:UIImage!
    var googleLocationID:String!
    var entranceSteps:Int!
    var entranceRamp:Int!
    var entranceAutomaticDoors:Int!
    var indoorType:[Int]!
    var indoorSteps:Int!
    var indoorRamp:Int!
    var indoorSpacious:Int!
    var indoorBraille:Int!
    
    var markerLocation:CLLocationCoordinate2D?
    
    var selectedPlaceID: String?
    var searchSuggestionsArray: [GMSAutocompletePrediction] = []
    
    var googlePlacesToken:GMSAutocompleteSessionToken!

    //Shared Preferences
    let preferences = UserDefaults.standard
    var activityIndicator = UIActivityIndicatorView()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        markerLocation = CLLocationCoordinate2D(latitude: self.lat, longitude: self.lng)
        mapView.delegate = self
        googlePlacesToken = GMSAutocompleteSessionToken.init()
        suggestionsTable.delegate = self
        suggestionsTable.dataSource = self
        searchBox.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchBox.delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Show hazard location on map
        mapView.camera = GMSCameraPosition(
            target: CLLocationCoordinate2D(latitude: self.lat, longitude: self.lng),
            zoom: defaultZoomLevel)
        let scaledIcon = self.resizeImage(image: UIImage(named: report_icon)!, targetSize: CGSize(width: 40.0, height:40.0))
        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: self.lat, longitude: self.lng))
        marker.isDraggable = true
        marker.icon = scaledIcon
        marker.map = self.mapView
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
    
    //Submit the hazard report to the server
    @IBAction func submitButtonPressed(_ sender: Any) {
        if searchBox.text != "" {
            startLoading()
            submitButton.layer.borderColor = AppColors.disabledBorder.cgColor
            submitButton.setTitleColor(AppColors.disabledBorder, for: .normal)
            
            let acctid = preferences.string(forKey: PrefKeys.aidKey)
            let ctyid = String(type)
            let cdescription = ""
            let clat = String(self.markerLocation?.latitude as! Double)
            let clng = String(self.markerLocation?.longitude as! Double)
            
            uploadImage(acctid: acctid!, ctyid: ctyid, cdescription: cdescription, clat: clat, clng: clng, caddress: searchBox.text ?? "", type: type)
        }
        else {
            debugPrint("User tried to submit report without selecting an address")
            //Show an alert if a route cannot be found
            let alert = UIAlertController(title: "Alert", message: "Please select an address for the location being reported.", preferredStyle: UIAlertControllerStyle.alert)
            self.present(alert, animated: true, completion: nil)
            alert.addAction(UIAlertAction(title: AlertConstant.okString, style: .default, handler: { action in
                switch action.style{
                default:
                    debugPrint("User tried to submit report without selecting an address")
                }
            }))
        }
    }
    
    func checkValues() {
        if(searchBox.text == "") {
            searchBox.layer.borderWidth = 1.5
        }
        searchBox.endEditing(true)
    }
    /**
     * This function uploads the image and POST parameters to the server
     * using a multipart request.
     */
    func uploadImage(acctid:String, ctyid:String, cdescription:String, clat:String, clng:String, caddress:String, type:Int) {
        //JPEG data representation
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        var imageKey = ""
        //Generate the image file name with the current time
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = ValidEmailFormattor.dateFormat
        let result = formatter.string(from: date)
        let cname = result + ".jpg"
        
        // build URL and parameters based on type being reported
        var url = ""
        var parameters = [String:String]()
        switch self.type! {
        case 0,1,2,3,4,5: // all hazard types
            //Server PHP URL
            url = APIURL.hazardReportURL
            //POST parameters
            parameters = [
                "uacctid": acctid,
                "htype": String(type),
                "hlat": clat,
                "hlon": clng
            ]
            imageKey = "himg"
            break
        case 6: // entrance type
            //Server PHP URL
            url = APIURL.entranceReportURL
            //POST parameters
            parameters = [
                "uacctid": acctid,
                "egoogleid": self.googleLocationID,
                "elat": clat,
                "elon": clng,
                "eaddress": caddress,
                "eoautodoor": String(self.entranceAutomaticDoors),
                "aesteps": String(self.entranceSteps),
                "aeramp": String(self.entranceRamp)
            ]
            
            imageKey = "eimg"
            break
        case 7:
            //Server PHP URL
            url = APIURL.indoorReportURL
            //POST parameters
            parameters = [
                "uacctid": acctid,
                "iagoogleid": self.googleLocationID,
                "ialat": clat,
                "ialon": clng,
                "iaaddress": caddress,
                "iaspace": String(self.indoorSpacious),
                "iabraille": String(self.indoorBraille),
                "iosteps": String(self.indoorSteps),
                "ioramp": String(self.indoorRamp)
            ]
            imageKey = "iaimg"
            break
        default:
            break
        }
        //Upload the data as a multipart request
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            //Send image file data
            multipartFormData.append(imageData!, withName: imageKey, fileName: cname, mimeType: "image/jpg")
            
            //Add POST parameters
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
                debugPrint(multipartFormData)
            }
            
            if type == 7 {
                for (index, item) in self.indoorType.enumerated() {
                    print("\(index) : \(item) : rtid[\(index)]")
                    multipartFormData.append(String(item).data(using:.utf8)!, withName: "rtid[\(index)]")
                }
            }
            
        }, to: url, encodingCompletion: { (encodingResult) -> Void in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    self.stopLoading()
                    self.performSegue(withIdentifier: StoryboardIdentifier.unwindSegueToVC1, sender: self)
                })
                upload.responseString { response in
                    self.stopLoading()
                    debugPrint("Successful report upload")
                }
                break
            case .failure(let error):
                self.stopLoading()
                self.showAlert(withTitle: AlertConstant.failed, withMessage: error.localizedDescription)
                debugPrint("failure")
                break
            }
        })
    }
    
    
    /**
     // ADD method for Ignor Interct Event for UI
     */
    func startLoading(){
        activityIndicator.center = self.view.center;
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        //activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.;
        view.addSubview(activityIndicator);
        view.bringSubview(toFront: activityIndicator)
        activityIndicator.startAnimating();
        UIApplication.shared.beginIgnoringInteractionEvents();
    }
    func stopLoading(){
        activityIndicator.stopAnimating();
        UIApplication.shared.endIgnoringInteractionEvents();
    }
    
    //Go back to navigation home screen
    @IBAction func goBackToOneButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: StoryboardIdentifier.unwindSegueToVC1, sender: self)
    }
    
    //Go back to the last screen
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func reverseGeocode(_ point:CLLocationCoordinate2D) -> GMSPlace? {
        var response:GMSPlace?
        GMSPlacesClient.shared().currentPlace(callback: { (placeLikelihoodList, error) in
            if error != nil {
                return
            }
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    response = place
                }
            }
        })
        return response
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        self.lat = marker.position.latitude
        self.lng = marker.position.longitude
        self.markerLocation = CLLocationCoordinate2D(latitude: self.lat, longitude: self.lng)
        if let place = reverseGeocode(self.markerLocation!) {
            self.address = place.formattedAddress
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == searchBox {
            selectedPlaceID = nil
            searchSuggestionsArray.removeAll()
            suggestionsTable.reloadData()
            suggestionsTable.isHidden = false
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
            // add placeholder text
            searchBox.placeholder = AlertConstant.searchLocationAddress
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
                        self.mapView.clear()
                        self.markerLocation = place.coordinate
                        if let markerLocation = self.markerLocation {
                            self.mapView.camera = GMSCameraPosition(
                                target: markerLocation,
                                zoom: defaultZoomLevel)
                            let scaledIcon = self.resizeImage(image: UIImage(named: report_icon)!, targetSize: CGSize(width: 40.0, height:40.0))
                            let marker = GMSMarker(position: markerLocation)
                            marker.isDraggable = true
                            marker.icon = scaledIcon
                            marker.map = self.mapView
                            self.googleLocationID = selectedPlaceID
                        }

                    }
                }
            )
        }
        suggestionsTable.isHidden = true
        
        checkValues()
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
            suggestionsTable.isHidden = false
            searchBox.text = currentCell?.textLabel?.text!
            selectedPlaceID = searchSuggestionsArray[indexPath.item].placeID
            searchSuggestionsArray.removeAll()
            suggestionsTable.reloadData()
            checkValues()
        }
    }
}



