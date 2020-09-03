//
//  FavoritePlaceInfo.swift
//  Access Path
//
//  Created by Nick Sinagra on 8/1/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit
import ArcGIS
import GoogleMaps
import SwiftyJSON
import GooglePlaces

/**
 * Shows favorite place information including the name, address, and place on the map.
 */
class MainFavoritesInformation: UIViewController, GMSMapViewDelegate {
    
    //UI Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var headerPlaceName: UILabel!
    @IBOutlet weak var cardPlaceName: UILabel!
    @IBOutlet weak var cardPlaceAddress: UILabel!
    @IBOutlet weak var setPathToButton: UIButton!
    
    //Favorite place info (set from favorites list)
    static var placeName:String!
    static var placeAddress:String!
    
    //Coorinates used for geocoding
    var lat:Double!
    var lng:Double!
    
    //Speech synthesizer for reading directions out loud
    let synth = AVSpeechSynthesizer()
    let preferences = UserDefaults.standard
    
    var favoriteAddressArray = [FavoriteCoordinateListModel]()
    
    // default zoom level for Google map
    var camera:GMSCameraPosition = GMSCameraPosition()
    
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
    
    var favoriteMarker: GMSMarker?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Disable the set path to button (will be enabled when we load the location)
        setPathToButton.layer.backgroundColor = AppColors.disabledBackground.cgColor
        setPathToButton.layer.borderColor = AppColors.disabledBorder.cgColor
        setPathToButton.isEnabled = false
        
        self.mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.camera = camera
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(MainFavoritesInformation.placeAddress, completionHandler: { (placemarkArray, err) in
            if err != nil {
                print("error occured in geocoding")
                return
            }
            let scaledIcon = self.resizeImage(image: UIImage(named: location_marker)!, targetSize: CGSize(width: 40.0, height:50.0))
            if let target = placemarkArray?.first?.location?.coordinate {
                self.lat = target.latitude
                self.lng = target.longitude
                self.favoriteMarker = GMSMarker()
                self.favoriteMarker?.icon = scaledIcon
                self.favoriteMarker?.position = target
                self.favoriteMarker?.map = self.mapView
                self.mapView.camera = GMSCameraPosition(target: target, zoom: defaultZoomLevel)
            }
            
        })

        //We have a location now, so enable the set path to button
        self.setPathToButton.layer.backgroundColor = AppColors.caretColor.cgColor
        self.setPathToButton.layer.borderColor = AppColors.darkBlue.cgColor
        self.setPathToButton.isEnabled = true
    }
            
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //Set header and card favorite information
        setPathToButton.setTitle("\(pathString) "  + MainFavoritesInformation.placeName, for: .normal)
        headerPlaceName.text = MainFavoritesInformation.placeName
        cardPlaceName.text = MainFavoritesInformation.placeName
        cardPlaceAddress.text = MainFavoritesInformation.placeAddress
    }

    
    //Show the edit favorite screen
    @IBAction func editFavoriteButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: StoryboardIdentifier.mainIdentifier, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.FavoritePlaceEdit) as! MainFavoritesEdit
        
        vc.placeName = MainFavoritesInformation.placeName
        vc.placeAddress = MainFavoritesInformation.placeAddress
      
        //Read Edit button voice is used
    if(preferences.bool(forKey: PrefKeys.soundKey)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(0), execute: {
            let utterance = AVSpeechUtterance(string: editFavorite)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            self.synth.speak(utterance)
        })
    }
      self.present(vc, animated: true, completion: nil)
    }
    
    //Resizes the location icon on the map
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
    
    //Allows the user to set a path from their current location to the favorite place
    @IBAction func setPathToButtonPressed(_ sender: Any) {
        //Point of the favorite place
        let storyboard = UIStoryboard (name: StoryboardIdentifier.mainIdentifier, bundle: nil)
        let resultVC = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.TemporaryNavigation) as! MainSetANewPathMap
        resultVC.enteredStop = CLLocationCoordinate2D(latitude: self.lat, longitude: self.lng)
        resultVC.destinationText = MainFavoritesInformation.placeAddress
        self.present(resultVC, animated: true, completion: nil)
    }
    
    
    //Go back to the previous screen
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}



