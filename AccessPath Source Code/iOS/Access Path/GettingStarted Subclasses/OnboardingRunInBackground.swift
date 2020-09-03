//
//  ComfortSettingsMain.swift
//  Access Path
//
//  Created by Nick Sinagra on 5/21/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit
import CoreLocation

/**
 * Class that asks for location permissions and if the app
 * is allowed to run in the background
 */
class OnboardingRunInBackground: UIViewController {
    
    //UI Outlets
    @IBOutlet weak var iUnderstandBtn: UIButton!
    
    //Location manager for asking permissions
    var locManager = CLLocationManager()
    
    //Local Saved Data
    let preferences = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Ask for location permissions if they haven't been granted already
        self.locManager.requestAlwaysAuthorization()
        self.locManager.requestWhenInUseAuthorization()
        
        //If the user has not visited a later screen, set this as the highest screen reached
        if(preferences.integer(forKey: PrefKeys.onboardProgKey) < 8) {
            preferences.set(8, forKey: PrefKeys.onboardProgKey)
        }
        
        iUnderstandBtn.layer.borderColor = AppColors.darkBlue.cgColor
    }
    
    
    //Go to navigation home screen, the onboarding process is completed
    @IBAction func iUnderstandBtnPressed(_ sender: Any) {
        preferences.set(true, forKey: PrefKeys.signedInKey)
        let storyboard = UIStoryboard(name: StoryboardIdentifier.mainIdentifier, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.navigationHomeIdentifier) as! MainNavigationHome
        UIApplication.shared.windows.first?.rootViewController = vc
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    
    //Return to previous screen
    @IBAction func dismissView(_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
