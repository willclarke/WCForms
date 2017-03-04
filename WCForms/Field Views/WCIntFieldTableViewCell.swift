//
//  WCIntFieldTableViewCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

public class WCIntFieldTableViewCell: WCTextFieldTableViewCell {

    @IBAction func intTextFieldEditingChanged(_ sender: UITextField) {
        let text = sender.text ?? ""
        print("Int field value: \(text)")
    }
    
}
