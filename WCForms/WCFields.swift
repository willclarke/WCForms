//
//  WCFields.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation

/// Protocol for a form field.
public protocol WCField: class {

    /// Whether or not the field is editable. Note that this is different from when a form is editable - a form can be editable generally, but an individual
    /// field may be designated as not editable. A form controller will only make a field editable if both the form is editable, and the individual field is
    /// designated as editable.
    var isEditable: Bool { get set }

    /// Whether or not the user can copy the field's value to the clipboard when the field is in read-only mode. This can be accomplished by tapping
    /// and holding on the read-only table view cell.
    var isAbleToCopy: Bool { get set }

    /// A string value for the field to copy to the clipboard when the user requests to copy the field. This will only be called if isAbleToCopy is set to true.
    var copyValue: String? { get }

    /// Whether or not this field has been changed since it began editing. If you inherit from WCGenericField, this will be automatically implemented by 
    /// comparing the stored, pre-edit value to the current value. If you have your own field implementation, you must manage the pre-editing and current
    /// values manually.
    var hasChanges: Bool { get }

    /// A pointer to the section that contains this field.
    weak var formSection: WCFormSection? { get set }

    /// Dequeue a cell from a tableView for an indexPath for this cell in the specified edit mode.
    ///
    /// - Parameters:
    ///   - tableView: The UITableView from which to dequeue the cell.
    ///   - indexPath: The IndexPath that is being requested.
    ///   - isEditing: The current editing mode of the form.
    /// - Returns: A valid UITableViewCell for the reqested IndexPath, dequeued from the specified UITableView.
    func dequeueCell(from tableView: UITableView, for indexPath: IndexPath, isEditing: Bool) -> UITableViewCell

    /// Register any nibs/cell reuse identifiers this field may use that aren't contained in the table view's prototype cells. Note that if you inherit from
    /// WCGenericField, this will be handled automatically by specifying the correct nibs and cell reuse identifiers in your appearance enum.
    ///
    /// - Parameter tableView: The UITableView in which to register the nibs for their cell reuse identifiers.
    func registerNibsForCellReuseIdentifiers(in tableView: UITableView)

    /// Called when a form containing the field begins editing. If your field has a field value, you should take this opportunity to save the pre-edit value
    /// in order to be able to revert the value if editing is canceled, or determine if the field has changed. If you inherit from WCGenericField, this
    /// behavior will be implemented automatically.
    func formWillBeginEditing()

    /// Called when a form containing the field cancels editing. If your field has a field value, you should revert it to the pre-editing value. If you inherit
    /// from WCGenericField, this behavior will be implemented automatically.
    func formDidCancelEditing()

    /// Called when a form containing the field cancels editing. If your field has a field value, and you are storing a pre-editing value, you should discard
    /// if. If you inherit from WCGenericField, this behavior will be implemented automatically.
    func formDidFinishEditing()

    /// Whether or not this field should be visible in the specified edit mode.
    ///
    /// - Parameter isEditing: Whether or not the form is editing.
    /// - Returns: Whether or not the form is editing.
    func isVisible(whenEditingForm isEditing: Bool) -> Bool

}

/// A validation error that can be thrown when a field is validated.
///
/// - missingValue: a required field has no value. The associated type `fieldName` is the name of the field with the missing value.
/// - outOfBounds: the field value is set outside of its defined bounds. The associated type `fieldName` is the name of the field, and the associated type
///                `boundsError` is a localized error string that may be displayed to the user.
/// - invalidFormat: the field value is in an invalid format. The associated type `fieldName` is the name of the field, and the associated type
///                `formatError` is a localized error string that may be displayed to the user.
public enum WCFieldValidationError: Error {

    case missingValue(fieldName: String)
    case outOfBounds(fieldName: String, boundsError: String)
    case invalidFormat(fieldName: String, formatError: String)

}

/// A field at that accepts user input.
public protocol WCInputField: WCField {

