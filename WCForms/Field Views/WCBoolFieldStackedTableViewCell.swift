//
//  WCBoolFieldStackedTableViewCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/2/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

public class WCBoolFieldStackedTableViewCell: WCBoolFieldTableViewCell {

    @IBOutlet weak var offDisplayValueLabel: UILabel!
    @IBOutlet weak var onDisplayValueLabel: UILabel!

    @IBAction override func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            onDisplayValueLabel.textColor = UIColor.darkGray
            offDisplayValueLabel.textColor = UIColor.lightGray
        } else {
            onDisplayValueLabel.textColor = UIColor.lightGray
            offDisplayValueLabel.textColor = UIColor.darkGray
        }
        delegate?.viewDidUpdateValue(newValue: sender.isOn)
    }

}
