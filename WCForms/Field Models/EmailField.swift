//
//  EmailField.swift
//  WCForms
//
//  Created by Will Clarke on 4/27/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation
import MessageUI

/// The possible appearances for email fields.
///
/// - stacked: The field name is stacked above the field value.
/// - stackedCaption: The field name is stacked above the field value, using the `caption` text style.
/// - rightDetail: The field value is to the right of the field name.
/// - fieldNameAsPlaceholder: The field name appears as placeholder text while editing, and is only visible in read-only mode when the field value is empty.
/// - custom: The field should use the views specified in the `descriptor` associated value. If certain values aren't specified, fall back to the field 
///           appearance specified in the `basedOn` associated value.
public enum WCEmailFieldAppearance: FieldCellAppearance {

    case stacked
    case stackedCaption
    case rightDetail
    case fieldNameAsPlaceholder
    indirect case custom(descriptor: WCFieldAppearanceDescription, basedOn: WCEmailFieldAppearance)

    /// The nib name for the read-only version of a field in this appearance.
    public var nibName: String {
        switch self {
        case .rightDetail:
            return "WCGenericButtonRightDetailCell"
        case .fieldNameAsPlaceholder:
            return "WCGenericButtonSingleLineCell"
        case .stacked:
            return "WCGenericButtonStackedCell"
        case .stackedCaption:
            return "WCGenericButtonStackedCaptionCell"
        case .custom(let descriptor, let baseAppearance):
            return descriptor.nibName ?? baseAppearance.nibName
        }
    }

    /// The cell identifier for the read-only version of a field in this appearance.
    public var cellIdentifier: String {
        switch self {
        case .custom(let descriptor, let baseAppearance):
            return descriptor.cellIdentifier ?? baseAppearance.cellIdentifier
        default:
            return nibName
        }
    }

    /// The nib name for the editable version of a field in this appearance.
    public var editableNibName: String {
        switch self {
        case .rightDetail:
            return "WCTextFieldRightDetailCell"
        case .fieldNameAsPlaceholder:
            return "WCTextFieldNoFieldNameLabelCell"
        case .stacked:
            return "WCTextFieldCell"
        case .stackedCaption:
            return "WCTextFieldStackedCaptionCell"
        case .custom(let descriptor, let baseAppearance):
            return descriptor.editableNibName ?? baseAppearance.editableNibName
        }
    }

    /// The cell identifier for the editable version of a field in this appearance.
    public var editableCellIdentifier: String {
        switch self {
        case .custom(let descriptor, let baseAppearance):
            return descriptor.editableCellIdentifier ?? baseAppearance.editableCellIdentifier
        default:
            return editableNibName
        }
    }

    /// The preferred color for the field name label
    public var preferredFieldNameColor: UIColor {
        switch self {
        case .stackedCaption, .fieldNameAsPlaceholder:
            return UIColor.darkGray
        default:
            return UIColor.black
        }
    }

    /// The preferred color for the field of value label.
    public var preferredFieldValueColor: UIColor {
        switch self {
        case .stackedCaption, .fieldNameAsPlaceholder:
            return UIColor.black
        default:
            return UIColor.darkGray
        }
    }

    /// Always returns `true`, because a text field can always become first responder.
    public var canBecomeFirstResponder: Bool {
        return true
    }

    /// Returns `stacked`, the default text field appearance.
    public static var `default`: WCEmailFieldAppearance {
        return WCEmailFieldAppearance.stacked
    }

    /// Returns all values of the text field appearance.
    public static var allValues: [WCEmailFieldAppearance] {
        return [.stacked, .stackedCaption, .rightDetail, .fieldNameAsPlaceholder]
    }

}

/// The behavior an email field may take when it's tapped in read-only mode and has a field value.
///
/// - none: No acton should be taken.
/// - copyToClipboard: The email address should be copied to the keyboard.
/// - inApp: A message composition view should be opened in the app, with the field's email address set to be the recipient. If a message composition view can 
///          not be created (because `MFMailComposeViewController.canSendMail()` is `false`) then the user is given the option to copy the email address to
///          their clipboard.
/// - inMailApp: The system mail app should be used to compose an email to the field's email address. If the Mail app can not be opened (because 
///              `UIApplication.shared` can not open `mailto:` URLs) then the user is given the option to copy the email address to their clipboard.
/// - useCallback: Use a callback specified in the associated value `composeEmailTo` to handle the email address.
public enum WCEmailFieldCompositionBehavior {
    case none
    case copyToClipboard
    case inApp
    case inMailApp
    case useCallback(composeEmailTo: (String) -> Void)
}

