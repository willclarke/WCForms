//
//  WCFormController.swift
//  WCForms
//
//  Created by Will Clarke on 2/27/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

open class WCFormController: UITableViewController {
    public var isEditable: Bool = true
    public var formModel: WCForm? = nil {
        didSet {
            registerNibsForModel()
            if let formTitle = formModel?.formTitle {
                navigationItem.title = formTitle
            }
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false

        if isEditable {
            self.navigationItem.rightBarButtonItem = self.editButtonItem
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override open func numberOfSections(in tableView: UITableView) -> Int {
        guard let formModel = formModel else {
            return 0
        }
        return formModel.formSections.count
    }

    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let formModel = formModel else {
            return 0
        }
        guard section < formModel.formSections.count else {
            return 0
        }
        return formModel.formSections[section].formFields.count
    }

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let formModel = formModel else {
            return UITableViewCell()
        }
        guard indexPath.section < formModel.formSections.count && indexPath.row < formModel.formSections[indexPath.section].formFields.count else {
            return UITableViewCell()
        }
        let formField = formModel.formSections[indexPath.section].formFields[indexPath.row]
        return formField.dequeueCell(from: tableView, for: indexPath, isEditing: isEditing)
    }

    open override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }

    open override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    open override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        guard let formModel = formModel else {
            return
        }
        var indexPathsToReload = [IndexPath]()
        for (sectionIndex, section) in formModel.formSections.enumerated() {
            for (fieldIndex, field) in section.formFields.enumerated() {
                if field.isEditable {
                    indexPathsToReload.append(IndexPath(row: fieldIndex, section: sectionIndex))
                }
            }
        }
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }

    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let formModel = formModel else {
            return nil
        }
        guard section < formModel.formSections.count else {
            return nil
        }
        return formModel.formSections[section].headerTitle
    }

    open override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let formModel = formModel else {
            return nil
        }
        guard section < formModel.formSections.count else {
            return nil
        }
        return formModel.formSections[section].footerTitle
    }

    open override func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        guard let formModel = formModel else {
            return false
        }
        guard let field = formModel[indexPath] else {
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
        guard let field = formModel[indexPath] else {
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
        guard let field = formModel[indexPath] else {
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

}
