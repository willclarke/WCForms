//
//  DoubleField.swift
//  WCForms
//
//  Created by Will Clarke on 7/18/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation

/// Appearance enum for double fields.
///
/// - stacked: The field name appears on a line above the field value.
/// - stackedCaption: Similar to stacked, but with the field name using the font `UIFontTextStyle.caption`
/// - rightDetail: The field value is on the right side of the cell, and the field name on the left.
public enum WCDoubleFieldAppearance: FieldCellAppearance {

    case stacked
    case stackedCaption
    case rightDetail

    /// The nib name for the read-only version of a field in this appearance.
    public var nibName: String {
        switch self {
        case .rightDetail:
            return "WCGenericFieldRightDetailTableViewCell"
        case .stacked:
            return "WCGenericFieldStackedCell"
        case .stackedCaption:
            return "WCGenericFieldStackedCaptionCell"
        }
    }

    /// The nib name for the editable version of a field in this appearance.
    public var editableNibName: String {
        switch self {
        case .rightDetail:
            return "WCDoubleFieldRightDetailCell"
        case .stacked:
            return "WCDoubleFieldCell"
        case .stackedCaption:
            return "WCDoubleFieldStackedCaptionCell"
        }
    }

    /// The preferred color for the field name label
    public var preferredFieldNameColor: UIColor {
        switch self {
        case .stackedCaption:
            return UIColor.darkGray
        default:
            return UIColor.black
        }
    }

    /// The preferred color for the field of value label.
    public var preferredFieldValueColor: UIColor {
        switch self {
        case .stackedCaption:
            return UIColor.black
        default:
            return UIColor.darkGray
        }
    }

    /// Returns `false` when the appearance is `slider` because UISlider can not become first responder. Otherwise returns `true`.
    public var canBecomeFirstResponder: Bool {
        switch self {
        case .rightDetail, .stacked, .stackedCaption:
            return true
        }
    }

    /// Returns `rightDetail`, the default Double field appearance.
    public static var `default`: WCDoubleFieldAppearance {
        return WCDoubleFieldAppearance.rightDetail
    }

    /// Returns all values of the double field appearance.
    public static var allValues: [WCDoubleFieldAppearance] {
        return [.stacked, .stackedCaption, .rightDetail]
    }

}

/// An double field.
public class WCDoubleField: WCGenericField<Double, WCDoubleFieldAppearance>, WCTextFieldInputDelegate {

    /// The minimum value allowed for the double. A field value less than this will generate a validation error when the user attempts to complete
    /// the form. This value is also used to set the `minimumValue` of the UISlider when the `slider` appearance is chosen. If this property is set to nil, no
    /// minimum date will be enforced for validation purposes, but the slider will default to a minimumValue of 0.
    public var minimumValue: Double?

    /// The maximum value allowed for the double. A field value greater than this will generate a validation error when the user attempts to complete
    /// the form. This value is also used to set the `maximumValue` of the UISlider when the `slider` appearance is chosen. If this property is set to nil, no
    /// maximum date will be enforced for validation purposes, but the slider will default to a maximumValue of 100.
    public var maximumValue: Double?

    /// Placeholder text to be set for the double field when it's empty.
    public var placeholderText: String?

    /// Text to prepend to the field value when displaying or inputting the value. This will only be shown if the field has a valid value.
    public var prefixText: String? = nil

    /// Text to append to the field value when displaying or inputting the value. This will only be shown if the field has a valid value.
    public var suffixText: String? = nil

    /// A number formatter to use when displaying the value in read-only mode.
    public var numberFormatter: NumberFormatter? = nil

    /// Number of decimal places to show for the value. This will be ignored if a `numberFormatter` is specified.
    public var decimalPlaces: UInt? = nil

    /// Whether or not to show trailing zeroes when the field value has fewer decimal places than the value specified in `decimalPlaces`. This value is ignored 
    /// if `decimalPlaces` is nil or zero. Defaults to `false`.
    public var displaysTrailingZeroes: Bool = false

