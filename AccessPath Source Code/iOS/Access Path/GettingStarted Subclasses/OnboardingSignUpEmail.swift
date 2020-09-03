//
//  InitialPage.swift
//  CustomStylesTest
//
//  Created by Nick Sinagra on 5/11/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit

/**
 * This class is used for signing up with a name and email address
 */
class OnboardingSignUpEmail: UIViewController, UITextFieldDelegate {
    
    //UI Outlets
    //Text Fields
    @IBOutlet weak var firstNameBox: CustomTextBox!
    @IBOutlet weak var lastNameBox: CustomTextBox!
    @IBOutlet weak var emailBox: CustomTextBox!
    @IBOutlet weak var passwordBox: CustomTextBox!
    
    //Status Labels
    @IBOutlet weak var firstNameStatus: UILabel!
    @IBOutlet weak var lastNameStatus: UILabel!
    @IBOutlet weak var emailStatus: UILabel!
    @IBOutlet weak var passwordStatus: UILabel!
    
    //Buttons
    @IBOutlet weak var validateButton: UIButton!
    @IBOutlet weak var validateButtonArrow: UIImageView!
    
    //Textbox Indicators
    @IBOutlet weak var firstNameCheck: UIImageView!
    @IBOutlet weak var lastNameCheck: UIImageView!
    @IBOutlet weak var emailCheck: UIImageView!
    @IBOutlet weak var passwordCheck: UIImageView!
    
    @IBOutlet weak var firstNameError: UIImageView!
    @IBOutlet weak var lastNameError: UIImageView!
    @IBOutlet weak var emailError: UIImageView!
    @IBOutlet weak var passwordError: UIImageView!
    
    @IBOutlet weak var firstNameClear: UIImageView!
    @IBOutlet weak var lastNameClear: UIImageView!
    @IBOutlet weak var emailClear: UIImageView!
    @IBOutlet weak var passwordClear: UIImageView!
    
    @IBOutlet weak var firstNameClearButton: UIButton!
    @IBOutlet weak var lastNameClearButton: UIButton!
    @IBOutlet weak var emailClearButton: UIButton!
    @IBOutlet weak var passwordClearButton: UIButton!
    
    //Shared Preferences
    let preferences = UserDefaults.standard
    
    //Input Validation Variables
    var allValid:Bool = false
    var phpEmailError = false
    var emailErrorMessage = ""
    var badEmail = ""
    
    //PHP Calls Class Instance
    let pathVuPHP = PHPCalls()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Set up initial textbox styles and delegate
        let boxes = [firstNameBox, lastNameBox, emailBox, passwordBox]
        for box in boxes {
            box?.tintColor = AppColors.caretColor
            box?.layer.borderWidth = 1.5
            box?.layer.borderColor = AppColors.darkBlue.cgColor
            box?.delegate = self
        }
        let indicators = [firstNameCheck, lastNameCheck, emailCheck, passwordCheck, firstNameError, lastNameError, emailError, passwordError, firstNameClear, lastNameClear, emailClear, passwordClear]
        
        for indicator in indicators {
            indicator!.isHidden = true
        }
        let clearBtns = [firstNameClearButton, lastNameClearButton, emailClearButton, passwordClearButton]
        for btn in clearBtns {
            btn?.isHidden = true
        }
        //Load Globals if Set from SharedData
        loadValues()
        
