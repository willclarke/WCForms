//
//  WCForm.swift
//  WCForms
//
//  Created by Will Clarke on 2/27/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation

open class WCForm {
    public var formTitle: String? = nil
    public var formSections: [WCFormSection] = [WCFormSection]()

    public init() {
        setupFormSections()
    }

    open func setupFormSections() {
        return
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

    public init(headerTitle: String? = nil, formFields: [WCField]? = nil) {
        self.headerTitle = headerTitle
        if let formFields = formFields {
            self.formFields = formFields
        }
    }
}
