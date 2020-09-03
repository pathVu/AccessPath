//
//  SelectPresetScreen.swift
//  Access Path
//
//  Created by Nick Sinagra on 5/14/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit

/**
 * Class for selecting a user type
 */
class OnboardingProfilePresets: UIViewController {
    
    //UI Outlets
    //Buttons
    @IBOutlet weak var blindOrVisuallyImpairedButton: UIButton!
    @IBOutlet weak var sightedAndWalkingButton: UIButton!
    @IBOutlet weak var wheelchairOrScooterButton: UIButton!
    @IBOutlet weak var caneOrWalkerButton: UIButton!
    @IBOutlet weak var approveButton: UIButton!
    
    //Checkmarks
    @IBOutlet weak var blindOrVisuallyImpairedCheckmark: UIImageView!
    @IBOutlet weak var sightedAndWalkingCheckmark: UIImageView!
    @IBOutlet weak var wheelchairOrScooterCheckmark: UIImageView!
    @IBOutlet weak var caneOrWalkerCheckmark: UIImageView!
    
    //Shared Preferences
    let preferences = UserDefaults.standard
    
    //PHP Calls class instance
    let pathVuPHP = PHPCalls()
    
    //User type ID
    var presetNumber = 0
    
    
    //add getting prefernce value save for roughness obstruction type and type values
    var thComfortKeyValue = 0
    var rComfortKeyValue = 0
    var rsComfortKeyValue = 0
    var csComfortKeyValue = 0
    var crComfortKeyValue = 0
    var wComfortKeyValue = 0
    var soComfortKeyValue = 0
    var iComfortKeyValue = 0
    
    //add alert values getting prefernce value save for roughness obstruction type
    
    var thAlertKeyValue = 0
    var rAlertKeyValue = 0
    var rsAlertKeyValue = 0
    var csAlertKeyValue = 0
    var crAlertKeyValue = 0
    var wAlertKeyValue = 0
    var  soAlertKeyValue = 0
    var iAlertKeyValue = 0
    
