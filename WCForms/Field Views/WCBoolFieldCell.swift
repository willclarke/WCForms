//
//  WCBoolFieldCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

/// A table view cell for an editable boolean field that displays its value in a `UISwitch`.
internal class WCBoolFieldCell: UITableViewCell {

    /// The label for the field name.
    @IBOutlet weak var fieldNameLabel: UILabel!

    /// The switch for the field value.
    @IBOutlet weak var fieldValueSwitch: UISwitch!

    /// A delegate to handle actions when the value changes.
    weak var delegate: WCBoolField? = nil

    /// Prepare the cell for reuse.
    public override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }

    /// IBAction for when the switch value changed.
    ///
    /// - Parameter sender: The switch that changed.
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        delegate?.viewDidUpdateValue(newValue: sender.isOn)
    }

}
