//
//  AboutPathVu.swift
//  Access Path
//
//  Created by Nick Sinagra on 6/19/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit

class MainSettingsAbout:UIViewController {
    
    @IBOutlet weak var termsOfAgreementButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        termsOfAgreementButton.layer.borderWidth = 1.5
        termsOfAgreementButton.layer.borderColor = AppColors.darkBlue.cgColor
        termsOfAgreementButton.layer.cornerRadius = 5 
    }
    
    
    
}
