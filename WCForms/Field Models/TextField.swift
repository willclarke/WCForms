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
    case fieldNameAsPlaceholder

    public var nibName: String {
        switch self {
        case .rightDetail:
            return "WCGenericFieldRightDetailTableViewCell"
        case .fieldNameAsPlaceholder:
            return "WCGenericFieldNoLabelTableViewCell"
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
        case .fieldNameAsPlaceholder:
            return "WCTextFieldNoLabelCell"
        }
    }

    public var canBecomeFirstResponder: Bool {
        return true
    }
    
    public static var `default`: WCTextFieldAppearance {
        return WCTextFieldAppearance.stacked
    }
    
    public static var allValues: [WCTextFieldAppearance] {
        return [.stacked, .rightDetail, .fieldNameAsPlaceholder]
    }
}

public class WCTextField: WCGenericField<String, WCTextFieldAppearance> {
    public var minimumLength: Int?
    public var maximumLength: Int?
    public var placeholderText: String? = nil
    weak var lastLoadedEditableCell: WCGenericTextFieldTableViewCell? = nil

    public override func setupCell(_ cell: UITableViewCell) {
        super.setupCell(cell)
        lastLoadedEditableCell = nil
    }

    public override func setupEditableCell(_ cell: UITableViewCell) {
        if let editableTextCell = cell as? WCGenericTextFieldTableViewCell {
            lastLoadedEditableCell = editableTextCell
        }
        if let editableTextCell = cell as? WCTextFieldNoLabelCell {
            editableTextCell.fieldValueTextField.text = fieldValue
            editableTextCell.fieldValueTextField.placeholder = placeholderText ?? fieldName
            editableTextCell.delegate = self
        }
        if let editableTextCell = cell as? WCTextFieldTableViewCell {
            editableTextCell.fieldNameLabel.text = fieldName
            editableTextCell.fieldValueTextField.text = fieldValue
            editableTextCell.fieldValueTextField.placeholder = placeholderText
            editableTextCell.delegate = self
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
}
