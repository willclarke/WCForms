//
//  WCDateFieldCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

/// A table view cell for an editable date field.
internal class WCDateFieldCell: WCGenericTextFieldAndLabelCell {

    /// The delegate for when the date picker changes the date.
    var datePickerDelegate: WCDatePickerInputDelegate? = nil

    /// A picker view to use as the inputView for the text field's keyboard.
    public var datePickerKeyboard = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 320.0, height: 162.0))

    /// A formatter to use to format the date value in the text field.
    public var dateDisplayFormatter = DateFormatter()

    /// The color to make the date text when the field is not active.
    public var inactiveValueColor: UIColor = UIColor.darkGray

    /// Set up the view when the cell awakes from the nib.
    public override func awakeFromNib() {
        super.awakeFromNib()
        fieldValueTextField.tintColor = UIColor.clear
        datePickerKeyboard.datePickerMode = .date
        datePickerKeyboard.addTarget(self, action: #selector(dateChanged(sender:)), for: UIControlEvents.valueChanged)
        datePickerKeyboard.autoresizingMask = .flexibleWidth
        fieldValueTextField.inputView = datePickerKeyboard
    }

    /// Target action for when the date picker changes dates.
    ///
    /// - Parameter sender: The date picker that changed.
    func dateChanged(sender: UIDatePicker) {
        fieldValueTextField.text = dateDisplayFormatter.string(from: sender.date)
        datePickerDelegate?.viewDidUpdateDatePicker(picker: sender)
    }

    /// Text field delegate that prevents characters from being entered manually into the text field through something like an external keyboard.
    ///
    /// - Returns: Always returns `false`.
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }

    /// Text field delegate function for when the user starts editing the text field.
    ///
    /// - Parameter textField: The text field that began editing.
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        fieldValueTextField.textColor = self.tintColor
    }

    /// Text field delegate function for when the user finishes editing the text field.
    ///
    /// - Parameters:
    ///   - textField: The text field that ended editing.
    ///   - reason: The reason the text field ended editing.
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        fieldValueTextField.textColor = inactiveValueColor
    }

}
