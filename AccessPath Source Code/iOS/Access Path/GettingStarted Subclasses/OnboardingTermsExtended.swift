//
//  FullTermsOfAgreement.swift
//  Access Path
//
//  Created by Nick Sinagra on 5/14/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit

/**
 * Presents the user with the full terms of agreement
 * The user can accept them or deny them, if denied
 * it will ask to close the app.
 */
class OnboardingTermsExtended: UIViewController {
    
    //UI Outlets
    @IBOutlet weak var dontAgreeAndCloseBtn: UIButton!
    
    //Local Saved Data
    let preferences = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //If the user has not visited a later screen, set this as the highest screen reached
        if(preferences.integer(forKey: PrefKeys.onboardProgKey) < 2) {
            preferences.set(2, forKey: PrefKeys.onboardProgKey)
        }
    }
    
    
    /**
     * Button handler for the dont agree and close button
     */
    @IBAction func dontAgreeAndCloseBtnPressed(_ sender: Any) {
        closeApp()
    }
    
    
    /**
     * This function presents a pop-up confirmation box
     * If the user clicks yes, the app will close
     * If the user clicks no, the pop-up closes and nothing happens
     */
    func closeApp() {
        let alert = UIAlertController(title: AlertConstant.confirm, message: AlertConstant.disAgreeTerm, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title:AlertConstant.yes, style: .default, handler: { action in
            exit(0)
        }))
        alert.addAction(UIAlertAction(title:AlertConstant.no, style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    //Go back to the last screen
    @IBAction func dismissView(_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
