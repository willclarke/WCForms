//
//  TextField.swift
//  WCForms
//
//  Created by Will Clarke on 3/4/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation

/// Appearance enum for text fields.
///
/// - stacked: The field name appears on a line above the field value.
/// - stackedCaption: Similar to stacked, but with the field name using the font `UIFontTextStyle.caption`
/// - rightDetail: The field value is on the right side of the cell, and the field name on the left.
/// - fieldNameAsPlaceholder: The field name appears as the placeholder text when being edited. When in read-only mode, the field name is hidden.
public enum WCTextFieldAppearance: FieldCellAppearance {

    case stacked
    case stackedCaption
    case rightDetail
    case fieldNameAsPlaceholder

    /// The nib name for the read-only version of a field in this appearance.
    public var nibName: String {
        switch self {
        case .rightDetail:
            return "WCGenericFieldRightDetailTableViewCell"
        case .fieldNameAsPlaceholder:
            return "WCGenericFieldCell"
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
            return "WCTextFieldRightDetailCell"
        case .fieldNameAsPlaceholder:
            return "WCTextFieldNoFieldNameLabelCell"
        case .stacked:
            return "WCTextFieldCell"
        case .stackedCaption:
            return "WCTextFieldStackedCaptionCell"
        }
    }

    /// The preferred color for the field name label
    public var preferredFieldNameColor: UIColor {
        switch self {
        case .stackedCaption, .fieldNameAsPlaceholder:
            return UIColor.darkGray
        default:
            return UIColor.black
        }
    }

    /// The preferred color for the field of value label.
    public var preferredFieldValueColor: UIColor {
        switch self {
        case .stackedCaption, .fieldNameAsPlaceholder:
            return UIColor.black
        default:
            return UIColor.darkGray
        }
    }

    /// Always returns `true`, because a text field can always become first responder.
    public var canBecomeFirstResponder: Bool {
        return true
    }

    /// Returns `stacked`, the default text field appearance.
    public static var `default`: WCTextFieldAppearance {
        return WCTextFieldAppearance.stacked
    }

    /// Returns all values of the text field appearance.
    public static var allValues: [WCTextFieldAppearance] {
        return [.stacked, .stackedCaption, .rightDetail, .fieldNameAsPlaceholder]
    }

}

public protocol WCTextFieldInputDelegate: class {

    func viewDidUpdateTextField(textField: UITextField)

}

/// A text field for a single line of text.
public class WCTextField: WCGenericField<String, WCTextFieldAppearance>, WCTextFieldInputDelegate {

    /// The minimum length allowed for the text. A string shorter than the minimum length will generate a validation error when the user attempts to complete 
    /// the form. If this property is set to nil, no minimum length will be enforced.
    public var minimumLength: Int?

    /// The maximum length allowed for the text. A string longer than the maximum length will generate a validation error when the user attempts to complete
    /// the form. If this property is set to nil, no maximum length will be enforced.
    public var maximumLength: Int?

    /// The autocapitalization type to use for the text field.
    public var autocapitalizationType = UITextAutocapitalizationType.none {
        didSet {
            if let validCell = lastLoadedEditableCell {
                validCell.valueTextField.autocapitalizationType = autocapitalizationType
            }
        }
    }

    /// The autocorrection style for the text field.
    public var autocorrectionType = UITextAutocorrectionType.default {
        didSet {
            if let validCell = lastLoadedEditableCell {
                validCell.valueTextField.autocorrectionType = autocorrectionType
            }
        }
    }

    /// The spell-checking style for the text field.
    public var spellCheckingType = UITextSpellCheckingType.default {
        didSet {
            if let validCell = lastLoadedEditableCell {
                validCell.valueTextField.spellCheckingType = spellCheckingType
            }
        }
    }

    /// Placeholder text to be set for the text field.
    public var placeholderText: String? = nil {
        didSet {
            if let validCell = lastLoadedEditableCell, let placeholderText = placeholderText {
                validCell.valueTextField.placeholder = placeholderText
            }
        }
    }