        //If the user has not visited a later screen, set this as the highest screen reached
        if(preferences.integer(forKey: PrefKeys.onboardProgKey) < 4) {
            preferences.set(4, forKey: PrefKeys.onboardProgKey)
        }
        checkValues()
    }
    
    
    /**
     * When the user hits the return key on the keyboard, it defocuses the text box and closes the keyboard.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    /**
     * What happens when the user clicks outside of a text box
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    
    /**
     * What happens when the user begins editing a text box
     */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentlyEditing(textField: textField)
    }
    
    
    /**
     * What happens when the user stops editing a text box
     */
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
        firstNameClear.isHidden = true
        lastNameClear.isHidden = true
        emailClear.isHidden = true
        passwordClear.isHidden = true
        
        firstNameClearButton.isHidden = true
        lastNameClearButton.isHidden = true
        emailClearButton.isHidden = true
        passwordClearButton.isHidden = true
        
        checkValues()
    }
    
    
    /**
     * Button handler for clearing the first name field
     */
    @IBAction func clearFirstNameBox(_ sender: Any) {
        firstNameBox.text = ""
    }
    
    
    /**
     * Button handler for clearing the last name field
     */
    @IBAction func clearLastNameBox(_ sender: Any) {
        lastNameBox.text = ""
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
        
        if(textField == firstNameBox) {
            firstNameBox.layer.borderWidth = 10
            firstNameBox.layer.borderColor = AppColors.darkBlue.cgColor
            firstNameBox.layer.backgroundColor = UIColor.white.cgColor
            firstNameStatus.text = ""
            
            firstNameCheck.isHidden = true
            firstNameError.isHidden = true
            
            firstNameClear.isHidden = false
            firstNameClearButton.isHidden = false
        }
        
        if(textField == lastNameBox) {
            lastNameBox.layer.borderWidth = 10
            lastNameBox.layer.borderColor = AppColors.darkBlue.cgColor
            lastNameBox.layer.backgroundColor = UIColor.white.cgColor
            lastNameStatus.text = ""
            
            lastNameCheck.isHidden = true
            lastNameError.isHidden = true
            
            lastNameClear.isHidden = false
            lastNameClearButton.isHidden = false
        }
        
        if(textField == emailBox) {
            phpEmailError = false
            emailBox.layer.borderWidth = 10
            emailBox.layer.borderColor = AppColors.darkBlue.cgColor
            emailBox.layer.backgroundColor = UIColor.white.cgColor
            emailCheck.isHidden = true
            emailError.isHidden = true
            emailStatus.text = ""
            
            emailClear.isHidden = false
            emailClearButton.isHidden = false
        }
        
        if(textField == passwordBox) {
            //firstNameHeight.constant = 0
            
            passwordBox.layer.borderWidth = 10
            passwordBox.layer.borderColor = AppColors.darkBlue.cgColor
            passwordBox.layer.backgroundColor = UIColor.white.cgColor
            passwordStatus.text = ""
            
            passwordCheck.isHidden = true
            passwordError.isHidden = true
            
            passwordClear.isHidden = false
            passwordClearButton.isHidden = false
        }
    }
    
    
    /**
     * This function performs the initial input validation, using the following parameters:
     *      - First name must contain more than one character
     *      - Last name must contain more than one character
     *      - Email address must be a valid email address
     *      - Password must contain at least 6 characters
     * If a textView contains no characters, the style is restored to the default as when the view first opened.
     * The styles of each box and their status messages will be changed depending on if they are valid or not
     */
    func checkValues() {
        
        var firstNameValid : Bool = false
        var lastNameValid : Bool = false
        var emailValid : Bool = false
        var passwordValid : Bool = false
        
        //Validate first name textField
        if(firstNameBox.text!.count > 0) {
            firstNameBox.layer.borderWidth = 10
            firstNameBox.layer.borderColor = AppColors.successBorder.cgColor
            firstNameBox.layer.backgroundColor = AppColors.successBackground.cgColor
            firstNameStatus.textColor = AppColors.successBorder
            firstNameStatus.text = AlertConstant.looksGood
            firstNameValid = true
            firstNameCheck.isHidden = false
        } else {
            firstNameBox.layer.borderColor = AppColors.darkBlue.cgColor
            firstNameBox.layer.borderWidth = 1.5
            firstNameStatus.text = ""
            firstNameValid = false
        }
        
        //Validate last name textField
        if(lastNameBox.text!.count > 0) {
            lastNameBox.layer.borderWidth = 10
            lastNameBox.layer.borderColor = AppColors.successBorder.cgColor
            lastNameBox.layer.backgroundColor = AppColors.successBackground.cgColor
            lastNameStatus.textColor = AppColors.successBorder
            lastNameStatus.text = AlertConstant.looksGood
            lastNameValid = true
            lastNameCheck.isHidden = false
        } else {
            lastNameBox.layer.borderColor = AppColors.darkBlue.cgColor
            lastNameBox.layer.borderWidth = 1.5
            lastNameStatus.text = ""
            lastNameValid = false
        }
        
        //Validate email textField
        if(!phpEmailError && emailBox.text != badEmail) { //If the php response changed email status text, keep it until edited
            if(isValidEmail(emailString: emailBox.text!)) {
                emailBox.layer.borderWidth = 10
                emailBox.layer.borderColor = AppColors.successBorder.cgColor
                emailBox.layer.backgroundColor = AppColors.successBackground.cgColor
                emailStatus.textColor = AppColors.successBorder
                emailStatus.text = AlertConstant.looksGood
                emailValid = true
                emailCheck.isHidden = false
            } else {
                if(emailBox.text!.count > 0) {
                    emailBox.layer.borderWidth = 10
                    emailBox.layer.borderColor = AppColors.errorBorder.cgColor
                    emailBox.layer.backgroundColor = AppColors.errorBackground.cgColor
                    emailStatus.textColor = AppColors.errorBorder
                    emailStatus.text = AlertConstant.pleaseEnterCorrectEmailAdd
                    emailError.isHidden = false
                } else {
                    emailBox.layer.borderColor = AppColors.darkBlue.cgColor
                    emailBox.layer.borderWidth = 1.5
                    emailStatus.text = ""
                }
                
                emailValid = false
            }
        } else {
            if(emailBox.text!.count > 0) {
                emailBox.layer.borderColor = AppColors.errorBorder.cgColor
                emailBox.layer.backgroundColor = AppColors.errorBackground.cgColor
                emailStatus.textColor = AppColors.errorBorder
                emailStatus.text = emailErrorMessage
                emailError.isHidden = false
            } else {
                emailBox.layer.borderColor = AppColors.darkBlue.cgColor
                emailBox.layer.borderWidth = 1.5
                emailStatus.text = ""
            }
        }
        
        //Validate password textField
        if(passwordBox.text!.count >= 6) {
            passwordBox.layer.borderWidth = 10
            passwordBox.layer.borderColor = AppColors.successBorder.cgColor
            passwordBox.layer.backgroundColor = AppColors.successBackground.cgColor
            passwordStatus.textColor = AppColors.successBorder
            passwordStatus.text = AlertConstant.looksGood
            passwordValid = true
            passwordCheck.isHidden = false
        } else {
            if(passwordBox.text!.count > 0) {
                passwordBox.layer.borderWidth = 10
                passwordBox.layer.borderColor = AppColors.errorBorder.cgColor
                passwordBox.layer.backgroundColor = AppColors.errorBackground.cgColor
                passwordStatus.textColor = AppColors.errorBorder
                passwordStatus.text = passwordMustContainMoreCharacter
                passwordError.isHidden = false
            } else {
                passwordBox.layer.borderColor = AppColors.darkBlue.cgColor
                passwordBox.layer.borderWidth = 1.5
                passwordStatus.text = ""
            }
            passwordValid = false
        }
        
        if(firstNameValid && lastNameValid && emailValid && passwordValid) {
            validateButton.isEnabled = true
            validateButton.layer.backgroundColor = AppColors.caretColor.cgColor
            validateButton.layer.borderColor = AppColors.darkBlue.cgColor
            validateButton.setTitleColor(AppColors.darkBlue, for: .normal)
            
            allValid = true
        } else {
            validateButton.isEnabled = false
            validateButton.layer.backgroundColor = AppColors.disabledBackground.cgColor
            validateButton.layer.borderColor = AppColors.disabledBorder.cgColor
            validateButton.setTitleColor(AppColors.disabledBorder, for: .normal)
            
            allValid = false
        }
        
        saveValues()
    }
    
    /**
     * This function checks if a given string is a valid email
     * It will try to find a template similar to [name]@[domain].[extension]
     * by checking for valid characters for each field.
     * Returns TRUE for a valid email
     * Returns FALSE for an invalid email
     */
    func isValidEmail(emailString:String) -> Bool {
        let emailRegEx = ValidEmailFormattor.validFormat
        let emailTest = NSPredicate(format:ValidEmailFormattor.selfMatchString, emailRegEx)
        return emailTest.evaluate(with: emailString)
    }
    
    /**
     * Button handler for the submit button
     * On sign up success the user will proceed to the username screen
     * On failure, the user will be alerted to why it failed
     */
    @IBAction func submitBtnPressed(_ sender: Any) {
        view.endEditing(true)
        if(allValid) {
            let firstName = firstNameBox.text!
            let lastName = lastNameBox.text!
            let email = emailBox.text!
            let password = passwordBox.text!
            
            let status = pathVuPHP.emailSignUp(firstName:firstName, lastName:lastName, email:email, password:password)
            
            //Each case represents a value returned by the PHP page.
            switch status {
            case 1:
                //Complete success
                if let aid = preferences.string(forKey: PrefKeys.aidKey) {
                    let storyboard = UIStoryboard(name: StoryboardIdentifier.gettingStarted1Storyboard, bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.onboardingUserNameScreen) as UIViewController
                    self.present(vc, animated: true, completion: nil)
                } else {
                    print("Error Getting Unique ID")
                }
                break
            case 2:
                //Account already exists
                phpEmailError = true
                badEmail = email
                emailBox.layer.borderColor = AppColors.errorBorder.cgColor
                emailStatus.textColor = AppColors.errorBorder
                emailErrorMessage = AlertConstant.accountAlreadyExists
                emailStatus.text = emailErrorMessage
                emailCheck.isHidden = true
                emailError.isHidden = false
                break
            case 5:
                // Error signing up
                break
            default:
                print("Unexpected error signing up via email.")
                break
            }
        }
    }
    
    /**
     * This function loads values from the SharedData instance file if the user
     * has previously set values for the textboxes.
     */
    func loadValues() {
        if(preferences.object(forKey: PrefKeys.firstNameKey) != nil) {
            firstNameBox.text = preferences.string(forKey: PrefKeys.firstNameKey)
        } else {
            firstNameBox.text = ""
        }
        
        if(preferences.object(forKey: PrefKeys.lastNameKey) != nil) {
            lastNameBox.text = preferences.string(forKey: PrefKeys.lastNameKey)
        } else {
            lastNameBox.text = ""
        }
        
        if(preferences.object(forKey: PrefKeys.emailKey) != nil) {
            emailBox.text = preferences.string(forKey: PrefKeys.emailKey)
        } else {
            emailBox.text = ""
        }
        
        if(preferences.object(forKey: PrefKeys.passwordKey) != nil) {
            passwordBox.text = preferences.string(forKey: PrefKeys.passwordKey)
        } else {
            passwordBox.text = ""
        }
        
        checkValues()
        
    }
    
    /**
     * This function saves values to preferences when a user is finished editing the text box
     */
    func saveValues() {
        preferences.setValue(firstNameBox.text!, forKey: PrefKeys.firstNameKey)
        preferences.setValue(lastNameBox.text!, forKey: PrefKeys.lastNameKey)
        preferences.setValue(emailBox.text!, forKey: PrefKeys.emailKey)
        preferences.setValue(passwordBox.text!, forKey: PrefKeys.passwordKey)
        
        let didSave = preferences.synchronize()
        
        if(!didSave) {
            print("Settings could not be saved")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissView(_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
