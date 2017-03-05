//
//  WCDateFieldTableViewCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

public class WCDateFieldTableViewCell: WCGenericTextFieldTableViewCell {

    public var datePickerKeyboard = UIDatePicker()
    public var dateDisplayFormatter = DateFormatter()

    weak var delegate: WCDateField? = nil

    public override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        datePickerKeyboard.datePickerMode = .date
        datePickerKeyboard.addTarget(self, action: #selector(dateChanged(sender:)), for: UIControlEvents.valueChanged)
        fieldValueTextField.inputView = datePickerKeyboard
    }

    @IBAction func dateFieldEditingChanged(_ sender: UITextField) {
        fieldValueTextField.text = dateDisplayFormatter.string(from: datePickerKeyboard.date)
    }

    func dateChanged(sender: UIDatePicker) {
        fieldValueTextField.text = dateDisplayFormatter.string(from: sender.date)
        delegate?.viewDidUpdateValue(newValue: sender.date)
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("tried replacing \(string)")
        return false
    }

}
