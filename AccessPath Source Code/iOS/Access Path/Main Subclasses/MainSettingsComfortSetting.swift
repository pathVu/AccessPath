//
//  MainComfortLevel.swift
//  Access Path
//
//  Created by Nick Sinagra on 5/25/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit

/**
 * Dynamic class for setting comfort settings
 * Type will change based on value received
 */
class MainSettingsComfortSetting: UIViewController {
    var comfortChooseValue = Int()
    //UI Outlets
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    
    @IBOutlet weak var veryUncomfortableButton: UIButton!
    @IBOutlet weak var mostlyComfortableButton: UIButton!
    @IBOutlet weak var veryComfortableButton: UIButton!
    @IBOutlet weak var completelyComfortableButton: UIButton!
    
    @IBOutlet weak var veryUncomfortableCheckmark: UIImageView!
    @IBOutlet weak var mostlyComfortableCheckmark: UIImageView!
    @IBOutlet weak var veryComfortableCheckmark: UIImageView!
    @IBOutlet weak var completelyComfortableCheckmark: UIImageView!
    
    //Shared Preferences
    var key = ""
    let preferences = UserDefaults.standard
    var comfortLevel = 0
    
    //Type will be passed to this class
    var type = -1
    
    
    @IBOutlet weak var continueBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttons = [veryUncomfortableButton, mostlyComfortableButton, veryComfortableButton, completelyComfortableButton]
        let checkmarks = [veryUncomfortableCheckmark, mostlyComfortableCheckmark, veryComfortableCheckmark, completelyComfortableCheckmark]
        
        //Set the default style for each button (white w/ dark blue border)
        for button in buttons {
            setDefaultButtonStyles(button: button!)
        }
        
        //Sets the default style for chechmarkts (hidden)
        for checkmark in checkmarks {
            setDefaultCheckmarkStyles(checkmark: checkmark!)
        }
        
