//
//  WCIntFieldSliderTableViewCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/2/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

public class WCIntFieldSliderTableViewCell: UITableViewCell {

    @IBOutlet weak var fieldNameLabel: UILabel!
    @IBOutlet weak var fieldValueLabel: UILabel!
    @IBOutlet weak var fieldValueSlider: UISlider!
    
    @IBAction func intSliderValueChanged(_ sender: UISlider) {
        let text = String(round(sender.value))
        print("Int field value: \(text)")
    }

}
