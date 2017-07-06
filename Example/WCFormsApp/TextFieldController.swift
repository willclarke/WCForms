//
//  TextFieldController.swift
//  WCFormsApp
//
//  Created by Will Clarke on 4/8/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation
import WCForms

class TextFieldController: WCFormController {

    var preferredAppearance = WCTextFieldAppearance.default {
        didSet {
            for formSection in formModel.formSections {
                for case let textField as WCTextField in formSection.formFields {
                    textField.appearance = preferredAppearance
                }
            }
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let shortField = WCTextField(fieldName: "Text Field")
        shortField.isVisibleWhenEmpty = true
        let longField = WCTextField(fieldName: "Text Field with a long field name to show how labels wrap to a new line")
        longField.isVisibleWhenEmpty = true
        let readOnlyField = WCTextField(fieldName: "Non-Editable Field", initialValue: "This field should not be editable even when the form is being edited.")
        readOnlyField.isEditable = false
        let requiredField = WCTextField(fieldName: "Required Field", isRequired: true)
        requiredField.isVisibleWhenEmpty = true
        let initialValueField = WCTextField(fieldName: "Field with an initial value", initialValue: "Test Value")
        let longValueField = WCTextField(fieldName: "Field with a long value",
                                         initialValue: "Macaroon icing wafer apple pie wafer cheesecake toffee gummies. Sesame snaps gingerbread cake sesame snaps jelly beans chupa chups fruitcake sesame snaps. Danish biscuit tiramisu candy liquorice chocolate bar.")
        let minimumValueField = WCTextField(fieldName: "Field requiring at least 5 characters")
        minimumValueField.minimumLength = 5
        minimumValueField.isVisibleWhenEmpty = true
        let maximumValueField = WCTextField(fieldName: "Field requiring less than 100 characters")
        maximumValueField.maximumLength = 99
        maximumValueField.isVisibleWhenEmpty = true
        let rangeValueField = WCTextField(fieldName: "Field requiring between 8 and 100 characters")
        rangeValueField.minimumLength = 9
        rangeValueField.maximumLength = 99
        rangeValueField.isVisibleWhenEmpty = true

        let placeholderField = WCTextField(fieldName: "Field with custom placeholder")
        placeholderField.placeholderText = "Enter text here"
        placeholderField.isVisibleWhenEmpty = true
        let capitalWordsField = WCTextField(fieldName: "Text Field with Capitalized Words")
        capitalWordsField.autocapitalizationType = .words
        capitalWordsField.isVisibleWhenEmpty = true
        let capitalSentencesField = WCTextField(fieldName: "Text Field with Capitalized Sentences")
        capitalSentencesField.autocapitalizationType = .sentences
        capitalSentencesField.isVisibleWhenEmpty = true
        let allCapsField = WCTextField(fieldName: "Text Field with All Caps")
        allCapsField.autocapitalizationType = .allCharacters
        allCapsField.isVisibleWhenEmpty = true
        let autocorrectionField = WCTextField(fieldName: "Field with autocorrection on")
        autocorrectionField.autocorrectionType = .yes
        autocorrectionField.isVisibleWhenEmpty = true
        let autocorrectionOffField = WCTextField(fieldName: "Field with autocorrection off")
        autocorrectionOffField.autocorrectionType = .no
        autocorrectionOffField.isVisibleWhenEmpty = true

        let firstSection = WCFormSection(headerTitle: nil, formFields: [shortField, longField, readOnlyField, requiredField, initialValueField, longValueField])
        let secondSection = WCFormSection(headerTitle: "Text Ranges", formFields: [minimumValueField, maximumValueField, rangeValueField])
        let thirdSection = WCFormSection(headerTitle: "Keyboard Options",
                                         formFields: [placeholderField, capitalWordsField, capitalSentencesField, allCapsField, autocorrectionField,
                                                      autocorrectionOffField])
        
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
        let placeholderOption = UIAlertAction(title: "Field Name as Placeholder", style: .default) { (action: UIAlertAction) in
            self.preferredAppearance = .fieldNameAsPlaceholder
        }
        let cancelOption = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        appearancePicker.addAction(stackedOption)
        appearancePicker.addAction(stackedCaptionOption)
        appearancePicker.addAction(rightDetailOption)
        appearancePicker.addAction(placeholderOption)
        appearancePicker.addAction(cancelOption)
        if let popoverController = appearancePicker.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        self.present(appearancePicker, animated: true, completion: nil)
    }

}
