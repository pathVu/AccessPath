//
//  CustomView.swift
//  Access Path
//
//  Created by Chetu on 4/17/19.
//  Copyright © 2019 pathVu. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CustomView: UIView{
    
    @IBInspectable var borderWidth: CGFloat = 0.0{
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
}
