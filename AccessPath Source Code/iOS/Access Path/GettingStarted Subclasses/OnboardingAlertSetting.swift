//
//  OnboardingAlertSetting.swift
//  Access Path
//
//  Created by Nick Sinagra on 6/19/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit

/**
 * This class is a dynamic class for changing alert settings.
 * The type of alert depends on the value passed to this class.
 * This class simply saves the alert value to shared preferences.
 */
class OnboardingAlertSetting: UIViewController {
    var comfortChooseValue = Int()
    //UI Outlets
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var alertOnButton: UIButton!
    @IBOutlet weak var alertOffButton: UIButton!
    @IBOutlet weak var alertOnCheckmark: UIImageView!
    @IBOutlet weak var alertOffCheckmark: UIImageView!
    
    //Shared Preferences
    let preferences = UserDefaults.standard
    var key = ""
    var alertSetting = 1
    
    //Hazard type will be passed to this class
    var type = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get the type of hazard and load it
        type = preferences.integer(forKey: settingTypeString)
        if type != 0 {
            return
        }
        loadType()
        getUserRouteAlertSettingTypeValue()
    }
    
    
    /**
     * Alert On Button Handler
     */
    @IBAction func alertOnButtonPressed(_ sender: Any) {
        alertSetting = 1
        setSelected(selectedButton: alertOnButton!)
        alertOnCheckmark.isHidden = false
    }
    
    
    /**
     * Alert Off Button Handler
     */
    @IBAction func alertOffButtonPressed(_ sender: Any) {
        alertSetting = 0
        setSelected(selectedButton: alertOffButton!)
        alertOffCheckmark.isHidden = false
    }
    
    
    /**
     * Saves the setting into shared preferences
     */
    @IBAction func saveButtonPressed(_ sender: Any) {
        saveData()
    }
    
    /**
     * Sets a button to the default white color
     */
    func setDefaultButtonStyles(btn: UIButton) {
        btn.layer.backgroundColor = UIColor.white.cgColor
        btn.layer.cornerRadius = 5
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = AppColors.defaultBorder.cgColor
    }
    
    /**
     * Sets a checkmark to be hidden
     */
    func setDefaultCheckmarkStyles(checkmark: UIImageView) {
        checkmark.isHidden = true
    }
    
    /**
     * Sets the style of the currently selected button
     * Clears the styles of the unselected buttons
     */
    func setSelected(selectedButton: UIButton) {
        
        //Button array
        let buttons = [alertOnButton, alertOffButton]
        
        //Checkmark array
        let checkmarks = [alertOnCheckmark, alertOffCheckmark]
        
        //Set all buttons to their default style
        for btn in buttons {
            setDefaultButtonStyles(btn: btn!)
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
     * Saves the user's selected alert setting
     * This happens after every button press
     */
    func saveData() {
        savedUserRouteAlertTypeValue(alertSetting:alertSetting)
        let saveStatus = preferences.synchronize()
        if(!saveStatus){
            print("Error saving settings")
        }
    }
    
    
    // Changed By Chetu
    //add Type value get set tick and untick uncomfortable,comfortable
    func getUserRouteAlertSettingTypeValue(){
        
        switch type {
        case 0:
            key = PrefKeys.thAlertKey
            titleText.text = trippingHazardString
            descriptionText.text = wouldYouLikeReceiveStringTH
            //thAlert
            if let thvalue =  preferences.value(forKey:PrefKeys.thAlertKeyValue)  {
                comfortChooseValue = thvalue as! Int
            }
            else{
                comfortChooseValue = 1
                
            }
            alertSetting = comfortChooseValue
            self.loadDataGetAlertValuemethod(alertSetting:alertSetting)
            break
            
        case 1:
            key = PrefKeys.rAlertKey
            titleText.text = alert
            descriptionText.text = wouldYouLikeReceiveStringRough
            //rAlert
            if let thvalue =  preferences.value(forKey:PrefKeys.rAlertKeyValue)  {
                comfortChooseValue = thvalue as! Int
            }
            else{
                comfortChooseValue = 1
            }
            alertSetting = comfortChooseValue
            self.loadDataGetAlertValuemethod(alertSetting:alertSetting)
            break
            
        case 2:
            key = PrefKeys.rsAlertKey
            titleText.text = runningSlopeString
            descriptionText.text = wouldYouLikeReceiveStringSlop
            //rsAlert
            if let thvalue =  preferences.value(forKey:PrefKeys.rsAlertKeyValue)  {
                comfortChooseValue = thvalue as! Int
            }
            else{
                comfortChooseValue = 1
            }
            alertSetting = comfortChooseValue
            self.loadDataGetAlertValuemethod(alertSetting:alertSetting)
            break
            
        case 3:
            key = PrefKeys.csAlertKey
            titleText.text = crossSlopAlertString
            descriptionText.text = wouldYouLikeReceiveStringCross
            //csAlert
            if let thvalue =  preferences.value(forKey: PrefKeys.csAlertKeyValue)  {
                comfortChooseValue = thvalue as! Int
            }
            else{
                comfortChooseValue = 1
            }
            alertSetting = comfortChooseValue
            self.loadDataGetAlertValuemethod(alertSetting:alertSetting)
            break
            
        case 4:
            key = PrefKeys.crAlertKey
            titleText.text = curbRampAlertString
            descriptionText.text = wouldYouLikeReceiveStringCurbRamp
            //crAlert
            if let thvalue =  preferences.value(forKey: PrefKeys.crAlertKeyValue)  {
                comfortChooseValue = thvalue as! Int
            }
            else{
                comfortChooseValue = 1
            }
            alertSetting = comfortChooseValue
            self.loadDataGetAlertValuemethod(alertSetting:alertSetting)
            break
            
        case 5:
            key = PrefKeys.wAlertKey
            titleText.text = widthAlertString
            descriptionText.text = wouldYouLikeReceiveStringWidth
            
            //wAlert
            if let thvalue =  preferences.value(forKey: PrefKeys.wAlertKeyValue)  {
                comfortChooseValue = thvalue as! Int
            }
            else{
                comfortChooseValue = 1
            }
            alertSetting = comfortChooseValue
            self.loadDataGetAlertValuemethod(alertSetting:alertSetting)
            break
            
        case 6:
            key = PrefKeys.soAlertKey
            titleText.text = obstructiobAlertString
            descriptionText.text = wouldYouLikeReceiveStringObstruction
            //soAlert
            if let thvalue =  preferences.value(forKey: PrefKeys.soAlertKeyValue)  {
                comfortChooseValue = thvalue as! Int
            }
            else{
                comfortChooseValue = 1
                
            }
            alertSetting = comfortChooseValue
            self.loadDataGetAlertValuemethod(alertSetting:alertSetting)
            break
            
        case 7:
            key = PrefKeys.iAlertKey
            titleText.text = instructionAlertString
            descriptionText.text = wouldYouLikeReceiveStringInstruction
            //iAlert
            if let thvalue =  preferences.value(forKey: PrefKeys.iAlertKeyValue)  {
                comfortChooseValue = thvalue as! Int
            }
            else{
                comfortChooseValue = 1
            }
            alertSetting = comfortChooseValue
            self.loadDataGetAlertValuemethod(alertSetting:alertSetting)
            break
            
        default:
            break
        }
    }
    
    
    /**
     * Loads the user's alert setting if it has previously been set.
     * If it has been set, the correct button is highlighted to reflect their alert setting.
     * If it has not been set, nothing happens and the all buttons are their default style.
     */
    // Changed By Chetu
    //add Type value get loadDataGetAlertaluemethod set tick and untick uncomfortable,comfortable
    func loadDataGetAlertValuemethod(alertSetting:Int) {
        switch alertSetting {
        case 1:
            setSelected(selectedButton: alertOnButton)
            alertOnCheckmark.isHidden = false
            break
        case 0:
            setSelected(selectedButton: alertOffButton)
            alertOffCheckmark.isHidden = false
            break
        default:
            break
        }
    }
    
    
    
    // Changed By Chetu
    // add Alert Type value pass
    func savedUserRouteAlertTypeValue(alertSetting:Int){
        
        switch type {
        case 0:
            key = PrefKeys.thAlertKey
            titleText.text = trippingHazardString
            descriptionText.text = wouldYouLikeReceiveStringTH
            preferences.setValue(alertSetting, forKey: PrefKeys.thAlertKeyValue)
            break
            
        case 1:
            key = PrefKeys.rAlertKey
            titleText.text = alert
            descriptionText.text = wouldYouLikeReceiveStringRough
            preferences.setValue(alertSetting, forKey: PrefKeys.rAlertKeyValue)
            break
            
        case 2:
            key = PrefKeys.rsAlertKey
            titleText.text = runningSlopeString
            descriptionText.text = wouldYouLikeReceiveStringSlop
            preferences.setValue(alertSetting, forKey: PrefKeys.rsAlertKeyValue)
            break
            
        case 3:
            key = PrefKeys.csAlertKey
            titleText.text = crossSlopAlertString
            descriptionText.text = wouldYouLikeReceiveStringCross
            preferences.setValue(alertSetting, forKey: PrefKeys.csAlertKeyValue)
            break
            
            /**
             *case4 removed from comfort setting
             case 4:
             key = PrefKeys.crAlertKey
             titleText.text = curbRampAlertString
             descriptionText.text = wouldYouLikeReceiveStringCurbRamp
             preferences.setValue(alertSetting, forKey: PrefKeys.crAlertKeyValue)
             break
             */
            
        case 5:
            key = PrefKeys.wAlertKey
            titleText.text = widthAlertString
            descriptionText.text = wouldYouLikeReceiveStringWidth
            preferences.setValue(alertSetting, forKey: PrefKeys.wAlertKeyValue)
            break
            
            /**
             *case 6 & 7 removed from comfort setting
             case 6:
             key = PrefKeys.soAlertKey
             titleText.text = obstructiobAlertString
             descriptionText.text = wouldYouLikeReceiveStringObstruction
             preferences.setValue(alertSetting, forKey: PrefKeys.soAlertKeyValue)
             break
             
             case 7:
             key = PrefKeys.iAlertKey
             titleText.text = instructionAlertString
             descriptionText.text = wouldYouLikeReceiveStringInstruction
             preferences.setValue(alertSetting, forKey: PrefKeys.iAlertKeyValue)
             break
             */
            
        default:
            break
        }
    }
    
    
    /**
     * Loads the user's alert setting if it has previously been set.
     * If it has been set, the correct button is highlighted to reflect their alert setting.
     * If it has not been set, nothing happens and the all buttons are their default style.
     */
    func loadData() {
        if(preferences.object(forKey: key) != nil) {
            alertSetting = preferences.integer(forKey: key)
        }
        
        switch alertSetting {
        case 1:
            setSelected(selectedButton: alertOnButton)
            alertOnCheckmark.isHidden = false
            break
        case 0:
            setSelected(selectedButton: alertOffButton)
            alertOffCheckmark.isHidden = false
            break
        default:
            break
        }
    }
    
    
    /**
     * Sets the button text depending on the hazard type
     */
    func setButtonText(hazardType: String) {
        alertOnButton.setTitle("\(turnOn) " + hazardType, for: .normal)
        alertOffButton.setTitle("\(turnOff) " + hazardType, for: .normal)
    }
    
    
    /**
     * Load which obstruction type the user is changing the setting for
     * based on what they chose on the obstruction list.
     */
    func loadType() {
        switch type {
        case 0:
            key = PrefKeys.thAlertKey
            titleText.text = trippingHazardString
            descriptionText.text = wouldYouLikeReceiveStringTH
            setButtonText(hazardType: trippingHazardButton)
            break
            
        case 1:
            key = PrefKeys.rAlertKey
            titleText.text = alert
            descriptionText.text = wouldYouLikeReceiveStringRough
            setButtonText(hazardType: roughnessButton)
            break
            
        case 2:
            key = PrefKeys.rsAlertKey
            titleText.text = runningSlopeString
            descriptionText.text = wouldYouLikeReceiveStringSlop
            setButtonText(hazardType: runningSlopButton)
            break
            
        case 3:
            key = PrefKeys.csAlertKey
            titleText.text = crossSlopAlertString
            descriptionText.text = wouldYouLikeReceiveStringCross
            setButtonText(hazardType: crossSlopButton)
            break
            /**
             *case 4 removed from comfort setting
             
             case 4:
             key = PrefKeys.crAlertKey
             titleText.text = curbRampAlertString
             descriptionText.text = wouldYouLikeReceiveStringCurbRamp
             setButtonText(hazardType: curbRampButton)
             break
             */
            
        case 5:
            key = PrefKeys.wAlertKey
            titleText.text = widthAlertString
            descriptionText.text = wouldYouLikeReceiveStringWidth
            setButtonText(hazardType: widthButton)
            break
            
            /**
             *case 6 & 7 removed from comfort setting
             
             case 6:
             key = PrefKeys.soAlertKey
             titleText.text = obstructiobAlertString
             descriptionText.text = wouldYouLikeReceiveStringObstruction
             setButtonText(hazardType: obstructionButton)
             break
             
             case 7:
             key = PrefKeys.iAlertKey
             titleText.text = instructionAlertString
             descriptionText.text = wouldYouLikeReceiveStringInstruction
             setButtonText(hazardType: instructiionButton)
             break
             */
            
        default:
            break
        }
    }
    
    //Go back to previous screen
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Return to obstruction list
    @IBAction func cancelAndReturnToObstructionList(_ sender: Any) {
        performSegue(withIdentifier: StoryboardIdentifier.onboardingObstructionList, sender: self)
    }
}
