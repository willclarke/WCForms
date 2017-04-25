//
//  SingleOptionField.swift
//  WCForms
//
//  Created by Will Clarke on 4/6/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation

public class WCSingleOptionField<ItemType: OptionFieldItem>: WCOptionField<ItemType, ItemType> {

    /// The behavior when an item is selected.
    public var selectionBehavior: WCOptionItemSelectionBehavior = .returnToForm

    /// Whether or not the option field allows the user to deselect items. If `false`, once the user has made a selection, they can change the selection but
    /// can not clear or deselect that option. Defaults to `true`.
    public var allowsDeselection = true {
        didSet {
            if let controller = optionPickerController {
                controller.allowsDeselection = allowsDeselection
            }
        }
    }

    override var localizedSelectionSummary: String? {
        return fieldValue?.localizedAbbreviation
    }

    override public var copyValue: String? {
        return fieldValue?.localizedValue
    }

    /// Returns whether or not a specific option item should be marked as selected.
    ///
    /// - Parameter optionItem: The option item to check.
    /// - Returns: Whether or not the item is currently selected in the field.
    override func isSelected(optionItem: ItemType) -> Bool {
        return fieldValue == optionItem
    }

    /// Called when the user has selected an option item in an option item picker controller.
    ///
    /// - Parameters:
    ///   - picker: The option picker controller in which the user has selected the option item.
    ///   - newItem: The new item that has been selected.
    override func optionPicker(_ picker: WCOptionPickerTableViewController<ItemType, ItemType>, didSelectItem newItem: ItemType) {
        if fieldValue != newItem {
            viewDidUpdateValue(newValue: newItem)
        }
        updateLastLoadedCellWithValue()
        if selectionBehavior == .returnToForm {
            if let navigationController = picker.navigationController, navigationController.topViewController == picker {
                navigationController.popViewController(animated: true)
            }
        }
    }

    /// Called when the user has deselected an option item in an option item picker controller.
    ///
    /// - Parameters:
    ///   - picker: The option picker controller in which the user has deselected the option item.
    ///   - deselectedItem: The item that has been deselected.
    override func optionPicker(_ picker: WCOptionPickerTableViewController<ItemType, ItemType>, didDeselectItem deselectedItem: ItemType) {
        if fieldValue == deselectedItem {
            viewDidUpdateValue(newValue: nil)
        }
        updateLastLoadedCellWithValue()
    }

    /// Presents an option picker controller for the user to select an option item. Called when the user has selected this field in a form.
    ///
    /// - Parameter formController: The form controller on which the user selected the option field.
    public override func didSelectField(in formController: WCFormController) {
        guard formController.isEditing && self.isEditable else {
            //We only want to be able to select the single option field when it's editable
            return
        }
        guard let navigationController = formController.navigationController else {
            NSLog("Error: WCOptionField \(fieldName) is on a form not embedded in a UINavigationController, so it can not present a picker view controller.")
            return
        }
        super.didSelectField(in: formController)
        let pickerTableViewStyle: UITableViewStyle = optionGroups.count == 1 ? optionGroups.first!.preferredTableViewStyle : .grouped
        let optionPickerController = WCOptionPickerTableViewController<ItemType, ItemType>(style: pickerTableViewStyle)
        optionPickerController.allowsDeselection = allowsDeselection
        optionPickerController.navigationItem.title = fieldName
        optionPickerController.delegate = self
        optionPickerController.dataSource = self
        navigationController.pushViewController(optionPickerController, animated: true)
        self.optionPickerController = optionPickerController
    }

}
