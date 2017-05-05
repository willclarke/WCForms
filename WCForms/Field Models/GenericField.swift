//
//  GenericField.swift
//  WCForms
//
//  Created by Will Clarke on 3/9/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation

/// A protocol for in enum that can has associated read-only and editable UITableViewCells for a particular Field type.
public protocol FieldCellAppearance {
    
    /// The nib name for the read-only version of the cell for the field's appearance.
    var nibName: String { get }

    /// The cell identifier for the read-only version of the cell. By default, this will be identical to the `nibName`.
    var cellIdentifier: String { get }

    /// The nib name for the editable version of the cell for the field's appearance.
    var editableNibName: String { get }
    
    /// The cell identifier for the editable version of the cell. By default, this will be identical to the `editableNibName`.
    var editableCellIdentifier: String { get }

    /// Whether or not this field cell appearance can become first responder.
    var canBecomeFirstResponder: Bool { get }

    /// The preferred color for field names in this appearance. Defaults to `UIColor.black`
    var preferredFieldNameColor: UIColor { get }

    /// The preferred color for field values in this appearance. Defaults to `UIColor.darkGray`
    var preferredFieldValueColor: UIColor { get }

    /// The preferred color for field values when they are empty in this appearance. Defaults to `UIColor.lightGray`
    var preferredEmptyFieldValueColor: UIColor { get }

    /// The default field cell appearance for this field.
    static var `default`: Self { get }

    /// An array of all the values of this field cell appearance.
    static var allValues: [Self] { get }

}

public extension FieldCellAppearance {

    /// By default, return the field cell appearance's `nibName`.
    public var cellIdentifier: String {
        return self.nibName
    }

    /// By default, return the field cell appearance's `editableNibName`.
    public var editableCellIdentifier: String {
        return self.editableNibName
    }

    /// The preferred color for field names in this appearance. Defaults to `UIColor.black`
    var preferredFieldNameColor: UIColor {
        return UIColor.black
    }

    /// The preferred color for field values in this appearance. Defaults to `UIColor.darkGray`
    var preferredFieldValueColor: UIColor {
        return UIColor.darkGray
    }

    /// The preferred color for field values when they are empty in this appearance. Defaults to `UIColor.lightGray`
    var preferredEmptyFieldValueColor: UIColor {
        return UIColor.lightGray
    }

}

/// A custom appearance description allowing
public struct WCFieldAppearanceDescription {

    /// Private storage for the cell identifier specified by the API user. Needs to be kept separate from the `cellIdentifier` property because that may return
    /// the `userSpecifiedNibName` if this is unspecified.
    private var userSpecifiedCellIdentifier: String? = nil

    /// The cell identifier for the read-only version of the field. If it's not specified, but a `nibName` is, then it will be assumed that the cell identifier
    /// and the nib name are the same.
    public var cellIdentifier: String? {
        get {
            return userSpecifiedCellIdentifier ?? userSpecifiedNibName
        }
        set (newIdentifier) {
            userSpecifiedCellIdentifier = newIdentifier
        }
    }

    /// Private storage for the nib name specified by the API user. Needs to be kept separate from the `nibName` property because that may return the
    /// `userSpecifiedCellIdentifier` if this is unspecified.
    private var userSpecifiedNibName: String? = nil

    /// The NIB name for the read-only version of the field. If it's not specified, but a `cellIdentifier` is, then it will be assumed that the nib name and
    /// the cell identifier are the same.
    public var nibName: String? {
        get {
            return userSpecifiedNibName ?? userSpecifiedCellIdentifier
        }
        set (newNibName) {
            userSpecifiedNibName = newNibName
        }
    }

    /// Private storage for the editable cell identifier specified by the API user. Needs to be kept separate from the `editableCellIdentifier` property
    /// because that may return the `userSpecifiedEditableNibName` if this is unspecified.
    private var userSpecifiedEditableCellIdentifier: String? = nil

