//
//  WCTextFieldTableViewCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

public class WCTextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var fieldNameLabel: UILabel!
    @IBOutlet weak var fieldValueTextField: UITextField!

    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        let text = sender.text ?? ""
        print("New text field value: \(text)")
    }

}
