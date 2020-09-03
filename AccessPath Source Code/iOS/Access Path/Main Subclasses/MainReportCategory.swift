//
//  SelectTypeScreen.swift
//  Access Path
//
//  Created by Nick Sinagra on 7/10/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit

/**
 * Allows users to select the category of the obstruction they are reporting.
 */
class MainReportCategory: UIViewController {
    
    //UI Outlets
    @IBOutlet weak var imageCaptured: UIImageView!
    @IBOutlet weak var noSidewalkButton: UIButton!
    @IBOutlet weak var thButton: UIButton!
    @IBOutlet weak var noCurbRampButton: UIButton!
    @IBOutlet weak var constructionButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    @IBOutlet weak var entranceButton: UIButton!
    @IBOutlet weak var indoorAccessibilityButton: UIButton!
    
    //Obstruction location information (passed from camera action, see MainNavigationHome)
    var lat:Double!
    var lng:Double!
    var image:UIImage!
    var address:String!
    var googleLocationID:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCaptured.image = image
        
        //Set basic styles of buttons
        let allButtons = [noSidewalkButton, thButton, noCurbRampButton, constructionButton, otherButton, entranceButton, indoorAccessibilityButton]
        for button in allButtons {
            button?.layer.cornerRadius = 10
            button?.layer.borderColor = AppColors.darkBlue.cgColor
        }
    }
    
    //The following functions set the type of obstruction and go to confirmation screen
    @IBAction func thButtonPressed(_ sender: Any) {
        selectType(type: 1)
    }
    
    @IBAction func noSidewalkButtonPressed(_ sender: Any) {
        selectType(type: 2)
    }
    
    @IBAction func noCurbRampButtonPressed(_ sender: Any) {
        selectType(type: 3)
    }
    
    @IBAction func constructionButtonPressed(_ sender: Any) {
        selectType(type: 4)
    }
    
    @IBAction func otherButtonPressed(_ sender: Any) {
        selectType(type: 5)
    }
    
    @IBAction func entranceButtonPressed(_ sender: Any) {
        selectType(type: 6)
    }
    
    @IBAction func indoorButtonPressed(_ sender: Any) {
        selectType(type: 7)
    }
    //
    
    //Take the user to the confirmation screen
    func selectType(type:Int) {
        let storyboard = UIStoryboard (name: StoryboardIdentifier.mainIdentifier, bundle: nil)
        
        if type == 6 {
            let resultVC = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.EntranceInfoScreen) as! MainReportEntranceInfoScreen
            resultVC.lat = lat
            resultVC.lng = lng
            resultVC.address = address
            resultVC.image = image
            resultVC.type = type
            resultVC.googleLocationID = googleLocationID
            //Pass location information
            self.present(resultVC, animated: true, completion: nil)
        }
        else if type == 7 {
            let resultVC = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.IndoorInfoScreen ) as! MainReportIndoorInfoScreen
            resultVC.lat = lat
            resultVC.lng = lng
            resultVC.address = address
            resultVC.image = image
            resultVC.type = type
            resultVC.googleLocationID = googleLocationID
            //Pass location information
            self.present(resultVC, animated: true, completion: nil)
        }
        else {
            let resultVC = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.SubmissionScreen) as! MainReportSubmit
            resultVC.lat = lat
            resultVC.lng = lng
            resultVC.address = address
            resultVC.image = image
            resultVC.type = type
            resultVC.googleLocationID = googleLocationID
            //Pass location information
            self.present(resultVC, animated: true, completion: nil)
        }
    }
    
    
    //Go back to MainNavigationHome
    @IBAction func goBackToOneButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: StoryboardIdentifier.unwindSegueToVC1, sender: self)
    }
    
    
    //Go back to previous screen
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
