//
//  MultipleOptionFieldController.swift
//  WCFormsApp
//
//  Created by Will Clarke on 4/8/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation
import WCForms

class MultipleOptionFieldController: OptionFieldController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let ringtoneOptionGroups = [OptionFieldGroup<Ringtone>(items: Ringtone.defaultRingtones,
                                                               localizedTitle: nil,
                                                               localizedFooter: "Default Ringtones built in to iOS"),
                                    OptionFieldGroup<Ringtone>(items: Ringtone.classicRingtones,
                                                               localizedTitle: "Classic Ringtones",
                                                               localizedFooter: "Ringtones before iOS 7")]
        
        let multiOption = WCMultipleOptionField<Ringtone>(fieldName: "Multiple Option", allOptions: Ringtone.defaultRingtones)
        multiOption.isVisibleWhenEmpty = true
        let multiGroupMultiOption = WCMultipleOptionField<Ringtone>(fieldName: "Multiple Option with Groups",
                                                                   optionGroups: ringtoneOptionGroups)
        multiGroupMultiOption.isVisibleWhenEmpty = true
        let longName = WCMultipleOptionField<Ringtone>(fieldName: "Multi option field with a long name to test wrapping the field name to multiple lines",
                                                     allOptions: Ringtone.defaultRingtones)
        longName.isVisibleWhenEmpty = true
        let initialRingtone: Set<Ringtone> = [Ringtone(name: "Alarm", isClassic: true)]
        let initialClassicRingtones: Set<Ringtone> = [Ringtone(name: "Alarm", isClassic: true), Ringtone(name: "Blues", isClassic: true)]
        let initialRingtones: Set<Ringtone> = [Ringtone(name: "Alarm", isClassic: true), Ringtone(name: "Beacon", isClassic: false)]
        let optionWithDefault = WCMultipleOptionField<Ringtone>(fieldName: "Field with single initial value",
                                                              initialValue: initialRingtone,
                                                              allOptions: Ringtone.classicRingtones)
        optionWithDefault.isVisibleWhenEmpty = true
        let optionWithMultiDefault = WCMultipleOptionField<Ringtone>(fieldName: "Field with two initial values",
                                                                initialValue: initialClassicRingtones,
                                                                allOptions: Ringtone.classicRingtones)
        optionWithMultiDefault.isVisibleWhenEmpty = true
        let optionGroupWithDefault = WCMultipleOptionField<Ringtone>(fieldName: "Field with initial values and groups",
                                                                   initialValue: initialRingtones,
                                                                   optionGroups: ringtoneOptionGroups)
        optionGroupWithDefault.isVisibleWhenEmpty = true
        let optionGroupWithAllSelected = WCMultipleOptionField<Ringtone>(fieldName: "Field with all values selected initially",
                                                                     initialValue: Set<Ringtone>(Ringtone.classicRingtones),
                                                                     allOptions: Ringtone.classicRingtones)
        optionGroupWithAllSelected.isVisibleWhenEmpty = true
        let readOnlyField = WCMultipleOptionField<RelationshipType>(fieldName: "Non-Editable Field", initialValue: [RelationshipType.acquaintance])
        readOnlyField.isEditable = false
        let hiddenWhileEmpty = WCMultipleOptionField<RelationshipType>(fieldName: "Hidden while empty", allOptions: RelationshipType.allValues)
        let requiredField = WCMultipleOptionField<RelationshipType>(fieldName: "Required Field", allOptions: RelationshipType.allValues, isRequired: true)
        requiredField.isVisibleWhenEmpty = true
        let selectionNotInOptions = WCMultipleOptionField<Ringtone>(fieldName: "Field whose inital value isn't in the options",
                                                                    initialValue: Set<Ringtone>([Ringtone(name: "Splork", isClassic: true),
                                                                                                 Ringtone(name: "Nerf", isClassic: false)]),
                                                                    optionGroups: ringtoneOptionGroups)
        selectionNotInOptions.readOnlySelectionBehavior = .showDetail

        let firstSection = WCFormSection(headerTitle: nil, formFields: [multiOption, multiGroupMultiOption, longName, optionWithDefault,
                                                                        optionWithMultiDefault, optionGroupWithDefault, optionGroupWithAllSelected,
                                                                        readOnlyField, hiddenWhileEmpty, requiredField, selectionNotInOptions])
        
        let countSummaryStyle = WCMultipleOptionField<RelationshipType>(fieldName: "Field that should always show a selection total",
                                                                        initialValue: Set<RelationshipType>([RelationshipType.acquaintance,
                                                                                                             RelationshipType.colleague]),
                                                                        allOptions: RelationshipType.allValues)
        countSummaryStyle.summaryStyle = .count
        let countAfterOne = WCMultipleOptionField<RelationshipType>(fieldName: "Field that should count after one option",
                                                                    initialValue: Set<RelationshipType>([RelationshipType.acquaintance]),
                                                                    allOptions: RelationshipType.allValues)
        let countAfterOne2 = WCMultipleOptionField<RelationshipType>(fieldName: "Field that should count after one option",
                                                                    initialValue: Set<RelationshipType>([RelationshipType.acquaintance,
                                                                                                         RelationshipType.colleague]),
                                                                    allOptions: RelationshipType.allValues)
        countAfterOne2.summaryStyle = .countAfter(numberToDisplay: 1)
        let countAfterTwo = WCMultipleOptionField<RelationshipType>(fieldName: "Field that should count after two options",
                                                                    initialValue: Set<RelationshipType>([RelationshipType.acquaintance]),
                                                                    allOptions: RelationshipType.allValues)
        countAfterTwo.summaryStyle = .countAfter(numberToDisplay: 2)
        let countAfterTwo2 = WCMultipleOptionField<RelationshipType>(fieldName: "Field that should count after two options",
                                                                    initialValue: Set<RelationshipType>([RelationshipType.acquaintance,
                                                                                                         RelationshipType.colleague]),
                                                                    allOptions: RelationshipType.allValues)
        countAfterTwo2.summaryStyle = .countAfter(numberToDisplay: 2)
        let countAfterTwo3 = WCMultipleOptionField<RelationshipType>(fieldName: "Field that should count after two options",
                                                                     initialValue: Set<RelationshipType>([RelationshipType.acquaintance,
                                                                                                          RelationshipType.colleague,
                                                                                                          RelationshipType.family]),
                                                                     allOptions: RelationshipType.allValues)
        countAfterTwo3.summaryStyle = .countAfter(numberToDisplay: 2)
        let countAfterTwo4 = WCMultipleOptionField<RelationshipType>(fieldName: "Field that should count after two options",
                                                                     initialValue: Set<RelationshipType>([RelationshipType.acquaintance,
                                                                                                          RelationshipType.colleague,
                                                                                                          RelationshipType.family, RelationshipType.other,
                                                                                                          RelationshipType.partner]),
                                                                     allOptions: RelationshipType.allValues)
        countAfterTwo4.summaryStyle = .countAfter(numberToDisplay: 2)
        let countAfterThree = WCMultipleOptionField<RelationshipType>(fieldName: "Field that should count after three options",
                                                                      initialValue: Set<RelationshipType>([RelationshipType.acquaintance,
                                                                                                           RelationshipType.colleague]),
                                                                     allOptions: RelationshipType.allValues)
        countAfterThree.summaryStyle = .countAfter(numberToDisplay: 3)
        let countAfterThree2 = WCMultipleOptionField<RelationshipType>(fieldName: "Field that should count after three options",
                                                                       initialValue: Set<RelationshipType>([RelationshipType.acquaintance,
                                                                                                            RelationshipType.colleague,
                                                                                                            RelationshipType.family]),
                                                                       allOptions: RelationshipType.allValues)
        countAfterThree2.summaryStyle = .countAfter(numberToDisplay: 3)
        let countAfterThree3 = WCMultipleOptionField<RelationshipType>(fieldName: "Field that should count after three options",
                                                                       initialValue: Set<RelationshipType>([RelationshipType.acquaintance,
                                                                                                            RelationshipType.colleague,
                                                                                                            RelationshipType.family, RelationshipType.other,
                                                                                                            RelationshipType.partner]),
                                                                       allOptions: RelationshipType.allValues)
        countAfterThree3.summaryStyle = .countAfter(numberToDisplay: 3)
        let localizedCountAfterThree = WCMultipleOptionField<RelationshipType>(fieldName: "Count after three options with a custom conjunction",
                                                                       initialValue: Set<RelationshipType>([RelationshipType.acquaintance,
                                                                                                            RelationshipType.colleague,
                                                                                                            RelationshipType.family, RelationshipType.other,
                                                                                                            RelationshipType.partner]),
                                                                       allOptions: RelationshipType.allValues)
        localizedCountAfterThree.summaryStyle = .localizedCountAfter(numberToDisplay: 3, conjunction: "or")
        let displayAll = WCMultipleOptionField<RelationshipType>(fieldName: "Field that should display all values",
                                                                 initialValue: Set<RelationshipType>([RelationshipType.acquaintance,
                                                                                                      RelationshipType.colleague]),
                                                                 allOptions: RelationshipType.allValues)
        displayAll.summaryStyle = .all
        let displayAll2 = WCMultipleOptionField<RelationshipType>(fieldName: "Field that should display all values",
                                                                  initialValue: Set<RelationshipType>([RelationshipType.acquaintance,
                                                                                                       RelationshipType.colleague,
                                                                                                       RelationshipType.family, RelationshipType.other,
                                                                                                       RelationshipType.partner]),
                                                                  allOptions: RelationshipType.allValues)
        displayAll2.summaryStyle = .all
        let displayAllLocalized = WCMultipleOptionField<RelationshipType>(fieldName: "Field that should display all values with custom conjunction",
                                                                          initialValue: Set<RelationshipType>([RelationshipType.acquaintance,
                                                                                                               RelationshipType.colleague]),
                                                                          allOptions: RelationshipType.allValues)
        displayAllLocalized.summaryStyle = .localizedAll(conjunction: "or")
        let displayAllLocalized2 = WCMultipleOptionField<RelationshipType>(fieldName: "Field that should display all values with custom conjunction",
                                                                           initialValue: Set<RelationshipType>([RelationshipType.acquaintance,
                                                                                                                RelationshipType.colleague,
                                                                                                                RelationshipType.family,
                                                                                                                RelationshipType.other,
                                                                                                                RelationshipType.partner]),
                                                                           allOptions: RelationshipType.allValues)
        displayAllLocalized2.summaryStyle = .localizedAll(conjunction: "or")

        let secondSection = WCFormSection(headerTitle: "Fields with custom summary styles", formFields: [countSummaryStyle, countAfterOne, countAfterOne2,
                                                                                                         countAfterTwo, countAfterTwo2, countAfterTwo3,
                                                                                                         countAfterTwo4, countAfterThree, countAfterThree2,
                                                                                                         countAfterThree3, localizedCountAfterThree,
                                                                                                         displayAll, displayAll2, displayAllLocalized,
                                                                                                         displayAllLocalized2])

        let customSelectionBehavior = WCMultipleOptionField<Ringtone>(fieldName: "Selection always shows detail",
                                                                      initialValue: Set<Ringtone>(Ringtone.classicRingtones),
                                                                      optionGroups: ringtoneOptionGroups)
        customSelectionBehavior.readOnlySelectionBehavior = .showDetail
        let sortedAscending = WCMultipleOptionField<Ringtone>(fieldName: "Summary is sorted ascending",
                                                              initialValue: Set<Ringtone>(Ringtone.classicRingtones),
                                                              optionGroups: ringtoneOptionGroups)
        sortedAscending.summaryOrder = .ascending
        sortedAscending.summaryStyle = .all
        let sortedDescending = WCMultipleOptionField<Ringtone>(fieldName: "Summary is sorted descending",
                                                              initialValue: Set<Ringtone>(Ringtone.defaultRingtones),
                                                              optionGroups: ringtoneOptionGroups)
        sortedDescending.summaryOrder = .descending
        sortedDescending.summaryStyle = .all
        let sortedDescendingSumAfterTwo = WCMultipleOptionField<Ringtone>(fieldName: "Summary is sorted ascending, count after two",
                                                                          initialValue: Set<Ringtone>(Ringtone.defaultRingtones),
                                                                          optionGroups: ringtoneOptionGroups)
        sortedDescendingSumAfterTwo.summaryOrder = .ascending
        sortedDescendingSumAfterTwo.summaryStyle = .countAfter(numberToDisplay: 2)
        sortedDescendingSumAfterTwo.readOnlySelectionBehavior = .showDetail
        let thirdSection = WCFormSection(headerTitle: "Fields with custom sorts and selection behavior", formFields: [customSelectionBehavior, sortedAscending,
                                                                                                                      sortedDescending,
                                                                                                                      sortedDescendingSumAfterTwo])

        formModel = WCForm(formSections: [firstSection, secondSection, thirdSection])
    }

}
