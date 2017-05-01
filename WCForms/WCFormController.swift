//
//  WCFormController.swift
//  WCForms
//
//  Created by Will Clarke on 2/27/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

/// The mode that the form controller is in. This is inferred based on the viewMode and editMode variables, which can be set in Interface Builder.
///
/// - `default`: The form controller supports view and edit mode.
/// - readOnly: The form controller only supports view mode.
/// - editableOnly: The form controller only supports edit mode.
public enum WCFormControllerMode {
    case `default`
    case readOnly
    case editableOnly
}


// MARK: - WCFormController class definition

/// A UITableViewController that displays a WCForm
open class WCFormController: UITableViewController {
    
    // MARK: - IBInspectable properties

    /// Whether or not the form supports the view (AKA read-only) mode. If both viewMode and editMode are false, the controller will treat the form as if it
    /// is in read-only mode, because you can't have a form that supports neither. This can only be set before a view loads.
    @IBInspectable public var viewMode: Bool = true {
        didSet {
            if isViewLoaded {
                viewMode = oldValue
                NSLog("Warning: viewMode can not be set after the WCFormController has been loaded.")
            }
        }
    }

    /// Whether or not the form supports the edit mode. This can only be set before a view loads.
    @IBInspectable public var editMode: Bool = true {
        didSet {
            if isViewLoaded {
                editMode = oldValue
                NSLog("Warning: editMode can not be set after the WCFormController has been loaded.")
            }
        }
    }

