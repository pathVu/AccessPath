//
//  AppDelegate.swift
//  Access Path
//
//  Created by Nick Sinagra on 3/28/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit
import GoogleSignIn
import IQKeyboardManagerSwift
import FacebookLogin
import FacebookCore
import UserNotifications
import CoreLocation
import ArcGIS
import GooglePlaces
import GoogleMaps
import SwiftyJSON

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, UNUserNotificationCenterDelegate{
    
    // current google client ID
    let googleClientID = "437738860881-np0k57eo9g4t83pqsoeh2pgpgmqahneo.apps.googleusercontent.com"
    
    //Shared preferences
    let preferences = UserDefaults.standard
    static let delegate = UIApplication.shared.delegate
    //PHP calls class instance
    let pathVuPHP = PHPCalls()
    
    var window: UIWindow?
    let mainView = UIView()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GIDSignIn.sharedInstance().clientID = self.googleClientID
        GIDSignIn.sharedInstance().delegate = self

        //Change by IQ
        //Provide API key for Google APIs
        GMSServices.provideAPIKey(GoogleAPILicenseKey)
        GMSPlacesClient.provideAPIKey(GoogleAPILicenseKey)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { (allow, error) in
            return
        }
        
        //If user is signed in, set MainNavigationHome as the root view controller
        //else, set the logo screen as the root view controller
        if(preferences.object(forKey: PrefKeys.signedInKey) != nil) {
            if(preferences.bool(forKey: PrefKeys.signedInKey)) {
                let storyboard = UIStoryboard(name: StoryboardIdentifier.mainIdentifier, bundle: nil)
                let rootController = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.navigationHomeIdentifier) as! MainNavigationHome
                if let window = self.window {
                    window.rootViewController = rootController
                }
            } else {
                let storyboard = UIStoryboard(name: StoryboardIdentifier.gettingStarted1Storyboard, bundle: nil)
                let rootController = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.getStarted1) as! OnboardingLogoScreen
                if let window = self.window {
                    window.rootViewController = rootController
                }
            }
        } else {
            let storyboard = UIStoryboard(name: StoryboardIdentifier.gettingStarted1Storyboard, bundle: nil)
            let rootController = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.getStarted1) as! OnboardingLogoScreen
            if let window = self.window {
                window.rootViewController = rootController
            }
        }

        //Change by IQ
        //Provide API key for Google APIs
        GMSServices.provideAPIKey(GoogleAPILicenseKey)
        GMSPlacesClient.provideAPIKey(GoogleAPILicenseKey)

        //Change by Chetu
        //Added by Chetu -- Facebook SDk Delegate
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        //Handles what happens when a keyboard shows over a text box
        IQKeyboardManager.shared.enable = true
        return true
    }
    
    //
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        
        //Added by Chetu
        //handle open url changed
        if (url.scheme?.hasPrefix("fb"))! && url.scheme != nil {
            return ApplicationDelegate.shared.application(app, open: url, options: options)
        }
        else
        {
            return GIDSignIn.sharedInstance().handle(url as URL?)
        }
    }
    
    //Handles Google sign up/in
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
            // [START_EXCLUDE silent]
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "ToggleAuthUINotification"), object: nil, userInfo: nil)
            // [END_EXCLUDE]
        } else {
            // Perform any operations on signed in user here.
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            
            print("<Google Sign In>: Sign In Successful, sending to PHP")
            //Needed in order to differentiate between signing up OR in with a Google account
            //Because we need to know which view controller to switch to
            let status = pathVuPHP.signUpWithGoogle(gtoken: idToken!)
            switch (status) {
            case 1:
                print("<Google Sign In>: Received UID, Success")
                preferences.set(true, forKey: PrefKeys.gSignupKey)
                
                let storyboard = UIStoryboard(name: StoryboardIdentifier.gettingStarted1Storyboard, bundle: nil)
                let createAccountVC = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.createNewAccount)
                let usernameVC = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.onboardingUserNameScreen)
                
                window = UIWindow(frame: UIScreen.main.bounds)
                window?.rootViewController = createAccountVC
                window?.makeKeyAndVisible()
                createAccountVC.present(usernameVC, animated: true, completion: nil)
            case 2:
                if let settings = self.pathVuPHP.getSettings(uacctid: String(self.preferences.string(forKey: PrefKeys.aidKey) ?? "")) {
                    self.processDict(response: settings)
                }
                else {
                    print("Error getting settings")
                }
            default:
                print("PHP returned an error")
            }
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "ToggleAuthUINotification"),
                object: nil,
                userInfo: ["statusText": "Signed in user " + (fullName?.description)!])
        }
    }
    
    func processDict(response:[JSON]?) {
        if let response = response {
            //Store comfort and alert settings in shared preferences
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
            
            self.preferences.set(true, forKey: PrefKeys.signedInKey)
            let storyboard2 = UIStoryboard(name: StoryboardIdentifier.mainIdentifier, bundle: nil)
            let navigationHomeVC = storyboard2.instantiateViewController(withIdentifier: StoryboardIdentifier.navigationHomeIdentifier)
            
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = navigationHomeVC
            window?.makeKeyAndVisible()
        } else {
            //If user has not completed onboarding process, take them to username screen
            let storyboard = UIStoryboard(name: StoryboardIdentifier.gettingStarted1Storyboard, bundle: nil)
            let logInVC = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.loginMainIdentifier)
            let usernameVC = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.onboardingUserNameScreen)
            
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = logInVC
            window?.makeKeyAndVisible()
            logInVC.present(usernameVC, animated: true, completion: nil)
        }
    }
    
    func displayLocalNotification(PlaceText:String,TextIdentifier:String) {
        
        //Notification Content
        let content = UNMutableNotificationContent()
        content.title = TextIdentifier
        content.subtitle = ""
        content.body = PlaceText
        //content.categoryIdentifier = "INVITATION"
        content.sound = UNNotificationSound.default()
        
        //Notification Trigger - when the notification should be fired
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        
        //Notification Request
        let request = UNNotificationRequest(identifier: TextIdentifier, content: content, trigger: trigger)
        
        //Scheduling the Notification
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            if let error = error
            {
                print(error.localizedDescription)
            }
        }
    }
    
   
    ///// ************* Showing Notification Bar from top ********************
    //***************** Show Notification Alert **************
    
    /*
    func showNotifificationAlert(text: String, bgColor: UIColor, textColor: UIColor, completed:@escaping(_ :Bool) -> Void) {
        
       
        var backgroundImageView = UIImageView()
        let l = UILabel()
        let closeButton   = UIButton(type: UIButtonType.custom) as UIButton
        
        if let window :UIWindow = UIApplication.shared.keyWindow {
            mainView.frame = CGRect.init(x: 0, y: 64, width: SCREEN_WIDTH, height: 64)
            
            
            //background image
            backgroundImageView = UIImageView(frame: CGRect(x: 0, y: 64, width: SCREEN_WIDTH, height: 64))
            backgroundImageView.image = UIImage(named: "hazard-background.png")
            mainView.addSubview(backgroundImageView)
            
            //Text display
            l.textColor = textColor
            l.font = UIFont(name: "Helvetica Neue Bold" , size:14)
            l.text = text
            l.textAlignment = .center
            l.numberOfLines = 0
            l.frame = CGRect.init(x: 0, y: 64, width: SCREEN_WIDTH, height: 64)
            //mainView.addSubview(l)
            
            //close button
            let image = UIImage(named: "yellow-close-icon.png") as UIImage?
            closeButton.frame = CGRect.init(x: mainView.frame.width - 40, y: 80 , width: 30, height: 30)
            closeButton.setImage(image, for: .normal)
           // closeButton.call()
            closeButton.addTarget(self, action: #selector(clickOnCloseButton(_:)), for: .touchUpInside)
            
            
            window.addSubview(mainView)
            mainView.addSubview(closeButton)
            //window.addSubview(closeButton)
            
        }
        mainView.center.y -= 114
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [.curveEaseInOut], animations: {
            
            self.mainView.center.y += 114
            
        }, completion: {_ in
//            UIView.animate(withDuration: 10, animations: {
//                //mainView.center.y -= 104
//            }, completion: { (_) in
//                completed(true)
//                mainView.removeFromSuperview()
//            })
        })
    }
    */
   
    
    
    //Needed for Google sign in
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // [START_EXCLUDE]
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "ToggleAuthUINotification"),
            object: nil,
            userInfo: ["statusText": "User has disconnected."])
        // [END_EXCLUDE]
    }
    //
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("application WillResignActive")
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("application DidEnterBackground")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("application WillEnterForeground")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("application DidBecomeActive")
        //AppEventsLogger.activate(application)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}


