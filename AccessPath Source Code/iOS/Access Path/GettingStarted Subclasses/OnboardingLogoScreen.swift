//
//  OnboardingLogoScreen.swift
//  Access Path
//
//  Created by Nick Sinagra on 8/15/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit

/**
 * Very beginning of the onboarding process, will be the first screen
 * a new user sees.
 */
class OnboardingLogoScreen: UIViewController {
    
    //Shared Preferences
    let preferences = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //If the user has already made progess in the onboarding process,
        //take them to their last checkpoint
        let storyboard = UIStoryboard(name: StoryboardIdentifier.gettingStarted1Storyboard, bundle: nil)
        var screenName = ""
        switch preferences.integer(forKey: PrefKeys.onboardProgKey) {
        case 1:
            screenName = ScreenNameStruct.termOfAgreementString
            break
        case 2:
            screenName = ScreenNameStruct.fullTermOfAgreementString
            break
        case 3:
            screenName = ScreenNameStruct.createNewAccountString//"CreateNewAccount"
            break
        case 4:
            screenName = ScreenNameStruct.nameAndEmailSignupString//"NameAndEmailSignUp"
            break
        case 5:
            screenName = ScreenNameStruct.userNameString//"UsernameScreen"
            break
        case 6:
            screenName = ScreenNameStruct.comforSettingMainString//"ComfortSettingsMain"
            break
        case 7:
            screenName = ScreenNameStruct.obstructionListString//"ObstructionList"
            break
        case 8:
            screenName = ScreenNameStruct.runInBackgroundString//"RunInBackground"
            break
        case 9:
            screenName = ScreenNameStruct.logInMainString//"LogInMain"
            break
        default:
            return
        }
        let vc = storyboard.instantiateViewController(withIdentifier: screenName) as UIViewController
        self.present(vc, animated: true, completion: nil)
    }
}
