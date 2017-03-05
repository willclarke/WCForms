//
//  WCTextFieldTableViewCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

public class WCGenericTextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var fieldValueTextField: UITextField!

}

public class WCTextFieldNoLabelCell: WCGenericTextFieldTableViewCell {

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

public class WCGenericTextFieldAndLabelCell: WCGenericTextFieldTableViewCell {
    
    @IBOutlet weak var fieldNameLabel: UILabel!

}

public class WCTextFieldTableViewCell: WCGenericTextFieldAndLabelCell {

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