    var userTypeLevel = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //All alerts will be on by default
        for key in PrefKeys.alertKeys {
            preferences.set(1, forKey: key)
        }
        self.getSettingsObstructionValueMethod()
        getSettingsObstructionAlertValueMethod()
        setStyles()
    }
    
    //Set default styles for buttons
    func setStyles() {
        let buttons = [blindOrVisuallyImpairedButton, sightedAndWalkingButton, wheelchairOrScooterButton, caneOrWalkerButton]
        
        let checkmarks = [blindOrVisuallyImpairedCheckmark, sightedAndWalkingCheckmark, wheelchairOrScooterCheckmark, caneOrWalkerCheckmark]
        
        for btn in buttons {
            setDefaultButtonStyles(button: btn!)
        }
        
        for checkmark in checkmarks {
            setDefaultCheckmarkStyles(checkmark: checkmark!)
        }
        
        approveButton.isEnabled = false
        approveButton.layer.backgroundColor = AppColors.disabledBackground.cgColor
        approveButton.layer.borderColor = AppColors.disabledBorder.cgColor
        approveButton.setTitleColor(AppColors.disabledBorder, for: .normal)
    }
    
    /*  Created by Chetu
     setting changes for  obstruction  comfort value saved prefernce values
     */
    
    func getSettingsObstructionValueMethod(){
        
        //th
        if let thvalue = preferences.value(forKey:PrefKeys.thComfortKeyValue)  {
            thComfortKeyValue = thvalue as! Int
        }
        else{
            thComfortKeyValue = 1
        }
        // r
        if let rvalue = preferences.value(forKey:PrefKeys.rComfortKeyValue) {
            rComfortKeyValue = rvalue as! Int
        }
        else{
            rComfortKeyValue = 1
        }
        // rs
        if let rsvalue = preferences.value(forKey:PrefKeys.rsComfortKeyValue)  {
            rsComfortKeyValue = rsvalue as! Int
        }
        else{
            rsComfortKeyValue = 1
        }
        //cs
        if let csvalue = preferences.value(forKey:PrefKeys.csComfortKeyValue) {
            csComfortKeyValue = csvalue as! Int
        }
        else{
            csComfortKeyValue = 1
        }
        //cr
        if let crvalue = preferences.value(forKey:PrefKeys.crComfortKeyValue)  {
            crComfortKeyValue = crvalue as! Int
        }
        else{
            crComfortKeyValue = 1
        }
        // w
        if let wvalue = preferences.value(forKey:PrefKeys.wComfortKeyValue) {
            wComfortKeyValue = wvalue as! Int
        }
        else{
            wComfortKeyValue = 1
        }
        // so
        if let sovalue = preferences.value(forKey:PrefKeys.soComfortKeyValue)  {
            soComfortKeyValue = sovalue as! Int
        }
        else{
            soComfortKeyValue = 1
        }
        //i
        if let ivalue = preferences.value(forKey:PrefKeys.iComfortKeyValue) {
            iComfortKeyValue = ivalue as! Int
        }
        else{
            iComfortKeyValue = 1
        }
        
    }
    
    /*  Created by Chetu
     setting changes for  obstruction  alert saved prefernce values
     */
    
    func getSettingsObstructionAlertValueMethod(){
        
        //th Alert
        if let thvalue = preferences.value(forKey:PrefKeys.thAlertKeyValue)  {
            thAlertKeyValue = thvalue as! Int
        }
        else{
            thAlertKeyValue = 1
        }
        // rAlert
        if let rvalue = preferences.value(forKey:PrefKeys.rAlertKeyValue) {
            rAlertKeyValue = rvalue as! Int
        }
        else{
            rAlertKeyValue = 1
        }
        // rsAlert
        if let rsvalue = preferences.value(forKey:PrefKeys.rsAlertKeyValue)  {
            rsAlertKeyValue = rsvalue as! Int
        }
        else{
            rsAlertKeyValue = 1
        }
        //csAlert
        if let csvalue = preferences.value(forKey:PrefKeys.csAlertKeyValue) {
            csAlertKeyValue = csvalue as! Int
        }
        else{
            csAlertKeyValue = 1
        }
        //crAlert
        if let crvalue = preferences.value(forKey:PrefKeys.crAlertKeyValue)  {
            crAlertKeyValue = crvalue as! Int
        }
        else{
            crAlertKeyValue = 1
        }
        // wAlert
        if let wvalue = preferences.value(forKey:PrefKeys.wAlertKeyValue) {
            wAlertKeyValue = wvalue as! Int
        }
        else{
            wAlertKeyValue = 1
        }
        // soAlert
        if let sovalue = preferences.value(forKey:PrefKeys.soAlertKeyValue)  {
            soAlertKeyValue = sovalue as! Int
        }
        else{
            soAlertKeyValue = 1
        }
        //iAlert
        if let ivalue = preferences.value(forKey:PrefKeys.iAlertKeyValue) {
            iAlertKeyValue = ivalue as! Int
        }
        else{
            iAlertKeyValue = 1
        }
        
    }
    
    
    //Button handler for setting user type as blind/visually impaired
    @IBAction func blindOrVisuallyImpairedButtonPressed(_ sender: Any) {
        
        userTypeLevel = 1
        
        setSelected(selectedButton: blindOrVisuallyImpairedButton!)
        
        setComfortSettings(comfort: [defaultSettingsValue.blindTrippingHazard,defaultSettingsValue.blindRoughness,defaultSettingsValue.blindRunningSlope,defaultSettingsValue.blindCrossSlope,crComfortKeyValue,defaultSettingsValue.blindWidth,soComfortKeyValue,iComfortKeyValue,userTypeSettingValue.blindthlimitValue,userTypeSettingValue.blindrolimitValue,userTypeSettingValue.blindrslimitValue,userTypeSettingValue.blindcslimitValue,userTypeSettingValue.blindUserValue])
        
        setAlertSettings(alert:[thAlertKeyValue,rAlertKeyValue,rsAlertKeyValue,csAlertKeyValue,crAlertKeyValue,wAlertKeyValue,soAlertKeyValue,iAlertKeyValue,userTypeSettingValue.blindthlimitValue,userTypeSettingValue.blindrolimitValue,userTypeSettingValue.blindrslimitValue,userTypeSettingValue.blindcslimitValue,userTypeSettingValue.blindUserValue])
        
        
        //        setComfortSettings(comfort: [3,2,1,1,3,3,2,1,12,1000,12,16,1])
        //        setAlertSettings(alert:[3,2,1,1,3,3,2,1,12,1000,12,16,1])
        blindOrVisuallyImpairedCheckmark.isHidden = false
        presetNumber = 1
    }
    
    //Button handler for setting user type as sighted and walking
    @IBAction func sightedAndWalkingButtonPressed(_ sender: Any) {
        
        userTypeLevel = 2
        setSelected(selectedButton: sightedAndWalkingButton!)
        
        setComfortSettings(comfort: [defaultSettingsValue.sightedTrippingHazard,defaultSettingsValue.sightedRoughness,defaultSettingsValue.sightedRunningSlope,defaultSettingsValue.sightedCrossSlope,crComfortKeyValue,defaultSettingsValue.sightedWidth,soComfortKeyValue,iComfortKeyValue,userTypeSettingValue.sightthlimitValue,userTypeSettingValue.sightrolimitValue,userTypeSettingValue.sightrslimitValue,userTypeSettingValue.sightcslimitValue,userTypeSettingValue.sightUserValue])
        
        setAlertSettings(alert:[thAlertKeyValue,rAlertKeyValue,rsAlertKeyValue,csAlertKeyValue,crAlertKeyValue,wAlertKeyValue,soAlertKeyValue,iAlertKeyValue,userTypeSettingValue.sightthlimitValue,userTypeSettingValue.sightrolimitValue,userTypeSettingValue.sightrslimitValue,userTypeSettingValue.sightcslimitValue,userTypeSettingValue.sightUserValue])
        
        //        setComfortSettings(comfort: [4,4,3,4,4,4,4,4,12,1000,12,6,2])
        //        setAlertSettings(alert:[4,4,3,4,4,4,4,4,12,1000,12,6,2])
        
        sightedAndWalkingCheckmark.isHidden = false
        presetNumber = 2
    }
    
    //Button handler for setting user type as a wheelchair or scooter user
    @IBAction func wheelchairOrScooterButtonPressed(_ sender: Any) {
        
        userTypeLevel = 3
        setSelected(selectedButton: wheelchairOrScooterButton!)
        
        setComfortSettings(comfort: [defaultSettingsValue.wheelchairTrippingHazard,defaultSettingsValue.wheelchairRoughness,defaultSettingsValue.wheelchairRunningSlope,defaultSettingsValue.wheelchairCrossSlope,crComfortKeyValue,defaultSettingsValue.wheelchairWidth,soComfortKeyValue,iComfortKeyValue,userTypeSettingValue.wheelChairthlimitValue,userTypeSettingValue.wheelChairrolimitValue,userTypeSettingValue.wheelChairrslimitValue,userTypeSettingValue.wheelChaircslimitValue,userTypeSettingValue.wheelChairUserValue])
        
        setAlertSettings(alert:[thAlertKeyValue,rAlertKeyValue,rsAlertKeyValue,csAlertKeyValue,crAlertKeyValue,wAlertKeyValue,soAlertKeyValue,iAlertKeyValue,userTypeSettingValue.wheelChairthlimitValue,userTypeSettingValue.wheelChairrolimitValue,userTypeSettingValue.wheelChairrslimitValue,userTypeSettingValue.wheelChaircslimitValue,userTypeSettingValue.wheelChairUserValue])
        
        wheelchairOrScooterCheckmark.isHidden = false
        presetNumber = 3
    }
    
    //Button handler for setting user type as a cane or walker user
    @IBAction func caneOrWalkerButtonPressed(_ sender: Any) {
        
        userTypeLevel = 4
        setSelected(selectedButton: caneOrWalkerButton!)
        
        setComfortSettings(comfort: [defaultSettingsValue.walkerUserTrippingHazard,defaultSettingsValue.walkerUserRoughness,defaultSettingsValue.walkerUserRunningSlope,defaultSettingsValue.walkerUserCrossSlope,crComfortKeyValue,defaultSettingsValue.walkerUserWidth,soComfortKeyValue,iComfortKeyValue,userTypeSettingValue.canethlimitValue,userTypeSettingValue.canerolimitValue,userTypeSettingValue.canerslimitValue,userTypeSettingValue.canecslimitValue,userTypeSettingValue.caneUserValues])
        
        setAlertSettings(alert:[thAlertKeyValue,rAlertKeyValue,rsAlertKeyValue,csAlertKeyValue,crAlertKeyValue,wAlertKeyValue,soAlertKeyValue,iAlertKeyValue,userTypeSettingValue.canethlimitValue,userTypeSettingValue.canerolimitValue,userTypeSettingValue.canerslimitValue,userTypeSettingValue.canecslimitValue,userTypeSettingValue.caneUserValues])
        
        caneOrWalkerCheckmark.isHidden = false
        presetNumber = 4
    }
    
    
    //Set comfort settings in shared preferences
    func setComfortSettings(comfort:[Int]) {
        var index = 0
        for key in PrefKeys.comfortKeys {
            preferences.set(comfort[index], forKey: key)
            index = index + 1
            
        }
    }
    
    //Set alert settings in shared preferences
    func setAlertSettings(alert:[Int]) {
        var index = 0
        for key in PrefKeys.alertKeys {
            preferences.set(alert[index], forKey: key)
            index = index + 1
        }
    }
    
    //Set button styles back to their default
    func setDefaultButtonStyles(button: UIButton) {
        button.layer.backgroundColor = UIColor.white.cgColor
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1.5
        button.layer.borderColor = AppColors.defaultBorder.cgColor
    }
    
    //Set checkmark styles back to their default
    func setDefaultCheckmarkStyles(checkmark: UIImageView) {
        checkmark.isHidden = true
    }
    
    /**
     * Sets the style of the currently selected button
     * Clears the styles of the unselected buttons
     */
    func setSelected(selectedButton: UIButton) {
        
        //Button array
        let buttons = [blindOrVisuallyImpairedButton, sightedAndWalkingButton, wheelchairOrScooterButton, caneOrWalkerButton]
        
        //Checkmark array
        let checkmarks = [blindOrVisuallyImpairedCheckmark, sightedAndWalkingCheckmark, wheelchairOrScooterCheckmark, caneOrWalkerCheckmark]
        
        //Set all buttons to their default style
        for btn in buttons {
            setDefaultButtonStyles(button: btn!)
        }
        
        //Set all checkmarks to their default style
        for checkmark in checkmarks {
            setDefaultCheckmarkStyles(checkmark: checkmark!)
        }
        
        //Set the border and background colors of selected button
        selectedButton.layer.borderColor = AppColors.selectedBorder.cgColor
        selectedButton.layer.backgroundColor = AppColors.selectedBackground.cgColor
        
        approveButton.isEnabled = true
        approveButton.layer.backgroundColor = AppColors.blueButton.cgColor
        approveButton.layer.borderColor = AppColors.darkBlue.cgColor
        approveButton.setTitleColor(AppColors.darkBlue, for: .normal)
    }
    
    
    
    @IBAction func customizeComfortAction(_ sender: UIButton) {
        if  blindOrVisuallyImpairedCheckmark.isHidden == true && sightedAndWalkingCheckmark.isHidden == true && wheelchairOrScooterCheckmark.isHidden == true && caneOrWalkerCheckmark.isHidden == true {
            return
        }
        else{
            
            savedUserType(userType: userTypeLevel)
            let storyboard = UIStoryboard(name: StoryboardIdentifier.gettingStarted1Storyboard, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.ObstructionList) as UIViewController
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    func savedUserType(userType:Int) {
        
        switch userType {
        case 1:
            print(userType)
            preferences.set(userType, forKey: UserTypeKeys.blindKey)
            break
        case 2:
            print(userType)
            preferences.set(userType, forKey: UserTypeKeys.sightedWalkingKey)
            break
        case 3:
            print(userType)
            preferences.set(userType, forKey: UserTypeKeys.whellChairKey)
            break
        case 4:
            print(userType)
            preferences.set(userType, forKey: UserTypeKeys.caneWalkUserKey)
            break
        default:
            break
        }
        self.pathVuPHP.setType(uacctid: self.preferences.string(forKey: PrefKeys.aidKey)!, type: String(userType))
    }
    
    
    
    
    /**
     * Insert the settings and proceed to map layer options
     */
    @IBAction func approveButtonPressed(_ sender: Any) {
        /// added by chetu
        savedUserType(userType: userTypeLevel)
        if self.pathVuPHP.setType(uacctid: preferences.string(forKey: PrefKeys.aidKey)!, type: preferences.string(forKey: PrefKeys.uTypeKey)!) {
            if(pathVuPHP.insertNewSettings()){
                let storyBoard: UIStoryboard = UIStoryboard(name: StoryboardIdentifier.gettingStarted1Storyboard, bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.mapLayerIdentifier)
                self.present(newViewController, animated: true, completion: nil)
            }
            else {
                print("Error setting user settings")
            }
        }
        else {
            print("Error setting user type")
        }
    }
    
    //Go back to last screen
    @IBAction func dismissView(_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

