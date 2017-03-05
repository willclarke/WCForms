//
//  TextField.swift
//  WCForms
//
//  Created by Will Clarke on 3/4/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation

public enum WCTextFieldAppearance: FieldCellLoadable {
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
            return "WCTextFieldRightDetailTableViewCell"
        case .stacked:
            return "WCTextFieldTableViewCell"
        }
    }

    public var canBecomeFirstResponder: Bool {
        return true
    }
    
    public static var `default`: WCTextFieldAppearance {
        return WCTextFieldAppearance.stacked
    }
    
    public static var allValues: [WCTextFieldAppearance] {
        return [.stacked, .rightDetail]
    }
}

public class WCTextField: WCGenericField<String, WCTextFieldAppearance> {
    public var minimumLength: Int?
    public var maximumLength: Int?
    
    public override func setupEditableCell(_ cell: UITableViewCell) {
        if let editableTextCell = cell as? WCTextFieldTableViewCell {
            editableTextCell.fieldNameLabel.text = fieldName
            editableTextCell.fieldValueTextField.text = fieldValue
            editableTextCell.delegate = self
        }
    }
}
