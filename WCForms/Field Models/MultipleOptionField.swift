//
//  MultipleOptionField.swift
//  WCForms
//
//  Created by Will Clarke on 4/6/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation

public class WCMultipleOptionField<ItemType: OptionFieldItem>: WCOptionField<ItemType, Set<ItemType>> {

    /// Returns whether or not a specific option item should be marked as selected.
    ///
    /// - Parameter optionItem: The option item to check.
    /// - Returns: Whether or not the item is currently selected in the field.
    override func isSelected(optionItem: ItemType) -> Bool {
        guard let selectedItems = fieldValue else {
            return false
        }
        return selectedItems.contains(optionItem)
    }

    /// Called when the user has selected an option item in an option item picker controller.
    ///
    /// - Parameters:
    ///   - picker: The option picker controller in which the user has selected the option item.
    ///   - newItem: The new item that has been selected.
    override func optionPicker(_ picker: WCOptionPickerTableViewController<ItemType, Set<ItemType>>, didSelectItem newItem: ItemType) {
        var newValue = fieldValue ?? Set<ItemType>()
        if !newValue.contains(newItem) {
            newValue.insert(newItem)
            viewDidUpdateValue(newValue: newValue)
            updateLastLoadedCellWithValue()
        }
    }

    /// Called when the user has deselected an option item in an option item picker controller.
    ///
    /// - Parameters:
    ///   - picker: The option picker controller in which the user has deselected the option item.
    ///   - deselectedItem: The item that has been deselected.
    override func optionPicker(_ picker: WCOptionPickerTableViewController<ItemType, Set<ItemType>>, didDeselectItem deselectedItem: ItemType) {
        var newValue = fieldValue ?? Set<ItemType>()
        if newValue.contains(deselectedItem) {
            newValue.remove(deselectedItem)
            if newValue.isEmpty {
                viewDidUpdateValue(newValue: nil)
            } else {
                viewDidUpdateValue(newValue: newValue)
            }
            updateLastLoadedCellWithValue()
        }
    }

    /// Presents an option picker controller for the user to select an option item. Called when the user has selected this field in a form.
    ///
    /// - Parameter formController: The form controller on which the user selected the option field.
    public override func didSelectField(in formController: WCFormController) {
        guard let navigationController = formController.navigationController else {
            NSLog("Error: WCOptionField \(fieldName) is on a form not embedded in a UINavigationController, so it can not present a picker view controller.")
            return
        }
        super.didSelectField(in: formController)
        let pickerTableViewStyle: UITableViewStyle = optionGroups.count == 1 ? optionGroups.first!.preferredTableViewStyle : .grouped
        let optionPickerController = WCOptionPickerTableViewController<ItemType, Set<ItemType>>(style: pickerTableViewStyle)
        optionPickerController.navigationItem.title = fieldName
        optionPickerController.delegate = self
        optionPickerController.dataSource = self
        optionPickerController.selectionMode = .multiple
        navigationController.pushViewController(optionPickerController, animated: true)
        self.optionPickerController = optionPickerController
    }

    override var localizedSelectionSummary: String? {
        guard let selectedItems = fieldValue else {
            return nil
        }
        var abbreviations = [String]()
        for item in selectedItems {
            abbreviations.append(item.localizedAbbreviation)
        }
        return abbreviations.joined(separator: ", ")
    }

}
