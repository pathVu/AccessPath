//
//  TransitPopUpAlert.swift
//  Access Path
//
//  Created by Chetu on 4/15/19.
//  Copyright © 2019 pathVu. All rights reserved.
//

import UIKit
import AVFoundation

class TransitPopUpAlert: UIViewController {
    
    
    @IBOutlet weak var transition_PopUp: UIView!
    @IBOutlet weak var transition_image: UIImageView!
    // @IBOutlet weak var showStopName: UILabel!
    
    @IBOutlet weak var direction: UILabel! {
        didSet{
            direction.text = directionValue
        }
    }
    @IBOutlet weak var routes: UILabel! {
        didSet{
            routes.text = routesValue
        }
    }
    @IBOutlet weak var sheltorName: UILabel! {
        didSet{
            sheltorName.text = sheltorNameValue
        }
    }
    @IBOutlet weak var stopType: UILabel! {
        didSet{
            stopType.text = stopTypeValue
        }
    }
    @IBOutlet weak var showStopName: UILabel! {
        didSet{
            showStopName.text = stopNameValue
        }
    }
    
    //MARK: View Outlet
    @IBOutlet weak var stopView: UIView!{
        didSet {
            let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeGestureRight.direction = UISwipeGestureRecognizerDirection.right
            stopView.addGestureRecognizer(swipeGestureRight)
            
            let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeGestureRight.direction = UISwipeGestureRecognizerDirection.left
            stopView.addGestureRecognizer(swipeGestureLeft)
        }
    }
    @IBOutlet weak var directionView: UIView! {
        didSet {
            let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeGestureRight.direction = UISwipeGestureRecognizerDirection.right
            directionView.addGestureRecognizer(swipeGestureRight)
            
            let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeGestureRight.direction = UISwipeGestureRecognizerDirection.left
            directionView.addGestureRecognizer(swipeGestureLeft)
        }
    }
    @IBOutlet weak var routesView: UIView! {
        didSet {
            let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeGestureRight.direction = UISwipeGestureRecognizerDirection.right
            routesView.addGestureRecognizer(swipeGestureRight)
            
            let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeGestureRight.direction = UISwipeGestureRecognizerDirection.left
            routesView.addGestureRecognizer(swipeGestureLeft)
        }
    }
    @IBOutlet weak var sheltorView: UIView! {
        didSet {
            let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeGestureRight.direction = UISwipeGestureRecognizerDirection.right
            sheltorView.addGestureRecognizer(swipeGestureRight)
            
            let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeGestureRight.direction = UISwipeGestureRecognizerDirection.left
            sheltorView.addGestureRecognizer(swipeGestureLeft)
        }
    }
    
    @IBOutlet weak var transitionContainerView: UIView!
    
    var stopNameValue: String!
    var directionValue: String!
    var routesValue : String!
    var sheltorNameValue: String!
    var stopTypeValue: String!
    
    //Speech synthesizer for reading directions out loud
    let synth = AVSpeechSynthesizer()
    //Shared Preferences
    let preferences = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                guard let view = gesture.view else {
                    return
                }
                
                if view.tag == 123 {
                    if(preferences.bool(forKey: PrefKeys.soundKey)) {
                        let utterance = AVSpeechUtterance(string: stopNameValue)
                        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                        self.synth.speak(utterance)
                    }
                }
                else if view.tag == 124 {
                    if(preferences.bool(forKey: PrefKeys.soundKey)) {
                        let utterance = AVSpeechUtterance(string: directionValue)
                        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                        self.synth.speak(utterance)
                    }
                }
                else if view.tag == 125 {
                    if(preferences.bool(forKey: PrefKeys.soundKey)) {
                        let utterance = AVSpeechUtterance(string: routesValue)
                        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                        self.synth.speak(utterance)
                    }
                }
                else if view.tag == 126 {
                    if(preferences.bool(forKey: PrefKeys.soundKey)) {
                        let utterance = AVSpeechUtterance(string: sheltorNameValue)
                        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                        self.synth.speak(utterance)
                    }
                }
                
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
                
                guard let view = gesture.view else {
                    return
                }
                
                if view.tag == 123 {
                    if(preferences.bool(forKey: PrefKeys.soundKey)) {
                        let utterance = AVSpeechUtterance(string: stopNameValue)
                        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                        self.synth.speak(utterance)
                    }
                }
                else if view.tag == 124 {
                    if(preferences.bool(forKey: PrefKeys.soundKey)) {
                        let utterance = AVSpeechUtterance(string: directionValue)
                        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                        self.synth.speak(utterance)
                    }
                }
                else if view.tag == 125 {
                    if(preferences.bool(forKey: PrefKeys.soundKey)) {
                        let utterance = AVSpeechUtterance(string: routesValue)
                        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                        self.synth.speak(utterance)
                    }
                }
                else if view.tag == 126 {
                    if(preferences.bool(forKey: PrefKeys.soundKey)) {
                        let utterance = AVSpeechUtterance(string: sheltorNameValue)
                        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                        self.synth.speak(utterance)
                    }
                }
                
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    @IBAction func clickOnDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:  close map alert with voie text 
    @IBAction func closeAlert(_ sender: UIButton) {
        
        if(preferences.bool(forKey: PrefKeys.soundKey)) {
            let utterance = AVSpeechUtterance(string: FavoriteAlertType.closeAlert)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            self.synth.speak(utterance)
        }
        self.dismiss(animated: true, completion: nil)
    }
}
