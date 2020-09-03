//
//  MainSettingsTermsExtended.swift
//  Access Path
//
//  Created by Nick Sinagra on 8/14/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit

/**
 * Shows the full terms of agreement
 */
class MainSettingsTermsExtended: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //Go back to the previous screen
    @IBAction func dismissView(_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //Go back to the settings list
    @IBAction func unwindToMainSettings(_ sender:Any) {
        performSegue(withIdentifier: StoryboardIdentifier.unwindToMainSettings, sender: self)
        
    }
}
