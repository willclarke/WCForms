//
//  WCDateFieldTableViewCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

public class WCDateFieldTableViewCell: WCTextFieldTableViewCell {

    public var datePickerKeyboard = UIDatePicker()

    public override func awakeFromNib() {
        super.awakeFromNib()
        datePickerKeyboard.datePickerMode = .date
        datePickerKeyboard.addTarget(self, action: #selector(dateChanged(sender:)), for: UIControlEvents.valueChanged)
        fieldValueTextField.inputView = datePickerKeyboard
    }

    @IBAction func dateFieldEditingChanged(_ sender: UITextField) {
        let text = sender.text ?? ""
        print("Date field value: \(text)")
    }

    func dateChanged(sender: UIDatePicker) {
        
    }

}
