//
//  FavoritePlaceEdit.swift
//  Access Path
//
//  Created by Nick Sinagra on 8/1/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit

/**
 * This class allows the user to edit or remove their favorite place.
 * Currently, the only edit they can make is renaming.
 */
class MainFavoritesEdit: UIViewController, UITextFieldDelegate {
    
    //UI Outlets
    @IBOutlet weak var placeNameTextBox: CustomTextBox!
    @IBOutlet weak var placeAddressLabel: UITextView!
    @IBOutlet weak var renameFavoriteButton: UIButton!
    @IBOutlet weak var removeFavoriteButton: UIButton!
    @IBOutlet weak var placeNameStatusMessage: UILabel!
    
    //Favorite information (passed from list)
    var placeName:String!
    var placeAddress:String!
    
    //PHP calls class instance
    let pathVuPHP = PHPCalls()
    
    //Shared preferences
    let preferences = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeNameTextBox.text = placeName
        placeAddressLabel.text = placeAddress
        
        //Set default styles
        setStyles()
    }
    
    /**
     * Default styles for text boxes and labels
     */
    func setStyles() {
        placeAddressLabel.layer.borderWidth = 1.5
        placeAddressLabel.layer.borderColor = AppColors.blueButton.cgColor
        placeAddressLabel.layer.cornerRadius = 5
        placeAddressLabel.layer.backgroundColor = AppColors.lightBlue.cgColor
        placeAddressLabel.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        placeNameTextBox.tintColor = AppColors.caretColor
        placeNameTextBox.layer.borderWidth = 1.5
        placeNameTextBox.layer.borderColor = AppColors.darkBlue.cgColor
        placeNameTextBox.delegate = self
    }
    
    /**
     * What happens when the user clicks off of a text field
     * Will defocus the text field being currently edited
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    /**
     * What happens when the user starts editing a text field
     */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentlyEditing(textField: textField)
    }
    
    /**
     * What happens when the user stops editing a text field
     */
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        checkValues()
        placeNameTextBox.layer.borderWidth = 1.5
    }
    
    /**
     * Sets the style of the text box being currently edited by the user
     */
    func currentlyEditing(textField : UITextField) {
        placeNameStatusMessage.text = ""
        placeNameTextBox.layer.borderWidth = 10
        placeNameTextBox.layer.borderColor = AppColors.darkBlue.cgColor
        placeNameTextBox.layer.backgroundColor = UIColor.white.cgColor
    }
    
    /**
     * Checks if the username entered is valid.
     * Paramaters: username must contain greater than 2 characters, usernames must not already exist
     */
    func checkValues() {
        if(placeNameTextBox.text?.count == 0) {
            //If empty, put original name in box
            placeNameStatusMessage.text = placeName
        }
    }
    
    //Rename the favorite
    @IBAction func renameFavoriteButtonPressed(_ sender: Any) {
        let acctid = preferences.string(forKey: PrefKeys.aidKey)
        let fnewname = placeNameTextBox.text
        
        if(fnewname != placeName) {
            if(pathVuPHP.updateFavorite(acctid: acctid!, fname: placeName, fnewname: fnewname!)) {
                print("Favorite updated")
                placeName = fnewname
                placeNameStatusMessage.text = AlertConstant.successfullyUpdated
                placeNameStatusMessage.textColor = AppColors.successBorder
                placeNameTextBox.layer.borderWidth = 10
                placeNameTextBox.layer.borderColor = AppColors.successBorder.cgColor
                placeNameTextBox.layer.backgroundColor = AppColors.successBackground.cgColor
                MainFavoritesInformation.placeName = fnewname
            }
        } else {
            placeNameStatusMessage.text = newName
            placeNameStatusMessage.textColor = AppColors.errorBorder
            placeNameTextBox.layer.borderWidth = 10
            placeNameTextBox.layer.borderColor = AppColors.errorBorder.cgColor
            placeNameTextBox.layer.backgroundColor = AppColors.errorBackground.cgColor
        }
    }
    
    /**
     * Remove favorite, if successful the user will be retuned to the favorites list
     */
    @IBAction func removeFavoriteButtonPressed(_ sender: Any) {
        let acctid = preferences.string(forKey: PrefKeys.aidKey)
        if(pathVuPHP.removeFavorite(acctid: acctid!, fname: placeName)) {
            returnToFavorites()
        } else {
            print("Could not remove favorite")
        }
    }
    
    
    //Go back to the favorites list
    func returnToFavorites() {
        performSegue(withIdentifier: StoryboardIdentifier.unwindSegueToObsList, sender: self)
    }
    
    
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}



extension UITextView {
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
    
}
