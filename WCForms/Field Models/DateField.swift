//
//  DateField.swift
//  WCForms
//
//  Created by Will Clarke on 3/4/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation

/// Appearance enum for date fields.
///
/// - stacked: The field name appears on a line above the field value.
/// - rightDetail: The field value is on the right side of the cell, and the field name on the left.
public enum WCDateFieldAppearance: FieldCellAppearance {

    case stacked
    case rightDetail

    /// The nib name for the read-only version of a field in this appearance.
    public var nibName: String {
        switch self {
        case .rightDetail:
            return "WCGenericFieldRightDetailTableViewCell"
        case .stacked:
            return "WCGenericFieldStackedCell"
        }
    }

    /// The nib name for the editable version of a field in this appearance.
    public var editableNibName: String {
        switch self {
        case .rightDetail:
            return "WCDateFieldRightDetailCell"
        case .stacked:
            return "WCDateFieldCell"
        }
    }

    /// Always returns `true`, because a date field can always become first responder.
    public var canBecomeFirstResponder: Bool {
        return true
    }

    /// Returns `stacked`, the default date field appearance.
    public static var `default`: WCDateFieldAppearance {
        return WCDateFieldAppearance.stacked
    }

    /// Returns all values of the date field appearance.
    public static var allValues: [WCDateFieldAppearance] {
        return [.stacked, .rightDetail]
    }

}

/// A date field for a specific day.
public class WCDateField: WCGenericField<Date, WCDateFieldAppearance> {

    /// Formatter to use to display the date to the user. By default, this will use a `dateStyle` of `DateFormatter.Style.medium` (and no `timeStyle`)
    public var dateDisplayFormatter = DateFormatter()

    /// The minimum date allowed for the field value. A date before this date will generate a validation error when the user attempts to complete
    /// the form. This date is also used to set the `minimumDate` of the UIDatePicker used to set the field. If this property is set to nil, no minimum date 
    /// will be enforced.
    public var minimumDate: Date? = nil

    /// The maximum date allowed for the field value. A date after this date will generate a validation error when the user attempts to complete
    /// the form. This date is also used to set the `maximumDate` of the UIDatePicker used to set the field. If this property is set to nil, no maximum date
    /// will be enforced.
    public var maximumDate: Date? = nil

    /// Placeholder text to be set for the text field.
    public var placeholderText: String? = nil

    /// The last loaded editable date field cell.
    weak var lastLoadedEditableCell: WCGenericTextFieldAndLabelCell? = nil

    /// Initializer that sets the initial date formatter style.
    ///
    /// - Parameter fieldName: A user facing, localized name for the field.
    public override init(fieldName: String) {
        super.init(fieldName: fieldName)
        dateDisplayFormatter.dateStyle = .medium
        dateDisplayFormatter.timeStyle = .none
    }

    /// Sets up the read-only version of the cell for this field.
    ///
    /// - Parameter cell: the table view cell.
    public override func setupCell(_ cell: UITableViewCell) {
        if isAbleToCopy && copyValue != nil {
            cell.selectionStyle = .default
        } else {
            cell.selectionStyle = .none
        }

        if let dateCell = cell as? WCGenericFieldWithFieldNameCell {
            dateCell.fieldNameLabel.text = fieldName
            if let dateValue = fieldValue {
                dateCell.valueLabel.text = dateDisplayFormatter.string(from: dateValue)
            } else {
                dateCell.valueLabel.text = NSLocalizedString("None", tableName: "WCForms", comment: "Displayed when there is no value for a field")
            }
        }
        lastLoadedEditableCell = nil
    }

    /// Sets up the editable version of the cell for this field.
    ///
    /// - Parameter cell: the table view cell.
    public override func setupEditableCell(_ cell: UITableViewCell) {
        if let editableDateCell = cell as? WCGenericTextFieldAndLabelCell {
            lastLoadedEditableCell = editableDateCell
            editableDateCell.fieldValueTextField.inputAccessoryView = self.fieldInputAccessory
        }
        if let editableDateCell = cell as? WCDateFieldCell {
            let dateValue: Date = fieldValue ?? Date()
            editableDateCell.fieldNameLabel.text = fieldName
            editableDateCell.datePickerKeyboard.date = dateValue
            editableDateCell.datePickerKeyboard.minimumDate = minimumDate
            editableDateCell.datePickerKeyboard.maximumDate = maximumDate
            editableDateCell.dateDisplayFormatter = dateDisplayFormatter
            if let initialValue = fieldValue {
                editableDateCell.fieldValueTextField.text = dateDisplayFormatter.string(from: initialValue)
            } else {
                editableDateCell.fieldValueTextField.text = nil
            }
            editableDateCell.fieldValueTextField.placeholder = placeholderText
            editableDateCell.delegate = self
        }
    }

    /// Attempt to make this field to become the first responder.
    public override func becomeFirstResponder() {
        if let lastLoadedEditableCell = lastLoadedEditableCell {
            lastLoadedEditableCell.fieldValueTextField.becomeFirstResponder()
        }
    }

    /// Attempt to make this field resign its first responder status.
    public override func resignFirstResponder() {
        if let lastLoadedEditableCell = lastLoadedEditableCell {
            lastLoadedEditableCell.fieldValueTextField.resignFirstResponder()
        }
    }

    /// Makes sure the value is set if it's required, and that the date is between `minimumDate` and `maximumDate` if they are set.
    ///
    /// - Throws: A `WCFieldValidationError` describing the first error in validating the field.
    public override func validateFieldValue() throws {
        if isRequired && fieldValue == nil {
            throw WCFieldValidationError.missingValue(fieldName: fieldName)
        }
        if let chosenDate = fieldValue {
            if let minimumDate = minimumDate, let maximumDate = maximumDate, (chosenDate < minimumDate || chosenDate > maximumDate) {
                let errorFormatter = NSLocalizedString("%@ must be between %@ and %@.",
                                                       tableName: "WCForms",
                                                       comment: "Warning that a date must occur between specified dates. %@ represent the dates.")
                let minimumDateString = dateDisplayFormatter.string(from: minimumDate)
                let maximumDateString = dateDisplayFormatter.string(from: maximumDate)
                let errorString = String(format: errorFormatter, fieldName, minimumDateString, maximumDateString)
                throw WCFieldValidationError.outOfBounds(fieldName: fieldName, boundsError: errorString)
            } else if let minimumDate = minimumDate, chosenDate < minimumDate {
                let errorFormatter = NSLocalizedString("%@ must be on or after %@.",
                                                       tableName: "WCForms",
                                                       comment: "Warning that a date must occur on or after a specified date. %@ represent the dates.")
                let minimumDateString = dateDisplayFormatter.string(from: minimumDate)
                let errorString = String(format: errorFormatter, fieldName, minimumDateString)
                throw WCFieldValidationError.outOfBounds(fieldName: fieldName, boundsError: errorString)
            } else if let maximumDate = maximumDate, chosenDate > maximumDate {
                let errorFormatter = NSLocalizedString("%@ must be on or before %@.",
                                                       tableName: "WCForms",
                                                       comment: "Warning that a must occur on or before a specified date. %@ represent the dates.")
                let maximumDateString = dateDisplayFormatter.string(from: maximumDate)
                let errorString = String(format: errorFormatter, fieldName, maximumDateString)
                throw WCFieldValidationError.outOfBounds(fieldName: fieldName, boundsError: errorString)
            }
        }
    }

}
