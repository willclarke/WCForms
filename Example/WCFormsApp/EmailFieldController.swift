//
//  EmailFieldController.swift
//  WCFormsApp
//
//  Created by Will Clarke on 4/29/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation
import WCForms

class EmailFieldController: WCFormController {

    static let customReadOnlyNibNameIdentifier = "CustomEmailTableViewCell"
    let customAppearanceDescriptor = WCFieldAppearanceDescription(nibName: EmailFieldController.customReadOnlyNibNameIdentifier)

    var preferredAppearance = WCEmailFieldAppearance.default {
        didSet {
            for formSection in formModel.formSections {
                for case let textField as WCEmailField in formSection.formFields {
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
        let customNib = UINib(nibName: EmailFieldController.customReadOnlyNibNameIdentifier, bundle: Bundle.main)
        tableView.register(customNib, forCellReuseIdentifier: EmailFieldController.customReadOnlyNibNameIdentifier)
        
        let emailField = WCEmailField(fieldName: "Email Field")
        emailField.isVisibleWhenEmpty = true
        let defaultValue = WCEmailField(fieldName: "Field with Initial Value", initialValue: "me@willclarke.net")
        let invalidDefaultValue = WCEmailField(fieldName: "Field with Invalid Initial Value", initialValue: "me@willclarke")
        
        let firstSection = WCFormSection(headerTitle: nil, formFields: [emailField, defaultValue, invalidDefaultValue])
        
        formModel = WCForm(formSections: [firstSection])
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
        let customOption = UIAlertAction(title: "Custom based on stacked", style: .default) { (action: UIAlertAction) in
            self.preferredAppearance = .custom(descriptor: self.customAppearanceDescriptor, basedOn: .stacked)
        }
        let cancelOption = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        appearancePicker.addAction(stackedOption)
        appearancePicker.addAction(stackedCaptionOption)
        appearancePicker.addAction(rightDetailOption)
        appearancePicker.addAction(placeholderOption)
        appearancePicker.addAction(customOption)
        appearancePicker.addAction(cancelOption)
        if let popoverController = appearancePicker.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        self.present(appearancePicker, animated: true, completion: nil)
    }

}
