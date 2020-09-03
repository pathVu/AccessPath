//
//  CurbRampPopupVC.swift
//  Access Path
//
//  Created by Chetu on 4/15/19.
//  Copyright © 2019 pathVu. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class CurbRampPopupVC: UIViewController {
    
    @IBOutlet weak var curbRamp_image: UIImageView!
    
    var imageUrl: String?
    var defaultImage:UIImage?
    var noAvailableImage:UIImage?
    
    @IBOutlet weak var slop_lbl: UILabel!{
        didSet{
            slop_lbl.text = slopValue
        }
    }
    @IBOutlet weak var quality_lbl: UILabel!{
        didSet{
            quality_lbl.text = qualityValue
        }
    }
    @IBOutlet weak var lippage_lbl: UILabel! {
        didSet{
            lippage_lbl.text = lippageValue
        }
    }
    
    @IBOutlet weak var animator: UIActivityIndicatorView! {
        didSet {
            animator.startAnimating()
        }
    }
    
    var slopValue: String!
    var qualityValue: String!
    var lippageValue : String!
    
    //Speech synthesizer for reading directions out loud
    let synth = AVSpeechSynthesizer()
    //Shared Preferences
    let preferences = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if defaultImage != nil {
            curbRamp_image.image = defaultImage
            self.animator.stopAnimating()
            self.animator.isHidden = true
        }
    }

    
    //MARK:  IMAGE DOWNLOAD FROM SERVICE URL 
    func downloadImageCurbRamp() {
        if let url = imageUrl, let imageUrl = URL(string: url) {
            self.downloadedImageFromService(from:imageUrl , success: { (image) in
                self.animator?.stopAnimating()
                self.animator?.isHidden = true
                self.curbRamp_image?.image = image
            }, failure: { (failureReason) in
                print(failureReason)
            })
        }
    }
    func downloadedImageFromService(from url: URL , success:@escaping((_ image:UIImage)->()),failure:@escaping ((_ msg:String)->())){
        print("Download Started")
        noAvailableImage = UIImage(named: "no_image")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else {
                failure("Image cant download from G+ or fb server")
                return
            }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                if let _img = UIImage(data: data){
                    success(_img)
                }
                else {
                    self.curbRamp_image?.image = self.noAvailableImage
                    self.animator?.stopAnimating()
                    self.animator?.isHidden = true
                }
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    
    
    @IBAction func clickOnDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    //MARK:   Close report alert with voice over text 
    @IBAction func closeAlert(_ sender: UIButton) {
        
    DispatchQueue.main.async() {
        if(self.preferences.bool(forKey: PrefKeys.soundKey)) {
            let utterance = AVSpeechUtterance(string: FavoriteAlertType.closeAlert)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            self.synth.speak(utterance)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
}
