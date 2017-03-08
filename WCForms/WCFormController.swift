//
//  WCFormController.swift
//  WCForms
//
//  Created by Will Clarke on 2/27/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

public enum WCFormControllerMode {
    case `default`
    case readOnly
    case editableOnly
}

open class WCFormController: UITableViewController {

    @IBInspectable public var viewMode: Bool = true {
        didSet {
            if isViewLoaded {
                viewMode = oldValue
                NSLog("Warning: viewMode can not be set after the WCFormController has been loaded.")
            }
        }
    }
    @IBInspectable public var editMode: Bool = true {
        didSet {
            if isViewLoaded {
                editMode = oldValue
                NSLog("Warning: editMode can not be set after the WCFormController has been loaded.")
            }
        }
    }
    @IBInspectable public var doneButtonTitle: String? = nil {
        didSet {
            if let validTitle = doneButtonTitle {
                doneEditingFormButtonItem = UIBarButtonItem(title: validTitle, style: .done, target: self, action: #selector(doneEditingFormButtonTapped(_:)))
            } else {
                doneEditingFormButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneEditingFormButtonTapped(_:)))
            }
        }
    }
    @IBInspectable public var validateForm: Bool = true
    @IBInspectable public var canCancel: Bool = true {
        didSet {
            if isViewLoaded {
                canCancel = oldValue
                NSLog("Warning: canCancel can not be set after the WCFormController has been loaded.")
            }
        }
    }

    private var formMode: WCFormControllerMode {
        if viewMode && !editMode {
            return .readOnly
        } else if !viewMode && editMode {
            return .editableOnly
        } else {
            return .default
        }
    }

    public var formModel: WCForm? = nil {
        didSet {
            registerNibsForModel()
            if isEditing {
                formModel?.beginEditing()
            }
            if let formTitle = formModel?.formTitle {
                navigationItem.title = formTitle
            }
        }
    }
    private var cancelEditingFormButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: nil, action: nil)
    private var editFormButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: nil, action: nil)
    private var doneEditingFormButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: nil, action: nil)
    private var previousLeftBarButtonItems: [UIBarButtonItem]? = nil
    private var previousLeftItemsSupplementBackButtonSetting: Bool = false

    override open func viewDidLoad() {
        if formMode == .editableOnly {
            isEditing = true
        }

        super.viewDidLoad()

        clearsSelectionOnViewWillAppear = false

        editFormButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(editFormButtonTapped(_:)))
        cancelEditingFormButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEditingButtonTapped(_:)))
        if let validTitle = doneButtonTitle {
            doneEditingFormButtonItem = UIBarButtonItem(title: validTitle, style: .done, target: self, action: #selector(doneEditingFormButtonTapped(_:)))
        } else {
            doneEditingFormButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneEditingFormButtonTapped(_:)))
        }

        if formMode == .default {
            if var rightBarButtonItems = navigationItem.rightBarButtonItems {
                rightBarButtonItems.append(editFormButtonItem)
                navigationItem.rightBarButtonItems = rightBarButtonItems
            } else {
                navigationItem.rightBarButtonItem = editFormButtonItem
            }
        } else if formMode == .editableOnly {
            if var rightBarButtonItems = navigationItem.rightBarButtonItems {
                rightBarButtonItems.append(doneEditingFormButtonItem)
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
        tableView.allowsSelectionDuringEditing = true
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override open func numberOfSections(in tableView: UITableView) -> Int {
        guard let formModel = formModel else {
            return 0
        }
        return formModel.numberOfVisibleSections(whenEditingForm: isEditing)
    }

    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let formModel = formModel else {
            return 0
        }
        guard section < formModel.formSections.count else {
            return 0
        }
        return formModel.numberOfVisibleFields(forVisibleSection: section, whenEditingForm: isEditing)
    }

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let formModel = formModel else {
            return UITableViewCell()
        }
        if let formField = formModel.field(for: indexPath, whenEditingForm: isEditing) {
            return formField.dequeueCell(from: tableView, for: indexPath, isEditing: isEditing)
        } else {
            return UITableViewCell()
        }
    }

    open override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }

    open override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    override final public func setEditing(_ editing: Bool, animated: Bool) {
        guard let formModel = formModel, isEditing != editing else {
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
                    sectionsToInsert.insert(formerVisibleSectionIndex)
                } else if !sectionIsVisible && sectionWasVisible {
                    //section was visible but isn't now, we want to delete it
                    sectionsToDelete.insert(formerVisibleSectionIndex)
                }
                if sectionIsVisible {
                    var formerVisibleFieldIndex = 0
                    var currentVisibleFieldIndex = 0
                    for field in section.formFields {
                        let fieldIsVisible = field.isVisible(whenEditingForm: editing)
                        let fieldWasVisible = field.isVisible(whenEditingForm: !editing)
                        if fieldIsVisible && !fieldWasVisible {
                            //field is visible but wasn't before, we want to insert it
                            indexPathsToInsert.append(IndexPath(row: formerVisibleFieldIndex, section: formerVisibleSectionIndex))
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
                    currentVisibleSectionIndex += 1
                }
                if sectionWasVisible {
                    formerVisibleSectionIndex += 1
                }
            }
            tableView.beginUpdates()
            tableView.insertRows(at: indexPathsToInsert, with: .left)
            tableView.deleteRows(at: indexPathsToDelete, with: .left)
            tableView.insertSections(sectionsToInsert, with: .left)
            tableView.deleteSections(sectionsToDelete, with: .left)
            tableView.endUpdates()
            
            tableView.beginUpdates()
            tableView.reloadRows(at: indexPathsToReload, with: .fade)
            tableView.endUpdates()
        }
    }

    final func editFormButtonTapped(_ sender: UIBarButtonItem) {
        guard isEditing == false else {
            return
        }
        guard let formModel = formModel else {
            return
        }
        if navigationItem.rightBarButtonItem == editFormButtonItem {
            navigationItem.setRightBarButton(doneEditingFormButtonItem, animated: true)
        } else if var rightBarButtonItems = navigationItem.rightBarButtonItems {
            if let editButtonIndex = rightBarButtonItems.index(of: editFormButtonItem) {
                rightBarButtonItems[editButtonIndex] = doneEditingFormButtonItem
            } else {
                rightBarButtonItems.append(doneEditingFormButtonItem)
            }
            navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: true)
        }
        previousLeftBarButtonItems = navigationItem.leftBarButtonItems
        previousLeftItemsSupplementBackButtonSetting = navigationItem.leftItemsSupplementBackButton
        navigationItem.leftItemsSupplementBackButton = false
        navigationItem.setLeftBarButton(cancelEditingFormButtonItem, animated: true)
        formModel.beginEditing()
        setEditing(true, animated: true)
    }

    final func doneEditingFormButtonTapped(_ sender: UIBarButtonItem) {
        guard isEditing == true else {
            return
        }
        guard let formModel = formModel else {
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
            } else {
                doneEditingFormButtonItem.isEnabled = true
            }
        }
    }

    open func formShouldFinishEditing() -> Bool {
        return true
    }

    open func formDidFinishEditing() { }

    open func formDidCancelEditing() { }

    final func cancelEditingButtonTapped(_ sender: UIBarButtonItem) {
        guard isEditing else {
            return
        }
        guard let formModel = formModel else {
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
                    formModel.cancelEditing()
                    self.formDidCancelEditing()
                    self.setEditing(false, animated: true)
                } else if self.formMode == .editableOnly {
                    formModel.cancelEditing()
                    self.formDidCancelEditing()
                    self.tableView.reloadData()
                    formModel.beginEditing()
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
    
    private func restoreBarButtonsAfterCompletion() {
        navigationItem.leftItemsSupplementBackButton = previousLeftItemsSupplementBackButtonSetting
        previousLeftItemsSupplementBackButtonSetting = false
        navigationItem.setLeftBarButtonItems(previousLeftBarButtonItems, animated: true)
        previousLeftBarButtonItems = nil
        if navigationItem.rightBarButtonItem == doneEditingFormButtonItem {
            navigationItem.setRightBarButton(editFormButtonItem, animated: true)
        } else if var rightBarButtonItems = navigationItem.rightBarButtonItems {
            if let doneButtonIndex = rightBarButtonItems.index(of: doneEditingFormButtonItem) {
                rightBarButtonItems[doneButtonIndex] = editFormButtonItem
            } else {
                rightBarButtonItems.append(editFormButtonItem)
            }
            navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: true)
        }
    }

    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return formModel?.section(forVisibleSection: section, whenEditingForm: isEditing)?.headerTitle
//        guard let formModel = formModel else {
//            return nil
//        }
//        if let section = formModel.section(forVisibleSection: section, whenEditingForm: isEditing) {
//            return section.headerTitle
//        } else {
//            return nil
//        }
    }

    open override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return formModel?.section(forVisibleSection: section, whenEditingForm: isEditing)?.footerTitle
//        guard let formModel = formModel else {
//            return nil
//        }
//        guard section < formModel.formSections.count else {
//            return nil
//        }
//        return formModel.formSections[section].footerTitle
    }

    open override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        guard let formModel = formModel else {
            return false
        }
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
        guard let formModel = formModel else {
            return false
        }
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
        guard let formModel = formModel else {
            return
        }
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
        tableView.deselectRow(at: indexPath, animated: true)
        guard let formModel = formModel else {
            return
        }
        guard let field = formModel.field(for: indexPath, whenEditingForm: isEditing) else {
            return
        }
        if let inputField = field as? WCInputField, isEditing && field.isEditable && inputField.canBecomeFirstResponder {
            inputField.becomeFirstResponder()
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func registerNibsForModel() {
        guard let formModel = formModel else {
            return
        }
        for section in formModel.formSections {
            for field in section.formFields {
                field.registerNibsForCellReuseIdentifiers(in: tableView)
            }
        }
    }

    func displayFormValidationError(for formError: WCFormValidationError) {
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

}
