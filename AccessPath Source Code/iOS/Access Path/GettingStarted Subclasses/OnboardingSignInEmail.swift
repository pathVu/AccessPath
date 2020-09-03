//
//  LogInScreen.swift
//  Access Path
//
//  Created by Nick Sinagra on 5/21/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit
import SwiftyJSON

/**
 * Class for signing in with an email or password
 */
class OnboardingSignInEmail: UIViewController, UITextFieldDelegate {
    
    //UI Outlets
    //Text Fields
    @IBOutlet weak var emailBox: CustomTextBox!
    @IBOutlet weak var passwordBox: CustomTextBox!
    
    //Text Field Elements
    @IBOutlet weak var emailError: UIImageView!
    @IBOutlet weak var emailClear: UIImageView!
    @IBOutlet weak var passwordError: UIImageView!
    @IBOutlet weak var passwordClear: UIImageView!
    @IBOutlet weak var emailClearBtn: UIButton!
    @IBOutlet weak var passwordClearBtn: UIButton!
    
    //Text Field Statuses
    @IBOutlet weak var emailStatus: UILabel!
    @IBOutlet weak var passwordStatus: UILabel!
    
    //Buttons
    @IBOutlet weak var logInButton: UIButton!
    
    //Input Validation Variables
    var allValid = false
    
    //Local Saved Data
    let preferences = UserDefaults.standard
    
    //PHP Calls Class Instance
    let pathVuPHP = PHPCalls()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //If the user has not visited a later screen, set this as the highest screen reached
        if(preferences.integer(forKey: PrefKeys.onboardProgKey) < 9) {
            preferences.set(9, forKey: PrefKeys.onboardProgKey)
        }
        
