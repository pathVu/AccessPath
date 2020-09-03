//
//  FavoritePlacesMAin.swift
//  Access Path
//
//  Created by Nick Sinagra on 5/16/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit
import SwiftyJSON

class MainFavoritesList : UIViewController {
    
    //UI Outlets
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var favoritesList: UITableView!
    @IBOutlet weak var loadingSpinner: SpinnerView!
    @IBOutlet weak var noFavoritesView: UIView!
    
    //Top bar gradient
    var gradientLayer: CAGradientLayer!
    
    //Holds favorite places information
    var placeNames:[String] = []
    var placeAddresses:[String] = []
    
    //Shared Preferences
    let preferences = UserDefaults.standard
    
    //PHP Calls Class Instance
    let pathVuPHP = PHPCalls()
    
     var favoriteAddressArray = [FavoriteCoordinateListModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favoritesList.delegate = self
        favoritesList.dataSource = self
        
        //Sets the top bar to be a gradient
        createGradientLayer(view: navView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        if preferences.string(forKey: PrefKeys.aidKey) != nil {
            let acctid = preferences.string(forKey: PrefKeys.aidKey)
            let responseData = pathVuPHP.getFavorites(acctid: acctid!)
            
            //If there is any error loading favorites, show the add first favorite view
            if let responseData = responseData, !JSON(responseData).stringValue.contains("error") {
                noFavoritesView.isHidden = true
                //Iterate through response and add to name and address arrays
                let json = JSON(responseData)
                for item in json["favorites"].arrayValue {
                    placeNames.append(item["fname"].stringValue)
                    placeAddresses.append(item["faddress"].stringValue)
                    let favLattitude = item["flat"].doubleValue
                    let favLongitude = item["flon"].doubleValue
                    
                    self.favoriteAddressArray = []
                    
                    let favModelArray = FavoriteCoordinateListModel.init(favName: item["fname"].stringValue, favAddress: item["faddress"].stringValue, favoritePlaceLattitude: favLattitude, favoritePlacelongitude: favLongitude, favPlacesStatus: false, favPlaceIndex: 0)
                    self.favoriteAddressArray.append(favModelArray)
                    
                    // finish loading and hide spinner
                    loadingSpinner.isHidden = true
                    favoritesList.reloadData()
                    
                }
            }
            else {
                loadingSpinner.isHidden = true
                noFavoritesView.isHidden = false
                return
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //Clear name and address arrays to prevent duplicates from being loaded in
        //every time this view controller appears
        placeNames.removeAll()
        placeAddresses.removeAll()
        noFavoritesView.isHidden = true
    }
    
    //Create the gradient for the top bar
    func createGradientLayer(view:UIView) {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [AppColors.gradStart.cgColor, AppColors.gradEnd.cgColor]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    //Return to the mainnavigation home screen
    @IBAction func dismissView(_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unwindToObsList(segue:UIStoryboardSegue) { }
}

/**
 * Delegate functions for tableViews
 */
extension MainFavoritesList: UITableViewDelegate, UITableViewDataSource {
    
    //How many sections to create
    func numberOfSections(in tableView: UITableView) -> Int {
        return placeNames.count
    }
    
    //Allow 1 cell per section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    //Set the header of each section to be clear
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    //Set the information inside each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = favoritesList.dequeueReusableCell(withIdentifier: StoryboardIdentifier.CustomCell, for: indexPath) as! CustomTableViewCell
        
        cell.layer.borderColor = AppColors.blueButton.cgColor
        cell.layer.borderWidth = 1.5
        cell.layer.cornerRadius = 5
        
        let name = placeNames[indexPath.section]
        let address = placeAddresses[indexPath.section]
        
        cell.nameLabel.text = name
        cell.addressLabel.text = address
        
        return cell
    }
    
    //Handle cell click events
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Get the cell that was clicked on
        let currentCell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell
        
        let storyboard = UIStoryboard(name: StoryboardIdentifier.mainIdentifier, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.FavoritePlaceInfo) as! MainFavoritesInformation
        MainFavoritesInformation.placeName = currentCell.nameLabel.text!
        MainFavoritesInformation.placeAddress = currentCell.addressLabel.text!
        self.present(vc, animated: true, completion: nil)
    }
}

//Outlets for each cell
class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
}
