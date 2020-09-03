//
//  MainNearbyPlacesViewController.swift
//  Access Path
//
//  Created by Pete Georgopoulos on 1/29/20.
//  Copyright © 2020 pathVu. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class NearbyPlacesItem : UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
}

class MainNearbyPlacesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GMSMapViewDelegate {
    @IBOutlet weak var modeButton: UIButton!
    @IBOutlet weak var modeButtonImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var detailNameLabel: UILabel!
    @IBOutlet weak var detailAddressLabel: UILabel!
    @IBOutlet weak var detailDistanceLabel: UILabel!
    
    var placesArray:[GooglePlace]?
    var userLocation:CLLocationCoordinate2D?
    var destination: CLLocationCoordinate2D?
    
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
        hideDetailView()
        self.detailView.layer.borderWidth = 5
        let detailRect = self.detailView.frame
        self.detailView.frame = CGRect(
            x: detailRect.origin.x,
            y: detailRect.origin.y,
            width: self.view.frame.width/2,
            height: self.view.frame.height)
        tableView.delegate = self
        tableView.dataSource = self
        do {
          // Set the map style by passing a valid JSON string.
          mapView.mapStyle = try GMSMapStyle(jsonString: kMapStyle)
        } catch {
          NSLog("One or more of the map styles failed to load. \(error)")
        }
        self.mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let location = self.userLocation {
            self.mapView.camera = GMSCameraPosition(target: location, zoom: defaultZoomLevel)
            mapView.settings.myLocationButton = true
            mapView.isMyLocationEnabled = true
            if let placesArray = placesArray {
                let icons = [String:UIImage]()
                for (index, place) in placesArray.enumerated() {
                    if let icon = icons[place.iconString] as? String {
                        // use icon from dictionary
                    }
                    else {
                        if let data = try? Data(contentsOf: URL(string: place.iconString)!) {
                            if let image = UIImage(data: data, scale: 2.5) {
                                DispatchQueue.main.async {
                                    let marker = GMSMarker(position: place.coordinate)
                                    marker.icon = image
                                    marker.userData = index as Int
                                    marker.map = self.mapView
                                    // add icon with dictionary url/string as key
                                }
                            }
                        }
                    }
                }
            }
        }
        self.mapView.isHidden = true
    }
    
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func modeButtonPressed(_ sender: Any) {
        if(mapView.isHidden) {
            modeButton.setTitle(Map, for: .normal)
            modeButtonImage.image = UIImage(named: map_iconImg)
            self.mapView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.alpha = 0
            }, completion:  nil)
        } else {
            modeButton.setTitle(list, for: .normal)
            modeButtonImage.image = UIImage(named: list_iconImg)
            UIView.animate(withDuration: 0.3/*Animation Duration second*/, animations: {
                self.mapView.isHidden = true
            }, completion:  {
                (value: Bool) in
                self.tableView.alpha = 1
            })
        }
    }
    
    @IBAction func detailCloseButtonPressed(_ sender: Any) {
        hideDetailView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setDetailInformation(usingIndex: indexPath.row)
        showDetailView()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placesArray?.count ?? 1
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let index = marker.userData as? Int? {
            setDetailInformation(usingIndex: index!)
            showDetailView()
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nearbyPlaceCellIdentifier", for: indexPath) as! NearbyPlacesItem
        guard let placesArray = placesArray else { return cell }
        cell.nameLabel.text = placesArray[indexPath.row].name
        if let userLocation = userLocation {
            let distance = placesArray[indexPath.row].distance * 3.28084
            cell.distanceLabel.text = "\(distance.rounded()) feet"
        }
        return cell
    }
    
    func showDetailView(){
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5,  options: .curveEaseInOut, animations: {() -> Void in
            self.detailView.transform = .identity
            self.detailView.isHidden = false
        }, completion:  nil)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {() -> Void in
            self.detailView.alpha = 1
        }, completion:  nil)
        
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification,  self.detailNameLabel);
    }
    
    func hideDetailView(){
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5,  options: .curveEaseInOut, animations: {() -> Void in
            self.detailView.transform = CGAffineTransform(translationX: self.detailView.frame.width, y: 0)
            self.detailView.isHidden = true
        }, completion: nil)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {() -> Void in
        self.detailView.alpha = 0
        }, completion: nil)
        
    }
    
    func setDetailInformation (usingIndex index:Int) {
        guard let name = placesArray?[index].name,
            let address = placesArray?[index].address,
            let coordinates = placesArray?[index].coordinate,
            let distance = placesArray?[index].distance
        else {
            self.detailNameLabel.text = ""
            self.detailAddressLabel.text = ""
            self.detailDistanceLabel.text = ""
            print("Error getting detailInformation")
            return
        }
        self.detailNameLabel.text = name
        self.detailAddressLabel.text = address
        self.detailDistanceLabel.text = "\(distance.rounded()) feet"
        self.destination = coordinates
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        hideDetailView()
    }
    
    @IBAction func navigationButtonPressed(_ sender: Any) {
        guard let lat = self.destination?.latitude, let lng = self.destination?.longitude else {
            print("error getting destination location")
            return
        }
        let storyboard = UIStoryboard (name: StoryboardIdentifier.mainIdentifier, bundle: nil)
        let resultVC = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.TemporaryNavigation) as! MainSetANewPathMap
        resultVC.enteredStop = CLLocationCoordinate2D(
            latitude: lat,
            longitude: lng)
        resultVC.destinationText = self.detailAddressLabel.text
        self.present(resultVC, animated: true, completion: nil)
    }
    
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