        //Get the type received and then load it
        type = preferences.integer(forKey: PrefKeys.settingsTypeKey)
        loadType()
        getUserRouteComfortableTypeValue()
        
    }
    
    //Save the user's setting
    @IBAction func continueButtonPressed(_ sender: Any) {
        //By default 0 already worked using segue

        if type == 1 {
            saveData()
            self.dismiss(animated: true, completion: nil)
        }
        else if type == 2 {
             saveData()
             self.dismiss(animated: true, completion: nil)
        }
        else if type == 3 {
             saveData()
            self.dismiss(animated: true, completion: nil)
        }
        else if type == 5 {
             saveData()
            self.dismiss(animated: true, completion: nil)
        }
        else {
            saveData()
        }
    }
    
    /**
     * Very Uncomfortable Button Handler
     */
    @IBAction func veryUncomfortableButtonPressed(_ sender:Any) {
        comfortLevel = 1 //4 Change and comment by Chetu
        setSelected(selectedButton: veryUncomfortableButton!)
        veryUncomfortableCheckmark.isHidden = false
    }
    
    /**
     * Mostly Comfortable Button Handler
     */
    @IBAction func mostlyComfortableButtonPressed(_ sender:Any) {
        comfortLevel = 2 //3 Change and comment by Chetu
        setSelected(selectedButton: mostlyComfortableButton!)
        mostlyComfortableCheckmark.isHidden = false
    }
    
    /**
     * Very Comfortable Button Handler
     */
    @IBAction func veryComfortableButtonPressed(_ sender:Any) {
        comfortLevel = 3 //2 Change and comment by Chetu
        setSelected(selectedButton: veryComfortableButton!)
        veryComfortableCheckmark.isHidden = false
    }
    
    /**
     * Completely Comfortable Button Handler
     */
    @IBAction func completelyComfortableButtonPressed(_ sender:Any) {
        comfortLevel = 4 //1  Change and comment by Chetu
        setSelected(selectedButton: completelyComfortableButton!)
        completelyComfortableCheckmark.isHidden = false
    }
    
    /**
     * Sets a button to the default white style
     */
    func setDefaultButtonStyles(button: UIButton) {
        button.layer.backgroundColor = UIColor.white.cgColor
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1.5
        button.layer.borderColor = AppColors.defaultBorder.cgColor
    }
    
    //Set default checkmark styles
    func setDefaultCheckmarkStyles(checkmark: UIImageView) {
        checkmark.isHidden = true
    }
    
    /**
     * Sets the style of the currently selected button
     * Clears the styles of the unselected buttons
     */
    func setSelected(selectedButton: UIButton) {
        
        //Button array
        let buttons = [veryUncomfortableButton, mostlyComfortableButton, veryComfortableButton, completelyComfortableButton]
        
        //Checkmark array
        let checkmarks = [veryUncomfortableCheckmark, mostlyComfortableCheckmark, veryComfortableCheckmark, completelyComfortableCheckmark]
        
        //Set all buttons to their default style
        for button in buttons {
            setDefaultButtonStyles(button: button!)
        }
        
        //Set all checkmarks to their default style
        for checkmark in checkmarks {
            setDefaultCheckmarkStyles(checkmark: checkmark!)
        }
        //Set the border and background colors of selected button
        selectedButton.layer.borderColor = AppColors.selectedBorder.cgColor
        selectedButton.layer.backgroundColor = AppColors.selectedBackground.cgColor
    }
    
    
    /**
     * Saves the user's selected comfort level
     * This happens after every button press
     */
    func saveData() {
        //add  save prefernce comfortable value
        savedUserRouteComfortableTypeValue(comfortLevel:comfortLevel)
        let saveStatus = preferences.synchronize()
        if(!saveStatus){
            print("Error saving settings")
        }
    }
    
    /**
     * Loads the user's setting if it has previously been set.
     * If it has been set, the correct button is highlighted to reflect their comfort level.
     * If it has not been set, nothing happens and the all buttons are their default style.
     */
    func loadData() {
        if(preferences.object(forKey: key) != nil) {
            comfortLevel = preferences.integer(forKey: key)
        }
        switch comfortLevel {
        case 1:
            setSelected(selectedButton: completelyComfortableButton)
            completelyComfortableCheckmark.isHidden = false
            break
        case 2:
            setSelected(selectedButton: veryComfortableButton)
            veryComfortableCheckmark.isHidden = false
            break
        case 3:
            setSelected(selectedButton: mostlyComfortableButton)
            mostlyComfortableCheckmark.isHidden = false
            break
        case 4:
            setSelected(selectedButton: veryUncomfortableButton)
            veryUncomfortableCheckmark.isHidden = false
            break
        default:
            break
        }
    }
    
    
    /**
     * Changed by Chetu
     * Reverse order of comfort button setting
     */
    func loadDataGetComfortValuemethod(comfortLevel:Int) {
        switch comfortLevel {
        case 1:
            setSelected(selectedButton: veryUncomfortableButton)
            veryUncomfortableCheckmark.isHidden = false
            break
        case 2:
            setSelected(selectedButton: mostlyComfortableButton)
            mostlyComfortableCheckmark.isHidden = false
            break
        case 3:
            setSelected(selectedButton: veryComfortableButton)
            veryComfortableCheckmark.isHidden = false
            break
        case 4:
            setSelected(selectedButton: completelyComfortableButton)
            completelyComfortableCheckmark.isHidden = false
            break
        default:
            break
        }
    }
    
    
    // Changed By Chetu
    // add Type value get set tick and untick uncomfortable,comfortable
    func getUserRouteComfortableTypeValue(){
        
        switch type {
        case 0:
            key = PrefKeys.thComfortKey
            titleText.text = thComfortLevelString
            descriptionText.text = comfortLevelStringTH
            //th
            if let thvalue =  preferences.value(forKey:PrefKeys.thComfortKeyValue)  {
                comfortChooseValue = thvalue as! Int
            }
            else{
                comfortChooseValue = 1
            }
            comfortLevel = comfortChooseValue
            self.loadDataGetComfortValuemethod(comfortLevel:comfortChooseValue)
            break
            
            
        case 1:
            key = PrefKeys.rComfortKey
            titleText.text = roughnessComfortString
            descriptionText.text = roughnessLevelStringRS
            //r
            if let thvalue =  preferences.value(forKey:PrefKeys.rComfortKeyValue)  {
                comfortChooseValue = thvalue as! Int
            }
            else{
                comfortChooseValue = 1
            }
            comfortLevel = comfortChooseValue
            self.loadDataGetComfortValuemethod(comfortLevel:comfortLevel)
            break
            
            
        case 2:
            key = PrefKeys.rsComfortKey
            titleText.text = runSlopComfortLevelString
            descriptionText.text = comfortLevelStringRSlop
            //rs
            if let thvalue =  preferences.value(forKey:PrefKeys.rsComfortKeyValue)  {
                comfortChooseValue = thvalue as! Int
            }
            else{
                comfortChooseValue = 1
            }
            comfortLevel = comfortChooseValue
            self.loadDataGetComfortValuemethod(comfortLevel:comfortLevel)
            break
            
        case 3:
            key = PrefKeys.csComfortKey
            titleText.text = crossComfortLevelString
            descriptionText.text = comfortLevelStringCrossSlop
            //cs
            if let thvalue =   preferences.value(forKey:PrefKeys.csComfortKeyValue) {
                comfortChooseValue = thvalue as! Int
            }
            else{
                comfortChooseValue = 1
            }
            comfortLevel = comfortChooseValue
            self.loadDataGetComfortValuemethod(comfortLevel:comfortLevel)
            break
            
        case 4:
            key = PrefKeys.crComfortKey
            titleText.text = curbRampComfortLevelString
            descriptionText.text = comfortLevelStringCR
            // cr
            if let thvalue =  preferences.value(forKey:PrefKeys.crComfortKeyValue) {
                comfortChooseValue = thvalue as! Int
            }
            else{
                comfortChooseValue = 1
            }
            comfortLevel = comfortChooseValue
            self.loadDataGetComfortValuemethod(comfortLevel:comfortLevel)
            break
            
        case 5:
            key = PrefKeys.wComfortKey
            titleText.text = wComfort
            descriptionText.text = comfortLevelStringWC
            // w
            if let thvalue =  preferences.value(forKey:PrefKeys.wComfortKeyValue) {
                comfortChooseValue = thvalue as! Int
            }
            else{
                comfortChooseValue = 1
            }
            comfortLevel = comfortChooseValue
            self.loadDataGetComfortValuemethod(comfortLevel:comfortLevel)
            break
            
        case 6:
            key = PrefKeys.soAlertKey
            titleText.text = obstructionComfortLevelString
            descriptionText.text = comfortLevelStringObstruction
            // so
            if let thvalue =  preferences.value(forKey:PrefKeys.soComfortKeyValue) {
                comfortChooseValue = thvalue as! Int
                
            }
            else{
                comfortChooseValue = 1
            }
            comfortLevel = comfortChooseValue
            self.loadDataGetComfortValuemethod(comfortLevel:comfortLevel)
            break
            
        case 7:
            key = PrefKeys.iComfortKey
            titleText.text = instructionComfortLevelString
            descriptionText.text = comfortLevelStringInstruction
            // i
            if let thvalue =  preferences.value(forKey:PrefKeys.iComfortKeyValue) {
                comfortChooseValue = thvalue as! Int
            }
            else{
                comfortChooseValue = 1
            }
            comfortLevel = comfortChooseValue
            self.loadDataGetComfortValuemethod(comfortLevel:comfortLevel)
            break
        default:
            break
        }
    }
    
    /**
     * Changed by Chetu
     * Save Comfort and uncomfort type values
     */
    func savedUserRouteComfortableTypeValue(comfortLevel:Int){
        
        switch type {
        case 0:
            key = PrefKeys.thComfortKey
            titleText.text = thComfortLevelString
            descriptionText.text = comfortLevelStringTH
            preferences.setValue(comfortLevel, forKey:PrefKeys.thComfortKeyValue)
            break
            
        case 1:
            key = PrefKeys.rComfortKey
            titleText.text = roughnessComfortString
            descriptionText.text = roughnessLevelStringRS
            preferences.setValue(comfortLevel, forKey:PrefKeys.rComfortKeyValue)
            break
            
        case 2:
            key = PrefKeys.rsComfortKey
            titleText.text = runSlopComfortLevelString
            descriptionText.text = comfortLevelStringRSlop
            preferences.setValue(comfortLevel, forKey:PrefKeys.rsComfortKeyValue)
            break
            
        case 3:
            key = PrefKeys.csComfortKey
            titleText.text = crossComfortLevelString
            descriptionText.text = comfortLevelStringCrossSlop
            preferences.setValue(comfortLevel, forKey:PrefKeys.csComfortKeyValue)
            
            break
            /**
             *case 4 removed from comfort setting
 
        case 4:
            key = PrefKeys.crComfortKey
            titleText.text = curbRampComfortLevelString
            descriptionText.text = comfortLevelStringCR
            preferences.setValue(comfortLevel, forKey:PrefKeys.crComfortKeyValue)
            break
             */
            
        case 5:
            key = PrefKeys.wComfortKey
            titleText.text = wComfort
            descriptionText.text = comfortLevelStringWC
            preferences.setValue(comfortLevel, forKey:PrefKeys.wComfortKeyValue)
            break
            
    /**
        *case 6 & 7 removed from comfort setting
 
        case 6:
            key = PrefKeys.soAlertKey
            titleText.text = obstructionComfortLevelString
            descriptionText.text = comfortLevelStringObstruction
            preferences.setValue(comfortLevel, forKey:PrefKeys.soComfortKeyValue)
            break
            
        case 7:
            key = PrefKeys.iComfortKey
            titleText.text = instructionComfortLevelString
            descriptionText.text = comfortLevelStringInstruction
            preferences.setValue(comfortLevel, forKey:PrefKeys.iComfortKeyValue)
            break
        */
        default:
            break
        }
    }
    
    
    
    /**
     * Load which obstruction type the user is changing the setting for
     * based on what they chose on the obstruction list.
     */
    func loadType()
    {
        switch type {
        case 0:
            continueBtn.setTitle(setContinueAlert, for: .normal) //set title continue button
            key = PrefKeys.thComfortKey
            titleText.text = thComfortLevelString
            descriptionText.text = comfortLevelStringTH
            break
            
        case 1:
            continueBtn.setTitle(titleContinue, for: .normal) //set title continue button
            key = PrefKeys.rComfortKey
            titleText.text = roughnessComfortString
            descriptionText.text = roughnessLevelStringRS
            break
            
        case 2:
            continueBtn.setTitle(titleContinue, for: .normal) //set title continue button
            key = PrefKeys.rsComfortKey
            titleText.text = runSlopComfortLevelString
            descriptionText.text = comfortLevelStringRSlop
            break
            
        case 3:
            continueBtn.setTitle(titleContinue, for: .normal) //set title continue button
            key = PrefKeys.csComfortKey
            titleText.text = crossComfortLevelString
            descriptionText.text = comfortLevelStringCrossSlop
            break
            
        case 4:
            key = PrefKeys.crComfortKey
            titleText.text = curbRampComfortLevelString
            descriptionText.text = comfortLevelStringCR
            break
            
        case 5:
            continueBtn.setTitle(titleContinue, for: .normal) //set title continue button
            key = PrefKeys.wComfortKey
            titleText.text = wComfort
            descriptionText.text = comfortLevelStringWC
            break
            
        case 6:
            key = PrefKeys.soAlertKey
            titleText.text = obstructionComfortLevelString
            descriptionText.text = comfortLevelStringObstruction
            break
            
        case 7:
            key = PrefKeys.iComfortKey
            titleText.text = instructionComfortLevelString
            descriptionText.text = comfortLevelStringInstruction
            break
            
        default:
            break
        }
    }
    
    //Go back to previous screen
    @IBAction func dismissView(_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

