//
//  SelectPresetScreen.swift
//  Access Path
//
//  Created by Nick Sinagra on 5/14/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit

/**
 * Allows the user to change their user type
 */
class MainSettingsProfilePresets: UIViewController {
    
    
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
    //Others
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
    var userTypeValue = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // call method for getting obstruction settings  comfort value
        self.getSettingsObstructionValueMethod()
        // call method for getting obstruction settings  Alert value
        self.getSettingsObstructionAlertValueMethod()
        //setStyles()
        loadData()
    }
    
    
    
    /**
     * Loads the user's setting if it has previously been set.
     * If it has been set, the correct button is highlighted to reflect their user type.
     */
    func loadData() {
        
        print(Int(preferences.string(forKey: PrefKeys.uTypeKey)!)!)
        userTypeValue = Int(preferences.string(forKey: PrefKeys.uTypeKey)!)!
        
        if preferences.object(forKey: UserTypeKeys.blindKey) != nil {
            userTypeValue = preferences.integer(forKey: UserTypeKeys.blindKey)
        }
         else if preferences.object(forKey: UserTypeKeys.sightedWalkingKey) != nil {
            userTypeValue = preferences.integer(forKey: UserTypeKeys.sightedWalkingKey)
        }
        else if preferences.object(forKey: UserTypeKeys.whellChairKey) != nil {
            userTypeValue = preferences.integer(forKey: UserTypeKeys.whellChairKey)
        }
        else if preferences.object(forKey: UserTypeKeys.caneWalkUserKey) != nil {
            userTypeValue = preferences.integer(forKey: UserTypeKeys.caneWalkUserKey)
        }
        
        switch userTypeValue {
        case 1:
            setSelected(selectedButton: blindOrVisuallyImpairedButton)
            blindOrVisuallyImpairedCheckmark.isHidden = false
            break
        case 2:
            setSelected(selectedButton: sightedAndWalkingButton)
            sightedAndWalkingCheckmark.isHidden = false
            break
        case 3:
            setSelected(selectedButton: wheelchairOrScooterButton)
            wheelchairOrScooterCheckmark.isHidden = false
            break
        case 4:
            setSelected(selectedButton: caneOrWalkerButton)
            caneOrWalkerCheckmark.isHidden = false
            break
        default:
            break
        }
    }
    
    
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
    
    
    
    /**  Created by Chetu
     *setting changes for  obstruction  comfort value saved prefernce values
     */
    func getSettingsObstructionValueMethod(){
        //th
        if let thvalue = preferences.value(forKey:PrefKeys.thComfortKeyValue)  {
            thComfortKeyValue = thvalue as! Int
            //blindOrVisuallyImpairedCheckmark.isHidden = false
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
    @IBAction func blindOrVisuallyImpairedButtonPressed(_ sender:Any) {
        
        userTypeValue = 1
        //preferences.set(nil, forKey: UserTypeKeys.blindKey)
        preferences.removeObject(forKey: UserTypeKeys.blindKey)
        setSelected(selectedButton: blindOrVisuallyImpairedButton!)
        
        setComfortSettings(comfort: [defaultSettingsValue.blindTrippingHazard,defaultSettingsValue.blindRoughness,defaultSettingsValue.blindRunningSlope,defaultSettingsValue.blindCrossSlope,crComfortKeyValue,defaultSettingsValue.blindWidth,soComfortKeyValue,iComfortKeyValue,userTypeSettingValue.blindthlimitValue,userTypeSettingValue.blindrolimitValue,userTypeSettingValue.blindrslimitValue,userTypeSettingValue.blindcslimitValue,userTypeSettingValue.blindUserValue])
        
        setAlertSettings(alert:[thAlertKeyValue,rAlertKeyValue,rsAlertKeyValue,csAlertKeyValue,crAlertKeyValue,wAlertKeyValue,soAlertKeyValue,iAlertKeyValue,userTypeSettingValue.blindthlimitValue,userTypeSettingValue.blindrolimitValue,userTypeSettingValue.blindrslimitValue,userTypeSettingValue.blindcslimitValue,userTypeSettingValue.blindUserValue])
        
        blindOrVisuallyImpairedCheckmark.isHidden = false
        presetNumber = 1
    }
    
    //Button handler for setting user type as sighted and walking
    @IBAction func sightedAndWalkingButtonPressed(_ sender:Any) {
        userTypeValue = 2
        preferences.removeObject(forKey: UserTypeKeys.sightedWalkingKey)
        setSelected(selectedButton: sightedAndWalkingButton!)
        
        setComfortSettings(comfort: [defaultSettingsValue.sightedTrippingHazard,defaultSettingsValue.sightedRoughness,defaultSettingsValue.sightedRunningSlope,defaultSettingsValue.sightedCrossSlope,crComfortKeyValue,defaultSettingsValue.sightedWidth,soComfortKeyValue,iComfortKeyValue,userTypeSettingValue.sightthlimitValue,userTypeSettingValue.sightrolimitValue,userTypeSettingValue.sightrslimitValue,userTypeSettingValue.sightcslimitValue,userTypeSettingValue.sightUserValue])
        
        
        setAlertSettings(alert:[thAlertKeyValue,rAlertKeyValue,rsAlertKeyValue,csAlertKeyValue,crAlertKeyValue,wAlertKeyValue,soAlertKeyValue,iAlertKeyValue,userTypeSettingValue.sightthlimitValue,userTypeSettingValue.sightrolimitValue,userTypeSettingValue.sightrslimitValue,userTypeSettingValue.sightcslimitValue,userTypeSettingValue.sightUserValue])
        
        sightedAndWalkingCheckmark.isHidden = false
        presetNumber = 2
    }
    
    //Button handler for setting user type as a wheelchair or scooter user
    @IBAction func wheelchairOrScooterButtonPressed(_ sender:Any) {
        
        userTypeValue = 3
        preferences.removeObject(forKey: UserTypeKeys.whellChairKey)
        setSelected(selectedButton: wheelchairOrScooterButton!)
        
        setComfortSettings(comfort: [defaultSettingsValue.wheelchairTrippingHazard,defaultSettingsValue.wheelchairRoughness,defaultSettingsValue.wheelchairRunningSlope,defaultSettingsValue.wheelchairCrossSlope,crComfortKeyValue,defaultSettingsValue.wheelchairWidth,soComfortKeyValue,iComfortKeyValue,userTypeSettingValue.wheelChairthlimitValue,userTypeSettingValue.wheelChairrolimitValue,userTypeSettingValue.wheelChairrslimitValue,userTypeSettingValue.wheelChaircslimitValue,userTypeSettingValue.wheelChairUserValue])
        
        setAlertSettings(alert:[thAlertKeyValue,rAlertKeyValue,rsAlertKeyValue,csAlertKeyValue,crAlertKeyValue,wAlertKeyValue,soAlertKeyValue,iAlertKeyValue,userTypeSettingValue.wheelChairthlimitValue,userTypeSettingValue.wheelChairrolimitValue,userTypeSettingValue.wheelChairrslimitValue,userTypeSettingValue.wheelChaircslimitValue,userTypeSettingValue.wheelChairUserValue])
        wheelchairOrScooterCheckmark.isHidden = false
        presetNumber = 3
    }
    
    //Button handler for setting user type as a cane or walker user
    @IBAction func aneOrWalkerButtonPressed(_ sender:Any) {
        userTypeValue = 4
        preferences.removeObject(forKey: UserTypeKeys.caneWalkUserKey)
        
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
        
        approveButton.isEnabled = true
        approveButton.layer.backgroundColor = AppColors.caretColor.cgColor
        approveButton.layer.borderColor = AppColors.darkBlue.cgColor
        approveButton.setTitleColor(AppColors.darkBlue, for: .normal)
    }
    
    /**
     * savedUserType values
     * Clears the styles of the unselected buttons
     */
    //Go back to obstruction list
    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        preferences.removeObject(forKey: UserTypeKeys.blindKey)
        preferences.removeObject(forKey: UserTypeKeys.sightedWalkingKey)
        preferences.removeObject(forKey: UserTypeKeys.whellChairKey)
        preferences.removeObject(forKey: UserTypeKeys.caneWalkUserKey)
        preferences.synchronize()
        
        switch userTypeValue {
        case 1:
            print(userTypeValue)
            preferences.set(userTypeValue, forKey: UserTypeKeys.blindKey)
            break
        case 2:
            print(userTypeValue)
            preferences.set(userTypeValue, forKey: UserTypeKeys.sightedWalkingKey)
            break
        case 3:
            print(userTypeValue)
            preferences.set(userTypeValue, forKey: UserTypeKeys.whellChairKey)
            break
        case 4:
            print(userTypeValue)
            preferences.set(userTypeValue, forKey: UserTypeKeys.caneWalkUserKey)
            break
        default:
            break
        }
        
        print("dismissed")
        performSegue(withIdentifier: StoryboardIdentifier.unwindToObstructionList, sender: self)
    }
    
    //Go back to previous screen
    @IBAction func dismissView(_ sender:Any) {
        dismiss(animated: true, completion: nil)
    }
}

