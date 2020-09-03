//
//  ForgotPasswordScreen.swift
//  Access Path
//
//  Created by Nick Sinagra on 7/5/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit

/**
 * The user will use this page to enter their email.
 * An email will be sent to them so they can reset their password.
 */
class OnboardingForgotPassword:UIViewController,  UITextFieldDelegate {
    
    //UI Outlets
    @IBOutlet weak var emailBox: CustomTextBox!
    @IBOutlet weak var emailClearButton: UIButton!
    @IBOutlet weak var emailErrorIcon: UIImageView!
    @IBOutlet weak var emailClearIcon: UIImageView!
    @IBOutlet weak var emailCheckIcon: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    
    
    //Input Validation Variables
    var emailValid = false
    var phpEmailError = false
    var emailErrorMessage = ""
    var badEmail = ""
    
    //PHP Calls Class Instance
    let pathVuPHP = PHPCalls()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set default styles
        emailBox.tintColor = AppColors.caretColor
        emailBox.layer.borderWidth = 1.5
        emailBox.layer.borderColor = AppColors.darkBlue.cgColor
        emailBox.delegate = self
        
        emailCheckIcon.isHidden = true
        emailErrorIcon.isHidden = true
        emailClearIcon.isHidden = true
        emailClearButton.isHidden = true
    }
    
    //Clears the email box on press
    @IBAction func emailClearButtonPressed(_ sender: Any) {
        emailBox.text = ""
    }
    
    
    //Submits user's email to the server
    @IBAction func submitButtonPressed(_ sender: Any) {
        
        checkValues()
        
        if(emailValid) {
            emailBox.isEnabled = false
            emailLabel.text = ""
            let email = emailBox.text ?? ""
            print(email.lowercased())
            let response = pathVuPHP.forgotPassword(email: email.lowercased())
            //emailLabel.text = response as? String
            processDict(response: response as? String ?? "")
        }
        
    }
    
    
    func processDict(response:String) {
    
            switch response {
            case UserGestNumber.sentMessage:
                emailLabel.text = UserGestNumber.sentResetMessage
                //setPasswordError(error: UserGestNumber.incorrectPWD)
                break
                
            case UserGestNumber.accountNotFound:
                //emailLabel.text = UserGestNumber.accountDontExist
                setEmailError(error: UserGestNumber.accountDontExist)
                break
            case UserGestNumber.incorrectPassword:
                emailLabel.text = UserGestNumber.incorrectPWD
                //setPasswordError(error: UserGestNumber.incorrectPWD)
                break
            default:
                break
            }
            return
        //}
    }
    
    //Sets the email box colors and error message if there is an issue with the email
    func setEmailError(error: String) {
        emailBox.layer.borderWidth = 10
        emailBox.layer.borderColor = AppColors.errorBorder.cgColor
        emailBox.layer.backgroundColor = AppColors.errorBackground.cgColor
        emailLabel.textColor = AppColors.errorBorder
        emailLabel.text = error
        emailLabel.isHidden = false
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
        emailClearIcon.isHidden = true
        emailClearButton.isHidden = true
        
        checkValues()
    }
    
    
    //Perform input validation
    func checkValues() {
        
        //Validate email textField
        //If the PHP returned an error and the user did not change the text box, we don't have to check
        if(!phpEmailError && emailBox.text != badEmail) {
            if(isValidEmail(emailString: emailBox.text!)) {
                emailBox.layer.borderWidth = 10
                emailBox.layer.borderColor = AppColors.successBorder.cgColor
                emailBox.layer.backgroundColor = AppColors.successBackground.cgColor
                emailLabel.textColor = AppColors.successBorder
                emailLabel.text = AlertConstant.looksGood
                emailCheckIcon.isHidden = false
                emailValid = true
            } else {
                if(emailBox.text!.count > 0) {
                    emailBox.layer.borderWidth = 10
                    emailBox.layer.borderColor = AppColors.errorBorder.cgColor
                    emailBox.layer.backgroundColor = AppColors.errorBackground.cgColor
                    emailLabel.textColor = AppColors.errorBorder
                    emailLabel.text = AlertConstant.pleaseEnterCorrectEmailAdd
                    emailErrorIcon.isHidden = false
                } else {
                    emailBox.layer.borderColor = AppColors.darkBlue.cgColor
                    emailBox.layer.borderWidth = 1.5
                    emailLabel.text = ""
                }
                emailValid = false
            }
        } else {
            if(emailBox.text!.count > 0) {
                emailBox.layer.borderColor = AppColors.errorBorder.cgColor
                emailBox.layer.backgroundColor = AppColors.errorBackground.cgColor
                emailLabel.textColor = AppColors.errorBorder
                emailLabel.text = emailErrorMessage
                emailErrorIcon.isHidden = false
            } else {
                emailBox.layer.borderColor = AppColors.darkBlue.cgColor
                emailBox.layer.borderWidth = 1.5
                emailLabel.text = ""
            }
            emailValid = false
        }
    }
    
    //Set styles for the textbox on edit
    func currentlyEditing(textField : UITextField) {
        
        if(textField == emailBox) {
            phpEmailError = false       //reset invalid email error
            emailBox.layer.borderWidth = 10
            emailBox.layer.borderColor = AppColors.darkBlue.cgColor
            emailBox.layer.backgroundColor = UIColor.white.cgColor
            emailCheckIcon.isHidden = true
            emailErrorIcon.isHidden = true
            emailLabel.text = ""
            
            emailClearIcon.isHidden = false
            emailClearButton.isHidden = false
        }
    }
    
    /**
     * This function checks if a given string is a valid email
     * It will try to find a template similar to [name]@[domain].[tld]
     * by checking for valid characters for each field.
     * Returns TRUE for a valid email
     * Returns FALSE for an invalid email
     */
    func isValidEmail(emailString:String) -> Bool {
        let emailRegEx = ValidEmailFormattor.validFormat
        let emailTest = NSPredicate(format:ValidEmailFormattor.selfMatchString, emailRegEx)
        return emailTest.evaluate(with: emailString)
    }
    
    //Go back to previous screen
    @IBAction func dismissView(_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
