//
//  IndoorPopupVC.swift
//  Access Path
//
//  Created by Pete Georgopoulos on 3/16/20.
//  Copyright © 2020 pathVu. All rights reserved.
//

import UIKit
import AVFoundation

class IndoorPopupVC: UIViewController {

    var uaccountId: String?
    var cid: Int?
    var imageUrl: String?
    var defaultImage:UIImage?
    var noAvailableImage:UIImage?
    var address:String!
    var indoorSteps:Int!
    var indoorType:[String]!
    var hasBraille:Int!
    var isSpacious:Int!
    var indoorRamp:Int!
    
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
            if self.indoorSteps != nil && self.indoorSteps != -1 {
                stepsLabel.text = stepOptions[self.indoorSteps]
            }
            else {
                stepsLabel.text = ""
            }
        }
    }
    
    @IBOutlet weak var rampLabel: UILabel!{
        didSet{
            if self.indoorRamp != nil && self.indoorRamp != -1 {
                rampLabel.text = (self.indoorRamp == 1) ? "yes" : "no"
            }
            else {
                rampLabel.text = ""
            }
        }
    }
    
    @IBOutlet weak var indoorTypeLabel: UILabel! {
        didSet{
            var tempArray = [String]()
            for (index, item) in self.indoorType.enumerated() {
                if let item = Int(item) {
                    if item != -1 {
                        tempArray.append("\(indoorArray[index]): \(item == 1 ? " yes" : " no")")
                    }
                }
            }
            indoorTypeLabel.text = tempArray.joined(separator: ", ")
        }
    }
    
    @IBOutlet weak var brailleLabel: UILabel!{
        didSet{
            if self.hasBraille != nil && self.hasBraille != -1 {
                brailleLabel.text = (self.hasBraille == 1) ? "yes" : "no"
            }
            else {
                brailleLabel.text = ""
            }
        }
    }
    
    @IBOutlet weak var spaciousLabel: UILabel!{
        didSet{
            if self.isSpacious != nil && self.isSpacious != -1 {
                spaciousLabel.text = (self.isSpacious == 1) ? "yes" : "no"
            }
            else {
                spaciousLabel.text = ""
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
