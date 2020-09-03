//
//  ComfortSettingsMain.swift
//  Access Path
//
//  Created by Nick Sinagra on 5/21/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit

/**
 * This class contains the obstruction list users can use
 * to set comfort and alert settings
 */
class OnboardingObstructionTypes: UIViewController {
    
    //UI Outlets
    //Buttons
    @IBOutlet weak var thButton: UIButton!
    @IBOutlet weak var rButton: UIButton!
    @IBOutlet weak var rsButton: UIButton!
    @IBOutlet weak var csButton: UIButton!
    @IBOutlet weak var crButton: UIButton!
    @IBOutlet weak var wButton: UIButton!
    @IBOutlet weak var soButton: UIButton!
    @IBOutlet weak var iButton: UIButton!
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var approveBtnArrow: UIImageView!
    
    //Shared Preferences
    let preferences = UserDefaults.standard
    
    //PHP Calls Class Instance
    let pathVuPHP = PHPCalls()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //If the user has not visited a later screen, set this as the highest screen reached
        if(preferences.integer(forKey: PrefKeys.onboardProgKey) < 7) {
            preferences.set(7, forKey: PrefKeys.onboardProgKey)
        }
        setStyles()
        checkValues()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        setStyles()
        checkValues()
    }
    
    //Set buttons to their default style
    func setStyles() {
        //Previous button with curb, intersection and obstruction
        //let buttons = [self.thButton, self.rButton, self.rsButton, self.csButton, self.crButton, self.wButton, self.soButton, self.iButton] //old code
        
        let buttons = [self.thButton, self.rButton, self.rsButton, self.csButton, self.wButton] //new code remove curb, intersect,obstruction
        
        for button in buttons {
            button?.layer.backgroundColor = UIColor.white.cgColor
            button?.layer.borderColor = AppColors.darkBlue.cgColor
            button?.layer.cornerRadius = 5
        }
    }
    
    /**
     * If any comfort setting is not set (which should not happen),
     * the respective button will turn red.
     */
    func checkValues() {
        
        //Comment code including curb,intersct , obstruction
        //let keys = [PrefKeys.thComfortKey, PrefKeys.rComfortKey, PrefKeys.rsComfortKey, PrefKeys.csComfortKey, PrefKeys.crComfortKey, PrefKeys.wComfortKey, PrefKeys.soComfortKey, PrefKeys.iComfortKey]
        
        //remove curb , intersect, obstruction from key array
        //let keys = [PrefKeys.thComfortKey, PrefKeys.rComfortKey, PrefKeys.rsComfortKey, PrefKeys.csComfortKey, PrefKeys.wComfortKey] //New code changed by Chetu
        
        /*
         *latest code feb 8,2019
         */
        let keys = [PrefKeys.thComfortKeyValue, PrefKeys.rComfortKeyValue, PrefKeys.rsComfortKeyValue, PrefKeys.csComfortKeyValue, PrefKeys.wComfortKeyValue]
        
        //let buttons = [thButton, rButton, rsButton, csButton, crButton, wButton, soButton, iButton] //old code include curb,intersct,obstruction
        let buttons = [thButton, rButton, rsButton, csButton, wButton] //Remove curb,intersection,obstruction changed by Chetu
        
        var count = 0 //Tracks how many comfort settings are set (8 in total)
        
        for index in 0...4 {
            if(preferences.string(forKey: keys[index]) == nil || preferences.integer(forKey: keys[index]) == 0) {
                buttons[index]?.layer.backgroundColor = AppColors.errorBackground.cgColor
                buttons[index]?.layer.borderColor = AppColors.errorBorder.cgColor
            } else {
                count += 1
                buttons[index]?.layer.backgroundColor = UIColor.white.cgColor
                buttons[index]?.layer.borderColor = AppColors.darkBlue.cgColor
            }
        }
        
        //Enable "Approve Settings" button if all the keys have set values
        if(count == 5) {
            approveButton.isEnabled = true
            approveButton.layer.backgroundColor = AppColors.caretColor.cgColor
            approveButton.layer.borderColor = AppColors.darkBlue.cgColor
            approveButton.setTitleColor(AppColors.darkBlue, for: .normal)
        } else {
            approveButton.isEnabled = false
            approveButton.layer.backgroundColor = AppColors.disabledBackground.cgColor
            approveButton.layer.borderColor = AppColors.disabledBorder.cgColor
            approveButton.setTitleColor(AppColors.disabledBorder, for: .normal)
        }
    }
    
    //The following actions will take the user to the selected comfort setting
    
    @IBAction func thButtonPressed(_ sender: Any) {
        thButton.layer.backgroundColor = AppColors.selectedBackground.cgColor
        thButton.layer.borderColor = AppColors.selectedBorder.cgColor
        
        //Type 0 = Tripping Hazards
        changeView(type: 0)
    }
    
    @IBAction func rButtonPressed(_ sender: Any) {
        rButton.layer.backgroundColor = AppColors.selectedBackground.cgColor
        rButton.layer.borderColor = AppColors.selectedBorder.cgColor
        
        //Type 1 = Sidewalk Roughness
        changeView(type: 1)
    }
    
    @IBAction func rsButtonPressed(_ sender: Any) {
        rsButton.layer.backgroundColor = AppColors.selectedBackground.cgColor
        rsButton.layer.borderColor = AppColors.selectedBorder.cgColor
        
        //Type 2 = Running Slope
        changeView(type: 2)
    }
    
    @IBAction func csButtonPressed(_ sender: Any) {
        csButton.layer.backgroundColor = AppColors.selectedBackground.cgColor
        csButton.layer.borderColor = AppColors.selectedBorder.cgColor
        
        //Type 3 = Cross Slope
        changeView(type: 3)
    }
    
    //Commented curb , intersct , obstruction
    /*
     @IBAction func crButtonPressed(_ sender: Any) {
     crButton.layer.backgroundColor = AppColors.selectedBackground.cgColor
     crButton.layer.borderColor = AppColors.selectedBorder.cgColor
     
     //Type 4 = Curb Ramps
     changeView(type: 4)
     }
     */
    
    @IBAction func wButtonPressed(_ sender: Any) {
        wButton.layer.backgroundColor = AppColors.selectedBackground.cgColor
        wButton.layer.borderColor = AppColors.selectedBorder.cgColor
        
        //Type 5 = Sidewalk Width
        changeView(type: 5)
    }
    
    //Commented curb , intersct , obstruction type option
    /*
     @IBAction func soButtonPressed(_ sender: Any) {
     soButton.layer.backgroundColor = AppColors.selectedBackground.cgColor
     soButton.layer.borderColor = AppColors.selectedBorder.cgColor
     
     //Type 6 = Obstructions
     changeView(type: 6)
     }
     
     @IBAction func iButtonPressed(_ sender: Any) {
     iButton.layer.backgroundColor = AppColors.selectedBackground.cgColor
     iButton.layer.borderColor = AppColors.selectedBorder.cgColor
     
     //Type 7 = Intersections
     changeView(type: 7)
     }
     */
    
    
    /**
     * Go to the settings page of the specified type
     * Uses Local Saved Data to communicate with the view controller
     */
    func changeView(type:Int) {
        preferences.set(type, forKey: PrefKeys.settingsTypeKey)
        let storyBoard: UIStoryboard = UIStoryboard(name: StoryboardIdentifier.gettingStarted1Storyboard, bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.onboardingComfortSettingIdentifier)
        self.present(vc, animated: true, completion: nil)
    }
    
    /**
     * Button handler for the set settings button
     */
    @IBAction func setSettingsBtnPressed(_ sender: Any) {
        //comment Code
        //if(pathVuPHP.insertSettings())
        
        /// added by chetu
        if(pathVuPHP.insertNewSettings()){ 
            let storyBoard: UIStoryboard = UIStoryboard(name: StoryboardIdentifier.gettingStarted1Storyboard, bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.mapLayerIdentifier)
            self.present(newViewController, animated: true, completion: nil)
        }
    }
    
    //Go to previous screen
    @IBAction func dismissView(_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Needed to segue back here from alert settings page
    @IBAction func unwindToOnboardingObstructionTypes(segue:UIStoryboardSegue) { }
}


