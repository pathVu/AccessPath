//
//  CustomTextBox.swift
//  CustomStylesTest
//
//  Created by Nick Sinagra on 5/11/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit

/**
 * This class is used for custom text boxes that have inner padding
 */
class CustomTextBox: UITextField {
    
    let padding = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 10)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
}

class CustomSearch: UITextField {
    
    let padding = UIEdgeInsets(top: 10, left: 50, bottom: 10, right: 40)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
}

class CustomTextBox2: UITextField {
    
    let padding = UIEdgeInsets(top: 10, left: 50, bottom: 10, right: 50)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
}

