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
    
    public override func setupEditableCell(_ cell: UITableViewCell) {
        if let editableIntCell = cell as? WCIntFieldTableViewCell {
            let intValue: Int = fieldValue ?? defaultValue ?? 0
            editableIntCell.fieldNameLabel.text = fieldName
            editableIntCell.fieldValueTextField.text = String(intValue)
            editableIntCell.delegate = self
        }
        if let sliderCell = cell as? WCIntFieldSliderTableViewCell {
            let sliderMinimum = minimumValue ?? 0
            let sliderMaximum = maximumValue ?? 100
            var intValue: Int = fieldValue ?? defaultValue ?? 0
            
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
}
