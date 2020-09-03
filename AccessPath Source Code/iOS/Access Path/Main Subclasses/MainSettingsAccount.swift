//
//  AccountSettings.swift
//  Access Path
//
//  Created by Nick Sinagra on 5/25/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit

/**
 * This screen shows basic account info such as username and account ID.
 * The user can change their username from here.
 */
class MainSettingsAccount : UIViewController, UITextFieldDelegate {
    
    //UI Outlets
    @IBOutlet weak var usernameTextBox: CustomTextBox!
    @IBOutlet weak var usernameStatus: UILabel!
    @IBOutlet weak var clearUsernameButton: UIButton!
    @IBOutlet weak var clearUsernameIcon: UIImageView!
    @IBOutlet weak var usernameGoodIcon: UIImageView!
    @IBOutlet weak var usernameBadIcon: UIImageView!
    @IBOutlet weak var aidLabel: UILabel!
    
    //Shared Preferences
    let preferences = UserDefaults.standard
    
    //PHP Class Instance
    let pathVuPHP = PHPCalls()
    
    //Input Validation Variables
    var originalUsername:String = ""
    var usernameValid = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set account ID label
        aidLabel.text = "ID: " + preferences.string(forKey: PrefKeys.aidKey)!
        
        //Set default styles of text boxes and buttons
        setStyles()
        
        //Load username
        loadValues()
    }
    
    
    
    /**
     * Sets the initial style for the username text box
     */
    func setStyles() {
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
     * Save the username to the server
     */
    @IBAction func saveSettingsButtonPressed(_ sender: Any) {
        setUsername()
    }
    
    
    
    /**
     * Function for setting the username
     */
    func setUsername() {
        let username = usernameTextBox.text!
        if(username != originalUsername) {
            checkValues()
            if(usernameValid) {
                let uid = preferences.string(forKey: PrefKeys.uidKey)!
                if(pathVuPHP.changeUsername(uusername:usernameTextBox.text!, uid:uid)) {
                    usernameStatus.text = AlertConstant.userNameChangedSuccesfully
                    debugPrint("Username successfully changed")
                    self.dismiss(animated: true, completion: nil)
                }
                else {
                    //username probably already exists
                    debugPrint("Username error")
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
            preferences.set(usernameTextBox.text!, forKey: PrefKeys.usernameKey)
            preferences.set(true, forKey: PrefKeys.usernameSet)
        }
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
            if(usernameTextBox.text!.count == 0) {
                usernameTextBox.text = originalUsername
                usernameTextBox.layer.borderColor = AppColors.darkBlue.cgColor
                usernameTextBox.layer.borderWidth = 1.5
                usernameStatus.text = ""
                usernameValid = false
            } else {
                usernameTextBox.layer.borderColor = AppColors.errorBorder.cgColor
                usernameTextBox.layer.borderWidth = 10
                usernameStatus.textColor = AppColors.errorBorder
                usernameStatus.text = AlertConstant.usernameCharacterTwoMoreChar
                usernameBadIcon.isHidden = false
                usernameValid = false
            }
        }
    }
    
    
    /**
     * Load automatically generated username based on the user's first and last name entered on previous screen.
     * Username will be first name + last initial
     */
    func loadValues() {
        var username:String = ""
        
        if(preferences.object(forKey: PrefKeys.usernameKey) == nil) {
            
            print(preferences.string(forKey: PrefKeys.uidKey))
            
            //If username username value is nil, generate default username from PHP
            if(!pathVuPHP.getUsername(uid: preferences.string(forKey: PrefKeys.uidKey)!)) {
                
                //If there is a PHP error for some reason, we'll use the user's first name and last initial
                //There is no guarantee that this default username is available
                let firstName = preferences.string(forKey: PrefKeys.firstNameKey)
                let lastName = preferences.string(forKey: PrefKeys.lastNameKey)
                
                username = firstName! + String((lastName?.first)!)
                preferences.set(username, forKey: PrefKeys.usernameKey)
            }
            else {
                username = preferences.string(forKey: PrefKeys.usernameKey)!
            }
        }
        else {
            username = preferences.string(forKey: PrefKeys.usernameKey)!
        }
        originalUsername = username
        usernameTextBox.text = username
    }
    
    //Go back to previous screen
    @IBAction func dismissView(_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
