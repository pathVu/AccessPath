//
//  MainSettingsObstructionList.swift
//  Access Path
//
//  Created by Nick Sinagra on 5/25/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit

/**
 * This class contains the obstruction list users can use
 * to set comfort and alert settings
 */
class MainSettingsObstructionTypes: UIViewController {
    
    //UI Outlets
    @IBOutlet weak var thButton: UIButton!
    @IBOutlet weak var rButton: UIButton!
    @IBOutlet weak var rsButton: UIButton!
    @IBOutlet weak var csButton: UIButton!
    @IBOutlet weak var crButton: UIButton!
    @IBOutlet weak var wButton: UIButton!
    @IBOutlet weak var soButton: UIButton!
    @IBOutlet weak var iButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var submitSpinner: SpinnerView!
    
    //Shared Preferencs
    let preferences = UserDefaults.standard
    
    //PHP Calls Class Instance
    let pathVuPHP = PHPCalls()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        setStyles()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        
        //Reset buttons to default style
        setStyles()
    }
    
    //Set buttons to their default style
    func setStyles() {
        /**
         *Remove curb , intersection, obstruction option from setting list
         *Commented old code given below
         */
        //var buttons = [self.thButton, self.rButton, self.rsButton, self.csButton, self.crButton, self.wButton, self.soButton, self.iButton]
        
        let buttons = [self.thButton, self.rButton, self.rsButton, self.csButton, self.wButton] //new code remove curb, intersect,obstruction
        
        for button in buttons {
            button?.layer.backgroundColor = UIColor.white.cgColor
            button?.layer.borderColor = AppColors.darkBlue.cgColor
            button?.layer.cornerRadius = 5
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
    
    
    /**
     *Commented curb ramp code
     */
    
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
        //changeView(type: 5)
        changeView(type: 5)
    }
    
    /**
     *Commented Obstruction and intersection code
     */
    
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
        preferences.synchronize()
        let storyBoard: UIStoryboard = UIStoryboard(name: StoryboardIdentifier.mainIdentifier, bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: StoryboardIdentifier.MainComfortLevelPage)
        self.present(vc, animated: true, completion: nil)
    }
    
    /**
     * Button handler for the set settings button
     */
    @IBAction func setSettingsBtnClicked(_ sender: Any) {
        submitSpinner.isHidden = false
        submitButton.setTitle(submitButtonString, for: .normal)
        submitButton.layer.borderColor = AppColors.disabledBorder.cgColor
        submitButton.layer.backgroundColor = AppColors.disabledBackground.cgColor
        submitButton.setTitleColor(AppColors.disabledBorder, for: .normal)
        submitButton.isEnabled = false
        
        
        /// added by chetu
        if(pathVuPHP.insertNewSettings()){
            submitSpinner.isHidden = true
            submitButton.setTitle(succString, for: .normal)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //Go to previous screen
    @IBAction func dismissView(_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Needed to segue back here from alert settings page
    @IBAction func unwindToObstructionList(segue:UIStoryboardSegue) { }
}
