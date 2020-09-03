//
//  EmailSupportPage.swift
//  Access Path
//
//  Created by Nick Sinagra on 5/25/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit
import MessageUI

/**
 * Shows a support screen the user can send an email from.
 */
class MainSettingsSupport: UIViewController {
    
    //Shared Preferences
    let preferences = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func sendEmailBtnPressed(_ sender: Any) {
        let composeVC = MFMailComposeViewController()
        
        if MFMailComposeViewController.canSendMail() {
            composeVC.mailComposeDelegate = self
            
            //Set the recipient to Nicks
            composeVC.setToRecipients([ArcGISLicenceKey.nickSinagraEmail])
            
            //Set the subject to include accound ID
            composeVC.setSubject("\(ArcGISLicenceKey.accessPathiOSSupport) (" + preferences.string(forKey: PrefKeys.aidKey)! + ")")
            self.present(composeVC, animated: true, completion: nil)
        }
    }
    
    //Go back to previous screen
    @IBAction func dismissView(_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

//Contains delegate functions for the email view controller
extension MainSettingsSupport: MFMailComposeViewControllerDelegate {
    
    //Gets the email result and closes the email view controller
    //User will land back on the support page
    func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            debugPrint("Mail cancelled")
            break
        case MFMailComposeResult.saved.rawValue:
            debugPrint("Mail saved")
            break
        case MFMailComposeResult.sent.rawValue:
            break
        case MFMailComposeResult.failed.rawValue:
            debugPrint("Mail sent failure: %@", [error?.localizedDescription])
            break
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
}
