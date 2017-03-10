//
//  WCBoolFieldStackedCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/2/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

/// A table view cell for an editable boolean field with the `stacked` appearance.
public class WCBoolFieldStackedCell: WCBoolFieldCell {

    /// The label displaying the off label.
    @IBOutlet weak var offDisplayValueLabel: UILabel!

    /// The label displaying the on label.
    @IBOutlet weak var onDisplayValueLabel: UILabel!

    /// IBAction for when the switch value changes.
    ///
    /// - Parameter sender: The switch that changed.
    @IBAction override func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            onDisplayValueLabel.textColor = offDisplayValueLabel.textColor
            offDisplayValueLabel.textColor = UIColor.lightGray
        } else {
            offDisplayValueLabel.textColor = onDisplayValueLabel.textColor
            onDisplayValueLabel.textColor = UIColor.lightGray
        }
        delegate?.viewDidUpdateValue(newValue: sender.isOn)
    }

}
