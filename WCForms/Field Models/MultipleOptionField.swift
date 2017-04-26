//
//  MultipleOptionField.swift
//  WCForms
//
//  Created by Will Clarke on 4/6/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation

/// How to summarize a multiple option selection on a form.
///
/// - all: Show all items, separated by `NSLocale`'s `groupingSeparator` and using the localized coordinating conjunction "and".
/// - localizedAll: Same as `all` but, using the associated value `conjunction` as a localized coordinating conjunction.
/// - sum: Show a total of the number of items selected.
/// - sumAfter: Display the first `numberToDisplay` items, and a sum of the number of items after that. For example, `sumAfter(numberToDisplay: 2)` might
///             display "Item 1, Item 2, and 6 more". This will use `NSLocale`'s `groupingSeparator` to separate the items, and the localized coordinating 
///             conjunction "and".
/// - localizedSumAfter: Same as `sumAfter`, but an associated value `conjunction` to specify a localized coordinating conjunction.
/// - useCallback: A callback will be used to determine the summary. The callback takes an array of Strings representing the items the user selected, and
///                expects a String in return that represents a localized summary of the items.
public enum MultipleOptionSummaryStyle: Equatable {
    case all
    case localizedAll(conjunction: String)
    case count
    case countAfter(numberToDisplay: Int)
    case localizedCountAfter(numberToDisplay: Int, conjunction: String)
    case useCallback(callback: ([Any]) -> String)
}

public func ==(lhs: MultipleOptionSummaryStyle, rhs: MultipleOptionSummaryStyle) -> Bool {
    switch (lhs, rhs) {
    case (.all, .all), (.count, .count):
        return true
    case (.localizedAll(let conjunction1), .localizedAll(let conjunction2)):
        return conjunction1 == conjunction2
    case (.countAfter(let numberToDisplay1), .countAfter(let numberToDisplay2)):
        return numberToDisplay1 == numberToDisplay2
    case (.localizedCountAfter(let numberToDisplay1, let conjunction1), .localizedCountAfter(let numberToDisplay2, let conjunction2)):
        return numberToDisplay1 == numberToDisplay2 && conjunction1 == conjunction2
    default:
        // callbacks are always considered different, because there is no notion of function equality in Swift.
        return false
    }
}

/// How to order the selected items in the field summary. This is not used if the `selectionStyle` is set to `count` because no items are displayed.
///
/// - none: Order the items randomly.
/// - ascending: Order the items ascending according to their display value.
/// - descending: Order the items descending according to their display value.
/// - with: Order the items according to the associated value `comparator`. The items themselves will be used in the `Comparator`.
public enum MultipleOptionSummaryOrder {
    case none
    case ascending
    case descending
    case with(comparator: Comparator)
}

/// The selection behavior for multiple option fields in read only mode.
///
/// - showDetail: If selections have been made, a new detail view controller should be pushed onto the navigation stack to display the user's selections.
/// - none: No action should be taken. The cell will be immediately deselected after
public enum MultipleOptionReadOnlySelectionBehavior {
    case showDetail, none
}

public class WCMultipleOptionField<ItemType: OptionFieldItem>: WCOptionField<ItemType, Set<ItemType>> {
    
    /// How to summarize the user's selections in the form. When this is `nil`, the cell appearance's preferred summary style will be used.
    public var summaryStyle: MultipleOptionSummaryStyle? = nil

    private var preferredSummaryStyle: MultipleOptionSummaryStyle {
        get {
            return summaryStyle ?? appearance.preferredSummaryStyle
        }
    }

    /// How to order the user's selections in the form summary. By default, this will use `.none`.
    public var summaryOrder: MultipleOptionSummaryOrder = .none

    /// The behavior when a multiple option field is selected in read-only mode. When `nil`, the cell appearance's preferred selection behavior will be used.
    public var readOnlySelectionBehavior: MultipleOptionReadOnlySelectionBehavior? = nil
    