/// A form field for viewing and editing an email address.
public class WCEmailField: WCGenericField<String, WCEmailFieldAppearance>, WCTextFieldInputDelegate, WCButtonActionDelegate, WCEditableSelectableField {

    /// Placeholder text to be set for the text field.
    public var placeholderText: String? = nil {
        didSet {
            if let validCell = lastLoadedEditableCell, let placeholderText = placeholderText {
                validCell.fieldValueTextField.placeholder = placeholderText
            }
        }
    }

    /// Whether or not the email address should be validated. By default, this is `true`. See also: `emailRegularExpression` and `addressValidator`.
    public var validateEmailAddress: Bool = true

    /// A regular expression to validate the email address. Contains a default validator which should validate most email addresses for proper syntax (but does 
    /// not attempt to validate domains, or the existence of valid TLDs). If an `addressValidator` block is specified, this regular expression will be ignored.
    public var emailRegularExpression = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    /// A block to call to validate the email address. It takes a String which represents the email address, and should return `true` if the email address is
    /// valid, and `false` if not.
    public var addressValidator: ((_ enteredString: String) -> Bool)? = nil

    /// The desired behavior when an email address is tapped on when the field is in read-only mode.
    public var emailCompositionBehavior: WCEmailFieldCompositionBehavior = .inApp

    /// The last loaded editable text field cell.
    weak var lastLoadedEditableCell: WCGenericTextFieldCell? = nil

    fileprivate let mailDismisser = MailDismissingDelegate()


    // MARK: - Cell setup

    public override func setupCell(_ cell: UITableViewCell) {
        if isAbleToCopy && copyValue != nil {
            cell.selectionStyle = .default
        } else {
            cell.selectionStyle = .none
        }
        if let cell = cell as? WCGenericButtonCellDisplayable {
            cell.fieldNameText = fieldName
            cell.buttonDelegate = self
            if hasActionableValue {
                cell.fieldValueText = fieldValue
                cell.isValueButtonEnabled = true
            } else {
                cell.disabledFieldValueText = fieldValue ?? emptyValueText
                cell.isValueButtonEnabled = false
                cell.disabledFieldValueColor = fieldValue == nil ? appearance.preferredEmptyFieldValueColor : appearance.preferredFieldValueColor
            }
        }
        lastLoadedEditableCell = nil
    }

    public override func setupEditableCell(_ cell: UITableViewCell) {
        if let editableTextCell = cell as? WCGenericTextFieldCell {
            editableTextCell.fieldValueTextField.inputAccessoryView = self.fieldInputAccessory
            editableTextCell.fieldValueTextField.keyboardType = .emailAddress
            editableTextCell.fieldValueTextField.autocorrectionType = .no
            editableTextCell.fieldValueTextField.spellCheckingType = .no
            editableTextCell.fieldValueTextField.text = fieldValue
            if let placeholderText = placeholderText {
                editableTextCell.fieldValueTextField.placeholder = placeholderText
            } else {
                editableTextCell.fieldValueTextField.placeholder = emptyValueLabelText
            }
            editableTextCell.textFieldDelegate = self
            lastLoadedEditableCell = editableTextCell
        } else {
            lastLoadedEditableCell = nil
        }
        if let editiableTextCell = cell as? WCGenericTextFieldAndLabelCell {
            editiableTextCell.fieldNameLabel.text = fieldName
        }
        if let editableTextCell = cell as? WCTextFieldNoFieldNameLabelCell {
            editableTextCell.fieldValueTextField.placeholder = placeholderText ?? fieldName
        }
    }

    /// Attempt to make this field to become the first responder.
    public override func becomeFirstResponder() {
        if let lastLoadedEditableCell = lastLoadedEditableCell {
            lastLoadedEditableCell.fieldValueTextField.becomeFirstResponder()
        }
    }

    /// Attempt to make this field resign its first responder status.
    public override func resignFirstResponder() {
        if let lastLoadedEditableCell = lastLoadedEditableCell {
            lastLoadedEditableCell.fieldValueTextField.resignFirstResponder()
        }
    }

