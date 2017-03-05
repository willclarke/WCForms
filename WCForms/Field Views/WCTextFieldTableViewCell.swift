//
//  WCTextFieldTableViewCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

public class WCGenericTextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var fieldNameLabel: UILabel!
    @IBOutlet weak var fieldValueTextField: UITextField!

}

public class WCTextFieldTableViewCell: WCGenericTextFieldTableViewCell {

    weak var delegate: WCTextField? = nil

    public override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }

    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        delegate?.viewDidUpdateValue(newValue: sender.text)
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
