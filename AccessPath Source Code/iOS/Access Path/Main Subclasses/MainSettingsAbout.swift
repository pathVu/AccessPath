//
//  AboutPathVu.swift
//  Access Path
//
//  Created by Nick Sinagra on 6/19/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit

/**
 * Shows information about the app/company
 * right now only contains an option to view full terms of agreement
 */
class MainSettingsAbout:UIViewController {
    
    //UI Outlets
    @IBOutlet weak var termsOfAgreementButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set button default style
        termsOfAgreementButton.layer.borderWidth = 1.5
        termsOfAgreementButton.layer.borderColor = AppColors.darkBlue.cgColor
        termsOfAgreementButton.layer.cornerRadius = 5 
    }
    
    //Go back to previous screen
    @IBAction func dismissView(_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
