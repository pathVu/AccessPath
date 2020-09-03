//
//  TermsOfAgreement.swift
//  Access Path
//
//  Created by Nick Sinagra on 5/21/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit

/**
 * Presents the user with an overview of the terms of agreement
 * The user can accept from here or view the full terms.
 */
class OnboardingTerms: UIViewController {
    
    //Shared Preferences
    let preferences = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //If the user has not visited a later screen, set this as the highest screen reached
        if(preferences.integer(forKey: PrefKeys.onboardProgKey) < 1) {
            preferences.set(1, forKey: PrefKeys.onboardProgKey)
        }
    }
    
}
