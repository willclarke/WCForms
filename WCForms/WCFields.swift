//
//  WCFields.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation

public protocol WCField: class {
    var nibName: String { get }
    var cellIdentifier: String { get }
    var editableNibName: String { get }
    var editableCellIdentifier: String { get }
    var isEditable: Bool { get set }
    func dequeueCell(from tableView: UITableView, for indexPath: IndexPath, isEditing: Bool) -> UITableViewCell
    func registerNibsForCellReuseIdentifiers(in tableView: UITableView)
}

public protocol WCInputField: WCField {
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

public class WCGenericField<ValueType, AppearanceType: FieldCellLoadable>: WCInputField {
    public typealias InputValueType = ValueType
    public var fieldName: String
    public var defaultValue: ValueType?
    public var fieldValue: ValueType?
    public var appearance: AppearanceType
    public var editableAppearance: AppearanceType?
    public var onValueChange: ((ValueType?) -> Void)? = nil

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

    public init(fieldName: String) {
        self.fieldName = fieldName
        self.appearance = AppearanceType.default
    }

    public convenience init(fieldName: String, initialValue: ValueType) {
        self.init(fieldName: fieldName)
        self.fieldValue = initialValue
    }

    public convenience init(fieldName: String, initialValue: ValueType, onValueChange: @escaping ((ValueType?) -> Void)) {
        self.init(fieldName: fieldName, initialValue: initialValue)
        self.onValueChange = onValueChange
    }

    public convenience init(fieldName: String, initialValue: ValueType, appearance: AppearanceType) {
        self.init(fieldName: fieldName, initialValue: initialValue)
        self.appearance = appearance
    }

    public convenience init(fieldName: String, initialValue: ValueType, appearance: AppearanceType, onValueChange: @escaping ((ValueType?) -> Void)) {
        self.init(fieldName: fieldName, initialValue: initialValue, appearance: appearance)
        self.onValueChange = onValueChange
    }

    public final func dequeueCell(from tableView: UITableView, for indexPath: IndexPath, isEditing: Bool) -> UITableViewCell {
        let editableCellIdentifier = editableAppearance?.editableCellIdentifier ?? appearance.editableCellIdentifier
        let cellIdentifier = isEditing ? editableCellIdentifier : appearance.cellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if isEditing {
            self.setupEditableCell(cell)
        } else {
            self.setupCell(cell)
        }
        return cell
    }
    
    public func setupCell(_ cell: UITableViewCell) {
        if let readOnlyCell = cell as? WCGenericFieldTableViewCell {
            readOnlyCell.titleLabel.text = fieldName
            if let stringConvertableValue = fieldValue as? CustomStringConvertible {
                if stringConvertableValue.description != "" {
                    readOnlyCell.valueLabel.textColor = UIColor.darkGray
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
}
