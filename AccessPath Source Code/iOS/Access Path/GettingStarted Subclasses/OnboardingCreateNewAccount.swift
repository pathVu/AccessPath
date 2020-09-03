//
//  CreateNewAccount.swift
//  Access Path
//
//  Created by Nick Sinagra on 5/21/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit
import GoogleSignIn
import FacebookLogin
import FacebookCore
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftyJSON

/**
 * Presents options for the user to create a new account such as Facebook,
 * Google, guest, and name and email
 */
class OnboardingCreateNewAccount: UIViewController {
    
    //UI Outlets
    @IBOutlet weak var signUpWithFacebookBtn: UIButton!
    @IBOutlet weak var signUpWithGoogleBtn: UIButton!
    @IBOutlet weak var guestAccountBtn: UIButton!
    
    @IBOutlet weak var nameAndEmailBtn: UIButton!
    @IBOutlet weak var haveAnAccountBtn: UIButton!
    
    //Shared Preferences
    let preferences = UserDefaults.standard
    
    //PHP Class Instance
    let pathVuPHP = PHPCalls()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Allow Google sign in to switch screens
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        //If the user has not visited a later screen, set this as the highest screen reached
        if(preferences.integer(forKey: PrefKeys.onboardProgKey) < 3) {
            preferences.set(3, forKey: PrefKeys.onboardProgKey)
        }
        //To differentiate between google sign up or sign in, see AppDelegate
        preferences.set(true, forKey: PrefKeys.googleSignUpKey)
        setStyles()
    }
    
    
    //Set button default styles
    func setStyles() {
        signUpWithFacebookBtn.layer.borderColor = AppColors.facebook.cgColor
        signUpWithGoogleBtn.layer.borderColor = AppColors.google.cgColor
        
        guestAccountBtn.layer.borderColor = AppColors.darkBlue.cgColor
        nameAndEmailBtn.layer.borderColor = AppColors.darkBlue.cgColor
        haveAnAccountBtn.layer.borderColor = AppColors.darkBlue.cgColor
    }
    
    
    //Sign up using Google
    @IBAction func signUpWithGoogleBtnPressed(_ sender: Any) {
        //Mark as non-guest account so user can report obstructions
        preferences.set(false, forKey: PrefKeys.guestAccountKey)
        preferences.removeObject(forKey: PrefKeys.usernameKey)
        
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
        //Shared preferences handled in AppDelegate
    }
    
    
    //Sign up with Facebook
    @IBAction func signUpWithFBBtnPressed(_ sender: Any) {
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
                
                let ftoken: String = accessToken.tokenString
                let status = self.pathVuPHP.signUpWithFacebook(ftoken: ftoken)
                
                if status == 1 {
                    let aid = self.preferences.string(forKey: PrefKeys.aidKey)!
                    self.preferences.set(aid, forKey: PrefKeys.uidKey)
                        //Go to username screen
                    let storyboard = UIStoryboard(name: StoryboardIdentifier.gettingStarted1Storyboard, bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.onboardingUserNameScreen) as UIViewController
                    self.present(vc, animated: true, completion: nil)
                }
                else if status == 2 {
                    if let settings = self.pathVuPHP.getSettings(uacctid: String(self.preferences.string(forKey: PrefKeys.aidKey) ?? "")) {
                        self.processDict(response: settings)
                        print("User already exists")
                    }
                }
                else {
                    print("Status: \(status)")
                    let alert = UIAlertController(title: "Error", message: "Error singing in with Facebook. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                    self.present(alert, animated: true, completion: nil)
                    alert.addAction(UIAlertAction(title: AlertConstant.okString, style: .default, handler: { action in
                        switch action.style{
                        default:
                            //Go back to search screen
                            debugPrint("nothing")
                            self.dismiss(animated: true, completion: nil)
                        }
                    }))
                }
            }
        }
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
    //Sign up as a guest
    @IBAction func signUpAsGuestBtnPressed(_ sender: Any) {
        //Mark as guest so user cannot report obstructions
        preferences.set(true, forKey: PrefKeys.guestAccountKey)
        
        
        let status = self.pathVuPHP.signUpAsGuest(uacctid: self.preferences.string(forKey: PrefKeys.aidKey) ?? "")
        preferences.removeObject(forKey: PrefKeys.usernameKey)
        
        if status == 1 {
            let aid = self.preferences.string(forKey: PrefKeys.aidKey)!
            self.preferences.set(aid, forKey: PrefKeys.uidKey)
            //Go to username screen
            let storyboard = UIStoryboard(name: StoryboardIdentifier.gettingStarted1Storyboard, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.onboardingUserNameScreen) as UIViewController
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
        else if status == 2 {
            if let settings = self.pathVuPHP.getSettings(uacctid: String(self.preferences.string(forKey: PrefKeys.aidKey) ?? "")) {
                self.processDict(response: settings)
                print("User already exists")
            }
        }
        else {
            print("Status: \(status)")
            let alert = UIAlertController(title: "Error", message: "Error signing in as guest. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
            self.present(alert, animated: true, completion: nil)
            alert.addAction(UIAlertAction(title: AlertConstant.okString, style: .default, handler: { action in
                switch action.style{
                default:
                    //Go back to search screen
                    debugPrint("nothing")
                    self.dismiss(animated: true, completion: nil)
                }
            }))
        }
    }
    
    //Go back to previous screen
    @IBAction func dismissView(_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
