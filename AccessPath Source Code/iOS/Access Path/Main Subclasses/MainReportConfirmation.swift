//
//  ConfirmationScreen.swift
//  ReportingTest
//
//  Created by Nick Sinagra on 7/9/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON

/**
 * Shows the type and locaiton of the hazard the user is reporting
 */
class MainReportConfirmation: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    //UI Outlets
    @IBOutlet weak var imageCaptured: UIImageView!
    @IBOutlet weak var confirmButton: UIButton!
    
    //Hazard location information (passed from previous screens)
    var lat:Double!
    var lng:Double!
    var image:UIImage!
    var address:String!
    var googleLocationID:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCaptured.image = image
    }
    
    //Pass information and take the user to the submission screen
    @IBAction func confirmButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard (name: StoryboardIdentifier.mainIdentifier, bundle: nil)
        let resultVC = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.SelectTypeScreen) as! MainReportCategory
        
        resultVC.lat = lat
        resultVC.lng = lng
        resultVC.address = address
        resultVC.image = image
        resultVC.googleLocationID = self.googleLocationID
        self.present(resultVC, animated: true, completion: nil)
    }
    
    @IBAction func clickOnRetakePhoto(_ sender: UIButton) {
        //dismiss(animated:true, completion: nil)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera;
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    /**
     * Called when the camera returns to this activity.
     * Passes location info to the report confirmation screen and then opens it.
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismiss(animated:true, completion: nil)
        
        let storyboard = UIStoryboard (name: StoryboardIdentifier.mainIdentifier, bundle: nil)
        let resultVC = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.ConfirmationScreen) as! MainReportConfirmation
        resultVC.lat = lat
        resultVC.lng = lng
        resultVC.address = address
        resultVC.image = image
        self.present(resultVC, animated: false, completion: nil)
    }
    
    
    //Go back to navigation home screen
    @IBAction func goBackToOneButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: StoryboardIdentifier.unwindSegueToVC1, sender: self)
    }
}

