//
//  WCForm.swift
//  WCForms
//
//  Created by Will Clarke on 2/27/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation

typealias WCFormValidationError = (field: WCInputField, indexPath: IndexPath, error: String)

/// A class that defines a form. This form does not have a backing object and instead acts as a plain form.
open class WCForm {

    /// The title for this form. If set, the form controller will attempt to assign this title to the navigationItem's title.
    public var formTitle: String? = nil

    /// Whether or not the form contains fields whose values have changed since they began editing.
    public final var hasFieldChanges: Bool {
        for formSection in formSections {
            if formSection.hasFieldChanges {
                return true
            }
        }
        return false
    }

    /// The sections in the form.
    public internal(set) var formSections: [WCFormSection] = [WCFormSection]() {
        didSet {
            for oldSection in oldValue {
                oldSection.form = nil
            }
            for section in formSections {
                section.form = self
            }
        }
    }

    /// The controller that displays this form
    weak var formController: WCFormController? = nil

    /// Initializes a new form.
    public init() {
        if let initialFormSections = getInitialFormSections() {
            formSections = initialFormSections
        }
        for section in formSections {
            section.form = self
        }
    }

    /// Convenience initializer when the form sections are known
    public convenience init(formSections: [WCFormSection]) {
        self.init()
        self.formSections = formSections
        for section in formSections {
            section.form = self
        }
    }

    /// Override point to set up form sections on initialization
    open func getInitialFormSections() -> [WCFormSection]? {
        return nil
    }

    /// Gets the first validation error for the form.
    ///
    /// - Returns: The first validation error for the form.
    internal func firstValidationError() -> WCFormValidationError? {
        for (formSectionIndex, formSection) in formSections.enumerated() {
            for (fieldIndex, field) in formSection.formFields.enumerated() {
                if let inputField = field as? WCInputField {
                    do {
                        try inputField.validateFieldValue()
                    } catch WCFieldValidationError.missingValue(_) {
                        let errorMessage = NSLocalizedString("This field is required.",
                                                             tableName: "WCForms",
                                                             comment: "Error message displayed when a required field is not completed.")
                        return WCFormValidationError(inputField, IndexPath(row: fieldIndex, section: formSectionIndex), errorMessage)
                    } catch WCFieldValidationError.outOfBounds(_, let boundsError) {
                        return WCFormValidationError(inputField, IndexPath(row: fieldIndex, section: formSectionIndex), boundsError)
                    } catch WCFieldValidationError.invalidFormat(_, let formatError) {
                        return WCFormValidationError(inputField, IndexPath(row: fieldIndex, section: formSectionIndex), formatError)
                    } catch {
                        let errorMessage = NSLocalizedString("An unknown error occurred.",
                                                             tableName: "WCForms",
                                                             comment: "Error message displayed when an unknown error occurrs on a form.")
                        return WCFormValidationError(inputField, IndexPath(row: fieldIndex, section: formSectionIndex), errorMessage)
                    }
                }
            }
        }
        return nil
    }

    /// Tells the form that the user is beginning to edit it. Internally, this tells all form sections and fields that they are being edited, which triggers
    /// them to store their current, pre-editing values so they can be restored if editing is canceled, and can determine if the form has been edited.
    internal func beginEditing() {
        for formSection in formSections {
            for formField in formSection.formFields {
                formField.formWillBeginEditing()
            }
        }
    }

    /// Tells the form that the user is canceling editing it. Internally, this tells all form sections and fields that editing is being canceled, which
    /// triggers them discard any changes and revert to their pre-editing values.
    internal func cancelEditing() {
        for formSection in formSections {
            for formField in formSection.formFields {
                formField.formDidCancelEditing()
            }
        }
    }

    /// Tells the form that the user is done editing it. Internally, this tells all form sections and fields that editing is complete, which triggers them to
    /// discard their pre-edit values and commit the new ones.
    internal func finishEditing() {
        for formSection in formSections {
            for formField in formSection.formFields {
                formField.formDidFinishEditing()
            }
        }
    }

    /// Gets the number of visible sections in the form during a particular edit mode. Sections are considered visible if they contain at least one
    /// visible field.
    ///
    /// - Parameter isEditing: Whether or not the form is editing.
    /// - Returns: A count of the visible sections.
    internal func numberOfVisibleSections(whenEditingForm isEditing: Bool) -> Int {
        var numberOfVisibleSections = 0
        for section in formSections {
            if section.numberOfVisibleFields(whenEditingForm: isEditing) > 0 {
                numberOfVisibleSections += 1
            }
        }
        return numberOfVisibleSections
    }

