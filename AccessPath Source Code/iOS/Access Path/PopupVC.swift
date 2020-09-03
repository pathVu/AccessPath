//
//  PopupVC.swift
//  Access Path
//
//  Created by Nick Sinagra on 6/15/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit

/**
 * View controller for map callouts
 */
class PopupVC: UIViewController {
    
    @IBOutlet weak var sidewalkImage: UIImageView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    var imgString: String!
    var idString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //The functions below are in place of IBActions, as those do not work here
    //These are declared here but set in the geoView function
    
    @objc func yesButtonPressed() {
        noButton.setTitleColor(AppColors.disabledBorder, for: .normal)
        noButton.backgroundColor = AppColors.disabledBackground
        noButton.layer.borderColor = AppColors.disabledBorder.cgColor
        
        yesButton.setTitleColor(AppColors.darkBlue, for: .normal)
        yesButton.backgroundColor = AppColors.caretColor
        yesButton.layer.borderColor = AppColors.darkBlue.cgColor
        
        if(idString != nil) {
            print(idString + " +1")
        }
    }
    
    @objc func noButtonPressed() {
        yesButton.setTitleColor(AppColors.disabledBorder, for: .normal)
        yesButton.backgroundColor = AppColors.disabledBackground
        yesButton.layer.borderColor = AppColors.disabledBorder.cgColor
        
        noButton.setTitleColor(AppColors.darkBlue, for: .normal)
        noButton.backgroundColor = AppColors.lightBlue
        noButton.layer.borderColor = AppColors.darkBlue.cgColor
        
        if(idString != nil) {
            print(idString + " -1")
        }
    }
    
}
