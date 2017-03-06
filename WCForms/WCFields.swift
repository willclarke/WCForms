//
//  WCFields.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation

public enum WCFieldValidationError: Error {
    case missingValue(fieldName: String)
    case outOfBounds(fieldName: String, boundsError: String)
    case invalidFormat(fieldName: String, formatError: String)
}

public protocol WCField: class {
    var nibName: String { get }
    var cellIdentifier: String { get }
    var editableNibName: String { get }
    var editableCellIdentifier: String { get }
    var isEditable: Bool { get set }
    var isAbleToCopy: Bool { get set }
    var copyValue: String? { get }
    func dequeueCell(from tableView: UITableView, for indexPath: IndexPath, isEditing: Bool) -> UITableViewCell
    func registerNibsForCellReuseIdentifiers(in tableView: UITableView)
}

public protocol WCInputField: WCField {
    var fieldName: String { get set }
    var isRequired: Bool { get set }
    func validateFieldValue() throws
    var canBecomeFirstResponder: Bool { get }
    func becomeFirstResponder()
    func resignFirstResponder()
}

public protocol WCTypedInputField: WCInputField {
    associatedtype InputValueType
    var fieldValue: InputValueType? { get set }
    func viewDidUpdateValue(newValue: InputValueType?)
    var onValueChange: ((InputValueType?) -> Void)? { get set }
}

public protocol FieldCellLoadable {
    var nibName: String { get }
    var cellIdentifier: String { get }
    var editableNibName: String { get }
    var editableCellIdentifier: String { get }
    var canBecomeFirstResponder: Bool { get }
    static var `default`: Self { get }
    static var allValues: [Self] { get }
}

public extension FieldCellLoadable {
    public var cellIdentifier: String {
        return self.nibName
    }

    public var editableCellIdentifier: String {
        return self.editableNibName
    }
}

public class WCGenericField<ValueType, AppearanceType: FieldCellLoadable>: WCTypedInputField {
    public typealias InputValueType = ValueType
    public var fieldName: String
    public var defaultValue: ValueType?
    public var fieldValue: ValueType?
    public var appearance: AppearanceType
    public var editableAppearance: AppearanceType?
    public var onValueChange: ((ValueType?) -> Void)? = nil
    public var canBecomeFirstResponder: Bool {
        return editableAppearance?.canBecomeFirstResponder ?? appearance.canBecomeFirstResponder
    }
    public var isRequired: Bool = false

    public final var nibName: String {
        return appearance.nibName
    }
    public final var cellIdentifier: String {
        return appearance.cellIdentifier
    }
    public final var editableNibName: String {
        return editableAppearance?.editableNibName ?? appearance.editableNibName
    }
    public final var editableCellIdentifier: String {
        return editableAppearance?.editableCellIdentifier ?? appearance.editableCellIdentifier
    }
    public var isEditable: Bool = true
    public var isAbleToCopy: Bool = true
    public var copyValue: String? {
        if let stringConvertableValue = fieldValue as? CustomStringConvertible {
            return stringConvertableValue.description
        }
        return nil
    }

    public init(fieldName: String) {
        self.fieldName = fieldName
        self.appearance = AppearanceType.default
    }

    public convenience init(fieldName: String, isRequired: Bool) {
        self.init(fieldName: fieldName)
        self.isRequired = isRequired
    }

    public convenience init(fieldName: String, initialValue: ValueType?) {
        self.init(fieldName: fieldName)
        self.fieldValue = initialValue
    }

    public convenience init(fieldName: String, initialValue: ValueType?, isRequired: Bool) {
        self.init(fieldName: fieldName, initialValue: initialValue)
        self.isRequired = isRequired
    }

    public convenience init(fieldName: String, initialValue: ValueType?, onValueChange: @escaping ((ValueType?) -> Void)) {
        self.init(fieldName: fieldName, initialValue: initialValue)
        self.onValueChange = onValueChange
    }

    public convenience init(fieldName: String, initialValue: ValueType?, onValueChange: @escaping ((ValueType?) -> Void), isRequired: Bool) {
        self.init(fieldName: fieldName, initialValue: initialValue, onValueChange: onValueChange)
        self.isRequired = isRequired
    }

