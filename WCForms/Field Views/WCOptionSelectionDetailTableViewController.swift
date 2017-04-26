//
//  WCOptionSelectionDetailTableViewController.swift
//  WCForms
//
//  Created by Will Clarke on 4/25/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

/// A table view controller displaying which options are selected in a multiple option field.
class WCOptionSelectionDetailTableViewController<SelectionItemType: OptionFieldItem>: UITableViewController {

    /// The cell identifier and nib name of a table view cell representing an option item.
    let optionItemIdentifier = "WCOptionItemTableViewCell"

    /// The items selected in the field
    var selectedItems = [SelectionItemType]()

    override func viewDidLoad() {
        let nibBundle = Bundle(for: WCOptionItemTableViewCell.self)
        let cellNib = UINib(nibName: optionItemIdentifier, bundle: nibBundle)
        tableView.register(cellNib, forCellReuseIdentifier: optionItemIdentifier)
        super.viewDidLoad()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let optionItem = selectedItems[indexPath.row]
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
        cell.accessoryType = .checkmark
        cell.selectionStyle = .none
        return cell
    }

}
