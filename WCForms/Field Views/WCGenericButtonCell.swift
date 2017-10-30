//
//  WCGenericButtonCell.swift
//  WCForms
//
//  Created by Will Clarke on 4/29/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

/// A delegate for a button field.
public protocol WCButtonActionDelegate: class {

    /// The text to appear on the field when no value has been set.
    var emptyValueText: String { get }

    /// Sent action when the field value button is tapped.
    func fieldValueButtonTapped()

}

/// A protocol for any field view that can display a button for a field.
public protocol WCGenericButtonCellDisplayable: class {

    /// The field name associated with this button field. Although this is an optional, it will always be set when the button field is being set up.
    var fieldNameText: String? { get set }

    /// The field value associated with this field. If nil, it means the field is empty.
    var fieldValueText: String? { get set }

    /// The text to appear on the value button when it's disabled.
    var disabledFieldValueText: String? { get set }

    /// The color for the disabled state of the value button.
    var disabledFieldValueColor: UIColor? { get set }

    /// Whether or not the value button should be enabled.
    var isValueButtonEnabled: Bool { get set }

    /// A delegate that should be called when button actions occur.
    var buttonDelegate: WCButtonActionDelegate? { get set }

}

/// A table view cell for a generic button field.
class WCGenericButtonCell: UITableViewCell, WCGenericButtonCellDisplayable {

    // MARK: - Internal variables

    /// The text to appear on the field when no value has been set.
    let emptyValueText = NSLocalizedString("None", tableName: "WCForms", comment: "Displayed when there is no value for a field")


    // MARK: - Public accessors for view elements; conformance to WCGenericButtonCellDisplayable

    /// The text that should be set for the field name.
    var fieldNameText: String? {
        get {
            return fieldValueButton.title(for: .disabled)
        }
        set {
            fieldValueButton.setTitle(newValue, for: .disabled)
        }
    }

    /// The text that should be set for the field value.
    var fieldValueText: String? {
        get {
            return fieldValueButton.title(for: .normal)
        }
        set {
            if let newTitle = newValue {
                fieldValueButton.setTitle(newTitle, for: .normal)
                fieldValueButton.isEnabled = true
            } else {
                let fieldValueText = buttonDelegate?.emptyValueText ?? emptyValueText
                fieldValueButton.setTitle(fieldValueText, for: .normal)
                fieldValueButton.isEnabled = false
            }
        }
    }

    /// The text to appear on the value button when it's disabled.
    var disabledFieldValueText: String? {
        get {
            return fieldValueButton.title(for: .disabled)
        }
        set {
            fieldValueButton.setTitle(newValue, for: .disabled)
        }
    }

    /// The color for the disabled state of the value button.
    var disabledFieldValueColor: UIColor? {
        get {
            return fieldValueButton.titleColor(for: .disabled)
        }
        set {
            fieldValueButton.setTitleColor(newValue, for: .disabled)
        }
    }

    /// Whether or not the value button should be enabled.
    var isValueButtonEnabled: Bool = true {
        didSet {
            fieldValueButton.isEnabled = isValueButtonEnabled
        }
    }

    /// The delegate that should be called when actions are performed on the button.
    var buttonDelegate: WCButtonActionDelegate? = nil


    // MARK: - IBOutlets

    @IBOutlet fileprivate weak var fieldValueButton: UIButton!
    
    @IBAction func fieldValueButtonTapped(_ sender: Any) {
        buttonDelegate?.fieldValueButtonTapped()
    }


    // MARK: - View lifecycle functions

    override func prepareForReuse() {
        super.prepareForReuse()
        fieldValueButton.isEnabled = true
    }

}

/// A button field that contains a field name and value, stacked on top of each other.
class WCGenericButtonStackedCell: WCGenericButtonCell {

    // MARK: - Public accessors for view elements; conformance to WCGenericButtonCellDisplayable

    override var fieldNameText: String? {
        get {
            return fieldNameLabel.text
        }
        set {
            fieldNameLabel.text = newValue
        }
    }


    // MARK: - IBOutlets

    @IBOutlet private weak var fieldNameLabel: UILabel!

}

/// A button field with the field value to the right of the field name.
class WCGenericButtonRightDetailCell: WCGenericButtonCell {

    // MARK: - Public accessors for view elements; conformance to WCGenericButtonCellDisplayable

    override var fieldNameText: String? {
        get {
            return fieldNameLabel.text
        }
        set {
            fieldNameLabel.text = newValue
        }
    }

    // MARK: - IBOutlets

    @IBOutlet internal weak var fieldNameLabel: UILabel!

}
