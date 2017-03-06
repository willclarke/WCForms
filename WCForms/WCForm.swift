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
    public var formSections: [WCFormSection] = [WCFormSection]()

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

    subscript(indexPath: IndexPath) -> WCField? {
        guard indexPath.section < formSections.count && indexPath.row < formSections[indexPath.section].formFields.count else {
            return nil
        }
        return formSections[indexPath.section].formFields[indexPath.row]
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
    public var formFields = [WCField]()
    public var footerTitle: String? = nil

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
        }
    }
}
