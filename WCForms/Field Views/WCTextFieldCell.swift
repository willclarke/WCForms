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

}

/// A table view cell for an editable WCTextField with the `fieldNameAsPlaceholder` appearance.
internal class WCTextFieldNoFieldNameLabelCell: WCGenericTextFieldCell {

    /// The text field delegate.
    weak var delegate: WCTextField? = nil

    /// Prepare the cell for reuse.
    public override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }

    /// Action for when the text field changes.
    ///
    /// - Parameter sender: The text field being changed.
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        let newValue = sender.text == "" ? nil : sender.text
        delegate?.viewDidUpdateValue(newValue: newValue)
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

/// A table view cell for an editable field that displays its value in a UITextField and also has a field name label.
internal class WCGenericTextFieldAndLabelCell: WCGenericTextFieldCell {

    /// The UILabel for the field name.
    @IBOutlet weak var fieldNameLabel: UILabel!

}

/// A table view cell for an editable WCTextField that also has a field name label.
internal class WCTextFieldCell: WCGenericTextFieldAndLabelCell {

    /// The text field delegate.
    weak var delegate: WCTextField? = nil

    /// Prepare the cell for reuse.
    public override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }

    /// IBAction for when the text area changes editing.
    ///
    /// - Parameter sender: The text field that changed.
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        let newValue = sender.text == "" ? nil : sender.text
        delegate?.viewDidUpdateValue(newValue: newValue)
    }

    /// Delegate function for when a text field has returned.
    ///
    /// - Parameter textField: The text field that returned.
    /// - Returns: Always returns `true`.
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
