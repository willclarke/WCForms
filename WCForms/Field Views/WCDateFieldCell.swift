//
//  WCDateFieldCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

/// A protocol for views that can be used to display a date field.
public protocol WCGenericDateFieldEditable: WCGenericTextFieldCellEditable {

    /// The delegate that should be called when the user picks a new date.
    var datePickerDelegate: WCDatePickerInputDelegate? { get set }

    /// The formatter that should be used to display the chosen date to the user.
    var dateDisplayFormatter: DateFormatter { get set }

    /// The type of selection that the user should be making.
    var dateSelectionType: WCDateFieldSelectionType { get set }

    /// The color of the text field when the field is not first responder.
    var inactiveValueColor: UIColor { get set }

    /// Update the date picker with date parameters.
    ///
    /// - Parameters:
    ///   - date: The currently selected date.
    ///   - minimumDate: The minimum date that can be selected by the picker.
    ///   - maximumDate: The maximum date that can be selected by the picker.
    func updateDatePicker(withDate date: Date?, minimumDate: Date?, maximumDate: Date?, timeZone: TimeZone?)

}


/// A table view cell for an editable date field.
internal class WCDateFieldCell: WCGenericTextFieldAndLabelCell, WCGenericDateFieldEditable {

    /// The delegate for when the date picker changes the date.
    var datePickerDelegate: WCDatePickerInputDelegate? = nil

    /// A picker view to use as the inputView for the text field's keyboard.
    public var datePickerKeyboard = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 320.0, height: 162.0))

    /// A formatter to use to format the date value in the text field.
    public var dateDisplayFormatter = DateFormatter()

    /// The color to make the date text when the field is not active.
    public var inactiveValueColor: UIColor = UIColor.darkGray

    /// The type of date selection to make.
    public var dateSelectionType: WCDateFieldSelectionType = .date {
        didSet {
            datePickerKeyboard.datePickerMode = dateSelectionType.datePickerMode
        }
    }

    var isEmpty: Bool {
        return fieldValueTextField.text?.isEmpty ?? true
    }

    /// Set up the view when the cell awakes from the nib.
    public override func awakeFromNib() {
        super.awakeFromNib()
        fieldValueTextField.tintColor = self.tintColor
        datePickerKeyboard.datePickerMode = .date
        datePickerKeyboard.addTarget(self, action: #selector(dateChanged(sender:)), for: UIControlEvents.valueChanged)
        datePickerKeyboard.autoresizingMask = .flexibleWidth
        fieldValueTextField.inputView = datePickerKeyboard
    }

    /// Target action for when the date picker changes dates.
    ///
    /// - Parameter sender: The date picker that changed.
    @objc func dateChanged(sender: UIDatePicker) {
        fieldValueTextField.text = dateDisplayFormatter.string(from: sender.date)
        fieldValueTextField.tintColor = self.isEmpty ? self.tintColor : UIColor.clear
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
        fieldValueTextField.tintColor = self.isEmpty ? self.tintColor : UIColor.clear
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

    /// Update the date picker with date parameters.
    ///
    /// - Parameters:
    ///   - date: The currently selected date.
    ///   - minimumDate: The minimum date that can be selected by the picker.
    ///   - maximumDate: The maximum date that can be selected by the picker.
    public func updateDatePicker(withDate date: Date?, minimumDate: Date? = nil, maximumDate: Date? = nil, timeZone: TimeZone? = nil) {
        if let setDate = date {
            datePickerKeyboard.date = setDate
        }
        datePickerKeyboard.minimumDate = minimumDate
        datePickerKeyboard.maximumDate = maximumDate
        datePickerKeyboard.timeZone = timeZone
    }

}