    /// The last loaded editable text field cell.
    weak var lastLoadedEditableCell: WCGenericTextFieldCellEditable? = nil

    /// Sets up the read-only version of the cell for this field.
    ///
    /// - Parameter cell: the table view cell.
    public override func setupCell(_ cell: UITableViewCell) {
        super.setupCell(cell)
        if let cell = cell as? WCGenericFieldCell, appearance == .fieldNameAsPlaceholder {
            if let fieldValue = fieldValue, fieldValue != "" {
                cell.valueLabelText = fieldValue
                cell.valueLabelColor = appearance.preferredFieldValueColor
            } else {
                cell.valueLabelText = fieldName
                cell.valueLabelColor = appearance.preferredFieldNameColor
            }
        }
        lastLoadedEditableCell = nil
    }

    /// Sets up the editable version of the cell for this field.
    ///
    /// - Parameter cell: the table view cell.
    public override func setupEditableCell(_ cell: UITableViewCell) {
        if let editableCell = cell as? WCGenericTextFieldCellEditable {
            editableCell.fieldNameText = fieldName
            editableCell.valueTextField.text = fieldValue
            let appearance = self.editableAppearance ?? self.appearance
            if appearance != .fieldNameAsPlaceholder {
                editableCell.valueTextField.placeholder = placeholderText ?? emptyValueLabelText
            }
            editableCell.valueTextField.autocapitalizationType = autocapitalizationType
            editableCell.valueTextField.autocorrectionType = autocorrectionType
            editableCell.valueTextField.spellCheckingType = spellCheckingType
            editableCell.valueTextField.inputAccessoryView = fieldInputAccessory
            editableCell.textFieldDelegate = self
            lastLoadedEditableCell = editableCell
        } else {
            lastLoadedEditableCell = nil
        }
    }

    /// Attempt to make this field to become the first responder.
    public override func becomeFirstResponder() {
        if let lastLoadedEditableCell = lastLoadedEditableCell {
            lastLoadedEditableCell.valueTextField.becomeFirstResponder()
        }
    }

    /// Attempt to make this field resign its first responder status.
    public override func resignFirstResponder() {
        if let lastLoadedEditableCell = lastLoadedEditableCell {
            lastLoadedEditableCell.valueTextField.resignFirstResponder()
        }
    }

    /// Makes sure the value is set if it's required, and that the length is between `minimumLength` and `maximumLength` if they are set.
    ///
    /// - Throws: A `WCFieldValidationError` describing the first error in validating the field.
    public override func validateFieldValue() throws {
        if isRequired && (fieldValue == "" || fieldValue == nil) {
            throw WCFieldValidationError.missingValue(fieldName: fieldName)
        }
        if let fieldValue = fieldValue {
            if let minimumLength = minimumLength, fieldValue.characters.count < minimumLength {
                let errorFormatter = NSLocalizedString("%@ must contain at least %d characters.",
                                                       tableName: "WCForms",
                                                       comment: "Warning that a string is too short. %@ is the field name, %d is the number of characters.")
                let errorString = String(format: errorFormatter, fieldName, minimumLength)
                throw WCFieldValidationError.outOfBounds(fieldName: fieldName, boundsError: errorString)
            }
            if let maximumLength = maximumLength, fieldValue.characters.count > maximumLength {
                let errorFormatter = NSLocalizedString("%@ must contain %d or fewer characters.",
                                                       tableName: "WCForms",
                                                       comment: "Warning that a string is too long. %@ is the field name, %d is the number of characters.")
                let errorString = String(format: errorFormatter, fieldName, maximumLength)
                throw WCFieldValidationError.outOfBounds(fieldName: fieldName, boundsError: errorString)
            }
        }
    }


    // MARK: - WCTextFieldInputDelegate conformance

    public func viewDidUpdateTextField(textField: UITextField) {
        let newValue = textField.text == "" ? nil : textField.text
        viewDidUpdateValue(newValue: newValue)
    }

}
