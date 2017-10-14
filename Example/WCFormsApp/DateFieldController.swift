//
//  DateFieldController.swift
//  WCFormsApp
//
//  Created by Will Clarke on 4/8/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation
import WCForms

class DateFieldController: WCFormController {

    var preferredAppearance = WCDateFieldAppearance.default {
        didSet {
            for formSection in formModel.formSections {
                for case let dateField as WCDateField in formSection.formFields {
                    dateField.appearance = preferredAppearance
                }
            }
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let currentDate = Date()
        let dateField = WCDateField(fieldName: "Date Field")
        dateField.isVisibleWhenEmpty = true
        let longDateField = WCDateField(fieldName: "Date Field with a long field name to show how labels wrap to a new line")
        longDateField.isVisibleWhenEmpty = true
        let requiredDateField = WCDateField(fieldName: "Required Date Field", initialValue: nil, isRequired: true)
        requiredDateField.isVisibleWhenEmpty = true
        let readOnlyField = WCDateField(fieldName: "Non-Editable Field", initialValue: currentDate)
        readOnlyField.isEditable = false
        let defaultTodayField = WCDateField(fieldName: "Field defaulting to today", initialValue: currentDate)
        defaultTodayField.isVisibleWhenEmpty = true
        let timeField = WCDateField(fieldName: "Time field")
        timeField.dateSelectionType = .time
        timeField.isVisibleWhenEmpty = true
        let dateTimeField = WCDateField(fieldName: "Date and Time field")
        dateTimeField.dateSelectionType = .dateAndTime
        dateTimeField.isVisibleWhenEmpty = true
        let customTimeZoneField = WCDateField(fieldName: "Custom Time Zone", initialValue: currentDate)
        customTimeZoneField.timeZone = TimeZone(identifier: "America/Chicago")
        customTimeZoneField.isVisibleWhenEmpty = true

        let afterTodayField = WCDateField(fieldName: "Future date field", initialValue: currentDate)
        afterTodayField.minimumDate = currentDate
        afterTodayField.isVisibleWhenEmpty = true
        let beforeTodayField = WCDateField(fieldName: "Past date field", initialValue: currentDate)
        beforeTodayField.maximumDate = currentDate
        beforeTodayField.isVisibleWhenEmpty = true
        let lastWeekField = WCDateField(fieldName: "Last week date field")
        lastWeekField.maximumDate = currentDate
        lastWeekField.minimumDate = Date(timeInterval: -604800.0, since: currentDate)
        lastWeekField.isVisibleWhenEmpty = true
        let nextMonthField = WCDateField(fieldName: "Next 30 days field")
        nextMonthField.minimumDate = currentDate
        nextMonthField.maximumDate = Date(timeInterval: 2592000.0, since: currentDate)
        nextMonthField.isVisibleWhenEmpty = true

        let firstSection = WCFormSection(headerTitle: nil, formFields: [dateField, longDateField, requiredDateField, readOnlyField, defaultTodayField,
                                                                        timeField, dateTimeField, customTimeZoneField])
        let secondSection = WCFormSection(headerTitle: "Fields with a date range",
                                          formFields: [afterTodayField, beforeTodayField, lastWeekField, nextMonthField])
        formModel = WCForm(formSections: [firstSection, secondSection])
    }

    @IBAction func actionButtonTapped(_ sender: UIBarButtonItem) {
        let appearancePicker = UIAlertController(title: "Change Appearance",
                                                 message: "Choose the desired field appearance",
                                                 preferredStyle: .actionSheet)
        let stackedOption = UIAlertAction(title: "Stacked", style: .default) { (action: UIAlertAction) in
            self.preferredAppearance = .stacked
        }
        let stackedCaptionOption = UIAlertAction(title: "Stacked Caption", style: .default) { (action: UIAlertAction) in
            self.preferredAppearance = .stackedCaption
        }
        let rightDetailOption = UIAlertAction(title: "Right Detail", style: .default) { (action: UIAlertAction) in
            self.preferredAppearance = .rightDetail
        }
        let cancelOption = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        appearancePicker.addAction(stackedOption)
        appearancePicker.addAction(stackedCaptionOption)
        appearancePicker.addAction(rightDetailOption)
        appearancePicker.addAction(cancelOption)
        if let popoverController = appearancePicker.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        self.present(appearancePicker, animated: true, completion: nil)
    }

}
