//
//  WCBoolFieldTableViewCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

public class WCBoolFieldTableViewCell: UITableViewCell {

    @IBOutlet weak var fieldNameLabel: UILabel!
    @IBOutlet weak var fieldValueSwitch: UISwitch!
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        print("Switch value: \(sender.isOn)")
    }

}
