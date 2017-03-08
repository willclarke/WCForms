//
//  WCForm.swift
//  WCForms
//
//  Created by Will Clarke on 2/27/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation

public typealias WCFormValidationError = (field: WCInputField, indexPath: IndexPath, error: String)

open class WCForm {
    public var formTitle: String? = nil
    public var formSections: [WCFormSection] = [WCFormSection]() {
        didSet {
            for section in formSections {
                section.form = self
            }
        }
    }
    weak var formController: WCFormController? = nil

    public init() {
        setupFormSections()
    }

    open func setupFormSections() {
        return
    }

    open func firstValidationError() -> WCFormValidationError? {
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

    func beginEditing() {
        for formSection in formSections {
            for formField in formSection.formFields {
                formField.formWillBeginEditing()
            }
        }
    }

    func cancelEditing() {
        for formSection in formSections {
            for formField in formSection.formFields {
                formField.formDidCancelEditing()
            }
        }
    }

    func finishEditing() {
        for formSection in formSections {
            for formField in formSection.formFields {
                formField.formDidFinishEditing()
            }
        }
    }

    var hasFieldChanges: Bool {
        for formSection in formSections {
            if formSection.hasFieldChanges {
                return true
            }
        }
        return false
    }

    func numberOfVisibleSections(whenEditingForm isEditing: Bool) -> Int {
        var numberOfVisibleSections = 0
        for section in formSections {
            if section.numberOfVisibleFields(whenEditingForm: isEditing) > 0 {
                numberOfVisibleSections += 1
            }
        }
        return numberOfVisibleSections
    }

    func numberOfVisibleFields(forVisibleSection visibleSection: Int, whenEditingForm isEditing: Bool) -> Int {
        return section(forVisibleSection: visibleSection, whenEditingForm: isEditing)?.numberOfVisibleFields(whenEditingForm: isEditing) ?? 0
    }

    func section(forVisibleSection visibleSection: Int, whenEditingForm isEditing: Bool) -> WCFormSection? {
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

    func field(for visibleIndexPath: IndexPath, whenEditingForm isEditing: Bool) -> WCField? {
        return section(forVisibleSection: visibleIndexPath.section, whenEditingForm: isEditing)?
                .field(forVisibleRow: visibleIndexPath.row, whenEditingForm: isEditing)
    }

    func nextVisibleResponder(after currentField: WCInputField) -> WCInputField? {
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

    func previousVisibleResponder(before currentField: WCInputField) -> WCInputField? {
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

}

open class WCObjectForm<ObjectType: WCFormObject>: WCForm {
    public var formObject: ObjectType

    public init(formObject: ObjectType) {
        self.formObject = formObject
        super.init()
    }
}

public class WCFormSection {
    public var headerTitle: String? = nil
    public var formFields = [WCField]() {
        didSet {
            for field in formFields {
                field.formSection = self
            }
        }
    }
    public var footerTitle: String? = nil
    weak var form: WCForm? = nil
    
    func isVisible(whenEditingForm isEditing: Bool) -> Bool {
        if numberOfVisibleFields(whenEditingForm: isEditing) > 0 {
            return true
        } else {
            return false
        }
    }

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

    public func numberOfVisibleFields(whenEditingForm isEditing: Bool) -> Int {
        var numberOfVisibleFields = 0
        for field in formFields {
            if field.isVisible(whenEditingForm: isEditing) {
                numberOfVisibleFields += 1
            }
        }
        return numberOfVisibleFields
    }

    var hasFieldChanges: Bool {
        for formField in formFields {
            if formField.hasChanges {
                return true
            }
        }
        return false
    }

    public init(headerTitle: String? = nil, formFields: [WCField]? = nil) {
        self.headerTitle = headerTitle
        if let formFields = formFields {
            self.formFields = formFields
            for field in formFields {
                field.formSection = self
            }
        }
    }
}
