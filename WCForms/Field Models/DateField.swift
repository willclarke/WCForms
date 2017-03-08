//
//  DateField.swift
//  WCForms
//
//  Created by Will Clarke on 3/4/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation

public enum WCDateFieldAppearance: FieldCellLoadable {
    case stacked
    case rightDetail
    
    public var nibName: String {
        switch self {
        case .rightDetail:
            return "WCGenericFieldRightDetailTableViewCell"
        case .stacked:
            return "WCGenericFieldTableViewCell"
        }
    }
    
    public var editableNibName: String {
        switch self {
        case .rightDetail:
            return "WCDateFieldRightDetailTableViewCell"
        case .stacked:
            return "WCDateFieldTableViewCell"
        }
    }

    public var canBecomeFirstResponder: Bool {
        return true
    }
    
    public static var `default`: WCDateFieldAppearance {
        return WCDateFieldAppearance.stacked
    }
    
    public static var allValues: [WCDateFieldAppearance] {
        return [.stacked, .rightDetail]
    }
}

public class WCDateField: WCGenericField<Date, WCDateFieldAppearance> {
    public var dateDisplayFormatter = DateFormatter()
    public var minimumDate: Date? = nil
    public var maximumDate: Date? = nil
    public var placeholderText: String? = nil
    weak var lastLoadedEditableCell: WCGenericTextFieldAndLabelCell? = nil
    
    public override init(fieldName: String) {
        super.init(fieldName: fieldName)
        dateDisplayFormatter.dateStyle = .medium
        dateDisplayFormatter.timeStyle = .none
    }
    
    public override func setupCell(_ cell: UITableViewCell) {
        if isAbleToCopy && copyValue != nil {
            cell.selectionStyle = .default
        } else {
            cell.selectionStyle = .none
        }

        if let dateCell = cell as? WCGenericFieldTableViewCell {
            dateCell.titleLabel.text = fieldName
            if let dateValue = fieldValue {
                dateCell.valueLabel.text = dateDisplayFormatter.string(from: dateValue)
            } else {
                dateCell.valueLabel.text = NSLocalizedString("None", tableName: "WCForms", comment: "Displayed when there is no value for a field")
            }
        }
        lastLoadedEditableCell = nil
    }
    
    public override func setupEditableCell(_ cell: UITableViewCell) {
        if let editableDateCell = cell as? WCGenericTextFieldAndLabelCell {
            lastLoadedEditableCell = editableDateCell
            editableDateCell.fieldValueTextField.inputAccessoryView = self.fieldInputAccessory
        }
        if let editableDateCell = cell as? WCDateFieldTableViewCell {
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

    public override func becomeFirstResponder() {
        if let lastLoadedEditableCell = lastLoadedEditableCell {
            lastLoadedEditableCell.fieldValueTextField.becomeFirstResponder()
        }
    }

    public override func resignFirstResponder() {
        if let lastLoadedEditableCell = lastLoadedEditableCell {
            lastLoadedEditableCell.fieldValueTextField.resignFirstResponder()
        }
    }

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
