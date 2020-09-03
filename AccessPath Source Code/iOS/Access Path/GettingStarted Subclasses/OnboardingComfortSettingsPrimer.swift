//
//  ComfortSettingsMain.swift
//  Access Path
//
//  Created by Nick Sinagra on 5/21/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit

/**
 * Presents an intro screen explaining to the user that they are bout
 * to choose comfort and alert settings
 */
class OnboardingComfortSettingsPrimer: UIViewController {
    
    //Shared Preferences
    let preferences = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //If the user has not visited a later screen, set this as the highest screen reached
        if(preferences.integer(forKey: PrefKeys.onboardProgKey) < 6) {
            preferences.set(6, forKey: PrefKeys.onboardProgKey)
        }
    }
    
    //Go back to previous screen
    @IBAction func dismissView(_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
