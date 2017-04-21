//
//  WCOptionPickerTableViewController.swift
//  WCForms
//
//  Created by Will Clarke on 3/31/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

enum OptionPickerSelectionMode {
    case single, multiple
}

/// A picker for an option field.
public class WCOptionPickerTableViewController<SelectionItemType: OptionFieldItem, ValueType: Equatable>: UITableViewController {
    
    /// The cell identifier and nib name of a table view cell representing an option item.
    let optionItemIdentifier = "WCOptionItemTableViewCell"
    
    /// A button to allow the user to clear the selection.
    var clearButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.undo, target: nil, action: nil)

    /// Whether or not the picker allows the user to deselect items.
    var allowsDeselection = true {
        didSet {
            if allowsDeselection {
                navigationItem.rightBarButtonItem = clearButton
            } else {
                navigationItem.rightBarButtonItem = nil
            }
        }
    }

    var selectionMode: OptionPickerSelectionMode = .single

    var checkedIndexPaths = Set<IndexPath>()

    /// The delegate for handling selection actions.
    weak var delegate: WCOptionField<SelectionItemType, ValueType>? = nil

    /// The data source for retrieving option items
    weak var dataSource: WCOptionItemSelectionDataSource? = nil

    /// Sets up the option picker.
    override public func viewDidLoad() {
        let nibBundle = Bundle(for: WCOptionItemTableViewCell.self)
        let cellNib = UINib(nibName: optionItemIdentifier, bundle: nibBundle)
        tableView.register(cellNib, forCellReuseIdentifier: optionItemIdentifier)
        super.viewDidLoad()
        let clearText = NSLocalizedString("Clear", tableName: "WCForms", comment: "Button to clear the value of a field")
        let clearButton = UIBarButtonItem(title: clearText, style: .plain, target: self, action: #selector(clearButtonTapped(_:)))
        if dataSource?.hasSelection == false {
            clearButton.isEnabled = false
        }
        self.clearButton = clearButton
        if allowsDeselection {
            navigationItem.rightBarButtonItem = clearButton
        } else {
            navigationItem.rightBarButtonItem = nil
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 47.0
    }

    /// Target action for when the user taps the `clearButton`
    ///
    /// - Parameter sender: The bar button item that was tapped. This should always be the `clearButton`
    func clearButtonTapped(_ sender: UIBarButtonItem) {
        guard let delegate = delegate else {
            return
        }
        if allowsDeselection {
            clearButton.isEnabled = false
            delegate.optionPickerDidClearValue(self)
            tableView.reloadRows(at: Array(checkedIndexPaths), with: .fade)
            checkedIndexPaths = Set<IndexPath>()
        }
    }


    // MARK: - Table view data source

    override public func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.numberOfOptionGroups ?? 0
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.numberOfOptionItems(forSection: section) ?? 0
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let optionItem = delegate?.optionItem(for: indexPath) else {
            return UITableViewCell()
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: optionItemIdentifier, for: indexPath) as? WCOptionItemTableViewCell else {
            return UITableViewCell()
        }
        cell.optionNameLabel.text = optionItem.localizedValue
        if let description = optionItem.localizedDescription {
            cell.descriptionLabel.isHidden = false
            cell.descriptionLabel.text = description
        } else {
            cell.descriptionLabel.isHidden = true
            cell.descriptionLabel.text = nil
        }
        if delegate?.isSelected(optionItem: optionItem) == true {
            if !checkedIndexPaths.contains(indexPath) {
                checkedIndexPaths.insert(indexPath)
            }
            cell.accessoryType = .checkmark
        } else {
            checkedIndexPaths.remove(indexPath)
            cell.accessoryType = .none
        }
        return cell
    }

    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource?.optionGroupTitle(forSection: section)
    }

    public override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return dataSource?.optionGroupFooter(forSection: section)
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let delegate = delegate else {
            return
        }
        let tappedItem = delegate.optionItem(for: indexPath)
        if delegate.isSelected(optionItem: tappedItem) {
            if allowsDeselection {
                delegate.optionPicker(self, didDeselectItem: tappedItem)
                checkedIndexPaths.remove(indexPath)
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        } else {
            delegate.optionPicker(self, didSelectItem: tappedItem)
            switch selectionMode {
            case .single:
                var indexPathsToReload = Array(checkedIndexPaths)
                indexPathsToReload.append(indexPath)
                tableView.reloadRows(at: indexPathsToReload, with: .fade)
                checkedIndexPaths = [indexPath]
            case .multiple:
                if !checkedIndexPaths.contains(indexPath) {
                    checkedIndexPaths.insert(indexPath)
                }
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        clearButton.isEnabled = delegate.hasSelection
    }

}
