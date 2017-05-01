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
/// - stackedCaption: Similar to stacked, but with the field name using the font `UIFontTextStyle.caption`
/// - rightDetail: The field value is on the right side of the cell, and the field name on the left.
/// - slider: In edit mode, a `UISlider` is used to set the value. In read-only mode, it mimics the appearance of the `rightDetail` appearance.
public enum WCIntFieldAppearance: FieldCellAppearance {

    case stacked
    case stackedCaption
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
        case .stackedCaption:
            return "WCGenericFieldStackedCaptionCell"
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
        case .stackedCaption:
            return "WCIntFieldStackedCaptionCell"
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
        return [.stacked, .stackedCaption, .rightDetail, .slider]
    }

}

/// An integer field.
public class WCIntField: WCGenericField<Int, WCIntFieldAppearance>, WCTextFieldInputDelegate {

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

    /// A formatter for the integer. All "#" characters will be replaced with a number entered by the user; other characters will be used to format the
    /// display of the integer. For example, "###-##-####" would format a social security number. If the user does not enter enough numbers, a validation error
    /// will occur (if field validation is enabled for the form). Note: format masks can not contain numbers.
    public var numberFormatMask: String? {
        didSet {
            if let numberFormatMask = numberFormatMask {
                let numberCharacters = prohibitedCharacters.inverted
                self.numberFormatMask = numberFormatMask.components(separatedBy: numberCharacters).joined(separator: "")
            }
        }
    }

    /// Characters that are prohibited from being entered into an int field.
    internal lazy var prohibitedCharacters = CharacterSet(charactersIn: "0123456789").inverted

    /// The last loaded editable int field cell.
    weak var lastLoadedEditableCell: WCGenericTextFieldAndLabelCell? = nil

    /// Sets up the read-only version of the cell for this field.
    ///
    /// - Parameter cell: the table view cell.
    public override func setupCell(_ cell: UITableViewCell) {
        super.setupCell(cell)
        if let readOnlyCell = cell as? WCGenericFieldCell {
            if let intValue = fieldValue {
                let parsedValue = parseValue(forUserInput: String(intValue), withInsertionIndex: nil)
                readOnlyCell.valueLabelText = parsedValue.display
            }
        }
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
            editableIntCell.fieldNameLabel.text = fieldName
            if let intValue = fieldValue {
                let parsedValue = parseValue(forUserInput: String(intValue), withInsertionIndex: nil)
                editableIntCell.fieldValueTextField.text = parsedValue.display
            } else {
                editableIntCell.fieldValueTextField.text = nil
            }
            if let placeholderText = placeholderText {
                editableIntCell.fieldValueTextField.placeholder = placeholderText
            }
            editableIntCell.textFieldDelegate = self
        }
        if let sliderCell = cell as? WCIntFieldSliderCell {
            let sliderMinimum = minimumValue ?? 0
            let sliderMaximum = maximumValue ?? 100
            var intValue: Int = fieldValue ?? sliderMinimum

            if intValue < sliderMinimum {
                intValue = sliderMinimum
                fieldValue = sliderMinimum
            } else if intValue > sliderMaximum {
                intValue = sliderMaximum
                fieldValue = sliderMaximum
            }
            let parsedValue = parseValue(forUserInput: String(intValue), withInsertionIndex: nil)
            sliderCell.fieldNameLabel.text = fieldName
            sliderCell.fieldValueLabel.text = parsedValue.display
            sliderCell.fieldValueSlider.minimumValue = Float(sliderMinimum)
            sliderCell.fieldValueSlider.maximumValue = Float(sliderMaximum)
            sliderCell.fieldValueSlider.value = Float(intValue)
            sliderCell.delegate = self
        }
    }

    func parseValue(forUserInput userInput: String,
                    withInsertionIndex insertionIndex: String.Index?) -> (display: String, value: Int?, newInsertionIndex: String.Index?)
    {
        if let numberFormatMask = numberFormatMask {
            var numberCharactersBeforeInsertionPoint: String = ""
            var newInsertionIndex: String.Index? = nil
            if let validInsertionIndex = insertionIndex {
                numberCharactersBeforeInsertionPoint = userInput.substring(to: validInsertionIndex)
                                                                .components(separatedBy: prohibitedCharacters)
                                                                .joined(separator: "")
            }
            let numberCharacters = userInput.components(separatedBy: prohibitedCharacters).joined(separator: "")
            var unusedNumberCharacters = numberCharacters
            if let intValue = Int(numberCharacters) {
                let expectedNumberOfNumbers = numberFormatMask.components(separatedBy: "#").count - 1
                if numberCharacters.characters.count > expectedNumberOfNumbers {
                    var preDisplayString = ""
                    for character in unusedNumberCharacters.characters {
                        if numberCharactersBeforeInsertionPoint.isEmpty {
                            break
                        } else if character == numberCharactersBeforeInsertionPoint.remove(at: numberCharactersBeforeInsertionPoint.startIndex) {
                            preDisplayString.append(character)
                        } else {
                            break
                        }
                    }
                    return (display: numberCharacters, value: intValue, newInsertionIndex: preDisplayString.endIndex)
                }
                var displayString = ""
                for formatCharacter in numberFormatMask.characters {
                    if unusedNumberCharacters.isEmpty {
                        break
                    }
                    if formatCharacter == "#" {
                        let nextNumberCharacter = unusedNumberCharacters.remove(at: numberCharacters.startIndex)
                        displayString.characters.append(nextNumberCharacter)
                        if !numberCharactersBeforeInsertionPoint.isEmpty
                            && nextNumberCharacter == numberCharactersBeforeInsertionPoint.remove(at: numberCharactersBeforeInsertionPoint.startIndex)
                        {
                            if numberCharactersBeforeInsertionPoint.isEmpty {
                                newInsertionIndex = displayString.endIndex
                            }
                        }
                    } else {
                        displayString.characters.append(formatCharacter)
                    }
                }
                return (display: displayString, value: intValue, newInsertionIndex: newInsertionIndex)
            } else {
                let emptyString = ""
                return (display: emptyString, value: nil, emptyString.endIndex)
            }
        } else if let intValue = Int(userInput) {
            return (display: userInput, value: intValue, newInsertionIndex: insertionIndex)
        } else {
            let emptyString = ""
            return (display: emptyString, value: nil, newInsertionIndex: emptyString.endIndex)
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


    // MARK: - Confromance to WCTextFieldInputDelegate

    public func viewDidUpdateTextField(textField: UITextField) {
        if let userInput = textField.text {
            var insertionIndex: String.Index? = nil
            if let validRange = textField.selectedTextRange {
                let offset = textField.offset(from: textField.beginningOfDocument, to: validRange.end)
                insertionIndex = userInput.index(userInput.startIndex, offsetBy: offset)
            }
            let parsedValue = parseValue(forUserInput: userInput, withInsertionIndex: insertionIndex)
            if fieldValue != parsedValue.value {
                viewDidUpdateValue(newValue: parsedValue.value)
            }
            textField.text = parsedValue.display
            if let newInsertionIndex = parsedValue.newInsertionIndex {
                let newOffset = parsedValue.display.distance(from: parsedValue.display.startIndex, to: newInsertionIndex)
                if let newTextPosition = textField.position(from: textField.beginningOfDocument, offset: newOffset) {
                    let newTextRange = textField.textRange(from: newTextPosition, to: newTextPosition)
                    textField.selectedTextRange = newTextRange
                } else {
                    textField.selectedTextRange = nil
                }
            } else {
                textField.selectedTextRange = nil
            }
        } else {
            viewDidUpdateValue(newValue: nil)
        }
    }

}
