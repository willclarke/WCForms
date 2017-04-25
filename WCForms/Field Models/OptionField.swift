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
        return WCOptionFieldAppearance.stacked
    }

    /// Returns all values of the Option field appearance.
    public static var allValues: [WCOptionFieldAppearance] {
        return [.stacked, .stackedCaption, .rightDetail]
    }

    /// The default multiple option summary style for the appearance.
    public var preferredSummaryStyle: MultipleOptionSummaryStyle {
        switch self {
        case .rightDetail:
            // Since the space for the value on right detail appearance is constrained, display a count.
            return .count
        case .stacked, .stackedCaption:
            // Space on stacked cells are not constrained, so show all selected options.
            return .all
        }
    }
    
    /// The default behavior for when a multiple option cell is selected for the appearance.
    public var preferredReadOnlySelectionBehavior: MultipleOptionReadOnlySelectionBehavior {
        switch self {
        case .rightDetail:
            // Since we are displaying a count by default, tapping the cell should push a detail VC onto the navigation stack.
            return .showDetail
        case .stacked, .stackedCaption:
            // Space on stacked cells are not constrained, so show all selected options.
            return .none
        }
    }

}

/// A protocol for objects whose appearance and editable appearance can be set.
public protocol WCOptionAppearanceSettable: class {

    var appearance: WCOptionFieldAppearance { get set }

    var editableAppearance: WCOptionFieldAppearance? { get set }

}

/// Protocol for items that can be selected in an option picker field. It is recommended to use an enum for option picker fields, but classes or structs are ok.
public protocol OptionFieldItem: Hashable {

    /// An identifier for this option item that will be used for comparison and hashing purposes.
    var optionIdentifier: String { get }

    /// An abbreviation for the option field item. The abbreviation will be used in some cases when space is tight. If unspecified, this will default to the
    /// localizedValue of the option field item.
    var localizedAbbreviation: String { get }

    /// The localized value for the option field item. This will be used when picking the option, and when viewing the form if no abbreviation is specified.
    var localizedValue: String { get }

    /// An optional localized description that will appear when picking the option.
    var localizedDescription: String? { get }

}

extension OptionFieldItem {

    /// Default implementation of the localized abbreviation that returns the `localizedValue`.
    public var localizedAbbreviation: String {
        return localizedValue
    }

    /// Default implementation of the localized description that returns `nil`.
    public var localizedDescription: String? {
        return nil
    }

    /// Default implementation of the option identifier.
    public var optionIdentifier: String {
        return localizedAbbreviation + localizedValue + (localizedDescription ?? "")
    }

    /// Default implementation of `Hashable`.
    public var hashValue: Int {
        return optionIdentifier.hashValue
    }

    /// Default implementation of `Equatable`.
    ///
    /// - Parameters:
    ///   - lhs: One `OptionFieldItem` object to compare.
    ///   - rhs: Another `OptionFieldItem` object to compare.
    /// - Returns: Whether or not the two objects are equal.
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.optionIdentifier == rhs.optionIdentifier
    }

}

//public protocol MultipleOptionFieldItem: OptionFieldItem, Hashable { }
//
//extension MultipleOptionFieldItem {
//
//    static func == (lhs: Self, rhs: Self) -> Bool {
//        return (lhs.localizedValue == rhs.localizedValue) && (lhs.localizedDescription == rhs.localizedDescription)
//    }
//
//    public var hashValue: Int {
//        var uniqueString = "\(localizedAbbreviation) \(localizedValue)"
//        if let localizedDescription = localizedDescription {
//            uniqueString += localizedDescription
//        }
//        return uniqueString.hashValue
//    }
//
//}

/// Delegate protocol for an option item selecting view controller that selects a single option item.
internal protocol WCOptionItemSelectionDelegate: class {

    /// The type of option item that the option field uses
    associatedtype SelectionItemType: OptionFieldItem

    /// The type of value that the option field uses
    associatedtype SelectionValueType: Equatable

    /// The currently selected item of the option field.
    var selectedValue: SelectionValueType? { get }

    /// Returns whether or not a specific option item should be marked as selected.
    ///
    /// - Parameter optionItem: The option item to check.
    /// - Returns: Whether or not the item is currently selected in the field.
    func isSelected(optionItem: SelectionItemType) -> Bool
    
    /// The item for an index path in an option picker.
    ///
    /// - Parameter indexPath: The index path for the item.
    /// - Returns: The option item specified by the `indexPath`.
    func optionItem(for indexPath: IndexPath) -> SelectionItemType

    /// Called when the user has selected an option item in an option item picker controller.
    ///
    /// - Parameters:
    ///   - picker: The option picker controller in which the user has selected the option item.
    ///   - newItem: The new item that has been selected.
    func optionPicker(_ picker: WCOptionPickerTableViewController<SelectionItemType, SelectionValueType>, didSelectItem newItem: SelectionItemType)

