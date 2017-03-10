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
        case .stackedCaption:
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

/// A text field for a single line of text.
public class WCTextField: WCGenericField<String, WCTextFieldAppearance> {

    /// The minimum length allowed for the text. A string shorter than the minimum length will generate a validation error when the user attempts to complete 
    /// the form. If this property is set to nil, no minimum length will be enforced.
    public var minimumLength: Int?

    /// The maximum length allowed for the text. A string longer than the maximum length will generate a validation error when the user attempts to complete
    /// the form. If this property is set to nil, no maximum length will be enforced.
    public var maximumLength: Int?

    /// Placeholder text to be set for the text field.
    public var placeholderText: String? = nil {
        didSet {
            if let validCell = lastLoadedEditableCell, let placeholderText = placeholderText {
                validCell.fieldValueTextField.placeholder = placeholderText
            }
        }
    }

    /// The last loaded editable text field cell.
    weak var lastLoadedEditableCell: WCGenericTextFieldCell? = nil

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
        if let editableTextCell = cell as? WCGenericTextFieldCell {
            lastLoadedEditableCell = editableTextCell
            editableTextCell.fieldValueTextField.inputAccessoryView = self.fieldInputAccessory
        }
        if let editableTextCell = cell as? WCTextFieldNoFieldNameLabelCell {
            editableTextCell.fieldValueTextField.text = fieldValue
            editableTextCell.fieldValueTextField.placeholder = placeholderText ?? fieldName
            editableTextCell.delegate = self
        }
        if let editableTextCell = cell as? WCTextFieldCell {
            editableTextCell.fieldNameLabel.text = fieldName
            editableTextCell.fieldValueTextField.text = fieldValue
            if let placeholderText = placeholderText {
                editableTextCell.fieldValueTextField.placeholder = placeholderText
            }
            editableTextCell.delegate = self
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

}
