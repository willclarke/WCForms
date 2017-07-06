//
//  IntFieldController.swift
//  WCFormsApp
//
//  Created by Will Clarke on 4/8/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation
import WCForms

class IntFieldController: WCFormController {

    var preferredAppearance = WCIntFieldAppearance.default {
        didSet {
            for formSection in formModel.formSections {
                for case let intField as WCIntField in formSection.formFields {
                    intField.appearance = preferredAppearance
                }
            }
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let intField = WCIntField(fieldName: "Integer Field")
        intField.isVisibleWhenEmpty = true
        let longName = WCIntField(fieldName: "Integer Field with a long name to test wrapping field name text to a new line or potentially multiple new lines")
        longName.isVisibleWhenEmpty = true
        let fieldWithDefault = WCIntField(fieldName: "Field with default value", initialValue: 5)
        fieldWithDefault.isVisibleWhenEmpty = true
        let hiddenWhileEmpty = WCIntField(fieldName: "Hidden while empty")
        let requiredField = WCIntField(fieldName: "Required Field", isRequired: true)
        requiredField.isVisibleWhenEmpty = true
        let readOnlyField = WCIntField(fieldName: "Non-Editable Field", initialValue: 5000)
        readOnlyField.isEditable = false
        let placeholderTextField = WCIntField(fieldName: "Field with placeholder text")
        placeholderTextField.isVisibleWhenEmpty = true
        placeholderTextField.placeholderText = "Enter Integer Here"
        let longPlaceholder = WCIntField(fieldName: "Field with long placeholder text")
        longPlaceholder.isVisibleWhenEmpty = true
        longPlaceholder.placeholderText = "Enter an integer in this space to set a value for the field and save it on this form"

        let minimumRange = WCIntField(fieldName: "Field with a minimum value")
        minimumRange.minimumValue = 5
        minimumRange.isVisibleWhenEmpty = true
        let minimumOutOfRange = WCIntField(fieldName: "Field with initial value below the minimum range", initialValue: 2)
        minimumOutOfRange.minimumValue = 5
        minimumOutOfRange.isVisibleWhenEmpty = true
        let maximumRange = WCIntField(fieldName: "Field with a maximum value")
        maximumRange.maximumValue = 100
        maximumRange.isVisibleWhenEmpty = true
        let maximumOutOfRange = WCIntField(fieldName: "Field with initial value above the maximum range", initialValue: 200)
        maximumOutOfRange.maximumValue = 100
        maximumOutOfRange.isVisibleWhenEmpty = true
        let bothRange = WCIntField(fieldName: "Field with a maximum and minimum value")
        bothRange.isVisibleWhenEmpty = true
        bothRange.minimumValue = 5
        bothRange.maximumValue = 100
        let bothRangeBelowMinimum = WCIntField(fieldName: "Field with a maximum and minimum value and initial value below the minimum", initialValue: 2)
        bothRangeBelowMinimum.isVisibleWhenEmpty = true
        bothRangeBelowMinimum.minimumValue = 5
        bothRangeBelowMinimum.maximumValue = 100
        let bothRangeAboveMaximum = WCIntField(fieldName: "Field with a maximum and minimum value and initial value above the maximum", initialValue: 200)
        bothRangeAboveMaximum.isVisibleWhenEmpty = true
        bothRangeAboveMaximum.minimumValue = 5
        bothRangeAboveMaximum.maximumValue = 100

        let ssnFormatter = WCIntField(fieldName: "Field with SSN mask")
        ssnFormatter.isVisibleWhenEmpty = true
        ssnFormatter.numberFormatMask = "###-##-####"
        let einFormatter = WCIntField(fieldName: "Field with EIN mask")
        einFormatter.isVisibleWhenEmpty = true
        einFormatter.numberFormatMask = "##-#######"
        let einWithMin = WCIntField(fieldName: "EIN field with minimum and maximum")
        einWithMin.isVisibleWhenEmpty = true
        einWithMin.numberFormatMask = "##-#######"
        einWithMin.minimumValue = 100000000
        einWithMin.maximumValue = 999999999
        let ssnWithShortDefault = WCIntField(fieldName: "SSN field with incomplete initial value", initialValue: 123456)
        ssnWithShortDefault.isVisibleWhenEmpty = true
        ssnWithShortDefault.numberFormatMask = "###-##-####"
        ssnWithShortDefault.minimumValue = 100000000
        ssnWithShortDefault.maximumValue = 999999999
        let ssnWithDefault = WCIntField(fieldName: "SSN field with initial value", initialValue: 123456789)
        ssnWithDefault.isVisibleWhenEmpty = true
        ssnWithDefault.numberFormatMask = "###-##-####"
        ssnWithDefault.minimumValue = 100000000
        ssnWithDefault.maximumValue = 999999999
        let ssnWithLongDefault = WCIntField(fieldName: "SSN field with long initial value", initialValue: 1234567890123)
        ssnWithLongDefault.isVisibleWhenEmpty = true
        ssnWithLongDefault.numberFormatMask = "###-##-####"
        ssnWithLongDefault.minimumValue = 100000000
        ssnWithLongDefault.maximumValue = 999999999

        let firstSection = WCFormSection(headerTitle: nil, formFields: [intField, longName, fieldWithDefault, hiddenWhileEmpty, requiredField, readOnlyField,
                                                                        placeholderTextField, longPlaceholder])
        let secondSection = WCFormSection(headerTitle: "Fields with value ranges",
                                          formFields: [minimumRange, minimumOutOfRange, maximumRange, maximumOutOfRange, bothRange, bothRangeBelowMinimum,
                                                       bothRangeAboveMaximum])
        let thirdSection = WCFormSection(headerTitle: "Fields with format masks",
                                          formFields: [ssnFormatter, einFormatter, einWithMin, ssnWithShortDefault, ssnWithDefault, ssnWithLongDefault])
        formModel = WCForm(formSections: [firstSection, secondSection, thirdSection])
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
        let sliderOption = UIAlertAction(title: "Slider", style: .default) { (action: UIAlertAction) in
            self.preferredAppearance = .slider
        }
        let cancelOption = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        appearancePicker.addAction(stackedOption)
        appearancePicker.addAction(stackedCaptionOption)
        appearancePicker.addAction(rightDetailOption)
        appearancePicker.addAction(sliderOption)
        appearancePicker.addAction(cancelOption)
        if let popoverController = appearancePicker.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        self.present(appearancePicker, animated: true, completion: nil)
    }

}
