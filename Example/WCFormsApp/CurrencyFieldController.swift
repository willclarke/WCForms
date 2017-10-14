//
//  CurrencyFieldController.swift
//  WCFormsApp
//
//  Created by Will Clarke on 7/20/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation
import WCForms

class CurrencyFieldController: WCFormController {

    var preferredAppearance = WCCurrencyFieldAppearance.default {
        didSet {
            for formSection in formModel.formSections {
                for case let textField as WCCurrencyField in formSection.formFields {
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

        let currencyField = WCCurrencyField(fieldName: "Enter Amount")
        currencyField.isVisibleWhenEmpty = true
        let longNameField = WCCurrencyField(fieldName: "Currency Field with a long name to test wrapping field name label")
        longNameField.isVisibleWhenEmpty = true
        let initialValueField = WCCurrencyField(fieldName: "Has Initial Value", initialValue: 100.1)
        let noDecimalField = WCCurrencyField(fieldName: "No Decimal", initialValue: 100.0)
        noDecimalField.showsDecimalPlaces = false
        let decimalResetField = WCCurrencyField(fieldName: "Shows Decimal", initialValue: 100.0)
        decimalResetField.showsDecimalPlaces = false
        decimalResetField.showsDecimalPlaces = true

        let firstSection = WCFormSection(headerTitle: "Currency Fields", formFields: [currencyField, longNameField, initialValueField, noDecimalField,
                                                                                      decimalResetField])

        let britishField = WCCurrencyField(fieldName: "British", initialValue: 100.1)
        britishField.locale = Locale(identifier: "en_GB")
        let frenchField = WCCurrencyField(fieldName: "French", initialValue: 100.1)
        frenchField.locale = Locale(identifier: "fr_FR")
        let germanField = WCCurrencyField(fieldName: "German", initialValue: 100.1)
        germanField.locale = Locale(identifier: "de_DE")
        let indiaField = WCCurrencyField(fieldName: "India", initialValue: 100.1)
        indiaField.locale = Locale(identifier: "hi_IN")
        let mexicoField = WCCurrencyField(fieldName: "Mexico", initialValue: 100.1)
        mexicoField.locale = Locale(identifier: "es_MX")
        let zimbabweField = WCCurrencyField(fieldName: "Zimbabwe", initialValue: 100.1)
        zimbabweField.locale = Locale(identifier: "sn_ZW")
        let botswanaField = WCCurrencyField(fieldName: "Botswana", initialValue: 100.1)
        botswanaField.locale = Locale(identifier: "en_BW")
        let chinaField = WCCurrencyField(fieldName: "China", initialValue: 100.1)
        chinaField.locale = Locale(identifier: "zh_Hans_CN")
        let japanField = WCCurrencyField(fieldName: "Japan", initialValue: 100.1)
        japanField.locale = Locale(identifier: "ja_JP")
        let israelField = WCCurrencyField(fieldName: "Israel (Hebrew)", initialValue: 100.1)
        israelField.locale = Locale(identifier: "he_IL")
        let israelEnField = WCCurrencyField(fieldName: "Israel (English)", initialValue: 100.1)
        israelEnField.locale = Locale(identifier: "en_IL")
        let iraqField = WCCurrencyField(fieldName: "Iraq", initialValue: 100.1)
        iraqField.locale = Locale(identifier: "ar_IQ")
        let trumpField = WCCurrencyField(fieldName: "Trump", initialValue: 100.1)
        trumpField.locale = Locale(identifier: "ru_RU")

        let globalFields = [britishField, frenchField, germanField, indiaField, mexicoField, zimbabweField, botswanaField, chinaField, japanField, israelField,
                            israelEnField, iraqField, trumpField]
        let secondSection = WCFormSection(headerTitle: "International Currencies", formFields: globalFields)

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
