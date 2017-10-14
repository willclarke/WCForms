//
//  WCTextFieldCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

/// Protocol for an editable field that uses a UITextField as the input control. All views that use a UITextField to take user input (including IntField,
/// DateField, and others) use this protocol.
public protocol WCGenericTextFieldCellEditable: class {

    /// The name of the field.
    var fieldNameText: String? { get set }

    /// The text field that contains the field value.
    var valueTextField: UITextField { get }

    /// The delegate that should receive notifications when actions occur in the view.
    weak var textFieldDelegate: WCTextFieldInputDelegate? { get set }

}

/// A table view cell for an editable field that displays its value in a UITextField.
internal class WCGenericTextFieldCell: UITableViewCell, UITextFieldDelegate, WCGenericTextFieldCellEditable {

    // MARK: - Conformance to WCGenericTextFieldCellEditable

    /// The name of the field
    var fieldNameText: String? {
        get {
            return fieldValueTextField.placeholder
        }
        set {
            fieldValueTextField.placeholder = newValue
        }
    }

    /// The text field that displays the field value.
    var valueTextField: UITextField {
        return fieldValueTextField
    }

    /// The text field delegate.
    weak var textFieldDelegate: WCTextFieldInputDelegate? = nil


    // MARK: - IBOutlets and IBActions

    /// The UITextField for the field value.
    @IBOutlet weak var fieldValueTextField: UITextField!

    /// Action for when the text field changes.
    ///
    /// - Parameter sender: The text field being changed.
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        textFieldDelegate?.viewDidUpdateTextField(textField: sender)
    }


    // MARK: - View lifecycle functions

    /// Prepare the cell for reuse.
    public override func prepareForReuse() {
        super.prepareForReuse()
        textFieldDelegate = nil
        valueTextField.clearButtonMode = .never
    }


    // MARK: - UITextFieldDelegate functions

    /// Delegate function to resign first responder when the return button is pressed.
    ///
    /// - Parameter textField: The text field that returned.
    /// - Returns: Always returns true.
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /// Called when the text field ends editing. This will call viewDidUpdateTextField one last time to make sure the text field wasn't changed by autocorrect
    /// before dismissing.
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldDelegate?.viewDidUpdateTextField(textField: textField)
    }

}

/// A table view cell for an editable WCTextField with the `fieldNameAsPlaceholder` appearance.
internal class WCTextFieldNoFieldNameLabelCell: WCGenericTextFieldCell {

}

/// A table view cell for an editable field that displays its value in a UITextField and also has a field name label.
internal class WCGenericTextFieldAndLabelCell: WCGenericTextFieldCell {

    /// The name of the field
    override var fieldNameText: String? {
        get {
            return fieldNameLabel.text
        }
        set {
            fieldNameLabel.text = newValue
        }
    }

    /// The UILabel for the field name.
    @IBOutlet weak var fieldNameLabel: UILabel!

}

/// A table view cell for an editable WCTextField that also has a field name label.
internal class WCTextFieldCell: WCGenericTextFieldAndLabelCell {

}
