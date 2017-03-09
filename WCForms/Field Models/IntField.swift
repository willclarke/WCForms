//
//  IntField.swift
//  WCForms
//
//  Created by Will Clarke on 3/4/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation

/// Appearance enum for integer fields.
///
/// - stacked: The field name appears on a line above the field value.
/// - rightDetail: The field value is on the right side of the cell, and the field name on the left.
/// - slider: In edit mode, a `UISlider` is used to set the value. In read-only mode, it mimics the appearance of the `rightDetail` appearance.
public enum WCIntFieldAppearance: FieldCellAppearance {

    case stacked
    case rightDetail
    case slider

    /// The nib name for the read-only version of a field in this appearance.
    public var nibName: String {
        switch self {
        case .rightDetail:
            return "WCGenericFieldRightDetailTableViewCell"
        case .stacked:
            return "WCGenericFieldStackedCell"
        case .slider:
            return "WCGenericFieldRightDetailTableViewCell"
        }
    }

    /// The nib name for the editable version of a field in this appearance.
    public var editableNibName: String {
        switch self {
        case .rightDetail:
            return "WCIntFieldRightDetailCell"
        case .stacked:
            return "WCIntFieldCell"
        case .slider:
            return "WCIntFieldSliderCell"
        }
    }

    /// Returns `false` when the appearance is `slider` because UISlider can not become first responder. Otherwise returns `true`.
    public var canBecomeFirstResponder: Bool {
        switch self {
        case .rightDetail, .stacked:
            return true
        case .slider:
            return false
        }
    }

    /// Returns `rightDetail`, the default Int field appearance.
    public static var `default`: WCIntFieldAppearance {
        return WCIntFieldAppearance.rightDetail
    }

    /// Returns all values of the int field appearance.
    public static var allValues: [WCIntFieldAppearance] {
        return [.stacked, .rightDetail, .slider]
    }

}

/// An integer field.
public class WCIntField: WCGenericField<Int, WCIntFieldAppearance> {

    /// The minimum value allowed for the int. A field value less than this will generate a validation error when the user attempts to complete
    /// the form. This value is also used to set the `minimumValue` of the UISlider when the `slider` appearance is chosen. If this property is set to nil, no
    /// minimum date will be enforced for validation purposes, but the slider will default to a minimumValue of 0.
    public var minimumValue: Int?

    /// The maximum value allowed for the int. A field value greater than this will generate a validation error when the user attempts to complete
    /// the form. This value is also used to set the `maximumValue` of the UISlider when the `slider` appearance is chosen. If this property is set to nil, no
    /// maximum date will be enforced for validation purposes, but the slider will default to a maximumValue of 100.
    public var maximumValue: Int?

    /// Placeholder text to be set for the integer field when it's empty.
    public var placeholderText: String?

    /// The last loaded editable int field cell.
    weak var lastLoadedEditableCell: WCGenericTextFieldAndLabelCell? = nil

    /// Sets up the read-only version of the cell for this field.
    ///
    /// - Parameter cell: the table view cell.
    public override func setupCell(_ cell: UITableViewCell) {
        super.setupCell(cell)
        lastLoadedEditableCell = nil
    }

    /// Sets up the editable version of the cell for this field.
    ///
    /// - Parameter cell: the table view cell.
    public override func setupEditableCell(_ cell: UITableViewCell) {
        if let editableIntCell = cell as? WCGenericTextFieldAndLabelCell {
            lastLoadedEditableCell = editableIntCell
            editableIntCell.fieldValueTextField.inputAccessoryView = self.fieldInputAccessory
        } else {
            lastLoadedEditableCell = nil
        }
        if let editableIntCell = cell as? WCIntFieldCell {
            let intValue: Int = fieldValue ?? 0
            editableIntCell.fieldNameLabel.text = fieldName
            editableIntCell.fieldValueTextField.text = String(intValue)
            editableIntCell.fieldValueTextField.placeholder = placeholderText
            editableIntCell.delegate = self
        }
        if let sliderCell = cell as? WCIntFieldSliderCell {
            let sliderMinimum = minimumValue ?? 0
            let sliderMaximum = maximumValue ?? 100
            var intValue: Int = fieldValue ?? 0
            
            if intValue < sliderMinimum {
                intValue = sliderMinimum
                fieldValue = sliderMinimum
            } else if intValue > sliderMaximum {
                intValue = sliderMaximum
                fieldValue = sliderMaximum
            }
            sliderCell.fieldNameLabel.text = fieldName
            sliderCell.fieldValueLabel.text = String(intValue)
            sliderCell.fieldValueSlider.minimumValue = Float(sliderMinimum)
            sliderCell.fieldValueSlider.maximumValue = Float(sliderMaximum)
            sliderCell.fieldValueSlider.value = Float(intValue)
            sliderCell.delegate = self
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

    /// Makes sure the value is set if it's required, and that the value is between `minimumValue` and `maximumValue` if they are set.
    ///
    /// - Throws: A `WCFieldValidationError` describing the first error in validating the field.
    public override func validateFieldValue() throws {
        if isRequired && fieldValue == nil {
            throw WCFieldValidationError.missingValue(fieldName: fieldName)
        }
        if let fieldValue = fieldValue {
            if let minimumValue = minimumValue, fieldValue < minimumValue {
                let errorFormatter = NSLocalizedString("%@ must be greater than or equal to %d.",
                                                       tableName: "WCForms",
                                                       comment: "Warning that an number is too small. %@ is the field name, %d is the minimum value.")
                let errorString = String(format: errorFormatter, fieldName, minimumValue)
                throw WCFieldValidationError.outOfBounds(fieldName: fieldName, boundsError: errorString)
            }
            if let maximumValue = maximumValue, fieldValue > maximumValue {
                let errorFormatter = NSLocalizedString("%@ must be less than or equal to %d.",
                                                       tableName: "WCForms",
                                                       comment: "Warning that a number is too large. %@ is the field name, %d is the maximum value.")
                let errorString = String(format: errorFormatter, fieldName, maximumValue)
                throw WCFieldValidationError.outOfBounds(fieldName: fieldName, boundsError: errorString)
            }
        }
    }
}
