//
//  SettingsPage.swift
//  Access Path
//
//  Created by Nick Sinagra on 5/21/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit
import FacebookCore
/**
 * Contains options to go to settings submenus
 */
class MainSettings: UIViewController {
    
    //UI Outlets
    @IBOutlet weak var comfortAndAlertSettingsButton: UIButton!
    @IBOutlet weak var mapSettingsButton: UIButton!
    @IBOutlet weak var accountSettingsButton: UIButton!
    @IBOutlet weak var emailSupportButton: UIButton!
    @IBOutlet weak var aboutPathVuButton: UIButton!
    
    @IBOutlet weak var favoritesAlertButton: UIButton!
    @IBOutlet weak var imuSettingsButton: UIButton!
    
    @IBOutlet weak var imuSwitch: UISwitch!
    
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    let loginManager = LoginManager()
    //Shared Preferences
    let preferences = UserDefaults.standard
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //Set default styles
        setStyles()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        //Set default styles
        setStyles()
    }
    
    
    /**
     * Set default styles of buttons
     */
    func setStyles() {
        let topButtons = [comfortAndAlertSettingsButton, accountSettingsButton, emailSupportButton, aboutPathVuButton,imuSettingsButton, mapSettingsButton,favoritesAlertButton]
        
        let allButtons = [comfortAndAlertSettingsButton, accountSettingsButton, emailSupportButton, aboutPathVuButton,imuSettingsButton, signOutButton, cancelButton]
        
        for button in topButtons {
            button?.layer.cornerRadius = 5
            button?.layer.backgroundColor = UIColor.white.cgColor
            button?.layer.borderColor = AppColors.darkBlue.cgColor
        }
        signOutButton.layer.borderColor = AppColors.darkBlue.cgColor
        cancelButton.layer.borderColor = AppColors.darkBlue.cgColor
    }
    
    
    /**
     * The following functions will set the selected button to be orange
     */
    @IBAction func comfortAndAlertSettingsButtonPressed(_ sender: Any) {
        comfortAndAlertSettingsButton.layer.borderColor = AppColors.selectedBorder.cgColor
        comfortAndAlertSettingsButton.layer.backgroundColor = AppColors.selectedBackground.cgColor
    }
    
    
    /**
     * accountSettingsButtonPressed
     */
    @IBAction func accountSettingsButtonPressed(_ sender: Any) {
        accountSettingsButton.layer.borderColor = AppColors.selectedBorder.cgColor
        accountSettingsButton.layer.backgroundColor = AppColors.selectedBackground.cgColor
    }
    
    
    /**
     * Email supported
     */
    @IBAction func emailSupportButtonPressed(_ sender: Any) {
        emailSupportButton.layer.borderColor = AppColors.selectedBorder.cgColor
        emailSupportButton.layer.backgroundColor = AppColors.selectedBackground.cgColor
    }
    
    /**
     * About PathVu Button
     */
    @IBAction func aboutPathVuButtonPressed(_ sender: Any) {
        aboutPathVuButton.layer.borderColor = AppColors.selectedBorder.cgColor
        aboutPathVuButton.layer.backgroundColor = AppColors.selectedBackground.cgColor
    }
    
    
    /*
     Changed by chetu
     Add Imu button action
     */
    /** Removed IMU button from setting.
     * Commneted code of IMU
     @IBAction func imuSettingButtonPressed(_ sender: Any) {
     self.imuSettingsButton.layer.borderColor = AppColors.selectedBorder.cgColor
     self.imuSettingsButton.layer.backgroundColor = AppColors.selectedBackground.cgColor
     }
     */
    
    
    @IBAction func mapSettingsButtonPressed(_ sender: Any) {
        mapSettingsButton.layer.borderColor = AppColors.selectedBorder.cgColor
        mapSettingsButton.layer.backgroundColor = AppColors.selectedBackground.cgColor
    }
    
    @IBAction func favoriteAlertButtonPressed(_ sender: Any) {
        favoritesAlertButton.layer.borderColor = AppColors.selectedBorder.cgColor
        favoritesAlertButton.layer.backgroundColor = AppColors.selectedBackground.cgColor
    }
    
    
    
    
    /**
     * Opens a confirmation dialog asking the user if they are sure they want to sign out.
     * If they sign out, shared preferences are wiped and they are taken to the logo screen.
     */
    @IBAction func signOut(_ sender: Any) {
        let alert = UIAlertController(title: AlertConstant.signOutKey, message: AlertConstant.sureSignOut, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: AlertConstant.signOutKey, style: .default, handler: {
            (action: UIAlertAction!) in
            
            let dictionary = self.preferences.dictionaryRepresentation()
            dictionary.keys.forEach { key in
                self.preferences.removeObject(forKey: key)
                self.preferences.synchronize()
            }
            self.preferences.removeObject(forKey: PrefKeys.usernameKey)
            self.preferences.synchronize()
            
            GIDSignIn.sharedInstance().signOut() //google
            self.loginManager.logOut() //facebook
            
            let storyboard = UIStoryboard(name: StoryboardIdentifier.gettingStarted1Storyboard, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.getStarted1) as UIViewController
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }))
        alert.addAction(UIAlertAction(title: AlertConstant.cancel, style: .cancel))
        present(alert, animated: true, completion: nil)
    }
    
    
    //Go back to navigation home screen
    @IBAction func goBackToOneButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //Needed to get back here from a submenu
    @IBAction func unwindToMainSettings(segue:UIStoryboardSegue) { }
}
