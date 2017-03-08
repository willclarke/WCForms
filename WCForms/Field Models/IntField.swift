//
//  IntField.swift
//  WCForms
//
//  Created by Will Clarke on 3/4/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation

public enum WCIntFieldAppearance: FieldCellLoadable {
    case stacked
    case rightDetail
    case slider
    
    public var nibName: String {
        switch self {
        case .rightDetail:
            return "WCGenericFieldRightDetailTableViewCell"
        case .stacked:
            return "WCGenericFieldTableViewCell"
        case .slider:
            return "WCGenericFieldRightDetailTableViewCell"
        }
    }
    
    public var editableNibName: String {
        switch self {
        case .rightDetail:
            return "WCIntFieldRightDetailTableViewCell"
        case .stacked:
            return "WCIntFieldTableViewCell"
        case .slider:
            return "WCIntFieldSliderTableViewCell"
        }
    }

    public var canBecomeFirstResponder: Bool {
        switch self {
        case .rightDetail, .stacked:
            return true
        case .slider:
            return false
        }
    }
    
    public static var `default`: WCIntFieldAppearance {
        return WCIntFieldAppearance.rightDetail
    }
    
    public static var allValues: [WCIntFieldAppearance] {
        return [.stacked, .rightDetail, .slider]
    }
}

public class WCIntField: WCGenericField<Int, WCIntFieldAppearance> {
    public var minimumValue: Int?
    public var maximumValue: Int?
    public var placeholderText: String?
    weak var lastLoadedEditableCell: WCGenericTextFieldAndLabelCell? = nil

    public override func setupCell(_ cell: UITableViewCell) {
        super.setupCell(cell)
        lastLoadedEditableCell = nil
    }

    public override func setupEditableCell(_ cell: UITableViewCell) {
        if let editableIntCell = cell as? WCGenericTextFieldAndLabelCell {
            lastLoadedEditableCell = editableIntCell
            editableIntCell.fieldValueTextField.inputAccessoryView = self.fieldInputAccessory
        } else {
            lastLoadedEditableCell = nil
        }
        if let editableIntCell = cell as? WCIntFieldTableViewCell {
            let intValue: Int = fieldValue ?? 0
            editableIntCell.fieldNameLabel.text = fieldName
            editableIntCell.fieldValueTextField.text = String(intValue)
            editableIntCell.fieldValueTextField.placeholder = placeholderText
            editableIntCell.delegate = self
        }
        if let sliderCell = cell as? WCIntFieldSliderTableViewCell {
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
