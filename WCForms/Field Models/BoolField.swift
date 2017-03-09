//
//  BoolField.swift
//  WCForms
//
//  Created by Will Clarke on 3/4/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation

/// Appearance enum for boolean fields.
///
/// - stacked: The field name appears on a line above the field value.
/// - rightDetail: The field value is on the right side of the cell, and the field name on the left.
public enum WCBoolFieldAppearance: FieldCellAppearance {

    case stacked
    case rightDetail

    /// The nib name for the read-only version of a field in this appearance.
    public var nibName: String {
        switch self {
        case .rightDetail:
            return "WCGenericFieldRightDetailTableViewCell"
        case .stacked:
            return "WCGenericFieldTableViewCell"
        }
    }

    /// The nib name for the editable version of a field in this appearance.
    public var editableNibName: String {
        switch self {
        case .rightDetail:
            return "WCBoolFieldTableViewCell"
        case .stacked:
            return "WCBoolFieldStackedTableViewCell"
        }
    }

    /// Always returns `false`, because a boolean field can never become first responder.
    public var canBecomeFirstResponder: Bool {
        return false
    }

    /// Returns `rightDetail`, the default bool field appearance.
    public static var `default`: WCBoolFieldAppearance {
        return WCBoolFieldAppearance.rightDetail
    }

    /// Returns all values of the boolean field appearance.
    public static var allValues: [WCBoolFieldAppearance] {
        return [.stacked, .rightDetail]
    }

}

/// A boolean field.
public class WCBoolField: WCGenericField<Bool, WCBoolFieldAppearance> {

    /// A localized display value for when the value is `true`
    public var onDisplayValue: String = NSLocalizedString("Yes", tableName: "WCForms", comment: "Affirmative response from the user")

    /// A localized display value for when the value is `false`
    public var offDisplayValue: String = NSLocalizedString("No", tableName: "WCForms", comment: "Negative response from the user")

    /// The text to add to the pasteboard when the user copies the boolean field.
    public override var copyValue: String? {
        let boolValue = fieldValue ?? false
        return boolValue ? onDisplayValue : offDisplayValue
    }

    /// Initializer that also sets the default value for the boolean field to false.
    ///
    /// - Parameter fieldName: A localized, user faceing name for the field.
    public override init(fieldName: String) {
        super.init(fieldName: fieldName)
        fieldValue = false
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

        if let readOnlyCell = cell as? WCGenericFieldTableViewCell {
            let boolValue = fieldValue ?? false
            readOnlyCell.fieldNameLabel.text = fieldName
            readOnlyCell.valueLabel.textColor = UIColor.darkGray
            readOnlyCell.valueLabel.text = boolValue ? onDisplayValue : offDisplayValue
        }
    }

    /// Sets up the editable version of the cell for this field.
    ///
    /// - Parameter cell: the table view cell.
    public override func setupEditableCell(_ cell: UITableViewCell) {
        let boolValue = fieldValue ?? false
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
