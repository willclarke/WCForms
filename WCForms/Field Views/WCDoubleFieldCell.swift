//
//  WCDoubleFieldCell.swift
//  WCForms
//
//  Created by Will Clarke on 7/18/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

protocol WCTextEntryPrefixingAndSuffixing: class {

    /// A label that displays a prefix for a field.
    var prefixText: String? { get set }

    /// A label that displays a suffix for a field.
    var suffixText: String? { get set }

}

class WCDoubleFieldCell: WCGenericTextFieldAndLabelCell, WCTextEntryPrefixingAndSuffixing {

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
