//
//  EntrancePopupVC.swift
//  Access Path
//
//  Created by Pete Georgopoulos on 3/16/20.
//  Copyright © 2020 pathVu. All rights reserved.
//

import Foundation
import UIKit

class EntrancePopupVC: UIViewController {

    
    var uaccountId: String?
    var cid: Int?
    var imageUrl: String?
    var defaultImage:UIImage?
    var noAvailableImage:UIImage?
    var address:String!
    var entranceSteps:Int!
    var entranceRamp:Int!
    var isAutomatic:Int!
    
    
    @IBOutlet weak var crowdsourceImage: UIImageView!
    
    @IBOutlet weak var animator: UIActivityIndicatorView! {
        didSet {
            animator.startAnimating()
        }
    }
    @IBOutlet weak var addressLabel: UILabel!{
        didSet{
            addressLabel.text = address
        }
    }
    
    @IBOutlet weak var stepsLabel: UILabel!{
        didSet{
            if self.entranceSteps != nil && self.entranceSteps != -1 {
                stepsLabel.text = stepOptions[entranceSteps]
            }
            else {
                self.stepsLabel.text = ""
            }
        }
    }
    
    @IBOutlet weak var rampLabel: UILabel!{
        didSet{
            if self.entranceRamp != nil && self.entranceRamp != -1 {
                self.rampLabel.text = (self.entranceRamp == 1) ? "yes" : "no"
            }
            else {
                self.rampLabel.text = ""
            }
        }
    }
    
    @IBOutlet weak var automaticLabel: UILabel!{
        didSet{
            if self.isAutomatic != nil && self.isAutomatic != -1 {
                self.automaticLabel.text = (self.isAutomatic == 1) ? "yes" : "no"
            }
            else {
                automaticLabel.text = ""
            }
        }
    }
    
    
    //PHP calls class instance
    let pathVuPHP = PHPCalls()
    
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
    
    @IBAction func clickOnCloseReport(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickOnDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
