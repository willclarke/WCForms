//
//  FriendController.swift
//  WCFormsApp
//
//  Created by Will Clarke on 2/27/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation
import WCForms

struct Friend {
    var name: String
    var age: Int
    var birthdate: Date
    var favorite: Bool
}

extension Friend: WCFormObject {}

class FriendForm: WCObjectForm<Friend> {

    override init(formObject: Friend) {
        super.init(formObject: formObject)
    }

    override func getInitialFormSections() -> [WCFormSection]? {
        var formSections = [WCFormSection]()
        let nameField = WCTextField(fieldName: "Full Name", initialValue: formObject.name, appearance: .stackedCaption) { (newValue: String?) in
            if let validName = newValue {
                self.formObject.name = validName
            }
        }
        let ageField = WCIntField(fieldName: "Age", initialValue: formObject.age, appearance: .rightDetail)
        let birthdateField = WCDateField(fieldName: "Birth Date", initialValue: Date(), appearance: .stackedCaption)
        let favoriteField = WCBoolField(fieldName: "Favorite?", initialValue: formObject.favorite, appearance: .rightDetail)
        let ringtoneOptionGroups = [OptionFieldGroup<Ringtone>(items: Ringtone.defaultRingtones, localizedFooter: "These are newer ringtones in iOS 9"),
                                    OptionFieldGroup<Ringtone>(items: Ringtone.classicRingtones, localizedTitle: "Classic")]
        let ringtonePickerField = WCMultipleOptionField<Ringtone>(fieldName: "Ringtone", optionGroups: ringtoneOptionGroups)
        ringtonePickerField.isRequired = true
        let mainSection = WCFormSection(headerTitle: nil, formFields: [nameField, favoriteField, birthdateField, ringtonePickerField])
        mainSection.footerTitle = "The main elements in a Friend object. There are a lot more, trust me. Duplicates appear below."
        formSections.append(mainSection)

        let emptyField = WCTextField(fieldName: "Some Text", initialValue: "Test")
        let ssnField = WCIntField(fieldName: "SSN", initialValue: nil, appearance: .slider)
        ssnField.minimumValue = 100000000
        ssnField.maximumValue = 999999999
        ssnField.numberFormatMask = "###-##-####"
        let relationshipField = WCSingleOptionField<RelationshipType>(fieldName: "Relationship", initialValue: .friend, allOptions: RelationshipType.allValues)
        relationshipField.allowsDeselection = false
        let someSection = WCFormSection(headerTitle: "Other Values", formFields: [emptyField, ssnField, relationshipField])
        formSections.append(someSection)

        let namePlaceholderField = WCTextField(fieldName: "Full Name", initialValue: formObject.name, appearance: .fieldNameAsPlaceholder)
        let nameAltField = WCTextField(fieldName: "Full Name", initialValue: formObject.name, appearance: .rightDetail)
        let nameReadOnlyField = WCTextField(fieldName: "Full Name", initialValue: formObject.name, appearance: .stacked)
        nameReadOnlyField.isEditable = false
        let ageStackedField = WCIntField(fieldName: "Age", initialValue: formObject.age, appearance: .stackedCaption)
        ageStackedField.maximumValue = 150
        let ageSliderField = WCIntField(fieldName: "Age", initialValue: formObject.age, appearance: .slider)
        let birthdateAltField = WCDateField(fieldName: "Birth Date", initialValue: formObject.birthdate, appearance: .rightDetail)
        let favoriteAltField = WCBoolField(fieldName: "Favorite?", initialValue: formObject.favorite, appearance: .stackedCaption)
        favoriteAltField.offDisplayValue = "No"
        favoriteAltField.onDisplayValue = "Yes"
        let altSection = WCFormSection(headerTitle: "Alternate Fields",
                                       formFields: [namePlaceholderField, ageField, nameAltField, ageStackedField, ageSliderField, birthdateAltField,
                                                    favoriteAltField, nameReadOnlyField])
        formSections.append(altSection)
        return formSections
    }
}

class JeffSection: WCFormController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let friend = Friend(name: "Jeff O'Brien", age: 34, birthdate: Date(), favorite: true)
        formModel = FriendForm(formObject: friend)
        navigationItem.leftItemsSupplementBackButton = true
        tableView.reloadData()
    }
}