    /// Called when the user has deselected an option item in an option item picker controller.
    ///
    /// - Parameters:
    ///   - picker: The option picker controller in which the user has deselected the option item.
    ///   - deselectedItem: The item that has been deselected.
    func optionPicker(_ picker: WCOptionPickerTableViewController<SelectionItemType, SelectionValueType>, didDeselectItem deselectedItem: SelectionItemType)

    /// Called when the option picker clears the selection.
    ///
    /// - Parameter picker: The option picker controller in which the user has cleared the value.
    func optionPickerDidClearValue(_ picker: WCOptionPickerTableViewController<SelectionItemType, SelectionValueType>)

}

/// Data source protocol for an option item selecting view controller.
internal protocol WCOptionItemSelectionDataSource: class {

    /// The number of option groups in the option field.
    var numberOfOptionGroups: Int { get }

    /// Whether or not the field currently has a value selected.
    var hasSelection: Bool { get }

    /// A localized summary of the current selection.
    var localizedSelectionSummary: String? { get }

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
internal class WCOptionField<ItemType: OptionFieldItem, ValueType: Equatable>: WCGenericField<ValueType, WCOptionFieldAppearance>,
                                                                               WCEditableSelectableField,
                                                                               WCOptionItemSelectionDelegate,
                                                                               WCOptionItemSelectionDataSource,
                                                                               WCOptionAppearanceSettable
{

    /// The groups of options that the user can pick from.
    internal var optionGroups = [OptionFieldGroup<ItemType>]()

    /// The controller that is used to select the option item.
    internal var optionPickerController: WCOptionPickerTableViewController<ItemType, ValueType>? = nil

    /// The last loaded editable cell
    weak var lastLoadedEditableCell: WCOptionFieldCell? = nil

    /// Whether or not the option field allows the user to deselect items. If `false`, once the user has made a selection, they can change the selection but
    /// can not clear or deselect that option. Defaults to `true`.
    internal var pickerAllowsDeselection = true {
        didSet {
            if let controller = optionPickerController {
                controller.allowsDeselection = pickerAllowsDeselection
            }
        }
    }

    override var fieldValue: ValueType? {
        didSet {
            guard fieldValue != oldValue else {
                return
            }
            guard let formController = formSection?.form?.formController else {
                return
            }
            formController.reloadIndexPath(for: self, with: .none)
        }
    }
    
    // MARK: Conformance to WCEditableSelectableField

    public func didSelectField(in formController: WCFormController) {
        return
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
    public convenience init(fieldName: String, initialValue: ValueType?, allOptions: [ItemType]) {
        self.init(fieldName: fieldName, initialValue: initialValue)
        self.optionGroups = [OptionFieldGroup<ItemType>(items: allOptions)]
    }

    /// Initialize a field with a field name and initial value.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - optionGroups: An array of option groups that should appear as options for the field.
    public convenience init(fieldName: String, initialValue: ValueType?, optionGroups: [OptionFieldGroup<ItemType>]) {
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
    public convenience init(fieldName: String, initialValue: ValueType?, allOptions: [ItemType], isRequired: Bool) {
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
    public convenience init(fieldName: String, initialValue: ValueType?, optionGroups: [OptionFieldGroup<ItemType>], isRequired: Bool) {
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
    public convenience init(fieldName: String, initialValue: ValueType?, allOptions: [ItemType], onValueChange: @escaping ((ValueType?) -> Void)) {
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
                            initialValue: ValueType?,
                            optionGroups: [OptionFieldGroup<ItemType>],
                            onValueChange: @escaping ((ValueType?) -> Void))
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
                            initialValue: ValueType?,
                            allOptions: [ItemType],
                            onValueChange: @escaping ((ValueType?) -> Void),
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
                            initialValue: ValueType?,
                            optionGroups: [OptionFieldGroup<ItemType>],
                            onValueChange: @escaping ((ValueType?) -> Void),
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
    public convenience init(fieldName: String, initialValue: ValueType?, allOptions: [ItemType], appearance: WCOptionFieldAppearance) {
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
    public convenience init(fieldName: String, initialValue: ValueType?, optionGroups: [OptionFieldGroup<ItemType>], appearance: WCOptionFieldAppearance) {
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
    public convenience init(fieldName: String, initialValue: ValueType?, allOptions: [ItemType], appearance: WCOptionFieldAppearance, isRequired: Bool) {
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
                            initialValue: ValueType?,
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
                            initialValue: ValueType?,
                            allOptions: [ItemType],
                            appearance: WCOptionFieldAppearance,
                            onValueChange: @escaping ((ValueType?) -> Void))
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
                            initialValue: ValueType?,
                            optionGroups: [OptionFieldGroup<ItemType>],
                            appearance: WCOptionFieldAppearance,
                            onValueChange: @escaping ((ValueType?) -> Void))
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
                            initialValue: ValueType,
                            allOptions: [ItemType],
                            appearance: WCOptionFieldAppearance,
                            onValueChange: @escaping ((ValueType?) -> Void),
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
                            initialValue: ValueType,
                            optionGroups: [OptionFieldGroup<ItemType>],
                            appearance: WCOptionFieldAppearance,
                            onValueChange: @escaping ((ValueType?) -> Void),
                            isRequired: Bool)
    {
        self.init(fieldName: fieldName, initialValue: initialValue, appearance: appearance, onValueChange: onValueChange, isRequired: isRequired)
        self.optionGroups = optionGroups
    }


    // MARK: - Conformance to WCOptionItemSelectionDataSource

    /// The number of option groups from which the user can choose.
    public var numberOfOptionGroups: Int {
        return optionGroups.count
    }
    
    /// Whether or not the field currently has a value selected.
    var hasSelection: Bool {
        return fieldValue != nil
    }

    /// A localized summary of the current selection.
    var localizedSelectionSummary: String? {
        return hasSelection ? "" : nil
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


    // MARK: - Conformance to WCOptionItemSelectionDelegate
    
    /// The item type being selected by the option item selector.
    public typealias SelectionItemType = ItemType

    public typealias SelectionValueType = ValueType
    
    /// The item that is currently selected.
    public var selectedValue: ValueType? {
        return fieldValue
    }

    /// Returns whether or not a specific option item should be marked as selected.
    ///
    /// - Parameter optionItem: The option item to check.
    /// - Returns: Whether or not the item is currently selected in the field.
    func isSelected(optionItem: SelectionItemType) -> Bool {
        return false
    }

    /// Gets an option item associated with a specified `IndexPath`.
    ///
    /// - Parameter indexPath: The `IndexPath` for which to retrieve the option item.
    /// - Returns: The item at the specified `IndexPath`.
    public func optionItem(for indexPath: IndexPath) -> ItemType {
        return optionGroups[indexPath.section].items[indexPath.row]
    }

    /// Called when the user has selected an option item in an option item picker controller.
    ///
    /// - Parameters:
    ///   - picker: The option picker controller in which the user has selected the option item.
    ///   - newItem: The new item that has been selected.
    func optionPicker(_ picker: WCOptionPickerTableViewController<SelectionItemType, SelectionValueType>, didSelectItem newItem: SelectionItemType) {
        return
    }

    /// Called when the user has deselected an option item in an option item picker controller.
    ///
    /// - Parameters:
    ///   - picker: The option picker controller in which the user has deselected the option item.
    ///   - deselectedItem: The item that has been deselected.
    func optionPicker(_ picker: WCOptionPickerTableViewController<SelectionItemType, SelectionValueType>, didDeselectItem deselectedItem: SelectionItemType) {
        return
    }

    /// Called when the option picker clears the selection.
    ///
    /// - Parameter picker: The option picker controller in which the user has cleared the value.
    func optionPickerDidClearValue(_ picker: WCOptionPickerTableViewController<SelectionItemType, SelectionValueType>) {
        if pickerAllowsDeselection && fieldValue != nil {
            viewDidUpdateValue(newValue: nil)
        }
        updateLastLoadedCellWithValue()
    }

    func updateLastLoadedCellWithValue() {
        let appearance = self.editableAppearance ?? self.appearance
        if let lastLoadedEditableCell = lastLoadedEditableCell {
            if hasSelection {
                lastLoadedEditableCell.valueLabelText = localizedSelectionSummary
                lastLoadedEditableCell.valueLabelColor = appearance.preferredFieldValueColor
            } else {
                lastLoadedEditableCell.valueLabelText = emptyValueLabelText
                lastLoadedEditableCell.valueLabelColor = appearance.preferredEmptyFieldValueColor
            }
        }
    }


    // MARK: - Cell setup
    
    /// Set up the read-only version of this cell. By default this will set up a `WCGenericFieldWithFieldNameCell` or `WCGenericFieldCell` -
    /// override this function in subclasses to customize behavior.
    ///
    /// - Parameter cell: The UITableViewCell for the field.
    public override func setupCell(_ cell: UITableViewCell) {
        super.setupCell(cell)
        if let readOnlyCell = cell as? WCGenericFieldCell, hasSelection {
            readOnlyCell.valueLabelColor = appearance.preferredFieldValueColor
            readOnlyCell.valueLabelText = localizedSelectionSummary
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

}
