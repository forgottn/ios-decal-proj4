//
//  TextInputTableViewCell.swift
//  FGCNetwork
//
//  Created by Peter Duong on 11/24/15.
//  Copyright © 2015 Peter Duong. All rights reserved.
//

import UIKit

public class TextInputTableViewCell: UITableViewCell, UITextFieldDelegate {
    let textfield: UITextField!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        textfield = UITextField(frame: CGRect.null)
        textfield.textColor = UIColor.blackColor()
        textfield.font = UIFont.systemFontOfSize(16)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textfield.delegate = self
        textfield.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        
        addSubview(textfield)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        textfield.frame = CGRect(x: 15.0, y: 0, width: bounds.size.width - 15.0, height: bounds.size.height)
        
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    public func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true
    }

    
}