    public convenience init(fieldName: String, initialValue: ValueType?, appearance: AppearanceType) {
        self.init(fieldName: fieldName, initialValue: initialValue)
        self.appearance = appearance
    }

    public convenience init(fieldName: String, initialValue: ValueType?, appearance: AppearanceType, isRequired: Bool) {
        self.init(fieldName: fieldName, initialValue: initialValue, appearance: appearance)
        self.isRequired = isRequired
    }

    public convenience init(fieldName: String, initialValue: ValueType?, appearance: AppearanceType, onValueChange: @escaping ((ValueType?) -> Void)) {
        self.init(fieldName: fieldName, initialValue: initialValue, appearance: appearance)
        self.onValueChange = onValueChange
    }

    public convenience init(fieldName: String,
                            initialValue: ValueType,
                            appearance: AppearanceType,
                            onValueChange: @escaping ((ValueType?) -> Void),
                            isRequired: Bool)
    {
        self.init(fieldName: fieldName, initialValue: initialValue, appearance: appearance, onValueChange: onValueChange)
        self.isRequired = isRequired
    }

    public final func dequeueCell(from tableView: UITableView, for indexPath: IndexPath, isEditing: Bool) -> UITableViewCell {
        let editableCellIdentifier = editableAppearance?.editableCellIdentifier ?? appearance.editableCellIdentifier
        let cellIdentifier = isEditing && isEditable ? editableCellIdentifier : appearance.cellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if isEditing && isEditable {
            self.setupEditableCell(cell)
        } else {
            self.setupCell(cell)
        }
        return cell
    }
    
    public func setupCell(_ cell: UITableViewCell) {
        var setValueTextColor = UIColor.black
        if isAbleToCopy && copyValue != nil {
            cell.selectionStyle = .default
        } else {
            cell.selectionStyle = .none
        }

        if let readOnlyCell = cell as? WCGenericFieldTableViewCell {
            setValueTextColor = UIColor.darkGray
            readOnlyCell.titleLabel.text = fieldName
        }
        if let readOnlyCell = cell as? WCGenericFieldNoLabelTableViewCell {
            if let stringConvertableValue = fieldValue as? CustomStringConvertible {
                if stringConvertableValue.description != "" {
                    readOnlyCell.valueLabel.textColor = setValueTextColor
                    readOnlyCell.valueLabel.text = stringConvertableValue.description
                } else {
                    readOnlyCell.valueLabel.textColor = UIColor.lightText
                    readOnlyCell.valueLabel.text = NSLocalizedString("None", tableName: "WCForms", comment: "Displayed when there is no value for a field")
                }
            } else {
                readOnlyCell.valueLabel.textColor = UIColor.lightText
                readOnlyCell.valueLabel.text = NSLocalizedString("None", tableName: "WCForms", comment: "Displayed when there is no value for a field")
            }
        }
    }

    public func setupEditableCell(_ cell: UITableViewCell) {
        setupCell(cell)
    }

    public func registerNibsForCellReuseIdentifiers(in tableView: UITableView) {
        let nibBundle = Bundle(for: WCTextField.self)
        for appearance in AppearanceType.allValues {
            let readOnlyNib = UINib(nibName: appearance.nibName, bundle: nibBundle)
            let editableNib = UINib(nibName: appearance.editableNibName, bundle: nibBundle)
            tableView.register(readOnlyNib, forCellReuseIdentifier: appearance.cellIdentifier)
            tableView.register(editableNib, forCellReuseIdentifier: appearance.editableCellIdentifier)
        }
    }

    public func viewDidUpdateValue(newValue: ValueType?) {
        fieldValue = newValue
        if let settingBlock = onValueChange {
            settingBlock(newValue)
        }
    }

    public func becomeFirstResponder() {}

    public func resignFirstResponder() {}

    public func validateFieldValue() throws {
        if isRequired && fieldValue == nil {
            throw WCFieldValidationError.missingValue(fieldName: fieldName)
        }
    }

}
