//
//  WCIntFieldTableViewCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

public class WCIntFieldTableViewCell: WCGenericTextFieldTableViewCell {

    weak var delegate: WCIntField? = nil
    lazy var prohibitedCharacters = CharacterSet(charactersIn: "0123456789").inverted

    public override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }

    @IBAction func intTextFieldEditingChanged(_ sender: UITextField) {
        let delegateValue = delegate?.fieldValue
        let newValue = Int(sender.text ?? "")
        if delegateValue != newValue {
            delegate?.viewDidUpdateValue(newValue: newValue)
        }
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.rangeOfCharacter(from: prohibitedCharacters) == nil {
            return true
        } else {
            return false
        }
    }

}