    /// The cell identifier for the editable version of the field. If it's not specified, but an `editableNibName` is, then it will be assumed that the
    /// editable cell identifier and the editable nib name are the same.
    public var editableCellIdentifier: String? {
        get {
            return userSpecifiedEditableCellIdentifier ?? userSpecifiedEditableNibName
        }
        set (newEditableCellIdentifier) {
            userSpecifiedEditableCellIdentifier = newEditableCellIdentifier
        }
    }

    /// Private storage for the editable nib name specified by the API user. Needs to be kept separate from the `editableNibName` property because that may
    /// return the `userSpecifiedEditableCellIdentifier` if this is unspecified.
    private var userSpecifiedEditableNibName: String? = nil

    /// The NIB name for the editable version of the field. If it's not specified, but an `editableCellIdentifier` is, then it will be assumed that the
    /// editable nib name and the editable cell identifier are the same.
    public var editableNibName: String? {
        get {
            return userSpecifiedEditableNibName ?? userSpecifiedEditableCellIdentifier
        }
        set (newEditableNibName) {
            userSpecifiedEditableNibName = newEditableNibName
        }
    }

    /// Initialize a custom appearance descriptor for a read only field.
    ///
    /// - Parameters:
    ///   - nibName: The nib name to initialize a cell with with the appearance. This nib should be registered for cell reuse in the form's table view.
    ///   - cellIdentifier: The cell identifier for the cell specified in the Nib. If nil, it will assume the cellIdentifier is the same as the nib name.
    public init(nibName: String, cellIdentifier: String? = nil) {
        self.cellIdentifier = cellIdentifier
        self.nibName = nibName
    }

    /// Initialize a custom appearance descriptor for an editable field.
    ///
    /// - Parameters:
    ///   - editableNibName: The nib name to initialize an editable cell with with the appearance. This nib should be registered for cell reuse in the form's
    ///                      table view.
    ///   - editableCellIdentifier: The cell identifier for the editable cell specified in the Nib. If nil, it will assume the `editableCellIdentifier` is the
    ///                             same as the nib name.
    public init(editableNibName: String, editableCellIdentifier: String? = nil) {
        self.editableCellIdentifier = editableCellIdentifier
        self.editableNibName = editableNibName
    }

    /// Initialize a custom appearance for a field that is both editable and viewable. Initialization is done by nib names, assuming the cell identifiers
    /// are the same as the nib names.
    ///
    /// - Parameters:
    ///   - nibName: The nib name to initialize a cell with with the appearance. This nib should be registered for cell reuse in the form's table view.
    ///   - editableNibName: The nib name to initialize an editable cell with with the appearance. This nib should be registered for cell reuse in the form's
    ///                      table view.
    public init(nibName: String, editableNibName: String) {
        self.nibName = nibName
        self.editableNibName = editableNibName
    }

}

/// A `WCTypedInputField` with a generic `ValueType` and `AppearanceType`.
public class WCGenericField<ValueType: Equatable, AppearanceType: FieldCellAppearance>: WCTypedInputField {

    // MARK: - Instance variables

    /// The appearance of this field. This appearance will determine both the read-only and editable appearance, unless a custom `editableAppearance` is set.
    public var appearance: AppearanceType {
        didSet {
            // If we are in a form and the appearance has changed, we need to reload the view.
            guard let formController = formSection?.form?.formController else {
                return
            }
            let isEditing = formController.isEditing
            if !isEditing || (isEditing && editableAppearance == nil) {
                formController.reloadIndexPath(for: self, with: .automatic)
            }
        }
    }

    /// A custom appearance to use when the field is being edited, in case the default editable appearance is not desired.
    public var editableAppearance: AppearanceType? {
        didSet {
            // If we are in a form and the appearance has changed, we need to reload the view.
            guard let formController = formSection?.form?.formController else {
                return
            }
            let isEditing = formController.isEditing
            if isEditing {
                formController.reloadIndexPath(for: self, with: .automatic)
            }
        }
    }

    /// The pre-edit value of the field.
    internal var previousValue: ValueType?

    /// The text to appear on the field when no value has been set.
    public var emptyValueLabelText: String = NSLocalizedString("None", tableName: "WCForms", comment: "Displayed when there is no value for a field")


