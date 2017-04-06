//
//  OptionField.swift
//  WCForms
//
//  Created by Will Clarke on 3/24/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation

/// Appearance enum for option fields.
///
/// - stacked: The field name appears on a line above the field value.
/// - stackedCaption: Similar to stacked, but with the field name using the font `UIFontTextStyle.caption`
/// - rightDetail: The field value is on the right side of the cell, and the field name on the left.
/// - slider: In edit mode, a `UISlider` is used to set the value. In read-only mode, it mimics the appearance of the `rightDetail` appearance.
public enum WCOptionFieldAppearance: FieldCellAppearance {
    
    case stacked
    case stackedCaption
    case rightDetail

    /// The nib name for the read-only version of a field in this appearance.
    public var nibName: String {
        switch self {
        case .rightDetail:
            return "WCGenericFieldRightDetailTableViewCell"
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
            return "WCOptionFieldCell"
        case .stacked:
            return "WCOptionFieldStackedCell"
        case .stackedCaption:
            return "WCOptionFieldStackedCaptionCell"
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

    /// Always returns false because option fields cannot become first responder.
    public var canBecomeFirstResponder: Bool {
        return false
    }

    /// Returns `rightDetail`, the default Option field appearance.
    public static var `default`: WCOptionFieldAppearance {
        return WCOptionFieldAppearance.rightDetail
    }

    /// Returns all values of the Option field appearance.
    public static var allValues: [WCOptionFieldAppearance] {
        return [.stacked, .stackedCaption, .rightDetail]
    }

}

/// Protocol for items that can be selected in an option picker field. It is recommended to use an enum for option picker fields, but classes or structs are ok.
public protocol OptionFieldItem: Equatable {

    /// An abbreviation for the option field item. The abbreviation will be used in some cases when space is tight. If unspecified, this will default to the
    /// localizedValue of the option field item.
    var localizedAbbreviation: String { get }

    /// The localized value for the option field item. This will be used when picking the option, and when viewing the form if no abbreviation is specified.
    var localizedValue: String { get }

    /// An optional localized description that will appear when picking the option.
    var localizedDescription: String? { get }

}

public extension OptionFieldItem {

    /// Default implementation of the localized abbreviation that returns the `localizedValue`.
    var localizedAbbreviation: String {
        return localizedValue
    }

    /// Default implementation of the localized description that returns `nil`.
    var localizedDescription: String? {
        return nil
    }

}

/// Delegate protocol for an option item selecting view controller that selects a single option item.
internal protocol WCOptionItemSingleSelectionDelegate: class {

    /// The type of option item that the option field uses
    associatedtype SelectionItemType: OptionFieldItem

    /// The currently selected item of the option field.
    var selectedItem: SelectionItemType? { get }
    
    /// The item for an index path in an option picker.
    ///
    /// - Parameter indexPath: The index path for the item.
    /// - Returns: The option item specified by the `indexPath`.
    func optionItem(for indexPath: IndexPath) -> SelectionItemType

    /// Called when the user has selected an option item in an option item picker controller.
    ///
    /// - Parameters:
    ///   - picker: The option picker controller in which the user has selected the option item.
    ///   - selectedItem: The item that has been selected.
    func optionPicker(picker: WCOptionPickerTableViewController<SelectionItemType>, didSelectItem selectedItem: SelectionItemType?)

}

/// Data source protocol for an option item selecting view controller.
internal protocol WCOptionItemSelectionDataSource: class {

    /// The number of option groups in the option field.
    var numberOfOptionGroups: Int { get }

    /// The number of option items in a section.
    ///
    /// - Parameter sectionIndex: The section index to get the number of option items from.
    /// - Returns: The number of option items in that section.
    func numberOfOptionItems(forSection sectionIndex: Int) -> Int

    /// Gets the title for an option group section.
    ///
    /// - Parameter sectionIndex: The index of the section.
    /// - Returns: The title text, if there is any.
    func optionGroupTitle(forSection sectionIndex: Int) -> String?

    /// Gets the footer for an option group section.
    ///
    /// - Parameter sectionIndex: The index of the section.
    /// - Returns: The footer text, if there is any.
    func optionGroupFooter(forSection sectionIndex: Int) -> String?

}

/// A group of option items.
public struct OptionFieldGroup<GroupItemType: OptionFieldItem> {

    /// The title of the option item group.
    var localizedTitle: String? = nil

    /// The footer of the option item group.
    var localizedFooter: String? = nil

    /// The items in the section.
    var items = [GroupItemType]()

    public init(items: [GroupItemType], localizedTitle: String? = nil, localizedFooter: String? = nil) {
        self.localizedTitle = localizedTitle
        self.localizedFooter = localizedFooter
        self.items = items
    }

    var preferredTableViewStyle: UITableViewStyle {
        return localizedTitle == nil && localizedFooter == nil ? .plain : .grouped
    }

}

/// The possible behavior for an option item picker controller when an option item selection occurrs. Note - these behaviors only apply to when an option item
/// is selected, not when an item is deselected or when the selection is cleared.
///
/// - returnToForm: The user should return to the form when a selection is made.
/// - remainInPicker: The user should remain in the picker controller.
public enum WCOptionItemSelectionBehavior {

    case returnToForm
    case remainInPicker

}

/// A field with a value that can come from a collection of preset options.
public class WCOptionField<ItemType: OptionFieldItem>: WCGenericField<ItemType, WCOptionFieldAppearance>, WCEditableSelectableField,
                                                       WCOptionItemSingleSelectionDelegate, WCOptionItemSelectionDataSource
{

    /// The behavior when an item is selected.
    public var selectionBehavior: WCOptionItemSelectionBehavior = .returnToForm

    /// Whether or not the option field allows the user to deselect items. If `false`, once the user has made a selection, they can change the selection but
    /// can not clear or deselect that option. Defaults to `true`.
    public var allowsDeselection = true {
        didSet {
            if let controller = optionPickerController {
                controller.allowsDeselection = allowsDeselection
            }
        }
    }

    /// The groups of options that the user can pick from.
    private var optionGroups = [OptionFieldGroup<ItemType>]()

    /// The controller that is used to select the option item.
    private var optionPickerController: WCOptionPickerTableViewController<ItemType>? = nil

    /// The last loaded editable cell
    weak var lastLoadedEditableCell: WCOptionFieldCell? = nil

    /// Presents an option picker controller for the user to select an option item. Called when the user has selected this field in a form.
    ///
    /// - Parameter formController: The form controller on which the user selected the option field.
    public func didSelectField(in formController: WCFormController) {
        guard let navigationController = formController.navigationController else {
            NSLog("Error: WCOptionField \(fieldName) is on a form not embedded in a UINavigationController, so it can not present a picker view controller.")
            return
        }
        let pickerTableViewStyle: UITableViewStyle = optionGroups.count == 1 ? optionGroups.first!.preferredTableViewStyle : .grouped
        let optionPickerController = WCOptionPickerTableViewController<ItemType>(style: pickerTableViewStyle)
        optionPickerController.allowsDeselection = allowsDeselection
        optionPickerController.navigationItem.title = fieldName
        optionPickerController.delegate = self
        optionPickerController.dataSource = self
        navigationController.pushViewController(optionPickerController, animated: true)
        self.optionPickerController = optionPickerController
    }


    // MARK: - Cell setup
    
    /// Set up the read-only version of this cell. By default this will set up a `WCGenericFieldWithFieldNameCell` or `WCGenericFieldCell` -
    /// override this function in subclasses to customize behavior.
    ///
    /// - Parameter cell: The UITableViewCell for the field.
    public override func setupCell(_ cell: UITableViewCell) {
        super.setupCell(cell)
        if let readOnlyCell = cell as? WCGenericFieldCell, let fieldValue = fieldValue {
            readOnlyCell.valueLabel.textColor = appearance.preferredFieldValueColor
            readOnlyCell.valueLabel.text = fieldValue.localizedAbbreviation
        }
    }

    /// Sets up the editable version of the cell for this field.
    ///
    /// - Parameter cell: the table view cell.
    public override func setupEditableCell(_ cell: UITableViewCell) {
        super.setupEditableCell(cell)
        if let editableCell = cell as? WCOptionFieldCell {
            editableCell.selectionStyle = .default
            lastLoadedEditableCell = editableCell
            updateLastLoadedCellWithValue()
        } else {
            lastLoadedEditableCell = nil
        }
    }


    // MARK: - Initialization
    
    /// Initialize an option field with a field name.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - allOptions: An array of items that should appear as options for the field.
    public convenience init(fieldName: String, allOptions: [ItemType]) {
        self.init(fieldName: fieldName)
        self.optionGroups = [OptionFieldGroup<ItemType>(items: allOptions)]
    }

    /// Initialize an option field with a field name.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - optionGroups: An array of option groups that should appear as options for the field.
    public convenience init(fieldName: String, optionGroups: [OptionFieldGroup<ItemType>]) {
        self.init(fieldName: fieldName)
        self.optionGroups = optionGroups
    }

    /// Initialize an option field with a field name and specify if it's required.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - allOptions: An array of items that should appear as options for the field.
    ///   - isRequired: Whether or not the field is required.
    public convenience init(fieldName: String, allOptions: [ItemType], isRequired: Bool) {
        self.init(fieldName: fieldName, isRequired: isRequired)
        self.optionGroups = [OptionFieldGroup<ItemType>(items: allOptions)]
    }

    /// Initialize an option field with a field name and specify if it's required.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - optionGroups: An array of option groups that should appear as options for the field.
    ///   - isRequired: Whether or not the field is required.
    public convenience init(fieldName: String, optionGroups: [OptionFieldGroup<ItemType>], isRequired: Bool) {
        self.init(fieldName: fieldName, isRequired: isRequired)
        self.optionGroups = optionGroups
    }

    /// Initialize a field with a field name and initial value.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - allOptions: An array of items that should appear as options for the field.
    public convenience init(fieldName: String, initialValue: ItemType?, allOptions: [ItemType]) {
        self.init(fieldName: fieldName, initialValue: initialValue)
        self.optionGroups = [OptionFieldGroup<ItemType>(items: allOptions)]
    }

    /// Initialize a field with a field name and initial value.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - optionGroups: An array of option groups that should appear as options for the field.
    public convenience init(fieldName: String, initialValue: ItemType?, optionGroups: [OptionFieldGroup<ItemType>]) {
        self.init(fieldName: fieldName, initialValue: initialValue)
        self.optionGroups = optionGroups
    }

    /// Initialize a field with a field name and initial value and specify if it's required.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - allOptions: An array of items that should appear as options for the field.
    ///   - isRequired: Whether or not the field is required.
    public convenience init(fieldName: String, initialValue: ItemType?, allOptions: [ItemType], isRequired: Bool) {
        self.init(fieldName: fieldName, initialValue: initialValue, isRequired: isRequired)
        self.optionGroups = [OptionFieldGroup<ItemType>(items: allOptions)]
    }

    /// Initialize a field with a field name and initial value and specify if it's required.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - optionGroups: An array of option groups that should appear as options for the field.
    ///   - isRequired: Whether or not the field is required.
    public convenience init(fieldName: String, initialValue: ItemType?, optionGroups: [OptionFieldGroup<ItemType>], isRequired: Bool) {
        self.init(fieldName: fieldName, initialValue: initialValue, isRequired: isRequired)
        self.optionGroups = optionGroups
    }

    /// Initialize a field with a field name, initial value, and block to call when the field changes its value.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - allOptions: An array of items that should appear as options for the field.
    ///   - onValueChange: A block to be called when the field changes its value.
    public convenience init(fieldName: String, initialValue: ItemType?, allOptions: [ItemType], onValueChange: @escaping ((ItemType?) -> Void)) {
        self.init(fieldName: fieldName, initialValue: initialValue, onValueChange: onValueChange)
        self.optionGroups = [OptionFieldGroup<ItemType>(items: allOptions)]
    }

    /// Initialize a field with a field name, initial value, and block to call when the field changes its value.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - optionGroups: An array of option groups that should appear as options for the field.
    ///   - onValueChange: A block to be called when the field changes its value.
    public convenience init(fieldName: String,
                            initialValue: ItemType?,
                            optionGroups: [OptionFieldGroup<ItemType>],
                            onValueChange: @escaping ((ItemType?) -> Void))
    {
        self.init(fieldName: fieldName, initialValue: initialValue, onValueChange: onValueChange)
        self.optionGroups = optionGroups
    }

    /// Initialize a field with a field name, initial value, a block to call when the field changes its value, and specify if it's required.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - allOptions: An array of items that should appear as options for the field.
    ///   - onValueChange: A block to be called when the field changes its value.
    ///   - isRequired: Whether or not the field is required.
    public convenience init(fieldName: String,
                            initialValue: ItemType?,
                            allOptions: [ItemType],
                            onValueChange: @escaping ((ItemType?) -> Void),
                            isRequired: Bool)
    {
        self.init(fieldName: fieldName, initialValue: initialValue, onValueChange: onValueChange, isRequired: isRequired)
        self.optionGroups = [OptionFieldGroup<ItemType>(items: allOptions)]
    }

    /// Initialize a field with a field name, initial value, a block to call when the field changes its value, and specify if it's required.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - optionGroups: An array of option groups that should appear as options for the field.
    ///   - onValueChange: A block to be called when the field changes its value.
    ///   - isRequired: Whether or not the field is required.
    public convenience init(fieldName: String,
                            initialValue: ItemType?,
                            optionGroups: [OptionFieldGroup<ItemType>],
                            onValueChange: @escaping ((ItemType?) -> Void),
                            isRequired: Bool)
    {
        self.init(fieldName: fieldName, initialValue: initialValue, onValueChange: onValueChange, isRequired: isRequired)
        self.optionGroups = optionGroups
    }

    /// Initialize a field with a field name, initial value, and appearance.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - allOptions: An array of items that should appear as options for the field.
    ///   - appearance: The appearance for this field.
    public convenience init(fieldName: String, initialValue: ItemType?, allOptions: [ItemType], appearance: WCOptionFieldAppearance) {
        self.init(fieldName: fieldName, initialValue: initialValue, appearance: appearance)
        self.optionGroups = [OptionFieldGroup<ItemType>(items: allOptions)]
    }

    /// Initialize a field with a field name, initial value, and appearance.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - optionGroups: An array of option groups that should appear as options for the field.
    ///   - appearance: The appearance for this field.
    public convenience init(fieldName: String, initialValue: ItemType?, optionGroups: [OptionFieldGroup<ItemType>], appearance: WCOptionFieldAppearance) {
        self.init(fieldName: fieldName, initialValue: initialValue, appearance: appearance)
        self.optionGroups = optionGroups
    }

    /// Initialize a field with a field name, initial value, appearance, and specify if it's required.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - allOptions: An array of items that should appear as options for the field.
    ///   - appearance: The appearance for this field.
    ///   - isRequired: Whether or not the field is required.
    public convenience init(fieldName: String, initialValue: ItemType?, allOptions: [ItemType], appearance: WCOptionFieldAppearance, isRequired: Bool) {
        self.init(fieldName: fieldName, initialValue: initialValue, appearance: appearance, isRequired: isRequired)
        self.optionGroups = [OptionFieldGroup<ItemType>(items: allOptions)]
    }

    /// Initialize a field with a field name, initial value, appearance, and specify if it's required.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - optionGroups: An array of option groups that should appear as options for the field.
    ///   - appearance: The appearance for this field.
    ///   - isRequired: Whether or not the field is required.
    public convenience init(fieldName: String,
                            initialValue: ItemType?,
                            optionGroups: [OptionFieldGroup<ItemType>],
                            appearance: WCOptionFieldAppearance,
                            isRequired: Bool)
    {
        self.init(fieldName: fieldName, initialValue: initialValue, appearance: appearance, isRequired: isRequired)
        self.optionGroups = optionGroups
    }

    /// Initialize a field with a field name, initial value, appearance, and a block to call when the field changes its value.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - allOptions: An array of items that should appear as options for the field.
    ///   - appearance: The appearance for this field.
    ///   - onValueChange: A block to be called when the field changes its value.
    public convenience init(fieldName: String,
                            initialValue: ItemType?,
                            allOptions: [ItemType],
                            appearance: WCOptionFieldAppearance,
                            onValueChange: @escaping ((ItemType?) -> Void))
    {
        self.init(fieldName: fieldName, initialValue: initialValue, appearance: appearance, onValueChange: onValueChange)
        self.optionGroups = [OptionFieldGroup<ItemType>(items: allOptions)]
    }

    /// Initialize a field with a field name, initial value, appearance, and a block to call when the field changes its value.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - optionGroups: An array of option groups that should appear as options for the field.
    ///   - appearance: The appearance for this field.
    ///   - onValueChange: A block to be called when the field changes its value.
    public convenience init(fieldName: String,
                            initialValue: ItemType?,
                            optionGroups: [OptionFieldGroup<ItemType>],
                            appearance: WCOptionFieldAppearance,
                            onValueChange: @escaping ((ItemType?) -> Void))
    {
        self.init(fieldName: fieldName, initialValue: initialValue, appearance: appearance, onValueChange: onValueChange)
        self.optionGroups = optionGroups
    }

    /// Initialize a field with a field name, initial value, appearance, a block to call when the field changes its value, and specify if it's required.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - allOptions: An array of items that should appear as options for the field.
    ///   - appearance: The appearance for this field.
    ///   - onValueChange: A block to be called when the field changes its value.
    ///   - isRequired: Whether or not the field is required.
    public convenience init(fieldName: String,
                            initialValue: ItemType,
                            allOptions: [ItemType],
                            appearance: WCOptionFieldAppearance,
                            onValueChange: @escaping ((ItemType?) -> Void),
                            isRequired: Bool)
    {
        self.init(fieldName: fieldName, initialValue: initialValue, appearance: appearance, onValueChange: onValueChange, isRequired: isRequired)
        self.optionGroups = [OptionFieldGroup<ItemType>(items: allOptions)]
    }

    /// Initialize a field with a field name, initial value, appearance, a block to call when the field changes its value, and specify if it's required.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - optionGroups: An array of option groups that should appear as options for the field.
    ///   - appearance: The appearance for this field.
    ///   - onValueChange: A block to be called when the field changes its value.
    ///   - isRequired: Whether or not the field is required.
    public convenience init(fieldName: String,
                            initialValue: ItemType,
                            optionGroups: [OptionFieldGroup<ItemType>],
                            appearance: WCOptionFieldAppearance,
                            onValueChange: @escaping ((ItemType?) -> Void),
                            isRequired: Bool)
    {
        self.init(fieldName: fieldName, initialValue: initialValue, appearance: appearance, onValueChange: onValueChange, isRequired: isRequired)
        self.optionGroups = optionGroups
    }

    func updateLastLoadedCellWithValue() {
        let appearance = self.editableAppearance ?? self.appearance
        if let lastLoadedEditableCell = lastLoadedEditableCell {
            if let validValue = fieldValue {
                lastLoadedEditableCell.valueLabel.text = validValue.localizedAbbreviation
                lastLoadedEditableCell.valueLabel.textColor = appearance.preferredFieldValueColor
            } else {
                lastLoadedEditableCell.valueLabel.text = emptyValueLabelText
                lastLoadedEditableCell.valueLabel.textColor = appearance.preferredEmptyFieldValueColor
            }
        }
    }


    // MARK: - Conformance to WCOptionItemSelectionDataSource

    /// The number of option groups from which the user can choose.
    public var numberOfOptionGroups: Int {
        return optionGroups.count
    }

    /// Gets the number of option items in a particular option group.
    ///
    /// - Parameter sectionIndex: The index of the section of the option group.
    /// - Returns: The number of option items in the option group.
    public func numberOfOptionItems(forSection sectionIndex: Int) -> Int {
        return optionGroups[sectionIndex].items.count
    }

    /// Gets the title of an option group for a specified section index.
    ///
    /// - Parameter sectionIndex: The index of the section for which to retrieve the title.
    /// - Returns: The title, if one is set. Otherwise, `nil`.
    public func optionGroupTitle(forSection sectionIndex: Int) -> String? {
        return optionGroups[sectionIndex].localizedTitle
    }

    /// Gets the footer text of an option group for a specified section index.
    ///
    /// - Parameter sectionIndex: The index of the section for which to retrieve the footer.
    /// - Returns: The footer text, if any is set. Otherwise, `nil`.
    public func optionGroupFooter(forSection sectionIndex: Int) -> String? {
        return optionGroups[sectionIndex].localizedFooter
    }


    // MARK: - Conformance to WCOptionItemSingleSelectionDelegate

    /// The item type being selected by the option item selector.
    public typealias SelectionItemType = ItemType

    /// The item that is currently selected.
    public var selectedItem: ItemType? {
        return fieldValue
    }

    /// Gets an option item associated with a specified `IndexPath`.
    ///
    /// - Parameter indexPath: The `IndexPath` for which to retrieve the option item.
    /// - Returns: The item at the specified `IndexPath`.
    public func optionItem(for indexPath: IndexPath) -> ItemType {
        return optionGroups[indexPath.section].items[indexPath.row]
    }

    /// A user has selected a new item in an option picker.
    ///
    /// - Parameters:
    ///   - picker: The picker view controller in which the user selected the option.
    ///   - selectedItem: The item that the user selected.
    public func optionPicker(picker: WCOptionPickerTableViewController<ItemType>, didSelectItem selectedItem: ItemType?) {
        if allowsDeselection == false && selectedItem == nil {
            return
        }
        if fieldValue != selectedItem {
            viewDidUpdateValue(newValue: selectedItem)
        }
        updateLastLoadedCellWithValue()
        if selectionBehavior == .returnToForm && selectedItem != nil {
            picker.navigationController?.popViewController(animated: true)
        }
    }

}
