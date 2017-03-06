//
//  BoolField.swift
//  WCForms
//
//  Created by Will Clarke on 3/4/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation

public enum WCBoolFieldAppearance: FieldCellLoadable {
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
            return "WCBoolFieldTableViewCell"
        case .stacked:
            return "WCBoolFieldStackedTableViewCell"
        }
    }

    public var canBecomeFirstResponder: Bool {
        return false
    }
    
    public static var `default`: WCBoolFieldAppearance {
        return WCBoolFieldAppearance.stacked
    }
    
    public static var allValues: [WCBoolFieldAppearance] {
        return [.stacked, .rightDetail]
    }
}

public class WCBoolField: WCGenericField<Bool, WCBoolFieldAppearance> {
    public var onDisplayValue: String = "Yes"
    public var offDisplayValue: String = "No"

    public override var copyValue: String? {
        let boolValue = fieldValue ?? defaultValue ?? false
        return boolValue ? onDisplayValue : offDisplayValue
    }

    public override init(fieldName: String) {
        super.init(fieldName: fieldName)
        fieldValue = false
    }

    public override func setupCell(_ cell: UITableViewCell) {
        if isAbleToCopy && copyValue != nil {
            cell.selectionStyle = .default
        } else {
            cell.selectionStyle = .none
        }

        if let readOnlyCell = cell as? WCGenericFieldTableViewCell {
            let boolValue = fieldValue ?? defaultValue ?? false
            readOnlyCell.titleLabel.text = fieldName
            readOnlyCell.valueLabel.textColor = UIColor.darkGray
            readOnlyCell.valueLabel.text = boolValue ? onDisplayValue : offDisplayValue
        }
    }
    
    public override func setupEditableCell(_ cell: UITableViewCell) {
        let boolValue = fieldValue ?? defaultValue ?? false
        if let editableBoolCell = cell as? WCBoolFieldTableViewCell {
            editableBoolCell.fieldNameLabel.text = fieldName
            editableBoolCell.fieldValueSwitch.isOn = boolValue
            editableBoolCell.delegate = self
        }
        if let stackedBoolCell = cell as? WCBoolFieldStackedTableViewCell {
            stackedBoolCell.onDisplayValueLabel.text = onDisplayValue
            stackedBoolCell.offDisplayValueLabel.text = offDisplayValue
            if boolValue {
                stackedBoolCell.onDisplayValueLabel.textColor = UIColor.darkGray
                stackedBoolCell.offDisplayValueLabel.textColor = UIColor.lightGray
            } else {
                stackedBoolCell.onDisplayValueLabel.textColor = UIColor.lightGray
                stackedBoolCell.offDisplayValueLabel.textColor = UIColor.darkGray
            }
            stackedBoolCell.delegate = self
        }
    }
}