    /// Validate the email address.
    ///
    /// - Throws: A WCFieldValidationError describing the validation error that occurred on the field.
    public override func validateFieldValue() throws {
        try super.validateFieldValue()
        if validateEmailAddress, let enteredAddress = fieldValue {
            if let validatingBlock = addressValidator {
                if !validatingBlock(enteredAddress) {
                    let errorFormatter = NSLocalizedString("%@ does not contain a valid email address.",
                                                           tableName: "WCForms",
                                                           comment: "Warning that an email address is not properly formatted. %@ is the field name.")
                    let errorString = String(format: errorFormatter, fieldName)
                    throw WCFieldValidationError.invalidFormat(fieldName: fieldName, formatError: errorString)
                }
            } else {
                let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegularExpression)
                if !emailPredicate.evaluate(with: enteredAddress) {
                    let errorFormatter = NSLocalizedString("%@ does not contain a valid email address.",
                                                           tableName: "WCForms",
                                                           comment: "Warning that an email address is not properly formatted. %@ is the field name.")
                    let errorString = String(format: errorFormatter, fieldName)
                    throw WCFieldValidationError.invalidFormat(fieldName: fieldName, formatError: errorString)
                }
            }
        }
    }


    // MARK: - Conformance to WCTextFieldInputDelegate

    public func viewDidUpdateTextField(textField: UITextField) {
        viewDidUpdateValue(newValue: textField.text)
    }


    // MARK: - Conformance to WCButtonActionDelegate

    public var emptyValueText: String {
        return emptyValueLabelText
    }

    public func fieldValueButtonTapped() {
        if let emailAddress = fieldValue {
            switch emailCompositionBehavior {
            case .none:
                return
            case .copyToClipboard:
                UIPasteboard.general.string = emailAddress
            case .inApp:
                guard let formController = formSection?.form?.formController else {
                    print("Error: WCEmailField \(fieldName) is not on a valid form, so an email composition controller cannot be presented.")
                    return
                }
                if MFMailComposeViewController.canSendMail() {
                    let composeVC = MFMailComposeViewController()
                    composeVC.mailComposeDelegate = mailDismisser
                    composeVC.setToRecipients([emailAddress])
                    formController.present(composeVC, animated: true, completion: nil)
                } else {
                    presentCopyAction(emailAddress: emailAddress)
                }
            case .inMailApp:
                if let mailtoURL = URL(string: "mailto:\(emailAddress)") {
                    if UIApplication.shared.canOpenURL(mailtoURL) {
                        UIApplication.shared.open(mailtoURL)
                    } else {
                        presentCopyAction(emailAddress: emailAddress)
                    }
                }
            case .useCallback(let composeEmailTo):
                composeEmailTo(emailAddress)
            }
        }
    }


    // MARK: - Conformance to WCEditableSelectableField

    /// The user selected the email field in a form controller.
    ///
    /// - Parameter formController: The form controller containing the field that the user selected. Use this view controller to push any dependent view
    ///   controllers.
    public func didSelectField(in formController: WCFormController, at indexPath: IndexPath) {
        formController.tableView.deselectRow(at: indexPath, animated: true)
        if formController.isEditing && isEditable {
            becomeFirstResponder()
        } else if hasActionableValue {
            fieldValueButtonTapped()
        }
    }


    // MARK: - Internal helper functions

    func presentCopyAction(emailAddress: String) {
        guard let formController = formSection?.form?.formController else {
            print("Error: WCEmailField \(fieldName) is not on a valid form, so an alert action controller cannot be presented.")
            return
        }
        let copyEmailTitle = NSLocalizedString("Email not set up",
                                               tableName: "WCForms",
                                               comment: "Title of an alert to the user that email is not set up on their device.")
        let copyEmailMessage = NSLocalizedString("The Mail app is not configured to send email on your phone. Would you like to copy the email address to your clipboard instead?",
                                                 tableName: "WCForms",
                                                 comment: "Message to the user giving them the option of copying an email address.")
        let copyActionController = UIAlertController(title: copyEmailTitle, message: copyEmailMessage, preferredStyle: .alert)
        let copyActionTitle = NSLocalizedString("Copy email address",
                                                tableName: "WCForms",
                                                comment: "Action to copy an email address.")
        let copyAction = UIAlertAction(title: copyActionTitle, style: .default, handler: { (action: UIAlertAction) in
            UIPasteboard.general.string = emailAddress
        })
        copyActionController.addAction(copyAction)
        let cancelActionTitle = NSLocalizedString("Cancel", tableName: "WCForms", comment: "Button to cancel an action.")
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: nil)
        copyActionController.addAction(cancelAction)
        formController.present(copyActionController, animated: true, completion: nil)
    }

    var hasActionableValue: Bool {
        var foundActionableValue = false
        do {
            try validateFieldValue()
            foundActionableValue = fieldValue != nil
        } catch {
            foundActionableValue = false
        }
        return foundActionableValue
    }

}

fileprivate class MailDismissingDelegate: NSObject, MFMailComposeViewControllerDelegate {

    // MARK: - Conformance to MFMailComposeViewControllerDelegate

    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}
