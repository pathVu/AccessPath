//
//  SidewalkPopAlert.swift
//  Access Path
//
//  Created by Chetu on 4/16/19.
//  Copyright © 2019 pathVu. All rights reserved.
//

import UIKit
import AVFoundation

class SidewalkPopAlert: UIViewController {

    
    @IBOutlet weak var streetName: UILabel! {
        didSet {
            streetName.text = street
        }
    }
    @IBOutlet weak var animator: UIActivityIndicatorView! {
        didSet {
            animator.startAnimating()
        }
    }
    @IBOutlet weak var sidewalk_pathImage: UIImageView!
    var imageUrl: String?
    var defaultImage:UIImage?
    var street : String?
    
    //Speech synthesizer for reading directions out loud
    let synth = AVSpeechSynthesizer()
    //Preferences Storage
    let preferences = UserDefaults.standard
    
    //MARK:  View didload
    override func viewDidLoad() {
        if defaultImage != nil {
            sidewalk_pathImage.image = defaultImage
            self.animator.stopAnimating()
            self.animator.isHidden = true
        }
    }
    
    //MARK:  Dismiss View alert
    @IBAction func clickOnDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func closeReport(_ sender: UIButton) {
        if(preferences.bool(forKey: PrefKeys.soundKey)) {
            let utterance = AVSpeechUtterance(string: FavoriteAlertType.closeAlert)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            self.synth.speak(utterance)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    

    //MARK:  IMAGE DOWNLOAD FROM SERVICE URL 
    func downloadImageFromServer() {
        if let url = imageUrl, let imageUrl = URL(string: url) {
            self.downloadedImageFromService(from:imageUrl , success: { (image) in
               self.sidewalk_pathImage?.image = image
                self.animator?.stopAnimating()
                self.animator?.isHidden = true
                
            }, failure: { (failureReason) in
                print(failureReason)
            })
        }
    }
    func downloadedImageFromService(from url: URL , success:@escaping((_ image:UIImage)->()),failure:@escaping ((_ msg:String)->())){
        print("Download Started")
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
                } else{
                    self.animator?.stopAnimating()
                    self.animator?.isHidden = true
                }
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

}
