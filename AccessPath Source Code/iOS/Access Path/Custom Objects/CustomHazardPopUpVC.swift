//
//  CustomHazardPopUpVC.swift
//  Access Path
//
//  Created by Chetu on 4/18/19.
//  Copyright © 2019 pathVu. All rights reserved.
//

import UIKit
import AVFoundation

class CustomHazardPopUpVC: UIViewController {

    
    @IBOutlet weak var vote_count: UILabel!
    @IBOutlet weak var yes_button: UIButton!
    @IBOutlet weak var no_button: UIButton!
    @IBOutlet weak var crowdsourceImage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var animator: UIActivityIndicatorView! {
        didSet {
            animator.startAnimating()
        }
    }
    @IBOutlet weak var hazrad_type: UILabel! {
        didSet{
            hazrad_type.text = hazardTypeValue
        }
    }
    var uaccountId: String?
    var cid: Int?
    var imageUrl: String?
    var hazardTypeValue : String!
    var defaultImage:UIImage?
    var noAvailableImage:UIImage?
    
    //PHP calls class instance
    let pathVuPHP = PHPCalls()
    
    //Speech synthesizer for reading directions out loud
    let synth = AVSpeechSynthesizer()
    
    //Preferences Storage
    let preferences = UserDefaults.standard
    
    
    //var delegate: CustomHazardPopUpVC?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if defaultImage != nil {
            crowdsourceImage.image = defaultImage
            self.animator.stopAnimating()
            self.animator.isHidden = true
        }
        vote_count.layer.cornerRadius =  vote_count.frame.width/2
        vote_count.layer.masksToBounds = true
        totalVoteCount()
    }

    
    
    //MARK:  ------ Total Vote Count Api -----------
    func totalVoteCount() {
        let cid = preferences.integer(forKey: "cidValue")
        guard let responseData:String =  pathVuPHP.totalVoteCountApi(cid: cid) else{
            return
        }
        if let count = Int(responseData) {
            vote_count.text = "\(count)"
            debugPrint("Total vote count \(count)")
        }
    }
    
    
    
    //MARK:    Tumbs up api
    @IBAction func clickOnThumbsUp(_ sender: UIButton) {
        
        let uaccountId = preferences.integer(forKey: "uacctID")
        let cid = preferences.integer(forKey: "cidValue")
        guard let responseData:String =  pathVuPHP.thumbsUpVoteApi(cid: cid, acctid: uaccountId, thumbsUp: 1) else {
            return
        }
        guard let thumbsUpCount = Int(responseData) else {
            return
        }
        vote_count.text = "\(thumbsUpCount)"
        print("thumbs up vote count \(thumbsUpCount)")
    }

    
    //MARK: ----------- Thumbs Down -----------------------
    @IBAction func clickOnThumbsDown(_ sender: UIButton) {
        let uaccountId = preferences.integer(forKey: "uacctID")
        let cid = preferences.integer(forKey: "cidValue")
        guard let responseData:String =  pathVuPHP.thumbsUpVoteApi(cid: cid, acctid: uaccountId, thumbsUp: -1) else {
            return
        }
        guard let thumbsDownCount = Int(responseData) else {
            return
        }
        vote_count.text = "\(thumbsDownCount)"
        print("thumbs Down vote count \(thumbsDownCount)")
    }
    
    
    //MARK:  IMAGE DOWNLOAD FROM SERVICE URL 
    func downloadImage() {
        if let url = imageUrl, let imageUrl = URL(string: url) {
            self.downloadedImageFromService(from:imageUrl , success: { (image) in
                self.animator?.stopAnimating()
                self.animator?.isHidden = true
                self.crowdsourceImage?.image = image
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
                    self.crowdsourceImage?.image = self.noAvailableImage
                    self.animator?.stopAnimating()
                    self.animator?.isHidden = true
                }
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func setMessage(_ message:String){
        messageLabel?.text = message
    }
    
    @IBAction func clickOnCloseReport(_ sender: UIButton) {
        DispatchQueue.main.async() {
            if(self.preferences.bool(forKey: PrefKeys.soundKey)) {
                let utterance = AVSpeechUtterance(string: FavoriteAlertType.closeAlert)
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                self.synth.speak(utterance)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickOnDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
