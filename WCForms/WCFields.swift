//
//  WCFields.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation

public protocol WCField {
    var fieldIdentifier: String { get }
    var nibName: String { get }
    var cellIdentifier: String { get }
    var editableNibName: String { get }
    var editableCellIdentifier: String { get }
    var isEditable: Bool { get set }
    func dequeueCell(from tableView: UITableView, for indexPath: IndexPath, isEditing: Bool) -> UITableViewCell
    func registerNibsForCellReuseIdentifiers(in tableView: UITableView)
}

public protocol FieldCellLoadable {
    var nibName: String { get }
    var cellIdentifier: String { get }
    var editableNibName: String { get }
    var editableCellIdentifier: String { get }
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

public class WCGenericField<ValueType, AppearanceType: FieldCellLoadable>: WCField {
    public var fieldIdentifier: String
    public var fieldName: String
    public var defaultValue: ValueType?
    public var fieldValue: ValueType?
    public var appearance: AppearanceType
    public var editableAppearance: AppearanceType?

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

    public init(fieldIdentifier: String, fieldName: String, initialValue: ValueType, appearance: AppearanceType? = nil) {
        self.fieldIdentifier = fieldIdentifier
        self.fieldName = fieldName
        self.fieldValue = initialValue
        self.appearance = appearance ?? AppearanceType.default
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
            print("Registering nib \(appearance.nibName) for cell ID \(appearance.cellIdentifier)")
            tableView.register(readOnlyNib, forCellReuseIdentifier: appearance.cellIdentifier)
            print("Registering nib \(appearance.editableNibName) for cell ID \(appearance.editableCellIdentifier)")
            tableView.register(editableNib, forCellReuseIdentifier: appearance.editableCellIdentifier)
        }
    }
}

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
        }
    }
}

public enum WCBoolFieldAppearance: FieldCellLoadable {
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
            return "WCBoolFieldTableViewCell"
        case .stacked:
            return "WCBoolFieldStackedTableViewCell"
        }
    }
    
    public static var `default`: WCBoolFieldAppearance {
        return WCBoolFieldAppearance.stacked
    }

    public static var allValues: [WCBoolFieldAppearance] {
        return [.stacked, .rightDetail]
    }
}

public class WCBoolField: WCGenericField<Bool, WCBoolFieldAppearance> {
    public var onDisplayValue: String = "Yes"
    public var offDisplayValue: String = "No"

    public override func setupCell(_ cell: UITableViewCell) {
        if let readOnlyCell = cell as? WCGenericFieldTableViewCell {
            let boolValue = fieldValue ?? defaultValue ?? false
            readOnlyCell.titleLabel.text = fieldName
            readOnlyCell.valueLabel.textColor = UIColor.darkGray
            readOnlyCell.valueLabel.text = boolValue ? onDisplayValue : offDisplayValue
        }
    }

    public override func setupEditableCell(_ cell: UITableViewCell) {
        let boolValue = fieldValue ?? defaultValue ?? false
        if let editableBoolCell = cell as? WCBoolFieldTableViewCell {
            editableBoolCell.fieldNameLabel.text = fieldName
            editableBoolCell.fieldValueSwitch.isOn = boolValue
        }
        if let stackedBoolCell = cell as? WCBoolFieldStackedTableViewCell {
            stackedBoolCell.onDisplayValueLabel.text = onDisplayValue
            stackedBoolCell.offDisplayValueLabel.text = offDisplayValue
            if boolValue {
                stackedBoolCell.onDisplayValueLabel.textColor = UIColor.darkGray
                stackedBoolCell.offDisplayValueLabel.textColor = UIColor.lightGray
            } else {
                stackedBoolCell.onDisplayValueLabel.textColor = UIColor.lightGray
                stackedBoolCell.offDisplayValueLabel.textColor = UIColor.darkGray
            }
        }
    }
}

public enum WCDateFieldAppearance: FieldCellLoadable {
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
            return "WCDateFieldRightDetailTableViewCell"
        case .stacked:
            return "WCDateFieldTableViewCell"
        }
    }
    
    public static var `default`: WCDateFieldAppearance {
        return WCDateFieldAppearance.stacked
    }

    public static var allValues: [WCDateFieldAppearance] {
        return [.stacked, .rightDetail]
    }
}

public class WCDateField: WCGenericField<Date, WCDateFieldAppearance> {
    let datePicker = UIDatePicker()
    let dateDisplayFormatter = DateFormatter()

    public override init(fieldIdentifier: String, fieldName: String, initialValue: Date, appearance: WCDateFieldAppearance?) {
        super.init(fieldIdentifier: fieldIdentifier, fieldName: fieldName, initialValue: initialValue, appearance: appearance)
        dateDisplayFormatter.dateStyle = .medium
        dateDisplayFormatter.timeStyle = .none
    }

    public override func setupCell(_ cell: UITableViewCell) {
        if let dateCell = cell as? WCGenericFieldTableViewCell {
            dateCell.titleLabel.text = fieldName
            if let dateValue = fieldValue {
                dateCell.valueLabel.text = dateDisplayFormatter.string(from: dateValue)
            } else {
                dateCell.valueLabel.text = NSLocalizedString("None", tableName: "WCForms", comment: "Displayed when there is no value for a field")
            }
        }
    }

    public override func setupEditableCell(_ cell: UITableViewCell) {
        if let editableDateCell = cell as? WCDateFieldTableViewCell {
            let dateValue: Date = fieldValue ?? defaultValue ?? Date()
            editableDateCell.fieldNameLabel.text = fieldName
            datePicker.date = dateValue
            editableDateCell.fieldValueTextField.inputView = datePicker
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            editableDateCell.fieldValueTextField.text = dateFormatter.string(from: dateValue)
        }
    }
}

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
        }
    }
}
