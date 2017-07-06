//
//  CustomEmailTableViewCell.swift
//  WCFormsApp
//
//  Created by Will Clarke on 5/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit
import WCForms

class CustomEmailTableViewCell: UITableViewCell, WCGenericButtonCellDisplayable {

    // MARK: - Conformance to WCGenericButtonCellDisplayable

    /// The field name associated with this button field. Although this is an optional, it will always be set when the button field is being set up.
    var fieldNameText: String? = nil {
        didSet {
            fieldNameLabel.text = fieldNameText
        }
    }
    
    /// The field value associated with this field. If nil, it means the field is empty.
    var fieldValueText: String? = nil {
        didSet {
            fieldValueButton.setTitle(fieldValueText, for: .normal)
        }
    }
    
    /// The text to appear on the value button when it's disabled.
    var disabledFieldValueText: String? = nil {
        didSet {
            fieldValueButton.setTitle(disabledFieldValueText, for: .disabled)
        }
    }
    
    /// The color for the disabled state of the value button.
    var disabledFieldValueColor: UIColor? = nil {
        didSet {
            fieldValueButton.setTitleColor(disabledFieldValueColor, for: .disabled)
        }
    }
    
    /// Whether or not the value button should be enabled.
    var isValueButtonEnabled: Bool = true {
        didSet {
            fieldValueButton.isEnabled = isValueButtonEnabled
        }
    }
    
    /// A delegate that should be called when button actions occur.
    var buttonDelegate: WCButtonActionDelegate? = nil


    // MARK: - IB Outlets and actions

    @IBOutlet weak var fieldNameLabel: UILabel!

    @IBOutlet weak var fieldValueButton: UIButton!

    @IBAction func fieldValueButtonTapped(_ sender: Any) {
        buttonDelegate?.fieldValueButtonTapped()
    }


    // MARK: - View lifecycle functions

    override func prepareForReuse() {
        super.prepareForReuse()
        fieldValueButton.isEnabled = true
        fieldValueButton.setTitle(buttonDelegate?.emptyValueText, for: .disabled)
        fieldValueButton.setTitle("Field Value", for: .normal)
    }

}
