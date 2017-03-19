//
//  WCIntFieldCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

/// A table view cell for an editable integer field.
internal class WCIntFieldCell: WCGenericTextFieldAndLabelCell {

    /// A delegate to handle actions when the field changes.
    weak var delegate: WCIntField? = nil

    /// Prepare the cell for reuse.
    public override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }

    /// IBAction for when an int field changes.
    ///
    /// - Parameter sender: The text field that changed.
    @IBAction func intTextFieldEditingChanged(_ sender: UITextField) {
        if let delegate = delegate, let userInput = sender.text {
            let delegateValue = delegate.fieldValue
            var insertionIndex: String.Index? = nil
            if let validRange = sender.selectedTextRange {
                let offset = sender.offset(from: sender.beginningOfDocument, to: validRange.end)
                insertionIndex = userInput.index(userInput.startIndex, offsetBy: offset)
            }
            let parsedValue = delegate.parseValue(forUserInput: userInput, withInsertionIndex: insertionIndex)
            if delegateValue != parsedValue.value {
                delegate.viewDidUpdateValue(newValue: parsedValue.value)
            }
            fieldValueTextField.text = parsedValue.display
            if let newInsertionIndex = parsedValue.newInsertionIndex {
                let newOffset = parsedValue.display.distance(from: parsedValue.display.startIndex, to: newInsertionIndex)
                if let newTextPosition = sender.position(from: sender.beginningOfDocument, offset: newOffset) {
                    let newTextRange = sender.textRange(from: newTextPosition, to: newTextPosition)
                    fieldValueTextField.selectedTextRange = newTextRange
                } else {
                    fieldValueTextField.selectedTextRange = nil
                }
            } else {
                fieldValueTextField.selectedTextRange = nil
            }
        }
    }

//    /// Text field delegate function for when characters change, to make sure prohibited characters aren't entered through something like an external keyboard.
//    ///
//    /// - Parameters:
//    ///   - textField: The text field that was edited.
//    ///   - range: The range of characters that was changed.
//    ///   - string: the new characters that are being added
//    /// - Returns: `false` if the characters being added are in the array of prohibited characters, `true` otherwise.
//    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if string.rangeOfCharacter(from: prohibitedCharacters) == nil {
//            return true
//        } else {
//            return false
//        }
//    }

}
