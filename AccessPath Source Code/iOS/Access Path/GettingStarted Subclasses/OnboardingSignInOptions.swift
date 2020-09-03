//
//  LogInMain.swift
//  Access Path
//
//  Created by Nick Sinagra on 5/21/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import SwiftyJSON
import GoogleSignIn

/**
 * Presents the user with different options for signing in including
 * Facebook, Google, or name and email.
 */
class OnboardingSignInOptions: UIViewController {
    
    //UI Outlets
    @IBOutlet weak var logInWithFacebookBtn: UIButton!
    @IBOutlet weak var logInWithGoogleBtn: UIButton!
    @IBOutlet weak var logInWithEmailBtn: UIButton!
    @IBOutlet weak var noAccountBtn: UIButton!
    
    //PHP calls class instance
    let pathVuPHP = PHPCalls()
    
    //Data saved on the device
    let preferences = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        //If the user has not visited a later screen, set this as the highest screen reached
        if(preferences.integer(forKey: PrefKeys.onboardProgKey) < 9) {
            preferences.set(9, forKey: PrefKeys.onboardProgKey)
        }
        //Needed for differenting between Google sign up and sign in, see AppDelegate
        preferences.set(false, forKey: PrefKeys.googleSignUpKey) //google Signup key
        setStyles()
    }
    
    //Button handler for signing in with Facebook
    @IBAction func logInWithFacebookButtonPressed(_ sender: Any) {
        preferences.set(false, forKey: PrefKeys.guestAccountKey)
        preferences.removeObject(forKey: PrefKeys.usernameKey)
        
        let loginManager = LoginManager()
        loginManager.logIn(permissions: [ .publicProfile, .email ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User Cancelled Login")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Successfully Logged In")
                print("Retrieved Access Token:")
                print(accessToken)
                
                let ftoken:String = accessToken.tokenString
                var status = self.pathVuPHP.signUpWithFacebook(ftoken: ftoken)
                switch (status) {
                case 0:
                    print("unexpected error")
                    return
                case 1:
                    guard let aid = self.preferences.string(forKey: PrefKeys.aidKey), let type = self.preferences.string(forKey: PrefKeys.uTypeKey) else {
                        print("error setting user type")
                        return
                    }
                    let storyboard = UIStoryboard(name: StoryboardIdentifier.gettingStarted1Storyboard, bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.onboardingUserNameScreen) as UIViewController
                    self.present(vc, animated: true, completion: nil)
                    return
                    
                case 2:
                    if let settings = self.pathVuPHP.getSettings(uacctid: String(self.preferences.string(forKey: PrefKeys.aidKey) ?? "")) {
                        self.processDict(response: settings)
                    }
                    print("User already exists")
                    break
                default:
                    print("default status")
                }
                return
            }
        }
    }
    
    //Button handler for signing in with Googleif 
    @IBAction func logInWithGoogleButtonPressed(_ sender: Any) {
        
        preferences.set(false, forKey: PrefKeys.guestAccountKey)
        preferences.removeObject(forKey: PrefKeys.usernameKey)
        GIDSignIn.sharedInstance().signIn()
        //Local saved data will be handled in AppDelegate.swift
    }
    
    //Process comfort and alert settings and store them in shared preferences
    func processDict(response:[JSON]?) {
        preferences.set(false, forKey: PrefKeys.guestAccountKey)
        print("<login.php>: Sign In Successful")
        
        if let response = response {
            let keys = [
                PrefKeys.thComfortKeyValue,
                PrefKeys.rComfortKeyValue,
                PrefKeys.rsComfortKeyValue,
                PrefKeys.csComfortKeyValue,
                PrefKeys.thAlertKeyValue,
                PrefKeys.rAlertKeyValue,
                PrefKeys.rsAlertKeyValue,
                PrefKeys.csAlertKeyValue,
            ]
            
            for index in 0 ... keys.count - 1 {
                let value = Int(response[index + 1][String(index + 1)].stringValue) ?? 1
                print("value: \(value)")
                self.preferences.setValue(value, forKey: keys[index])
            }
            
            // pathVuPHP.checkActivation(aid: self.preferences.value(forKey: PrefKeys.aidKey) as! String)
            self.preferences.set(true, forKey: PrefKeys.signedInKey)
            let storyboard = UIStoryboard(name: StoryboardIdentifier.mainIdentifier, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.navigationHomeIdentifier) as UIViewController
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
        else {
            let storyboard = UIStoryboard(name: StoryboardIdentifier.gettingStarted1Storyboard, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.onboardingUserNameScreen) as UIViewController
            self.present(vc, animated: true, completion: nil)
            return
        }
    }
    
    
    //Set default styles for buttons
    func setStyles() {
        logInWithFacebookBtn.layer.borderColor = AppColors.facebook.cgColor
        logInWithGoogleBtn.layer.borderColor = AppColors.google.cgColor
        logInWithEmailBtn.layer.borderColor = AppColors.darkBlue.cgColor
        noAccountBtn.layer.borderColor = AppColors.darkBlue.cgColor
    }
    
}
