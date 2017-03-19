//
//  WCIntFieldSliderCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/2/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

/// A table view cell for an editable integer field with the `slider` appearance.
internal class WCIntFieldSliderCell: UITableViewCell {

    /// A delegate to handle actions when the field changes.
    weak var delegate: WCIntField? = nil

    /// A label for the field name.
    @IBOutlet weak var fieldNameLabel: UILabel!

    /// A label for the field value.
    @IBOutlet weak var fieldValueLabel: UILabel!

    /// A `UISlider` for the user to choose a new value.
    @IBOutlet weak var fieldValueSlider: UISlider!

    /// Prepare the cell for reuse.
    public override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }

    /// IBAction for when the view changes the value.
    ///
    /// - Parameter sender: The slider that changed.
    @IBAction func intSliderValueChanged(_ sender: UISlider) {
        let delegateValue = delegate?.fieldValue
        var newValue = Int(round(sender.value))
        if let validDelegate = delegate {
            if let minimumValue = validDelegate.minimumValue, newValue < minimumValue {
                newValue = minimumValue
            }
            if let maximumValue = validDelegate.maximumValue, newValue > maximumValue {
                newValue = maximumValue
            }
        }

        if delegateValue == nil || delegateValue! != newValue {
            delegate?.viewDidUpdateValue(newValue: newValue)
        }
        if let validDelegate = delegate {
            let parsedValue = validDelegate.parseValue(forUserInput: String(newValue), withInsertionIndex: nil)
            fieldValueLabel.text = parsedValue.display
        } else {
            fieldValueLabel.text = String(newValue)
        }
    }

}
