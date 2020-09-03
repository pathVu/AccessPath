//
//  HazardPopUpAlert.swift
//  Access Path
//
//  Created by Chetu on 4/15/19.
//  Copyright © 2019 pathVu. All rights reserved.
//

import UIKit

class HazardPopUpAlert: UIView {

    @IBOutlet weak var hazradPopUp: UIView!
    @IBOutlet weak var hazrad_image: UIImageView!
    @IBOutlet weak var hazard_type: UILabel!
    @IBOutlet weak var hazrard_confirmationType: UILabel!
   
    var senderVC: UIViewController?
    
    func showPopUp(_ sender: UIViewController) {
        senderVC = sender
        self.frame = sender.view.frame
        animateIn(sender)
    }
    
    func animateIn(_ sender: UIViewController) {
        sender.view.addSubview(self)
        self.center = sender.view.center
        hazradPopUp.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        hazradPopUp.alpha = 0.5
        
        UIView.animate(withDuration: 0.3) {
            self.hazradPopUp.alpha = 1
            self.hazradPopUp.transform = CGAffineTransform.identity
        }
    }
    
    func animateOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.hazradPopUp.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            self.hazradPopUp.alpha = 0
        }) { (true) in
            self.removeFromSuperview()
        }
    }
    
    @IBAction func clickOnYesButton(_ sender: UIButton) {
        animateOut()
    }
}
