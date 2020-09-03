//
//  CustomTextBox.swift
//  CustomStylesTest
//
//  Created by Nick Sinagra on 5/11/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import UIKit

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
