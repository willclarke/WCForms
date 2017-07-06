//
//  BoolFieldController.swift
//  WCFormsApp
//
//  Created by Will Clarke on 4/8/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation
import WCForms

class BoolFieldController: WCFormController {

    var preferredAppearance = WCBoolFieldAppearance.default {
        didSet {
            for formSection in formModel.formSections {
                for case let boolField as WCBoolField in formSection.formFields {
                    boolField.appearance = preferredAppearance
                }
            }
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let boolField = WCBoolField(fieldName: "Bool Field")
        boolField.isVisibleWhenEmpty = true
        let defaultValueBoolField = WCBoolField(fieldName: "Field Defaulting to True", initialValue: true)
        defaultValueBoolField.isVisibleWhenEmpty = true
        let defaultOffField = WCBoolField(fieldName: "Field Defaulting to False", initialValue: false)
        defaultOffField.isVisibleWhenEmpty = true
        let readOnlyField = WCBoolField(fieldName: "Non-Editable Field", initialValue: false)
        readOnlyField.isEditable = false
        let mediumName = WCBoolField(fieldName: "Field with a medium length name")
        mediumName.isVisibleWhenEmpty = true
        let longName = WCBoolField(fieldName: "Bool Field with a long field name to show how labels wrap to a new line")
        longName.isVisibleWhenEmpty = true

        let yesNoField = WCBoolField(fieldName: "Yes/No field")
        yesNoField.offDisplayValue = "No"
        yesNoField.onDisplayValue = "Yes"
        yesNoField.isVisibleWhenEmpty = true
        let fieldWithLabels = WCBoolField(fieldName: "Sure/Nope field")
        fieldWithLabels.offDisplayValue = "Nope"
        fieldWithLabels.onDisplayValue = "Sure"
        fieldWithLabels.isVisibleWhenEmpty = true
        let enabledDisabledField = WCBoolField(fieldName: "Enabled/Disabled field")
        enabledDisabledField.offDisplayValue = "Disabled"
        enabledDisabledField.onDisplayValue = "Enabled"
        enabledDisabledField.isVisibleWhenEmpty = true
        let fieldWithLongOnLabel = WCBoolField(fieldName: "Field with long \"on\" label")
        fieldWithLongOnLabel.onDisplayValue = "Tiramisu croissant ice cream jelly carrot cake lollipop sweet apple pie."
        fieldWithLongOnLabel.isVisibleWhenEmpty = true
        let fieldWithLongOffLabel = WCBoolField(fieldName: "Field with long \"off\" label")
        fieldWithLongOffLabel.offDisplayValue = "Fruitcake fruitcake sweet topping. Croissant cake jujubes ice cream."
        fieldWithLongOffLabel.isVisibleWhenEmpty = true
        let fieldWithLongLabels = WCBoolField(fieldName: "Field with long labels")
        fieldWithLongLabels.onDisplayValue = "Sesame snaps bear claw ice cream donut chocolate."
        fieldWithLongLabels.offDisplayValue = "Chupa chups chocolate bar chocolate cake apple pie gingerbread croissant chocolate cake."
        fieldWithLongLabels.isVisibleWhenEmpty = true

        let firstSection = WCFormSection(headerTitle: nil, formFields: [boolField, defaultValueBoolField, defaultOffField, readOnlyField, mediumName, longName])
        let secondSection = WCFormSection(headerTitle: "Custom On/Off Values",
                                          formFields: [yesNoField, fieldWithLabels, enabledDisabledField, fieldWithLongOnLabel, fieldWithLongOffLabel,
                                                       fieldWithLongLabels])
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
        appearancePicker.addAction(rightDetailOption)
        appearancePicker.addAction(stackedOption)
        appearancePicker.addAction(stackedCaptionOption)
        appearancePicker.addAction(cancelOption)
        if let popoverController = appearancePicker.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        self.present(appearancePicker, animated: true, completion: nil)
    }

}
