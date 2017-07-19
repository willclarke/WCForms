//
//  WCIntFieldCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

/// A table view cell for an editable integer field.
internal class WCIntFieldCell: WCGenericTextFieldAndLabelCell, WCTextEntryPrefixingAndSuffixing {

    // MARK: - IBOutlets

    @IBOutlet weak var prefixLabel: UILabel!
    @IBOutlet weak var suffixLabel: UILabel!

    // MARK: - Conformance to WCTextEntryPrefixingAndSuffixing

    var prefixText: String? {
        get {
            return prefixLabel.text
        }
        set {
            prefixLabel.text = newValue
            prefixLabel.isHidden = (newValue == nil)
        }
    }

    var suffixText: String? {
        get {
            return suffixLabel.text
        }
        set {
            suffixLabel.text = newValue
            suffixLabel.isHidden = (newValue == nil)
        }
    }

    // MARK: - View lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        prefixLabel.text = nil
        prefixLabel.isHidden = true
        suffixLabel.text = nil
        suffixLabel.isHidden = true
    }

}