    /// Characters that are prohibited from being entered into a double field.
    internal lazy var prohibitedCharacters = CharacterSet(charactersIn: "0123456789.").inverted

    /// The last loaded editable double field cell.
    weak var lastLoadedEditableTextCell: WCGenericTextFieldCellEditable? = nil

    /// Sets up the read-only version of the cell for this field.
    ///
    /// - Parameter cell: the table view cell.
    public override func setupCell(_ cell: UITableViewCell) {
        super.setupCell(cell)
        if let readOnlyCell = cell as? WCGenericFieldCell {
            if let doubleValue = fieldValue {
                var displayValue = prefixText ?? ""
                if let userSpecifiedNumberFormatter = self.numberFormatter {
                    displayValue += userSpecifiedNumberFormatter.string(from: NSNumber(floatLiteral: doubleValue)) ?? String(doubleValue)
                } else if let decimalPlaces = self.decimalPlaces {
                    let decimalPlaceNumberFormatter = NumberFormatter()
                    decimalPlaceNumberFormatter.minimumFractionDigits = displaysTrailingZeroes ? Int(decimalPlaces) : 0
                    decimalPlaceNumberFormatter.maximumFractionDigits = Int(decimalPlaces)
                    displayValue += decimalPlaceNumberFormatter.string(from: NSNumber(floatLiteral: doubleValue)) ?? String(doubleValue)
                } else {
                    displayValue += String(doubleValue)
                }
                displayValue += suffixText ?? ""
                readOnlyCell.valueLabelText = String(doubleValue)
            }
        }
        lastLoadedEditableTextCell = nil
    }

    /// Sets up the editable version of the cell for this field.
    ///
    /// - Parameter cell: the table view cell.
    public override func setupEditableCell(_ cell: UITableViewCell) {
        if let editableDoubleCell = cell as? WCGenericTextFieldCellEditable {
            editableDoubleCell.fieldNameText = fieldName
            if let doubleValue = fieldValue {
                editableDoubleCell.valueTextField.text = String(doubleValue)
            } else {
                editableDoubleCell.valueTextField.text = nil
            }
            editableDoubleCell.valueTextField.placeholder = placeholderText ?? emptyValueLabelText
            editableDoubleCell.valueTextField.inputAccessoryView = fieldInputAccessory
            editableDoubleCell.textFieldDelegate = self
            lastLoadedEditableTextCell = editableDoubleCell
        } else {
            lastLoadedEditableTextCell = nil
        }
        if let prefixableCell = cell as? WCTextEntryPrefixingAndSuffixing {
            prefixableCell.prefixText = prefixText
            prefixableCell.suffixText = suffixText
        }
    }

    /// Attempt to make this field to become the first responder.
    public override func becomeFirstResponder() {
        if let lastLoadedEditableCell = lastLoadedEditableTextCell {
            lastLoadedEditableCell.valueTextField.becomeFirstResponder()
        }
    }

    /// Attempt to make this field resign its first responder status.
    public override func resignFirstResponder() {
        if let lastLoadedEditableCell = lastLoadedEditableTextCell {
            lastLoadedEditableCell.valueTextField.resignFirstResponder()
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


    // MARK: - Confromance to WCTextFieldInputDelegate

    public func viewDidUpdateTextField(textField: UITextField) {
        if let validText = textField.text {
            let formattedText = validText.components(separatedBy: prohibitedCharacters).joined(separator: "")
            if formattedText != validText {
                //They somehow entered prohibited characters, perhaps through a paste of using an external keyboard. Remove those characters.
                textField.text = formattedText
            }
            let newValue = Double(formattedText)
            if fieldValue != newValue {
                viewDidUpdateValue(newValue: newValue)
            }
        } else {
            viewDidUpdateValue(newValue: nil)
        }
    }
    
}
