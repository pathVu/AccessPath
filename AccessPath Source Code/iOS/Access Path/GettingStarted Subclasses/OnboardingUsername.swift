//
//  FullTermsOfAgreement.swift
//  Access Path
//
//  Created by Nick Sinagra on 5/14/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit

/**
 * Allows the user to change their account username during the onboarding process
 * They can only change once during the onboarding process.
 */
class OnboardingUsername: UIViewController, UITextFieldDelegate {
    
    //UI Outlets
    @IBOutlet weak var usernameTextBox: CustomTextBox!
    @IBOutlet weak var editUsernameBtn: UIButton!
    @IBOutlet weak var usernameStatus: UILabel!
    @IBOutlet weak var clearUsernameButton: UIButton!
    @IBOutlet weak var clearUsernameIcon: UIImageView!
    @IBOutlet weak var usernameGoodIcon: UIImageView!
    @IBOutlet weak var usernameBadIcon: UIImageView!
    
    //Shared Preferences
    let preferences = UserDefaults.standard
    
    //PHP Class Instance
    let pathVuPHP = PHPCalls()
    
    //Input Validation Variables
    var originalUsername:String = ""
    var usernameValid = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setStyles()
        loadValues()
        
        //If the user has not visited a later screen, set this as the highest screen reached
        if(preferences.integer(forKey: PrefKeys.onboardProgKey) < 5) {
            preferences.set(5, forKey: PrefKeys.onboardProgKey)
        }
        