    private var preferredReadOnlySelectionBehavior: MultipleOptionReadOnlySelectionBehavior {
        get {
            return readOnlySelectionBehavior ?? appearance.preferredReadOnlySelectionBehavior
        }
    }

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
            if let indexPathForRow = formController.tableView.indexPathForSelectedRow {
                formController.tableView.deselectRow(at: indexPathForRow, animated: true)
            }
            return
        }
        super.didSelectField(in: formController)
        let isFieldInEditMode = formController.isEditing && isEditable
        let shouldPushSelectionSummary = !isFieldInEditMode && preferredReadOnlySelectionBehavior == .showDetail
        if isFieldInEditMode {
            let pickerTableViewStyle: UITableViewStyle = optionGroups.count == 1 ? optionGroups.first!.preferredTableViewStyle : .grouped
            let optionPickerController = WCOptionPickerTableViewController<ItemType, Set<ItemType>>(style: pickerTableViewStyle)
            optionPickerController.navigationItem.title = fieldName
            optionPickerController.delegate = self
            optionPickerController.dataSource = self
            optionPickerController.selectionMode = .multiple
            navigationController.pushViewController(optionPickerController, animated: true)
            self.optionPickerController = optionPickerController
        } else if let selectedItemArray = self.selectedItemArray, shouldPushSelectionSummary {
            let optionDetailController = WCOptionSelectionDetailTableViewController<ItemType>(style: .grouped)
            optionDetailController.navigationItem.title = fieldName
            optionDetailController.selectedItems = selectedItemArray
            navigationController.pushViewController(optionDetailController, animated: true)
        } else if let indexPathForRow = formController.tableView.indexPathForSelectedRow {
            formController.tableView.deselectRow(at: indexPathForRow, animated: true)
        }
    }

    override public var copyValue: String? {
        guard let fieldValue = fieldValue else {
            return nil
        }
        return Array(fieldValue).map({$0.localizedValue}).joined(separator: Locale.current.groupingSeparatorWithTrailingWhitespace)
    }

    public override func preferredCellIdentifier(whenEditing isEditing: Bool) -> String {
        if (!isEditing || !isEditable) && preferredReadOnlySelectionBehavior == .showDetail && !isEmpty {
            return appearance.editableCellIdentifier
        } else {
            return super.preferredCellIdentifier(whenEditing: isEditing)
        }
    }

    // MARK: - Summarization functions and variables

    var selectedItemArray: [ItemType]? {
        guard let selectedItems = fieldValue else {
            return nil
        }
        var selectedItemArray = Array(selectedItems)
        switch summaryOrder {
        case .ascending:
            selectedItemArray = selectedItemArray.sorted(by: { (item1: ItemType, item2: ItemType) -> Bool in
                return item1.localizedAbbreviation < item2.localizedAbbreviation
            })
        case .descending:
            selectedItemArray = selectedItemArray.sorted(by: { (item1: ItemType, item2: ItemType) -> Bool in
                return item1.localizedAbbreviation > item2.localizedAbbreviation
            })
        case .none:
            break
        case .with(let comparator):
            selectedItemArray = selectedItemArray.sorted(by: { (item1: ItemType, item2: ItemType) -> Bool in
                if comparator(item1, item2) == .orderedAscending {
                    return true
                } else {
                    return false
                }
            })
        }
        return selectedItemArray
    }

    override var localizedSelectionSummary: String? {
        guard let selectedItemArray = self.selectedItemArray else {
            return nil
        }
        if preferredSummaryStyle == .count {
            return String(selectedItemArray.count)
        }
        
        var coordinatingConjunction = NSLocalizedString("and", tableName: "WCForms", comment: "A coordinating conjunction used when joining lists of items.")
        switch preferredSummaryStyle {
        case .localizedAll(let customConjunction):
            coordinatingConjunction = customConjunction
            fallthrough
        case .all:
            coordinatingConjunction = coordinatingConjunction.trimmingCharacters(in: CharacterSet.whitespaces)
            var abbreviations = selectedItemArray.map({$0.localizedAbbreviation})
            if abbreviations.count == 1 {
                return abbreviations[0]
            } else if abbreviations.count == 2 {
                if coordinatingConjunction.isEmpty {
                    return abbreviations.joined(separator: Locale.current.groupingSeparatorWithTrailingWhitespace)
                } else {
                    return abbreviations.joined(separator: " \(coordinatingConjunction) ")
                }
            } else if abbreviations.count > 2 {
                if !coordinatingConjunction.isEmpty {
                    abbreviations[abbreviations.count - 1] = coordinatingConjunction + " " + abbreviations[abbreviations.count - 1]
                }
                return abbreviations.joined(separator: Locale.current.groupingSeparatorWithTrailingWhitespace)
            } else {
                return nil
            }

        case .countAfter(let numberToDisplay):
            return self.summaryString(forSortedItems: selectedItemArray, numberToDisplay: numberToDisplay, coordinatingConjunction: coordinatingConjunction)

        case .localizedCountAfter(let numberToDisplay, let customConjunction):
            coordinatingConjunction = customConjunction.trimmingCharacters(in: CharacterSet.whitespaces)
            return self.summaryString(forSortedItems: selectedItemArray, numberToDisplay: numberToDisplay, coordinatingConjunction: coordinatingConjunction)

        case .useCallback(let callback):
            return callback(selectedItemArray)

        default:
            return nil
        }
    }

    func summaryString(forSortedAbbreviations sortedAbbreviations: [String], withCoordinatingConjunction coordinatingConjunction: String) -> String? {
        var abbreviations = sortedAbbreviations
        if abbreviations.count == 1 {
            return abbreviations[0]
        } else if abbreviations.count == 2 {
            if coordinatingConjunction.isEmpty {
                return abbreviations.joined(separator: Locale.current.groupingSeparatorWithTrailingWhitespace)
            } else {
                return abbreviations.joined(separator: " \(coordinatingConjunction) ")
            }
        } else if abbreviations.count > 2 {
            if !coordinatingConjunction.isEmpty {
                abbreviations[abbreviations.count - 1] = coordinatingConjunction + " " + abbreviations[abbreviations.count - 1]
            }
            return abbreviations.joined(separator: Locale.current.groupingSeparatorWithTrailingWhitespace)
        } else {
            return nil
        }
    }

    func summaryString(forSortedItems sortedItems: [ItemType], numberToDisplay: Int, coordinatingConjunction: String) -> String? {
        if sortedItems.count <= numberToDisplay {
            //we want the whole list
            let abbreviations = sortedItems.map({$0.localizedAbbreviation})
            return summaryString(forSortedAbbreviations: abbreviations, withCoordinatingConjunction: coordinatingConjunction)
        } else {
            let initialItems = sortedItems.prefix(upTo: numberToDisplay)
            var initialItemStrings = initialItems.map({$0.localizedAbbreviation})
            let additionalItems = sortedItems.count - numberToDisplay
            let loclaizedMoreStringFormatter = NSLocalizedString("%d more",
                                                                 tableName: "WCForms",
                                                                 comment: "Text appended to a list of items to indicate there are additional unnamed items")
            let localizedMoreString = String(format: loclaizedMoreStringFormatter, additionalItems).trimmingCharacters(in: CharacterSet.whitespaces)
            initialItemStrings.append(localizedMoreString)
            return summaryString(forSortedAbbreviations: initialItemStrings, withCoordinatingConjunction: coordinatingConjunction)
        }
    }

    // MARK: - Cell setup
    
    /// Set up the read-only version of this cell. By default this will set up a `WCGenericFieldWithFieldNameCell` or `WCGenericFieldCell` -
    /// override this function in subclasses to customize behavior.
    ///
    /// - Parameter cell: The UITableViewCell for the field.
    public override func setupCell(_ cell: UITableViewCell) {
        if let cell = cell as? WCOptionFieldRightDetailCell {
            if preferredSummaryStyle == .count {
                cell.fieldNameAndValueStackView.alignment = .center
            } else {
                cell.fieldNameAndValueStackView.alignment = .firstBaseline
            }
        }
        super.setupCell(cell)
    }

}

fileprivate extension Locale {
    var groupingSeparatorWithTrailingWhitespace: String {
        let groupingSeparator = self.groupingSeparator ?? ""
        return groupingSeparator.trimmingCharacters(in: CharacterSet.whitespaces) + " "
    }
}
