//
//  CurrencyField.swift
//  WCForms
//
//  Created by Will Clarke on 7/19/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation

/// Appearance enum for double fields.
///
/// - stacked: The field name appears on a line above the field value.
/// - stackedCaption: Similar to stacked, but with the field name using the font `UIFontTextStyle.caption`
/// - rightDetail: The field value is on the right side of the cell, and the field name on the left.
public enum WCCurrencyFieldAppearance: FieldCellAppearance {

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
            return "WCCurrencyFieldRightDetailCell"
        case .stacked:
            return "WCCurrencyFieldCell"
        case .stackedCaption:
            return "WCCurrencyFieldStackedCaptionCell"
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

    /// Returns `rightDetail`, the default Currency field appearance.
    public static var `default`: WCCurrencyFieldAppearance {
        return WCCurrencyFieldAppearance.rightDetail
    }

    /// Returns all values of the double field appearance.
    public static var allValues: [WCCurrencyFieldAppearance] {
        return [.stacked, .stackedCaption, .rightDetail]
    }
    
}

protocol WCCurrencyFieldInputDelegate: class {

    func viewDidUpdateCurrencyValue(with newValue: Double?)

}

/// A currency field.
public class WCCurrencyField: WCGenericField<Double, WCCurrencyFieldAppearance> {

    /// The minimum value allowed for the double. A field value less than this will generate a validation error when the user attempts to complete
    /// the form. If this property is set to `nil`, no minimum date will be enforced for validation purposes.
    public var minimumValue: Double?

    /// The maximum value allowed for the double. A field value greater than this will generate a validation error when the user attempts to complete
    /// the form. If this property is set to `nil`, no maximum date will be enforced for validation purposes.
    public var maximumValue: Double?

    /// Placeholder text to be set for the currency field when it's empty.
    public var placeholderText: String?

    /// The last loaded editable double field cell.
    weak var lastLoadedEditableCurrencyCell: WCCurrencyFieldCell? = nil

    /// The formatter to use to display the currency when it's not being edited.
    private var currencyFormatter: NumberFormatter = {
        let newFormatter = NumberFormatter()
        newFormatter.numberStyle = .currency
        return newFormatter
        }()
        {
        didSet {
            lastLoadedEditableCurrencyCell?.currencyFormatter = currencyFormatter
        }
    }

    /// The locale of the currency. If not specified, the device's Locale will be used.
    public var locale: Locale {
        get {
            return currencyFormatter.locale
        }
        set {
            currencyFormatter.locale = newValue
        }
    }

    /// Whether or not the currency formatter should show decimals
    public var showsDecimalPlaces: Bool = true {
        didSet {
            if showsDecimalPlaces {
                let temporaryCurrencyFormatter = NumberFormatter()
                temporaryCurrencyFormatter.numberStyle = .currency
                temporaryCurrencyFormatter.locale = currencyFormatter.locale
                currencyFormatter = temporaryCurrencyFormatter
            } else {
                currencyFormatter.maximumFractionDigits = 0
            }
        }
    }

    /// Sets up the read-only version of the cell for this field.
    ///
    /// - Parameter cell: the table view cell.
    public override func setupCell(_ cell: UITableViewCell) {
        super.setupCell(cell)
        if let readOnlyCell = cell as? WCGenericFieldCell {
            if let doubleValue = fieldValue {
                let currencyNumber = NSNumber(floatLiteral: doubleValue)
                readOnlyCell.valueLabelText = currencyFormatter.string(from: currencyNumber)
            }
        }
        lastLoadedEditableCurrencyCell = nil
    }

    /// Sets up the editable version of the cell for this field.
    ///
    /// - Parameter cell: the table view cell.
    public override func setupEditableCell(_ cell: UITableViewCell) {
        if let editableGenericTextCell = cell as? WCGenericTextFieldCellEditable {
            editableGenericTextCell.fieldNameText = fieldName
            if let doubleValue = fieldValue {
                let currencyNumber = NSNumber(floatLiteral: doubleValue)
                editableGenericTextCell.valueTextField.text = currencyFormatter.string(from: currencyNumber)
            } else {
                editableGenericTextCell.valueTextField.text = nil
            }
            editableGenericTextCell.valueTextField.placeholder = placeholderText ?? emptyValueLabelText
            editableGenericTextCell.valueTextField.inputAccessoryView = fieldInputAccessory
        }
        if let editableCurrencyCell = cell as? WCCurrencyFieldCell {
            editableCurrencyCell.currencyFormatter = self.currencyFormatter
            editableCurrencyCell.currencyFieldDelegate = self
            lastLoadedEditableCurrencyCell = editableCurrencyCell
        } else {
            lastLoadedEditableCurrencyCell = nil
        }
    }

    /// Attempt to make this field to become the first responder.
    public override func becomeFirstResponder() {
        if let lastLoadedEditableCell = lastLoadedEditableCurrencyCell {
            lastLoadedEditableCell.valueTextField.becomeFirstResponder()
        }
    }

    /// Attempt to make this field resign its first responder status.
    public override func resignFirstResponder() {
        if let lastLoadedEditableCell = lastLoadedEditableCurrencyCell {
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

}

extension WCCurrencyField: WCCurrencyFieldInputDelegate {

    func viewDidUpdateCurrencyValue(with newValue: Double?) {
        if fieldValue != newValue {
            viewDidUpdateValue(newValue: newValue)
        }
    }

}