        //Only allow the user to set username once per onboarding process
        //They can change it later in settings
        if(preferences.bool(forKey: PrefKeys.usernameSetKey)) {
            editUsernameBtn.isEnabled = false
            editUsernameBtn.layer.borderColor = AppColors.disabledBorder.cgColor
            editUsernameBtn.layer.backgroundColor = AppColors.disabledBackground.cgColor
            editUsernameBtn.setTitleColor(AppColors.disabledBorder, for: .normal)
        }
    }
    
    /**
     * Sets the initial style for the username text box
     */
    func setStyles() {
        usernameTextBox.isEnabled = false
        usernameTextBox.tintColor = AppColors.caretColor
        usernameTextBox.layer.borderWidth = 1.5
        usernameTextBox.layer.borderColor = AppColors.darkBlue.cgColor
        usernameTextBox.delegate = self
        
        clearUsernameIcon.isHidden = true
        clearUsernameButton.isHidden = true
        usernameGoodIcon.isHidden = true
        usernameBadIcon.isHidden = true
    }
    
    /**
     * Button handler for setting the username
     * Handles input validation and submission
     */
    @IBAction func setUsername(_ sender: Any) {
        let username = usernameTextBox.text!
        if(username != originalUsername) {
            if(preferences.string(forKey: PrefKeys.usernameSetKey) == nil) {
                checkValues()
                if(usernameValid) {
                    let UidValue = preferences.string(forKey: PrefKeys.uidKey ?? "")
                    let uid = preferences.string(forKey: UidValue ?? "")
                    if(pathVuPHP.changeUsername(uusername:usernameTextBox.text!, uid:uid ?? "")) {
                        preferences.set(username, forKey: PrefKeys.usernameKey)
                        preferences.set(true, forKey: PrefKeys.usernameSetKey)
                        let storyboard = UIStoryboard(name: StoryboardIdentifier.gettingStarted1Storyboard, bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.onboardingComfortSetMainIdentifier) as UIViewController
                        self.present(vc, animated: true, completion: nil)
                    } else {
                        //username probably already exists
                        print("Username error")
                        usernameTextBox.layer.borderColor = AppColors.errorBorder.cgColor
                        usernameTextBox.layer.borderWidth = 10
                        usernameStatus.text = AlertConstant.usernameAlreadyExist
                        usernameStatus.textColor = AppColors.errorBorder
                        usernameGoodIcon.isHidden = true
                        usernameBadIcon.isHidden = false
                        clearUsernameIcon.isHidden = true
                        clearUsernameButton.isHidden = true
                    }
                }
            } else {
                let storyboard = UIStoryboard(name: StoryboardIdentifier.gettingStarted1Storyboard, bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.onboardingComfortSetMainIdentifier) as UIViewController
                self.present(vc, animated: true, completion: nil)
            }
        }
        else {
            preferences.set(usernameTextBox.text!, forKey: PrefKeys.usernameKey)
            preferences.set(true, forKey: PrefKeys.usernameSetKey)
            let storyboard = UIStoryboard(name: StoryboardIdentifier.gettingStarted1Storyboard, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.onboardingComfortSetMainIdentifier) as UIViewController
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    /**
     * Button handler for the edit username button
     */
    @IBAction func editUsernameBtnPressed(_ sender: Any) {
        usernameTextBox.isEnabled = true
        usernameTextBox.becomeFirstResponder()
    }
    
    /**
     * Button handler for the clear username button
     */
    @IBAction func clearUsernameBox(_ sender: Any) {
        usernameTextBox.text = ""
    }
    
    /**
     * What happens when the user clicks off of a text field
     * Will defocus the text field being currently edited
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    /**
     * What happens when the user starts editing a text field
     */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentlyEditing(textField: textField)
    }
    
    /**
     * What happens when the user stops editing a text field
     */
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        clearUsernameIcon.isHidden = true
        clearUsernameButton.isHidden = true
        checkValues()
        
    }
    
    /**
     * Sets the style of the text box being currently edited by the user
     */
    func currentlyEditing(textField : UITextField) {
        usernameTextBox.layer.borderWidth = 10
        usernameTextBox.layer.borderColor = AppColors.darkBlue.cgColor
        usernameTextBox.layer.backgroundColor = UIColor.white.cgColor
        usernameStatus.text = ""
        usernameGoodIcon.isHidden = true
        usernameBadIcon.isHidden = true
        clearUsernameIcon.isHidden = false
        clearUsernameButton.isHidden = false
    }
    
    /**
     * Checks if the username entered is valid.
     * Paramaters: username must contain greater than 2 characters, usernames must not already exist
     * TODO: CHECK IF USERNAME ALREADY EXISTS
     */
    func checkValues() {
        if(usernameTextBox.text!.count >= 2) {
            usernameTextBox.layer.borderColor = AppColors.successBorder.cgColor
            usernameTextBox.layer.backgroundColor = AppColors.successBackground.cgColor
            usernameStatus.textColor = AppColors.successBorder
            usernameStatus.text = AlertConstant.looksGood
            usernameGoodIcon.isHidden = false
            usernameValid = true
            
        } else {
            usernameTextBox.layer.borderColor = AppColors.errorBorder.cgColor
            usernameTextBox.layer.borderWidth = 10
            usernameStatus.textColor = AppColors.errorBorder
            usernameStatus.text = AlertConstant.usernameCharacterTwoMoreChar
            usernameBadIcon.isHidden = false
            usernameValid = false
        }
    }
    
    /**
     * Load automatically generated username assigned by the server
     * Username will be first name + last initial + unique id
     */
    func loadValues() {
        var username:String = ""
        /*
         Created by Chetu
         */
        if(preferences.object(forKey: PrefKeys.usernameKey) == nil) {
            //If username username value is nil, generate default username from PHP
            let uidValue = preferences.string(forKey: PrefKeys.uidKey)
            if(preferences.bool(forKey: PrefKeys.guestAccountKey)){
                if(!pathVuPHP.getGuestUsername(acctid: uidValue ?? "")){
                    username = ""
                }
                else {
                    username = preferences.string(forKey: PrefKeys.usernameKey)!
                }
            }
            else if(!pathVuPHP.getUsername(uid: uidValue ?? "")) {
                
                //If there is a PHP error for some reason, we'll use the user's first name and last initial
                //There is no guarantee that this default username is available
                let firstName = preferences.string(forKey: PrefKeys.firstNameKey)
                let lastName = preferences.string(forKey: PrefKeys.lastNameKey)
                
                username = firstName! + String((lastName?.first)!)
                preferences.set(username, forKey: PrefKeys.usernameKey)
            } else {
                username = preferences.string(forKey: PrefKeys.usernameKey)!
            }
        } else {
            username = preferences.string(forKey: PrefKeys.usernameKey)!
        }
        originalUsername = username
        usernameTextBox.text = username
    }
    
    //Go back to last screen
    @IBAction func dismissView(_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