        setStyles()
    }
    
    /**
     * Set the initial styles of the text fields
     */
    func setStyles() {
        let boxes = [emailBox, passwordBox]
        for box in boxes {
            box?.tintColor = AppColors.caretColor
            box?.layer.borderWidth = 1.5
            box?.layer.borderColor = AppColors.darkBlue.cgColor
            box?.delegate = self
        }
        
        let indicators = [emailError, emailClear, passwordError, passwordClear]
        
        for indicator in indicators {
            indicator?.isHidden = true
        }
        
        let clearBtns = [emailClearBtn, passwordClearBtn]
        
        for btn in clearBtns {
            btn?.isHidden = true
        }
    }
    
    /**
     * What happens when the user clicks outside of a text field
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    /**
     * What happens when the user begins editing a text field
     */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentlyEditing(textField: textField)
    }
    
    /**
     * What happens when the user stops editing a text field
     */
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
        emailClear.isHidden = true
        passwordClear.isHidden = true
        
        emailClearBtn.isHidden = true
        passwordClearBtn.isHidden = true
        
        checkValues()
    }
    
    /**
     * Button handler for clearing the email field
     */
    @IBAction func clearEmailBox(_ sender: Any) {
        emailBox.text = ""
    }
    
    /**
     * Button handler for clearing the password field
     */
    @IBAction func clearPasswordBox(_ sender: Any) {
        passwordBox.text = ""
    }
    
    /**
     * If the user is editing a textField, this function sets the style to the normal editing style and removes
     * the status message. For example, if the password the user enters is less than 6 characters, the checkValues()
     * function turns the box red and sets the status message to display the error. This function will turn the
     * box back to blue like when the user was first editing the textView, and remove the status message. Once the user
     * is finished editing, the checkValues() function will changed the style of the textView again.
     */
    func currentlyEditing(textField : UITextField) {
        
        if(textField == emailBox) {
            emailBox.layer.borderWidth = 10
            emailBox.layer.borderColor = AppColors.darkBlue.cgColor
            emailBox.layer.backgroundColor = UIColor.white.cgColor
            emailError.isHidden = true
            emailClear.isHidden = false
            emailClearBtn.isHidden = false
            emailStatus.text = ""
        }
        
        if(textField == passwordBox) {
            passwordBox.layer.borderWidth = 10
            passwordBox.layer.borderColor = AppColors.darkBlue.cgColor
            passwordBox.layer.backgroundColor = UIColor.white.cgColor
            passwordError.isHidden = true
            passwordClear.isHidden = false
            passwordClearBtn.isHidden = false
            passwordStatus.text = ""
        }
    }
    
    /**
     * This function performs the initial input validation, using the following parameters:
     *      - Email address must be a valid email address
     *      - Password must contain at least 6 characters
     * If a textView contains no characters, the style is restored to the default as when the view first opened.
     * The styles of each box and their status messages will be changed depending on if they are valid or not
     */
    func checkValues() {
        var emailValid = false
        var passwordValid = false
        
        if(isValidEmail(emailString: emailBox.text!)) {
            emailBox.layer.borderWidth = 1.5
            emailStatus.text = ""
            emailValid = true
        } else {
            if(emailBox.text!.count > 0) {
                setEmailError(error: AlertConstant.pleaseEnterCorrectEmailAdd)
            } else {
                emailBox.layer.borderColor = AppColors.darkBlue.cgColor
                emailBox.layer.borderWidth = 1.5
                emailStatus.text = ""
            }
            emailValid = false
        }
        
        if(passwordBox.text!.count >= 6) {
            passwordBox.layer.borderWidth = 1.5
            passwordStatus.text = ""
            passwordValid = true
        } else {
            if(passwordBox.text!.count > 0) {
                setPasswordError(error: passwordMustContainMoreCharacter)
            } else {
                passwordBox.layer.borderColor = AppColors.darkBlue.cgColor
                passwordBox.layer.borderWidth = 1.5
                passwordStatus.text = ""
            }
            passwordValid = false
        }
        if(emailValid && passwordValid) {
            allValid = true
        } else {
            allValid = false
        }
    }
    
    
    /**
     * Button handler for the log in button
     */
    @IBAction func logInBtnPressed(_ sender: Any) {
        view.endEditing(true)
        checkValues()
        
        if(allValid) {
            let email = emailBox.text
            let password = passwordBox.text
            let status = pathVuPHP.signInWithEmail(email: email!, password: password!)
            switch (status) {
            case 1:
                if let settings = self.pathVuPHP.getSettings(uacctid: String(self.preferences.string(forKey: PrefKeys.aidKey) ?? "")) {
                    self.processDict(response: settings)
                }
                else {
                    print("Error getting settings")
                }
            case 2:
                setEmailError(error: UserGestNumber.accountDontExist)
                break
            case 3:
                setPasswordError(error: UserGestNumber.incorrectPWD)
                break
            default:
                print("Unexpected error logging in with email")
                break
            }
        }
    }
    
    //Process comfort and alert settings returned from server
    //and put them into shared preferences
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
            
            // pathVuPHP.checkActivation(aid: String(self.preferences.integer(forKey: PrefKeys.aidKey)))
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
    
    //Sets the email box colors and error message if there is an issue with the email
    func setEmailError(error: String) {
        emailBox.layer.borderWidth = 10
        emailBox.layer.borderColor = AppColors.errorBorder.cgColor
        emailBox.layer.backgroundColor = AppColors.errorBackground.cgColor
        emailStatus.textColor = AppColors.errorBorder
        emailStatus.text = error
        emailError.isHidden = false
    }
    
    //Sets the password box colors and error message if there is an issue with the password
    func setPasswordError(error: String) {
        passwordBox.layer.borderWidth = 10
        passwordBox.layer.borderColor = AppColors.errorBorder.cgColor
        passwordBox.layer.backgroundColor = AppColors.errorBackground.cgColor
        passwordStatus.textColor = AppColors.errorBorder
        passwordStatus.text = error
        passwordError.isHidden = false
    }
    
    /**
     * Checks if a string is a valid email by pattern-matching
     */
    func isValidEmail(emailString:String) -> Bool {
        let emailRegEx = ValidEmailFormattor.validFormat
        let emailTest = NSPredicate(format:ValidEmailFormattor.selfMatchString, emailRegEx)
        return emailTest.evaluate(with: emailString)
    }
    
    //Return to the last screen
    @IBAction func dismissView(_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
