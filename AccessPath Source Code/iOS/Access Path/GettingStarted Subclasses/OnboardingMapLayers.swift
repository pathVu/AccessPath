//
//  MapLayers.swift
//  Access Path
//
//  Created by Nick Sinagra on 6/28/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit

/**
 * Allows users to choose which map layers will appear on the map.
 * This can also be changed in settings later.
 */
class OnboardingMapLayers: UIViewController {
    
    //UI Outlets
    @IBOutlet weak var curbRampsBtn: UIButton!
    @IBOutlet weak var transitStopsBtn: UIButton!
    
    @IBOutlet weak var curbRampsCM: UIImageView!
    @IBOutlet weak var transitStopsCM: UIImageView!
    
    @IBOutlet weak var crowdSourceButton: UIButton!
    @IBOutlet weak var crowdSourceCheckmark: UIImageView!
    
    //Shared Preferences
    let prefs = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Basic styles for buttons
        curbRampsBtn.layer.cornerRadius = 5
        transitStopsBtn.layer.cornerRadius = 5
        crowdSourceButton.layer.cornerRadius = 5
        
        //Both layers are checked by default
        if(prefs.object(forKey: PrefKeys.curbRampsKey) == nil) {
            prefs.set(true, forKey: PrefKeys.curbRampsKey)
        }
        
        if(prefs.object(forKey: PrefKeys.transitStopsKey) == nil) {
            prefs.set(true, forKey: PrefKeys.transitStopsKey)
        }
        
        if(prefs.object(forKey: PrefKeys.crowdSourceKey) == nil) {
            prefs.set(true, forKey: PrefKeys.crowdSourceKey)
        }
        
        //Set style of button depending on if the setting is on or off
        if(prefs.bool(forKey: PrefKeys.curbRampsKey) == true) {
            curbRampsCM.isHidden = false
            curbRampsBtn.layer.backgroundColor = AppColors.selectedBackground.cgColor
            curbRampsBtn.layer.borderColor = AppColors.selectedBorder.cgColor
        } else {
            curbRampsCM.isHidden = true
            curbRampsBtn.layer.backgroundColor = UIColor.white.cgColor
            curbRampsBtn.layer.borderColor = AppColors.darkBlue.cgColor
        }
        
        if(prefs.bool(forKey: PrefKeys.transitStopsKey) == true) {
            transitStopsCM.isHidden = false
            transitStopsBtn.layer.backgroundColor = AppColors.selectedBackground.cgColor
            transitStopsBtn.layer.borderColor = AppColors.selectedBorder.cgColor
        } else {
            transitStopsCM.isHidden = true
            transitStopsBtn.layer.backgroundColor = UIColor.white.cgColor
            transitStopsBtn.layer.borderColor = AppColors.darkBlue.cgColor
        }
        
        if(prefs.bool(forKey: PrefKeys.crowdSourceKey) == true) {
            crowdSourceCheckmark.isHidden = false
            crowdSourceButton.layer.backgroundColor = AppColors.selectedBackground.cgColor
            crowdSourceButton.layer.borderColor = AppColors.selectedBorder.cgColor
        } else {
            crowdSourceCheckmark.isHidden = true
            crowdSourceButton.layer.backgroundColor = UIColor.white.cgColor
            crowdSourceButton.layer.borderColor = AppColors.darkBlue.cgColor
        }
    }
    
    //Turn curb ramp layer on or off
    @IBAction func curbRampsButtonPressed(_ sender: Any) {
        if(prefs.bool(forKey: PrefKeys.curbRampsKey) == true) {
            //Turn Off Layer
            curbRampsCM.isHidden = true
            curbRampsBtn.layer.backgroundColor = UIColor.white.cgColor
            curbRampsBtn.layer.borderColor = AppColors.darkBlue.cgColor
            prefs.set(false, forKey: PrefKeys.curbRampsKey)
        } else {
            //Turn On Layer
            curbRampsCM.isHidden = false
            curbRampsBtn.layer.backgroundColor = AppColors.selectedBackground.cgColor
            curbRampsBtn.layer.borderColor = AppColors.selectedBorder.cgColor
            prefs.set(true, forKey: PrefKeys.curbRampsKey)
        }
    }
    
    //Turn transit stop layer on or off
    @IBAction func transitStopsButtonPressed(_ sender: Any) {
        if(prefs.bool(forKey: PrefKeys.transitStopsKey) == true) {
            //Turn Off Layer
            transitStopsCM.isHidden = true
            transitStopsBtn.layer.backgroundColor = UIColor.white.cgColor
            transitStopsBtn.layer.borderColor = AppColors.darkBlue.cgColor
            prefs.set(false, forKey: PrefKeys.transitStopsKey)
        } else {
            //Turn On Layer
            transitStopsCM.isHidden = false
            transitStopsBtn.layer.backgroundColor = AppColors.selectedBackground.cgColor
            transitStopsBtn.layer.borderColor = AppColors.selectedBorder.cgColor
            prefs.set(true, forKey: PrefKeys.transitStopsKey)
        }
    }
    
    //Turn crowdsource layer on or off
    @IBAction func clickOnCrowdSourceLayer(_ sender: UIButton) {
        if(prefs.bool(forKey: PrefKeys.crowdSourceKey) == true) {
            //Turn Off Layer
            crowdSourceCheckmark.isHidden = true
            crowdSourceButton.layer.backgroundColor = UIColor.white.cgColor
            crowdSourceButton.layer.borderColor = AppColors.darkBlue.cgColor
            prefs.set(false, forKey: PrefKeys.crowdSourceKey)
        } else {
            //Turn On Layer
            crowdSourceCheckmark.isHidden = false
            crowdSourceButton.layer.backgroundColor = AppColors.selectedBackground.cgColor
            crowdSourceButton.layer.borderColor = AppColors.selectedBorder.cgColor
            prefs.set(true, forKey: PrefKeys.crowdSourceKey)
        }
    }
    
    
    //Go back to last previous screen
    @IBAction func dismissView(_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
