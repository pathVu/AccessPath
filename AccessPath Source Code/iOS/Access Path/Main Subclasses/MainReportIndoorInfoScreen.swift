//
//  MainReportIndoorInfo.swift
//  Access Path
//
//  Created by Pete Georgopoulos on 3/13/20.
//  Copyright © 2020 pathVu. All rights reserved.
//
import UIKit

/**
 * Allows users to select the category of the obstruction they are reporting.
 */
class MainReportIndoorInfoScreen: UIViewController {
    
    @IBOutlet weak var stepsView: UIView!
    @IBOutlet weak var mfButton: UISegmentedControl!
    @IBOutlet weak var familyButton: UISegmentedControl!
    @IBOutlet weak var adaButton: UISegmentedControl!
    @IBOutlet weak var lockedButton: UISegmentedControl!
    @IBOutlet weak var brailleButton: UISegmentedControl!
    @IBOutlet weak var spaciousButton: UISegmentedControl!
    @IBOutlet weak var rampButton: UISegmentedControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var zeroStepButton: UIButton!
    @IBOutlet weak var oneStepButton: UIButton!
    @IBOutlet weak var twoPlusStepButton: UIButton!
    
    let indoorArray = ["Male/Female", "Family", "ADA Accessible", "Locked Door"]
    
    //Report location information (passed from camera action, see MainNavigationHome)
    var lat:Double?
    var lng:Double?
    var image:UIImage!
    var address:String!
    var googleLocationID:String!
    var information:String!
    var type:Int!
    var steps:Int = -1
    var indoorType:Int!
    var types = [String]()
    var stepButtons = [UIButton]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set button styles
        self.stepButtons.append(zeroStepButton)
        self.stepButtons.append(oneStepButton)
        self.stepButtons.append(twoPlusStepButton)
        for btn in self.stepButtons {
            setDefaultButtonStyles(btn: btn)
        }
        
        //set scrollview and stackview attributes
        self.scrollView.addSubview(stackView)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
        self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
        self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        self.stackView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor).isActive = true
    }

    @IBAction func confirmButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard (name: StoryboardIdentifier.mainIdentifier, bundle: nil)
        let resultVC = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.SubmissionScreen) as! MainReportSubmit
        resultVC.lat = lat ?? 0.0
        resultVC.lng = lng ?? 0.0
        resultVC.address = address
        resultVC.image = image
        resultVC.type = type
        resultVC.googleLocationID = googleLocationID
        resultVC.indoorSteps = self.steps
        resultVC.indoorRamp = rampButton.selectedSegmentIndex
        resultVC.indoorSpacious = spaciousButton.selectedSegmentIndex
        resultVC.indoorBraille = brailleButton.selectedSegmentIndex
        resultVC.indoorType = [
            mfButton.selectedSegmentIndex,
            familyButton.selectedSegmentIndex,
            adaButton.selectedSegmentIndex,
            lockedButton.selectedSegmentIndex
        ]
        resultVC.indoorSpacious =
            spaciousButton.selectedSegmentIndex
        resultVC.indoorBraille = brailleButton.selectedSegmentIndex
        self.present(resultVC, animated: true, completion: nil)
    }
    
    @IBAction func goBackToNav(_ sender: Any) {
        performSegue(withIdentifier: StoryboardIdentifier.unwindSegueToVC1, sender: self)
    }
    
    @IBAction func dissmissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func stepButtonPressed(_ sender: Any) {
        //Set button styles
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
    