    /// The name of the field. This should be a user facing string.
    var fieldName: String { get set }

    /// Whether or not this field is required to have a valid value set.
    var isRequired: Bool { get set }

    /// Whether or not this field should be visible in the read only mode when it does not have a valid value set.
    var isVisibleWhenEmpty: Bool { get set }

    /// Whether or not this field has a valid value set.
    var isEmpty: Bool { get }

    /// Whether or not this field has the ability to become a first responder.
    var canBecomeFirstResponder: Bool { get }

    /// Attempt to make this field to become the first responder. To implement this, you may need to store the last loaded table view cell.
    func becomeFirstResponder()

    /// Attempt to make this field resign its first responder status. Implement this you may need to store the last loaded table view cell.
    func resignFirstResponder()

    /// Make sure this field has a valid value assigned.
    ///
    /// - Throws: A `WCFieldValidationError` describing the first error in validating the field.
    func validateFieldValue() throws

}

extension WCInputField {
    
    /// Determines whether the field is visible during a particular edit mode. A field should visible if it is being edited, if it is in read-only mode and is 
    /// not empty, or if it is set to be visible when empty. See also: `isEditable`, `isEmpty`, and `isVisibleWhenEmpty`
    ///
    /// - Parameter isEditing: Whether or not the form is editing.
    /// - Returns: True if the section is visible, false otherwise.
    public func isVisible(whenEditingForm isEditing: Bool) -> Bool {
        if isEditing && isEditable {
            return true
        } else if isVisibleWhenEmpty || !isEmpty {
            return true
        }
        return false
    }

    /// An input accessory view for a field that can become first responder.
    public var fieldInputAccessory: InputAccessoryView? {
        let formBundle = Bundle(for: InputAccessoryView.self)
        if let nib = formBundle.loadNibNamed("InputAccessoryView", owner: nil, options: nil) {
            if let inputAccessoryView = nib.first as? InputAccessoryView {
                if formSection?.form?.previousVisibleResponder(before: self) == nil {
                    inputAccessoryView.previousButton.isEnabled = false
                } else {
                    inputAccessoryView.previousButton.isEnabled = true
                }
                if formSection?.form?.nextVisibleResponder(after: self) == nil {
                    inputAccessoryView.nextButton.isEnabled = false
                } else {
                    inputAccessoryView.nextButton.isEnabled = true
                }
                inputAccessoryView.fieldDelegate = self
                return inputAccessoryView
            }
        }
        return nil
    }

    /// Resign first responder status and make the previous visible responder the first responder if possible.
    func makePreviousVisibleResponderFirstResponder() {
        self.resignFirstResponder()
        formSection?.form?.previousVisibleResponder(before: self)?.becomeFirstResponder()
    }

    /// Resign first responder status and make the previous visible responder the first responder if possible.
    func makeNextVisibleResponderFirstResponder() {
        self.resignFirstResponder()
        formSection?.form?.nextVisibleResponder(after: self)?.becomeFirstResponder()
    }

}

/// An input field with an associated type for its field value.
public protocol WCTypedInputField: WCInputField {

    /// The type this input field uses.
    associatedtype InputValueType

    /// The value of this field.
    var fieldValue: InputValueType? { get set }

    /// User interaction with a view as resulted in the field's value changing.
    ///
    /// - Parameter newValue: The new value that has been set by the user in the view.
    func viewDidUpdateValue(newValue: InputValueType?)

    /// A block to call when the field changes its value.
    var onValueChange: ((InputValueType?) -> Void)? { get set }

}

/// Protocol for an editable field that can be selected
public protocol WCEditableSelectableField: WCField {

    /// The user selected a field in a form controller.
    ///
    /// - Parameter formController: The form controller containing the field that the user selected. Use this view controller to push any dependent view 
    ///   controllers.
    func didSelectField(in formController: WCFormController, at indexPath: IndexPath)

}
