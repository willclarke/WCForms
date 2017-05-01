//
//  WCTextFieldCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

/// A table view cell for an editable field that displays its value in a UITextField.
internal class WCGenericTextFieldCell: UITableViewCell, UITextFieldDelegate {

    /// The UITextField for the field value.
    @IBOutlet weak var fieldValueTextField: UITextField!

    /// The text field delegate.
    weak var textFieldDelegate: WCTextFieldInputDelegate? = nil

    /// Prepare the cell for reuse.
    public override func prepareForReuse() {
        super.prepareForReuse()
        textFieldDelegate = nil
    }

    /// Action for when the text field changes.
    ///
    /// - Parameter sender: The text field being changed.
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        textFieldDelegate?.viewDidUpdateTextField(textField: sender)
    }

    /// Delegate function to resign first responder when the return button is pressed.
    ///
    /// - Parameter textField: The text field that returned.
    /// - Returns: Always returns true.
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

/// A table view cell for an editable WCTextField with the `fieldNameAsPlaceholder` appearance.
internal class WCTextFieldNoFieldNameLabelCell: WCGenericTextFieldCell {

}

/// A table view cell for an editable field that displays its value in a UITextField and also has a field name label.
internal class WCGenericTextFieldAndLabelCell: WCGenericTextFieldCell {

    /// The UILabel for the field name.
    @IBOutlet weak var fieldNameLabel: UILabel!

}

/// A table view cell for an editable WCTextField that also has a field name label.
internal class WCTextFieldCell: WCGenericTextFieldAndLabelCell {

}
