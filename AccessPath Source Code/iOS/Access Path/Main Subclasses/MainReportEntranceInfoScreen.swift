//
//  MainReportEntranceInfo.swift
//  Access Path
//
//  Created by Pete Georgopoulos on 3/13/20.
//  Copyright © 2020 pathVu. All rights reserved.
//

import UIKit

/**
 * Allows users to select the category of the obstruction they are reporting.
 */
class MainReportEntranceInfoScreen: UIViewController {
    
    @IBOutlet weak var automaticDoorButton: UISegmentedControl!
    @IBOutlet weak var rampButton: UISegmentedControl!
    @IBOutlet weak var zeroStepButton: UIButton!
    @IBOutlet weak var oneStepButton: UIButton!
    @IBOutlet weak var twoPlusStepButton: UIButton!
    
    //Obstruction location information (passed from camera action, see MainNavigationHome)
    var lat:Double?
    var lng:Double?
    var image:UIImage!
    var address:String!
    var googleLocationID:String!
    var type:Int!
    var steps:Int = -1
    var stepButtons = [UIButton]()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //set button styles
        self.stepButtons.append(zeroStepButton)
        self.stepButtons.append(oneStepButton)
        self.stepButtons.append(twoPlusStepButton)
        for btn in self.stepButtons {
            setDefaultButtonStyles(btn: btn)
        }
        for btn in self.stepButtons {
            setDefaultButtonStyles(btn: btn)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func goBackToNav(_ sender: Any) {
        performSegue(withIdentifier: StoryboardIdentifier.unwindSegueToVC1, sender: self)
    }
    
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        //if typeLabel.text != "(type)" {
        let storyboard = UIStoryboard (name: StoryboardIdentifier.mainIdentifier, bundle: nil)
        let resultVC = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.SubmissionScreen) as! MainReportSubmit
        resultVC.lat = lat ?? 0.0
        resultVC.lng = lng ?? 0.0
        resultVC.address = address
        resultVC.image = image
        resultVC.type = type
        resultVC.googleLocationID = googleLocationID
        resultVC.entranceSteps = self.steps
        resultVC.entranceRamp = rampButton.selectedSegmentIndex
        resultVC.entranceAutomaticDoors = automaticDoorButton.selectedSegmentIndex
        self.present(resultVC, animated: true, completion: nil)
    }
    
    @IBAction func stepButtonPressed(_ sender: Any) {
        setSelected(selectedButton: sender as! UIButton)
        
        for (index, btn) in self.stepButtons.enumerated(){
            if btn == sender as! UIButton {
                self.steps = index
            }
        }
    }
    
    func setSelected(selectedButton: UIButton) {
        //Set all buttons to their default style
        for btn in self.stepButtons {
            setDefaultButtonStyles(btn: btn)
        }
        
        //Set the border and background colors of selected button
        selectedButton.layer.borderColor = AppColors.selectedBorder.cgColor
        selectedButton.layer.backgroundColor = AppColors.selectedBackground.cgColor
    }
    
    func setDefaultButtonStyles(btn: UIButton) {
        btn.layer.backgroundColor = UIColor.white.cgColor
        btn.layer.cornerRadius = 5
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = AppColors.defaultBorder.cgColor
    }
}
    