    /// Gets the number of visible fields in a form's section during a particular edit mode. Generally, fields are considered visible if they are in edit mode,
    /// or if they are in read-only mode and they have a valid value (or if isVisibleWhenEmpty is set to true). However, individual fields may have custom
    /// rules to determine if they are visible.
    ///
    /// - Parameters:
    ///   - visibleSection: The section index for which to retrieve the number of fields.
    ///   - isEditing: Whether or not the form is editing.
    /// - Returns: The number of fields in the section.
    internal func numberOfVisibleFields(forVisibleSection visibleSection: Int, whenEditingForm isEditing: Bool) -> Int {
        return section(forVisibleSection: visibleSection, whenEditingForm: isEditing)?.numberOfVisibleFields(whenEditingForm: isEditing) ?? 0
    }

    /// Gets a visible form section for a section index when the form is in a particular edit mode.
    ///
    /// - Parameters:
    ///   - visibleSection: The section index for which to retrieve the form section.
    ///   - isEditing: Whether or not the form is editing.
    /// - Returns: The form section for the specified section index.
    internal func section(forVisibleSection visibleSection: Int, whenEditingForm isEditing: Bool) -> WCFormSection? {
        var currentVisibleSection = 0
        for section in formSections {
            if section.isVisible(whenEditingForm: isEditing) {
                if visibleSection == currentVisibleSection {
                    return section
                }
                currentVisibleSection += 1
            }
        }
        return nil
    }

    /// Gets a visible field for an index path when the form is in a particular edit mode.
    ///
    /// - Parameters:
    ///   - visibleIndexPath: The index path for which to retrieve the field.
    ///   - isEditing: Whether or not the form is editing.
    /// - Returns: The field for the specified index path.
    internal func field(for visibleIndexPath: IndexPath, whenEditingForm isEditing: Bool) -> WCField? {
        return section(forVisibleSection: visibleIndexPath.section, whenEditingForm: isEditing)?
                .field(forVisibleRow: visibleIndexPath.row, whenEditingForm: isEditing)
    }

    /// Gets the next visible input field that can become a first responder after a specified input field, typically for the purposes of bringing first
    /// responder status to the next field.
    ///
    /// - Parameter currentField: The field for which to search before finding the next visible responder input field.
    /// - Returns: The next input field that can become a first responder.
    internal func nextVisibleResponder(after currentField: WCInputField) -> WCInputField? {
        var foundCurrentField = false
        for section in formSections {
            for field in section.formFields {
                if let inputField = field as? WCInputField {
                    if inputField === currentField {
                        foundCurrentField = true
                    } else if foundCurrentField && inputField.isEditable && inputField.canBecomeFirstResponder && inputField.isVisible(whenEditingForm: true) {
                        return inputField
                    }
                }
            }
        }
        return nil
    }

    /// Gets the previous visible input field that can become a first responder before a specified input field, typically for the purposes of bringing first
    /// responder status to the previous field.
    ///
    /// - Parameter currentField: The field for which to search before finding the previous visible responder input field.
    /// - Returns: The previous input field that can become a first responder.
    internal func previousVisibleResponder(before currentField: WCInputField) -> WCInputField? {
        var previousVisibleResponder: WCInputField? = nil
        for section in formSections {
            for field in section.formFields {
                if let inputField = field as? WCInputField {
                    if inputField === currentField {
                        return previousVisibleResponder
                    } else if inputField.isEditable && inputField.canBecomeFirstResponder && inputField.isVisible(whenEditingForm: true){
                        previousVisibleResponder = inputField
                    }
                }
            }
        }
        return nil
    }

    /// Gets the `IndexPath` for a specified field in the form, if it exists in the form.
    ///
    /// - Parameters:
    ///   - formField: The form field of which to get the index.
    ///   - isEditing: Whether the returned `IndexPath` should be for when the form is being edited or not.
    /// - Returns: The `IndexPath` of the requested field, if it could be found. Otherwise, `nil`.
    internal func visibleIndexPath(for formField: WCField, whenEditingForm isEditing: Bool) -> IndexPath? {
        var visibleSectionIndex = 0
        for section in formSections {
            if section.isVisible(whenEditingForm: isEditing) {
                if let visibleRowIndex = section.visibleRowIndex(for: formField, whenEditingForm: isEditing) {
                    return IndexPath(row: visibleRowIndex, section: visibleSectionIndex)
                }
                visibleSectionIndex += 1
            }
        }
        return nil
    }

}

