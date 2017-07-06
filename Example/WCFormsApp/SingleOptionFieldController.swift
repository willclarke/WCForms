//
//  SingleOptionFieldController.swift
//  WCFormsApp
//
//  Created by Will Clarke on 4/8/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation
import WCForms

class SingleOptionFieldController: OptionFieldController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ringtoneOptionGroups = [OptionFieldGroup<Ringtone>(items: Ringtone.defaultRingtones,
                                                               localizedTitle: nil,
                                                               localizedFooter: "Default Ringtones built in to iOS"),
                                    OptionFieldGroup<Ringtone>(items: Ringtone.classicRingtones,
                                                               localizedTitle: "Classic Ringtones",
                                                               localizedFooter: "Ringtones before iOS 7")]

        let singleOption = WCSingleOptionField<Ringtone>(fieldName: "Single Option", allOptions: Ringtone.defaultRingtones)
        singleOption.isVisibleWhenEmpty = true
        let multiGroupSingleOption = WCSingleOptionField<Ringtone>(fieldName: "Single Option with Groups",
                                                                   optionGroups: ringtoneOptionGroups)
        multiGroupSingleOption.isVisibleWhenEmpty = true
        let longName = WCSingleOptionField<Ringtone>(fieldName: "Single option field with a long name to test wrapping the field name to multiple lines",
                                                     allOptions: Ringtone.defaultRingtones)
        longName.isVisibleWhenEmpty = true
        let initialRingtone = Ringtone(name: "Alarm", isClassic: true)
        let optionWithDefault = WCSingleOptionField<Ringtone>(fieldName: "Field with initial value",
                                                              initialValue: initialRingtone,
                                                              allOptions: Ringtone.classicRingtones)
        optionWithDefault.isVisibleWhenEmpty = true
        let optionGroupWithDefault = WCSingleOptionField<Ringtone>(fieldName: "Field with initial value and groups",
                                                                   initialValue: initialRingtone,
                                                                   optionGroups: ringtoneOptionGroups)
        optionGroupWithDefault.isVisibleWhenEmpty = true
        let readOnlyField = WCSingleOptionField<RelationshipType>(fieldName: "Non-Editable Field", initialValue: RelationshipType.acquaintance)
        readOnlyField.isEditable = false
        let hiddenWhileEmpty = WCSingleOptionField<RelationshipType>(fieldName: "Hidden while empty", allOptions: RelationshipType.allValues)
        let requiredField = WCSingleOptionField<RelationshipType>(fieldName: "Required Field", allOptions: RelationshipType.allValues, isRequired: true)
        requiredField.isVisibleWhenEmpty = true
        let noDeselection = WCSingleOptionField<RelationshipType>(fieldName: "Field that doesn't allow deselection",
                                                                  allOptions: RelationshipType.allValues)
        noDeselection.allowsDeselection = false
        noDeselection.isVisibleWhenEmpty = true

        let singleOptionStay = WCSingleOptionField<Ringtone>(fieldName: "Single Option", allOptions: Ringtone.defaultRingtones)
        singleOptionStay.isVisibleWhenEmpty = true
        singleOptionStay.selectionBehavior = .remainInPicker
        let multiGroupSingleOptionStay = WCSingleOptionField<Ringtone>(fieldName: "Single Option with Groups",
                                                                   optionGroups: ringtoneOptionGroups)
        multiGroupSingleOptionStay.isVisibleWhenEmpty = true
        multiGroupSingleOptionStay.selectionBehavior = .remainInPicker
        let optionWithDefaultStay = WCSingleOptionField<Ringtone>(fieldName: "Field with initial value",
                                                              initialValue: initialRingtone,
                                                              allOptions: Ringtone.classicRingtones)
        optionWithDefaultStay.isVisibleWhenEmpty = true
        optionWithDefaultStay.selectionBehavior = .remainInPicker
        let optionGroupWithDefaultStay = WCSingleOptionField<Ringtone>(fieldName: "Field with initial value and groups",
                                                                   initialValue: initialRingtone,
                                                                   optionGroups: ringtoneOptionGroups)
        optionGroupWithDefaultStay.isVisibleWhenEmpty = true
        optionGroupWithDefaultStay.selectionBehavior = .remainInPicker
        let hiddenWhileEmptyStay = WCSingleOptionField<RelationshipType>(fieldName: "Hidden while empty", allOptions: RelationshipType.allValues)
        hiddenWhileEmptyStay.selectionBehavior = .remainInPicker
        let requiredFieldStay = WCSingleOptionField<RelationshipType>(fieldName: "Required Field", allOptions: RelationshipType.allValues, isRequired: true)
        requiredFieldStay.isVisibleWhenEmpty = true
        requiredFieldStay.selectionBehavior = .remainInPicker
        let noDeselectionStay = WCSingleOptionField<RelationshipType>(fieldName: "Field that doesn't allow deselection",
                                                                  allOptions: RelationshipType.allValues)
        noDeselectionStay.allowsDeselection = false
        noDeselectionStay.isVisibleWhenEmpty = true
        noDeselectionStay.selectionBehavior = .remainInPicker
        

        let firstSection = WCFormSection(headerTitle: nil, formFields: [singleOption, longName, multiGroupSingleOption, optionWithDefault,
                                                                        optionGroupWithDefault, readOnlyField, hiddenWhileEmpty, requiredField, noDeselection])
        let secondSection = WCFormSection(headerTitle: "Stays in Picker", formFields: [singleOptionStay, multiGroupSingleOptionStay, optionWithDefaultStay,
                                                                                       optionGroupWithDefaultStay, hiddenWhileEmptyStay, requiredFieldStay,
                                                                                       noDeselectionStay])
        secondSection.footerTitle = "Items in this section have their selectionBehavior set to remainInPicker."
        formModel = WCForm(formSections: [firstSection, secondSection])
    }

}
