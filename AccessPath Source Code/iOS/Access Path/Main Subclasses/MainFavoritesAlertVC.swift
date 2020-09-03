//
//  MainFavoritesAlertVC.swift
//  Access Path
//
//  Created by Chetu on 3/25/19.
//  Copyright © 2019 pathVu. All rights reserved.
//

import UIKit

class MainFavoritesAlertVC: UIViewController {

    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var alertOnButton: UIButton!
    @IBOutlet weak var alertOffButton: UIButton!
    @IBOutlet weak var alertOnCheckmark: UIImageView!
    @IBOutlet weak var alertOffCheckmark: UIImageView!
    
    //Shared Preferences
    let preferences = UserDefaults.standard
    var key = ""
    var alertSetting = 1
    
    //favorite type will be passed to this class
    var type = 1
    var comfortChooseValue = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //Get the type of hazard and load it
        type = 0
        debugPrint("dismiss alert view")
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
            debugPrint("Error saving settings")
        }
    }
    
    // Changed By Chetu
    //add Alert Type value pass
    func savedUserRouteAlertTypeValue(alertSetting:Int){
        
        switch type {
        case 0:
            key = PrefKeys.thAlertKey
            preferences.setValue(alertSetting, forKey: PrefKeys.favoritePlaceAlertKey)
            break
            
        case 1:
            key = PrefKeys.rAlertKey
            preferences.setValue(alertSetting, forKey: PrefKeys.rAlertKeyValue)
            break
            
        case 2:
            key = PrefKeys.rsAlertKey
           // titleText.text = runningSlopeString
            //descriptionText.text = wouldYouLikeReceiveStringSlop
            preferences.setValue(alertSetting, forKey: PrefKeys.rsAlertKeyValue)
            break
            
        case 3:
            key = PrefKeys.csAlertKey
           // titleText.text = crossSlopAlertString
            //descriptionText.text = wouldYouLikeReceiveStringCross
            preferences.setValue(alertSetting, forKey: PrefKeys.csAlertKeyValue)
            break
            
        case 5:
            key = PrefKeys.wAlertKey
           // titleText.text = widthAlertString
            //descriptionText.text = wouldYouLikeReceiveStringWidth
            preferences.setValue(alertSetting, forKey: PrefKeys.wAlertKeyValue)
            break
            
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    // Changed By Chetu
    //add Type value get set tick and untick uncomfortable,comfortable
    func getUserRouteAlertSettingTypeValue(){
        
        switch type {
        case 0:
            key = PrefKeys.thAlertKey
            if let thvalue =  preferences.value(forKey:PrefKeys.favoritePlaceAlertKey)  {
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
            //titleText.text = alert
            //descriptionText.text = wouldYouLikeReceiveStringRough
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
           // titleText.text = runningSlopeString
            //descriptionText.text = wouldYouLikeReceiveStringSlop
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
            //titleText.text = crossSlopAlertString
            //descriptionText.text = wouldYouLikeReceiveStringCross
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
            
        //Case 4 code is disabled from comfort setting so this is not working
        case 4:
            key = PrefKeys.crAlertKey
            //titleText.text = curbRampAlertString
            //descriptionText.text = wouldYouLikeReceiveStringCurbRamp
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
            //titleText.text = widthAlertString
            //descriptionText.text = wouldYouLikeReceiveStringWidth
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
            
        //Case 6 & 7 is disabled from comfort setting so this is not working
        case 6:
            key = PrefKeys.soAlertKey
           // titleText.text = obstructiobAlertString
            //descriptionText.text = wouldYouLikeReceiveStringObstruction
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
            //titleText.text = instructionAlertString
            //descriptionText.text = wouldYouLikeReceiveStringInstruction
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
    
    /**
     * Saves the setting into shared preferences
     */
    @IBAction func saveButtonPressed(_ sender: Any) {
        saveData()
    }
    
    
    /**
     * Sets the button text depending on the hazard type
     */
    func setButtonText(hazardType: String) {
        alertOnButton.setTitle(FavoriteAlertType.favoriteAlertON, for: .normal)
        alertOffButton.setTitle(FavoriteAlertType.favoriteAlertOff, for: .normal)
    }
    
    /**
     * Load which obstruction type the user is changing the setting for
     * based on what they chose on the obstruction list.
     */
    func loadType() {
        switch type {
        case 0:
            key = PrefKeys.thAlertKey
           // titleText.text = trippingHazardString
            //descriptionText.text = wouldYouLikeReceiveStringTH
            setButtonText(hazardType: trippingHazardButton)
            break
            
        case 1:
            key = PrefKeys.rAlertKey
           // titleText.text = alert
            //descriptionText.text = wouldYouLikeReceiveStringRough
            setButtonText(hazardType: roughnessButton)
            break
            
        case 2:
            key = PrefKeys.rsAlertKey
           // titleText.text = runningSlopeString
            //descriptionText.text = wouldYouLikeReceiveStringSlop
            setButtonText(hazardType: runningSlopButton)
            break
            
        case 3:
            key = PrefKeys.csAlertKey
            //titleText.text = crossSlopAlertString
            //descriptionText.text = wouldYouLikeReceiveStringCross
            setButtonText(hazardType: crossSlopButton)
            break
            
        case 5:
            key = PrefKeys.wAlertKey
           // titleText.text = widthAlertString
            //descriptionText.text = wouldYouLikeReceiveStringWidth
            setButtonText(hazardType: widthButton)
            break

        default:
            break
        }
    }
    
    
    //Go back to previous screen from cancel button
    @IBAction func dismissView(_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Return to obstruction list
    @IBAction func cancelButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: StoryboardIdentifier.unwindToObstructionList, sender: self)
        //self.dismiss(animated: true, completion: nil)
    }
}