/// A generic typed object form. Subclass this and override setupFormSections() to initialize your own form.
open class WCObjectForm<ObjectType: WCFormObject>: WCForm {

    /// The object that this form represents
    public var formObject: ObjectType

    /// Initializes the form with the specified object.
    ///
    /// - Parameter formObject: The object that the form will represent.
    public init(formObject: ObjectType) {
        self.formObject = formObject
        super.init()
    }
}

/// A section on a form
public class WCFormSection {

    /// A header title for the section.
    public var headerTitle: String? = nil

    /// An array of fields contained in the form
    public internal(set) var formFields = [WCField]() {
        didSet {
            for oldField in oldValue {
                oldField.formSection = nil
            }
            for field in formFields {
                field.formSection = self
            }
        }
    }

    /// Footer text for the section.
    public var footerTitle: String? = nil

    /// Weak pointer to the parent containing form.
    internal weak var form: WCForm? = nil

    /// Indicates whether the section is visible during a particular edit mode. A section is considered visible if it has at least one visible field.
    ///
    /// - Parameter isEditing: Whether or not the form is editing.
    /// - Returns: True if the section is visible, false otherwise.
    internal func isVisible(whenEditingForm isEditing: Bool) -> Bool {
        if numberOfVisibleFields(whenEditingForm: isEditing) > 0 {
            return true
        } else {
            return false
        }
    }

    /// Returns the field for a visible row when the form is in a particular edit mode.
    ///
    /// - Parameters:
    ///   - visibleRow: The row index of the requested field.
    ///   - isEditing: Whether or not the form is editing.
    /// - Returns: The field for the specified row index.
    func field(forVisibleRow visibleRow: Int, whenEditingForm isEditing: Bool) -> WCField? {
        var visibleRowIndex = 0
        for field in formFields {
            if field.isVisible(whenEditingForm: isEditing) {
                if visibleRow == visibleRowIndex {
                    return field
                }
                visibleRowIndex += 1
            }
        }
        return nil
    }

    /// Gets the number of visible fields in this form section during a particular edit mode. Generally, fields are considered visible if they are in edit mode,
    /// or if they are in read-only mode and they have a valid value (or if isVisibleWhenEmpty is set to true). However, individual fields may have custom
    /// rules to determine if they are visible.
    ///
    /// - Parameter isEditing: Whether or not the form is editing.
    /// - Returns: The number of fields in the section.
    public func numberOfVisibleFields(whenEditingForm isEditing: Bool) -> Int {
        var numberOfVisibleFields = 0
        for field in formFields {
            if field.isVisible(whenEditingForm: isEditing) {
                numberOfVisibleFields += 1
            }
        }
        return numberOfVisibleFields
    }

    /// Whether or not the section has fields that have changed since the form has started editing.
    public final var hasFieldChanges: Bool {
        for formField in formFields {
            if formField.hasChanges {
                return true
            }
        }
        return false
    }

    /// Initializes a new form section.
    ///
    /// - Parameters:
    ///   - headerTitle: The header title for the section
    ///   - formFields: Fields that should be contained in the section.
    public init(headerTitle: String? = nil, formFields: [WCField]? = nil) {
        self.headerTitle = headerTitle
        if let formFields = formFields {
            self.formFields = formFields
            for field in formFields {
                field.formSection = self
            }
        }
    }

    /// Gets the row index for a specified field in the form section, if it exists in the form section.
    ///
    /// - Parameters:
    ///   - searchField: The form field of which to get the index.
    ///   - isEditing: Whether the returned `IndexPath` should be for when the form is being edited or not.
    /// - Returns: The index of the requested field, if it could be found. Otherwise, `nil`.
    func visibleRowIndex(for searchField: WCField, whenEditingForm isEditing: Bool) -> Int? {
        var visibleRowIndex = 0
        for field in formFields {
            if field.isVisible(whenEditingForm: isEditing) {
                if field === searchField {
                    return visibleRowIndex
                }
                visibleRowIndex += 1
            }
        }
        return nil
    }
    
}
