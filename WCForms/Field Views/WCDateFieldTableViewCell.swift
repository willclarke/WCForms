//
//  WCDateFieldTableViewCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

/// A table view cell for an editable date field.
public class WCDateFieldTableViewCell: WCGenericTextFieldAndLabelCell {

    /// A picker view to use as the inputView for the text field's keyboard.
    public var datePickerKeyboard = UIDatePicker()

    /// A formatter to use to format the date value in the text field.
    public var dateDisplayFormatter = DateFormatter()

    /// A delegate to handle actions when the field changes.
    weak var delegate: WCDateField? = nil

    /// Prepare the cell for reuse.
    public override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }

    /// Set up the view when the cell awakes from the nib.
    public override func awakeFromNib() {
        super.awakeFromNib()
        fieldValueTextField.tintColor = UIColor.clear
        datePickerKeyboard.datePickerMode = .date
        datePickerKeyboard.addTarget(self, action: #selector(dateChanged(sender:)), for: UIControlEvents.valueChanged)
        fieldValueTextField.inputView = datePickerKeyboard
    }

    /// IBAction for when the text field changes. We want to always ignore any input entered here and defer to the value in the `datePickerKeyboard`.
    ///
    /// - Parameter sender: The text field that changed.
    @IBAction func dateFieldEditingChanged(_ sender: UITextField) {
        fieldValueTextField.text = dateDisplayFormatter.string(from: datePickerKeyboard.date)
    }

    /// Target action for when the date picker changes dates.
    ///
    /// - Parameter sender: The date picker that changed.
    func dateChanged(sender: UIDatePicker) {
        fieldValueTextField.text = dateDisplayFormatter.string(from: sender.date)
        delegate?.viewDidUpdateValue(newValue: sender.date)
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
        fieldValueTextField.textColor = UIColor.darkGray
    }

}
