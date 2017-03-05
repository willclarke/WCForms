//
//  WCIntFieldSliderTableViewCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/2/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

public class WCIntFieldSliderTableViewCell: UITableViewCell {

    weak var delegate: WCIntField? = nil

    @IBOutlet weak var fieldNameLabel: UILabel!
    @IBOutlet weak var fieldValueLabel: UILabel!
    @IBOutlet weak var fieldValueSlider: UISlider!

    public override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }

    @IBAction func intSliderValueChanged(_ sender: UISlider) {
        let delegateValue = delegate?.fieldValue
        let newValue = Int(round(sender.value))
        if delegateValue == nil || delegateValue! != newValue {
            delegate?.viewDidUpdateValue(newValue: newValue)
        }
        
        fieldValueLabel.text = String(newValue)
    }

}
