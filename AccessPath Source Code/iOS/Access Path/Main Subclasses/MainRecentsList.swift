//
//  RecentPathsMain.swift
//  Access Path
//
//  Created by Nick Sinagra on 7/31/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit
import ArcGIS
import SwiftyJSON
/**
 * Shows a list of the user's recent paths
 */
class MainRecentsList: UIViewController {
    
    //UI Outlets
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var recentsList: UITableView!
    @IBOutlet weak var loadingSpinner: SpinnerView!
    @IBOutlet weak var noRecentsMessage: UILabel!
    
    //For creating a gradient on the navView
    var gradientLayer: CAGradientLayer!
    
    //Recent place addresses array
    var placeAddresses:[String] = []
    
    //Shared Preferences
    let preferences = UserDefaults.standard
    
    //PHP Calls Class Instance
    let pathVuPHP = PHPCalls()
    
    //Recent place location information
    var lat:Double!
    var lng:Double!
    
    //ArcGIS Location Tasks for geocoding (getting point)
    var locatorTask: AGSLocatorTask!
    var reverseGeocodeParameters: AGSReverseGeocodeParameters!
    var cancelable: AGSCancelable!
    let overlay = AGSGraphicsOverlay()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recentsList.delegate = self
        recentsList.dataSource = self
        
        createGradientLayer(view: navView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
        let acctid = preferences.string(forKey: PrefKeys.aidKey)
        if let responseData = pathVuPHP.getRecents(acctid: acctid!) {
            //Parse JSON for list of recents
            let json = JSON(responseData)
            for item in json["recents"].arrayValue {
                placeAddresses.append(item["raddress"].stringValue)
                recentsList.reloadData()
            }
        }
        
        //If no recents, show message that there are no recents
        if(placeAddresses.count == 0){
            recentsList.isHidden = true
            noRecentsMessage.isHidden = false
        }
        //Done loading, hide loading spinner
        loadingSpinner.isHidden = true
    }
    
    
    
    //Create a gradient background for a view
    func createGradientLayer(view:UIView) {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [AppColors.gradStart.cgColor, AppColors.gradEnd.cgColor]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    
    //Go back to previous screen
    @IBAction func goBackToOneButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


//Delegate methods for tableViews
extension MainRecentsList: UITableViewDelegate, UITableViewDataSource {
    
    //How many sections to create
    func numberOfSections(in tableView: UITableView) -> Int {
        return placeAddresses.count
    }
    
    //Allow 1 cell per section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    // Make the section headers transparent
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    //Set the style/information for each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = recentsList.dequeueReusableCell(withIdentifier: StoryboardIdentifier.CustomCell, for: indexPath) as! CustomRecentsCell
        
        cell.layer.borderColor = AppColors.blueButton.cgColor
        cell.layer.borderWidth = 1.5
        cell.layer.cornerRadius = 5
        
        let address = placeAddresses[indexPath.section]
        cell.addressLabel.text = address
        return cell
    }
    
    
    //Set cell click listeners
    //Clicking on a recent will set a path to that recent
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let currentCell = tableView.cellForRow(at: indexPath) as! CustomRecentsCell
        let placeAddress = currentCell.addressLabel.text!
        
        locatorTask = AGSLocatorTask(url: RoutingUrls.locatorTaskURL!)
        let params = AGSGeocodeParameters()
        params.maxResults = 1
        self.locatorTask.geocode(withSearchText: placeAddress, parameters: params, completion: {(results, error) -> Void in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            results?.forEach {(result) in
                if let displayLocation = result.displayLocation {
                    print("Geocode SearchValues = ", result.label, " at ", displayLocation.x, ", ", displayLocation.y)
                    
                    self.lat = displayLocation.y
                    self.lng = displayLocation.x
                    
                    let storyboard = UIStoryboard (name: "Main", bundle: nil)
                    let resultVC = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.TemporaryNavigation) as! MainSetANewPathMap
                    
                    resultVC.destinationText = placeAddress
                    resultVC.enteredStop = CLLocationCoordinate2D(latitude: self.lat, longitude: self.lng)
                    self.present(resultVC, animated: true, completion: nil)
                }
            }
        })
    }
}

//Recent cell outlets
class CustomRecentsCell: UITableViewCell {
    @IBOutlet weak var addressLabel: UILabel!
}
