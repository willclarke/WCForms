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
    
    public override init(fieldIdentifier: String, fieldName: String) {
        super.init(fieldIdentifier: fieldIdentifier, fieldName: fieldName)
        dateDisplayFormatter.dateStyle = .medium
        dateDisplayFormatter.timeStyle = .none
    }
    
    public override func setupCell(_ cell: UITableViewCell) {
        if let dateCell = cell as? WCGenericFieldTableViewCell {
            dateCell.titleLabel.text = fieldName
            if let dateValue = fieldValue {
                dateCell.valueLabel.text = dateDisplayFormatter.string(from: dateValue)
            } else {
                dateCell.valueLabel.text = NSLocalizedString("None", tableName: "WCForms", comment: "Displayed when there is no value for a field")
            }
        }
    }
    
    public override func setupEditableCell(_ cell: UITableViewCell) {
        if let editableDateCell = cell as? WCDateFieldTableViewCell {
            let dateValue: Date = fieldValue ?? defaultValue ?? Date()
            editableDateCell.fieldNameLabel.text = fieldName
            editableDateCell.datePickerKeyboard.date = dateValue
            editableDateCell.datePickerKeyboard.minimumDate = minimumDate
            editableDateCell.datePickerKeyboard.maximumDate = maximumDate
            editableDateCell.dateDisplayFormatter = dateDisplayFormatter
            editableDateCell.fieldValueTextField.text = dateDisplayFormatter.string(from: dateValue)
            editableDateCell.delegate = self
        }
    }
}