    // MARK: - Initialization

    /// Initialize a field with a field name.
    ///
    /// - Parameter fieldName: The user facing, localized field name of the field.
    public init(fieldName: String) {
        self.fieldName = fieldName
        self.appearance = AppearanceType.default
    }

    /// Initialize a field with a field name and specify if it's required.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - isRequired: Whether or not the field is required.
    public convenience init(fieldName: String, isRequired: Bool) {
        self.init(fieldName: fieldName)
        self.isRequired = isRequired
    }

    /// Initialize a field with a field name and initial value.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    public convenience init(fieldName: String, initialValue: ValueType?) {
        self.init(fieldName: fieldName)
        self.fieldValue = initialValue
    }

    /// Initialize a field with a field name and initial value and specify if it's required.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - isRequired: Whether or not the field is required.
    public convenience init(fieldName: String, initialValue: ValueType?, isRequired: Bool) {
        self.init(fieldName: fieldName, initialValue: initialValue)
        self.isRequired = isRequired
    }

    /// Initialize a field with a field name, initial value, and block to call when the field changes its value.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - onValueChange: A block to be called when the field changes its value.
    public convenience init(fieldName: String, initialValue: ValueType?, onValueChange: @escaping ((ValueType?) -> Void)) {
        self.init(fieldName: fieldName, initialValue: initialValue)
        self.onValueChange = onValueChange
    }

    /// Initialize a field with a field name, initial value, a block to call when the field changes its value, and specify if it's required.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - onValueChange: A block to be called when the field changes its value.
    ///   - isRequired: Whether or not the field is required.
    public convenience init(fieldName: String, initialValue: ValueType?, onValueChange: @escaping ((ValueType?) -> Void), isRequired: Bool) {
        self.init(fieldName: fieldName, initialValue: initialValue, onValueChange: onValueChange)
        self.isRequired = isRequired
    }

    /// Initialize a field with a field name, initial value, and appearance.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - appearance: The appearance for this field.
    public convenience init(fieldName: String, initialValue: ValueType?, appearance: AppearanceType) {
        self.init(fieldName: fieldName, initialValue: initialValue)
        self.appearance = appearance
    }

    /// Initialize a field with a field name, initial value, appearance, and specify if it's required.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - appearance: The appearance for this field.
    ///   - isRequired: Whether or not the field is required.
    public convenience init(fieldName: String, initialValue: ValueType?, appearance: AppearanceType, isRequired: Bool) {
        self.init(fieldName: fieldName, initialValue: initialValue, appearance: appearance)
        self.isRequired = isRequired
    }

    /// Initialize a field with a field name, initial value, appearance, and a block to call when the field changes its value.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - appearance: The appearance for this field.
    ///   - onValueChange: A block to be called when the field changes its value.
    public convenience init(fieldName: String, initialValue: ValueType?, appearance: AppearanceType, onValueChange: @escaping ((ValueType?) -> Void)) {
        self.init(fieldName: fieldName, initialValue: initialValue, appearance: appearance)
        self.onValueChange = onValueChange
    }

    /// Initialize a field with a field name, initial value, appearance, a block to call when the field changes its value, and specify if it's required.
    ///
    /// - Parameters:
    ///   - fieldName: The user facing, localized field name of the field.
    ///   - initialValue: The initial value for the field.
    ///   - appearance: The appearance for this field.
    ///   - onValueChange: A block to be called when the field changes its value.
    ///   - isRequired: Whether or not the field is required.
    public convenience init(fieldName: String,
                            initialValue: ValueType,
                            appearance: AppearanceType,
                            onValueChange: @escaping ((ValueType?) -> Void),
                            isRequired: Bool)
    {
        self.init(fieldName: fieldName, initialValue: initialValue, appearance: appearance, onValueChange: onValueChange)
        self.isRequired = isRequired
    }


    // MARK: - Conformance to `WCTypedInputField`

    /// The type this input field uses.
    public typealias InputValueType = ValueType

    /// The value of this field.
    public var fieldValue: ValueType?

    /// User interaction with a view as resulted in the field's value changing. Updates the field value and calls the specified `onValueChange`, if set.
    ///
    /// - Parameter newValue: The new value that has been set by the user in the view.
    public func viewDidUpdateValue(newValue: ValueType?) {
        fieldValue = newValue
        if let settingBlock = onValueChange {
            settingBlock(newValue)
        }
    }

    /// A block to call when the field changes its value.
    public var onValueChange: ((ValueType?) -> Void)? = nil


    // MARK: - Conformance to `WCInputField`

    /// The name of the field. This should be a user facing string.
    public var fieldName: String

    /// Whether or not this field is required to have a valid value set. Defaults to `false`.
    public var isRequired: Bool = false

    /// Whether or not this field should be visible in the read only mode when it does not have a valid value set. Defaults to `false`.
    public var isVisibleWhenEmpty: Bool = false

    /// Whether or not this field has a valid value set.
    public var isEmpty: Bool {
        return fieldValue == nil
    }

    /// Whether or not this field has the ability to become a first responder. Uses the specified `editableAppearance` and `appearance`.
    public var canBecomeFirstResponder: Bool {
        return editableAppearance?.canBecomeFirstResponder ?? appearance.canBecomeFirstResponder
    }

    /// Attempt to make this field to become the first responder. By default, this does nothing unless overridden by subclasses.
    public func becomeFirstResponder() {}

    /// Attempt to make this field resign its first responder status. By default, this does nothing unless overridden by subclasses.
    public func resignFirstResponder() {}

    /// Make sure this field has a valid value assigned.
    ///
    /// - Throws: A `WCFieldValidationError` describing the first error in validating the field.
    public func validateFieldValue() throws {
        if isRequired && fieldValue == nil {
            throw WCFieldValidationError.missingValue(fieldName: fieldName)
        }
    }


    // MARK: - Conformance to `WCField`

    /// Whether or not the field is editable. Note that this is different from when a form is editable - a form can be editable generally, but an individual
    /// field may be designated as not editable. A form controller will only make a field editable if both the form is editable, and the individual field is
    /// designated as editable. Defaults to `true`.
    public var isEditable: Bool = true

    /// Whether or not the user can copy the field's value to the clipboard when the field is in read-only mode. This can be accomplished by tapping
    /// and holding on the read-only table view cell. Defaults to `true`.
    public var isAbleToCopy: Bool = true

    /// If the `fieldValue` conforms to `CustomStringConvertible`, then this returns the `description` property. Otherwise, it returns `nil`. This behavior
    /// should be overridden in subclasses to implement custom copy functionality.
    public var copyValue: String? {
        if let stringConvertableValue = fieldValue as? CustomStringConvertible {
            return stringConvertableValue.description
        }
        return nil
    }

    /// Whether or not this field has been changed since it began editing. If the field is not editable, it will return `false`.
    public var hasChanges: Bool {
        if !isEditable {
            return false
        }
        if fieldValue != previousValue {
            return true
        } else {
            return false
        }
    }

    /// A pointer to the section that contains this field.
    weak public var formSection: WCFormSection? = nil

    /// Dequeues a cell from the specified `tableView` for an index path for this cell in the specified edit mode. This uses the `appearance` and
    /// `editableAppearance` to determine what kinds of cells to dequeue.
    ///
    /// - Parameters:
    ///   - tableView: The UITableView from which to dequeue the cell.
    ///   - indexPath: The IndexPath that is being requested.
    ///   - isEditing: The current editing mode of the form.
    /// - Returns: A valid UITableViewCell for the reqested IndexPath, dequeued from the specified UITableView.
    public final func dequeueCell(from tableView: UITableView, for indexPath: IndexPath, isEditing: Bool) -> UITableViewCell {
        let cellIdentifier = preferredCellIdentifier(whenEditing: isEditing)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if isEditing && isEditable {
            self.setupEditableCell(cell)
        } else {
            self.setupCell(cell)
        }
        return cell
    }

    /// The preferred cell identifier for the cell when the form is in a particular editing mode. By default, this will return the cell identifier
    /// for the field's appearance. If overridden, make sure the specified cell identifier has a nib registered with the form's table view.
    ///
    /// - Parameter isEditing: Whether or not the form is being edited.
    /// - Returns: The cell identifier for the cell.
    public func preferredCellIdentifier(whenEditing isEditing: Bool) -> String {
        let editableCellIdentifier = editableAppearance?.editableCellIdentifier ?? appearance.editableCellIdentifier
        return isEditing && isEditable ? editableCellIdentifier : appearance.cellIdentifier
    }

    /// Registers the nibs/cell reuse identifiers for field based on the field's `AppearanceType`.
    ///
    /// - Parameter tableView: The UITableView in which to register the nibs for their cell reuse identifiers.
    public func registerNibsForCellReuseIdentifiers(in tableView: UITableView) {
        let nibBundle = Bundle(for: WCTextField.self)
        for appearance in AppearanceType.allValues {
            let readOnlyNib = UINib(nibName: appearance.nibName, bundle: nibBundle)
            let editableNib = UINib(nibName: appearance.editableNibName, bundle: nibBundle)
            tableView.register(readOnlyNib, forCellReuseIdentifier: appearance.cellIdentifier)
            tableView.register(editableNib, forCellReuseIdentifier: appearance.editableCellIdentifier)
        }
    }

    /// Stores the previous value of the field so it can be compared and potentially restored if editing is canceled. NOTE: if you override this function but
    /// want to maintain the form restoration behavior, you must call `super.formWillBeginEditing()`.
    public func formWillBeginEditing() {
        previousValue = fieldValue
    }

    /// If the field has changed since editing began, this restores the pre-editing value for the field and calls the `onValueChange` block with the old value
    /// that is being restored. NOTE: if you override this function but want to maintain the form restoration behavior, you must call
    /// `super.formWillBeginEditing()`.
    public func formDidCancelEditing() {
        if fieldValue != previousValue {
            fieldValue = previousValue
            if let settingBlock = onValueChange {
                settingBlock(previousValue)
            }
        }
        previousValue = nil
    }

    /// Clears the stored pre-editing value. NOTE: if you override this function but want to maintain the form restoration behavior, you must call
    /// `super.formWillBeginEditing()`.
    public func formDidFinishEditing() {
        previousValue = nil
    }


    // MARK: - Cell setup

    /// Set up the read-only version of this cell. By default this will set up a `WCGenericFieldWithFieldNameCell` or `WCGenericFieldCell` - 
    /// override this function in subclasses to customize behavior.
    ///
    /// - Parameter cell: The UITableViewCell for the field.
    public func setupCell(_ cell: UITableViewCell) {
        if isAbleToCopy && copyValue != nil {
            cell.selectionStyle = .default
        } else {
            cell.selectionStyle = .none
        }
        
        if let readOnlyCell = cell as? WCGenericFieldWithFieldNameCell {
            readOnlyCell.fieldNameLabelColor = appearance.preferredFieldNameColor
            readOnlyCell.fieldNameLabelText = fieldName
        }
        if let readOnlyCell = cell as? WCGenericFieldCell {
            if let stringConvertableValue = fieldValue as? CustomStringConvertible {
                if stringConvertableValue.description != "" {
                    readOnlyCell.valueLabelColor = appearance.preferredFieldValueColor
                    readOnlyCell.valueLabelText = stringConvertableValue.description
                } else {
                    readOnlyCell.valueLabelColor = appearance.preferredEmptyFieldValueColor
                    readOnlyCell.valueLabelText = emptyValueLabelText
                }
            } else {
                readOnlyCell.valueLabelColor = appearance.preferredEmptyFieldValueColor
                readOnlyCell.valueLabelText = emptyValueLabelText
            }
        }
    }

    /// Set up the editable version of this cell. By default, this just calls `setupCell(cell)` - override this function in subclasses to customize behavior.
    ///
    /// - Parameter cell: The UITableViewCell for the field.
    public func setupEditableCell(_ cell: UITableViewCell) {
        setupCell(cell)
    }

}
