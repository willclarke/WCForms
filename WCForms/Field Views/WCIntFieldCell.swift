//
//  WCIntFieldCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

/// A table view cell for an editable integer field.
internal class WCIntFieldCell: WCGenericTextFieldAndLabelCell {

    /// A delegate to handle actions when the field changes.
    weak var delegate: WCIntField? = nil

    /// Characters that are prohibited from being entered into an int field.
    lazy var prohibitedCharacters = CharacterSet(charactersIn: "0123456789").inverted

    /// Prepare the cell for reuse.
    public override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }

    /// IBAction for when an int field changes.
    ///
    /// - Parameter sender: The text field that changed.
    @IBAction func intTextFieldEditingChanged(_ sender: UITextField) {
        let delegateValue = delegate?.fieldValue
        let newValue = Int(sender.text ?? "")
        if delegateValue != newValue {
            delegate?.viewDidUpdateValue(newValue: newValue)
        }
    }

    /// Text field delegate function for when characters change, to make sure prohibited characters aren't entered through something like an external keyboard.
    ///
    /// - Parameters:
    ///   - textField: The text field that was edited.
    ///   - range: The range of characters that was changed.
    ///   - string: the new characters that are being added
    /// - Returns: `false` if the characters being added are in the array of prohibited characters, `true` otherwise.
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.rangeOfCharacter(from: prohibitedCharacters) == nil {
            return true
        } else {
            return false
        }
    }

}