    /// The title that should appear on the right bar button when the form is being edited.
    @IBInspectable public var doneButtonTitle: String? = nil {
        didSet {
            if let validTitle = doneButtonTitle {
                doneEditingFormButtonItem = UIBarButtonItem(title: validTitle, style: .done, target: self, action: #selector(doneEditingFormButtonTapped(_:)))
            } else {
                doneEditingFormButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneEditingFormButtonTapped(_:)))
            }
        }
    }

    /// Whether or not the form should attempt to validate fields and display errors when the user taps the done button.
    @IBInspectable public var validateForm: Bool = true

    /// Whether or not the user can cancel editing the form. Canceling will check for any changes to the form and prompt the user to discard them. This can 
    /// only be set before a view loads.
    @IBInspectable public var canCancel: Bool = true {
        didSet {
            if isViewLoaded {
                canCancel = oldValue
                NSLog("Warning: canCancel can not be set after the WCFormController has been loaded.")
            }
        }
    }


    // MARK: - Instance variables

    /// The form that the controller displays.
    public var formModel: WCForm = WCForm() {
        didSet {
            registerNibsForModel()
            if isEditing {
                formModel.beginEditing()
            }
            if let formTitle = formModel.formTitle {
                navigationItem.title = formTitle
            }
            formModel.formController = self
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }


    // MARK: - Private instance variables

    /// A computed property for the controller mode based on the `viewMode` and `editMode` booleans.
    private var formMode: WCFormControllerMode {
        if viewMode && editMode {
            return .default
        } else if !viewMode && editMode {
            return .editableOnly
        } else {
            return .readOnly
        }
    }

    /// The identifier for the custom footer since Apple's is ugly
    private let customFooterIdentifier = "CustomPlainFooterView"

    /// A bar button item for canceling the form.
    private var cancelEditingFormButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: nil, action: nil)

    /// A bar button item for editing the form.
    private var editFormButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: nil, action: nil)

    /// A bar button item for completing editing a form.
    private var doneEditingFormButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: nil, action: nil)

    /// Storage for previous right bar button items while a form is editing. These should be restored after the form is done editing.
    private var previousRightBarButtonItems: [UIBarButtonItem]? = nil

    /// Storage for previous left bar button items while a form is editing. These should be restored after the form is done editing.
    private var previousLeftBarButtonItems: [UIBarButtonItem]? = nil

    /// Storage for the previous `leftItemsSupplementBackButton` setting for while a form is editing.  This should be restored after the form is done editing.
    private var previousLeftItemsSupplementBackButtonSetting: Bool = false


    // MARK: - View lifecycle methods

    override open func viewDidLoad() {
        if formMode == .editableOnly {
            isEditing = true
        }

        super.viewDidLoad()

        clearsSelectionOnViewWillAppear = true

        editFormButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(editFormButtonTapped(_:)))
        cancelEditingFormButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEditingButtonTapped(_:)))
        if let validTitle = doneButtonTitle {
            doneEditingFormButtonItem = UIBarButtonItem(title: validTitle, style: .done, target: self, action: #selector(doneEditingFormButtonTapped(_:)))
        } else {
            doneEditingFormButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneEditingFormButtonTapped(_:)))
        }

        if formMode == .default {
            if var rightBarButtonItems = navigationItem.rightBarButtonItems {
                rightBarButtonItems.insert(editFormButtonItem, at: 0)
                navigationItem.rightBarButtonItems = rightBarButtonItems
            } else {
                navigationItem.rightBarButtonItem = editFormButtonItem
            }
        } else if formMode == .editableOnly {
            if var rightBarButtonItems = navigationItem.rightBarButtonItems {
                rightBarButtonItems.insert(doneEditingFormButtonItem, at: 0)
                navigationItem.rightBarButtonItems = rightBarButtonItems
            } else {
                navigationItem.rightBarButtonItem = doneEditingFormButtonItem
            }
            if canCancel {
                navigationItem.leftItemsSupplementBackButton = true
                if var leftBarButtonItems = navigationItem.leftBarButtonItems {
                    leftBarButtonItems.append(cancelEditingFormButtonItem)
                    navigationItem.leftBarButtonItems = leftBarButtonItems
                } else {
                    navigationItem.leftBarButtonItem = cancelEditingFormButtonItem
                }
            }
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        if tableView.style == .plain {
            tableView.sectionFooterHeight = UITableViewAutomaticDimension
            tableView.estimatedSectionFooterHeight = 46.0
        }
        tableView.allowsSelectionDuringEditing = true
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    // MARK: - Table view data source

    override open func numberOfSections(in tableView: UITableView) -> Int {
        return formModel.numberOfVisibleSections(whenEditingForm: isEditing)
    }

    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < formModel.formSections.count else {
            return 0
        }
        return formModel.numberOfVisibleFields(forVisibleSection: section, whenEditingForm: isEditing)
    }

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let formField = formModel.field(for: indexPath, whenEditingForm: isEditing) {
            return formField.dequeueCell(from: tableView, for: indexPath, isEditing: isEditing)
        } else {
            return UITableViewCell()
        }
    }

    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return formModel.section(forVisibleSection: section, whenEditingForm: isEditing)?.headerTitle
    }

    open override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let footerTitle = formModel.section(forVisibleSection: section, whenEditingForm: isEditing)?.footerTitle
        if tableView.style == .plain {
            return ""
        }
        return footerTitle
    }


    // MARK: - Table view delegate

    open override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }

    open override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    open override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        guard let field = formModel.field(for: indexPath, whenEditingForm: isEditing) else {
            return false
        }
        guard !isEditing || !field.isEditable else {
            //we only want to allow copying if the form is in non-edit mode, or if the field itself isn't editable
            return false
        }
        return field.isAbleToCopy && field.copyValue != nil
    }

    open override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        guard let field = formModel.field(for: indexPath, whenEditingForm: isEditing) else {
            return false
        }
        guard !isEditing || !field.isEditable else {
            //we only want to allow copying if the form is in non-edit mode, or if the field itself isn't editable
            return false
        }
        if field.isAbleToCopy && field.copyValue != nil {
            return action == #selector(copy(_:))
        } else {
            return false
        }
    }

    open override func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        guard let field = formModel.field(for: indexPath, whenEditingForm: isEditing) else {
            return
        }
        guard !isEditing || !field.isEditable else {
            //we only want to allow copying if the form is in non-edit mode, or if the field itself isn't editable
            return
        }
        if let valueToCopy = field.copyValue, field.isAbleToCopy && action == #selector(copy(_:)) {
            UIPasteboard.general.string = valueToCopy
        }
    }

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let field = formModel.field(for: indexPath, whenEditingForm: isEditing) else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        if let selectableField = field as? WCEditableSelectableField {
            selectableField.didSelectField(in: self, at: indexPath)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        if let inputField = field as? WCInputField, isEditing && field.isEditable && inputField.canBecomeFirstResponder {
            inputField.becomeFirstResponder()
        }
    }

    open override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard tableView.style == .plain else {
            return UITableViewAutomaticDimension
        }
        guard let section = formModel.section(forVisibleSection: section, whenEditingForm: isEditing) else {
            return UITableViewAutomaticDimension
        }
        if section.footerTitle == nil {
            return 0.0
        } else {
            return UITableViewAutomaticDimension
        }
    }

    open override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard tableView.style == .plain else {
            return nil
        }
        guard let section = formModel.section(forVisibleSection: section, whenEditingForm: isEditing) else {
            return nil
        }
        guard let sectionFooterTitle = section.footerTitle else {
            return nil
        }
        if let dequeuedFooter = tableView.dequeueReusableHeaderFooterView(withIdentifier: customFooterIdentifier) as? CustomPlainFooterView {
            dequeuedFooter.footerLabel.text = sectionFooterTitle
            return dequeuedFooter
        } else {
            return nil
        }
    }


    // MARK: - Override superclass editing

    override final public func setEditing(_ editing: Bool, animated: Bool) {
        guard isEditing != editing else {
            super.setEditing(editing, animated: animated)
            return
        }
        super.setEditing(editing, animated: animated)

        if formMode == .default {
            var sectionsToInsert = IndexSet()
            var sectionsToDelete = IndexSet()
            var indexPathsToReload = [IndexPath]()
            var indexPathsToInsert = [IndexPath]()
            var indexPathsToDelete = [IndexPath]()
            
            var currentVisibleSectionIndex = 0
            var formerVisibleSectionIndex = 0
            for section in formModel.formSections {
                let sectionIsVisible = section.isVisible(whenEditingForm: editing)
                let sectionWasVisible = section.isVisible(whenEditingForm: !editing)
                if sectionIsVisible && !sectionWasVisible {
                    //section is now visible but wasn't before, we want to add it
                    sectionsToInsert.insert(currentVisibleSectionIndex)
                } else if !sectionIsVisible && sectionWasVisible {
                    //section was visible but isn't now, we want to delete it
                    sectionsToDelete.insert(formerVisibleSectionIndex)
                }
                if sectionIsVisible && sectionWasVisible {
                    var formerVisibleFieldIndex = 0
                    var currentVisibleFieldIndex = 0
                    for field in section.formFields {
                        let fieldIsVisible = field.isVisible(whenEditingForm: editing)
                        let fieldWasVisible = field.isVisible(whenEditingForm: !editing)
                        if fieldIsVisible && !fieldWasVisible {
                            //field is visible but wasn't before, we want to insert it
                            indexPathsToInsert.append(IndexPath(row: currentVisibleFieldIndex, section: currentVisibleSectionIndex))
                        } else if !fieldIsVisible && fieldWasVisible {
                            //field was visible but isn't now, we want to delete it
                            indexPathsToDelete.append(IndexPath(row: formerVisibleFieldIndex, section: formerVisibleSectionIndex))
                        } else if fieldIsVisible && fieldWasVisible && field.isEditable {
                            indexPathsToReload.append(IndexPath(row: currentVisibleFieldIndex, section: currentVisibleSectionIndex))
                        }
                        if fieldIsVisible {
                            currentVisibleFieldIndex += 1
                        }
                        if fieldWasVisible {
                            formerVisibleFieldIndex += 1
                        }
                    }
                }
                if sectionWasVisible {
                    formerVisibleSectionIndex += 1
                }
                if sectionIsVisible {
                    currentVisibleSectionIndex += 1
                }
            }
            tableView.beginUpdates()
            tableView.insertRows(at: indexPathsToInsert, with: .middle)
            tableView.deleteRows(at: indexPathsToDelete, with: .middle)
            tableView.insertSections(sectionsToInsert, with: .middle)
            tableView.deleteSections(sectionsToDelete, with: .middle)
            tableView.endUpdates()
            
            tableView.beginUpdates()
            tableView.reloadRows(at: indexPathsToReload, with: .fade)
            tableView.endUpdates()
        }
    }


    // MARK: - Target actions for buttons

    final func editFormButtonTapped(_ sender: UIBarButtonItem) {
        guard isEditing == false else {
            return
        }
        previousRightBarButtonItems = navigationItem.rightBarButtonItems
        previousLeftBarButtonItems = navigationItem.leftBarButtonItems
        previousLeftItemsSupplementBackButtonSetting = navigationItem.leftItemsSupplementBackButton
        navigationItem.leftItemsSupplementBackButton = false
        navigationItem.setLeftBarButtonItems([cancelEditingFormButtonItem], animated: true)
        navigationItem.setRightBarButtonItems([doneEditingFormButtonItem], animated: true)
        formModel.beginEditing()
        setEditing(true, animated: true)
    }

    final func doneEditingFormButtonTapped(_ sender: UIBarButtonItem) {
        guard isEditing == true else {
            return
        }
        view.endEditing(true)
        if validateForm {
            if let firstError = formModel.firstValidationError() {
                displayFormValidationError(for: firstError)
                return
            }
        }
        if formMode == .editableOnly {
            doneEditingFormButtonItem.isEnabled = false
            if formShouldFinishEditing() {
                formModel.finishEditing()
                doneEditingFormButtonItem.isEnabled = true
                formDidFinishEditing()
                formModel.beginEditing()
            } else {
                doneEditingFormButtonItem.isEnabled = true
            }
        } else if formMode == .default {
            doneEditingFormButtonItem.isEnabled = false
            if formShouldFinishEditing() {
                formModel.finishEditing()
                doneEditingFormButtonItem.isEnabled = true
                formDidFinishEditing()
                restoreBarButtonsAfterCompletion()
                setEditing(false, animated: true)
            } else {
                doneEditingFormButtonItem.isEnabled = true
            }
        }
    }

    final func cancelEditingButtonTapped(_ sender: UIBarButtonItem) {
        guard isEditing else {
            return
        }
        view.endEditing(true)
        if formModel.hasFieldChanges {
            let confirmationTitle = NSLocalizedString("Are you sure?",
                                                      tableName: "WCForms",
                                                      comment: "Error message title to confirm a destructive action")
            let confirmationMessage = NSLocalizedString("You have made changes. Do you want to discard them?",
                                                        tableName: "WCForms",
                                                        comment: "Message to the user to confirm a destructive action")
            let confirmationAlert = UIAlertController(title: confirmationTitle, message: confirmationMessage, preferredStyle: .alert)
            let cancelTitle = NSLocalizedString("No, Keep Editing", tableName: "WCForms", comment: "Action to keep editing a form")
            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
            let discardTitle = NSLocalizedString("Yes, Discard", tableName: "WCForms", comment: "Action stop editing a form and discard changes")
            let discardAction = UIAlertAction(title: discardTitle, style: .destructive, handler: { (action: UIAlertAction) in
                if self.formMode == .default {
                    self.restoreBarButtonsAfterCompletion()
                    self.formModel.cancelEditing()
                    self.formDidCancelEditing()
                    self.setEditing(false, animated: true)
                } else if self.formMode == .editableOnly {
                    self.formModel.cancelEditing()
                    self.formDidCancelEditing()
                    self.tableView.reloadData()
                    self.formModel.beginEditing()
                }
            })
            confirmationAlert.addAction(discardAction)
            confirmationAlert.addAction(cancelAction)
            present(confirmationAlert, animated: true, completion: nil)
        } else {
            if formMode == .default {
                restoreBarButtonsAfterCompletion()
                formModel.cancelEditing()
                formDidCancelEditing()
                setEditing(false, animated: true)
            } else if formMode == .editableOnly {
                formModel.cancelEditing()
                formDidCancelEditing()
                formModel.beginEditing()
            }
        }
    }


    // MARK: - Override point for subclasses to handle form actions

    /// Called after the user taps the completion button to make sure the form should finish editing. Be default, it always returns true - override it and
    /// return false to stop the form from finishing editing. It's recommended that you also display some from of error view to the user to let them know why
    /// the form could not finish editing. Feel free to block this and wait on a web service call to complete before returning true or false.
    ///
    /// - Returns: true if the form should finish editing, and false if not.
    open func formShouldFinishEditing() -> Bool {
        return true
    }

    /// Called after a form finishes editing. If validateForm is set to true, this means all field validation passed. Override this to perform some action 
    /// after completing, like dismissing the view.
    open func formDidFinishEditing() { }
    
    /// Called after a form cancels editing. If changes were made to the form, the user was asked to confirm discarding any changes. Override this to perform 
    /// some action after completing, like dismissing the view.
    open func formDidCancelEditing() { }


    // MARK: - Functions for updating UI

    private func restoreBarButtonsAfterCompletion() {
        navigationItem.leftItemsSupplementBackButton = previousLeftItemsSupplementBackButtonSetting
        previousLeftItemsSupplementBackButtonSetting = false
        navigationItem.setLeftBarButtonItems(previousLeftBarButtonItems, animated: true)
        previousLeftBarButtonItems = nil
        navigationItem.setRightBarButtonItems(previousRightBarButtonItems, animated: true)
        previousRightBarButtonItems = nil
    }


    private func registerNibsForModel() {
        let nibBundle = Bundle(for: CustomPlainFooterView.self)
        let footerNib = UINib(nibName: customFooterIdentifier, bundle: nibBundle)
        tableView.register(footerNib, forHeaderFooterViewReuseIdentifier: customFooterIdentifier)
        for section in formModel.formSections {
            for field in section.formFields {
                field.registerNibsForCellReuseIdentifiers(in: tableView)
            }
        }
    }

    private func displayFormValidationError(for formError: WCFormValidationError) {
        var errorTitle = NSLocalizedString("Error:", tableName: "WCForms", comment: "An error that has occurred. What follows the colon is a field name")
        errorTitle += " \(formError.field.fieldName)"
        let errorAlert = UIAlertController(title: errorTitle, message: formError.error, preferredStyle: .alert)
        let okayTitle = NSLocalizedString("OK", tableName: "WCForms", comment: "Title of an alert view button")
        let okayAction = UIAlertAction(title: okayTitle, style: .default) { (action: UIAlertAction) in
            if formError.field.canBecomeFirstResponder {
                formError.field.becomeFirstResponder()
            }
        }
        errorAlert.addAction(okayAction)
        present(errorAlert, animated: true) { 
            self.tableView.scrollToRow(at: formError.indexPath, at: .middle, animated: true)
        }
    }

    public func reloadIndexPath(for formField: WCField, with animation: UITableViewRowAnimation) {
        guard let indexPath = formModel.visibleIndexPath(for: formField, whenEditingForm: isEditing) else {
            return
        }
        tableView.reloadRows(at: [indexPath], with: animation)
    }

}
