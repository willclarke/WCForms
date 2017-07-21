//
//  WCCurrencyFieldCell.swift
//  WCForms
//
//  Created by Will Clarke on 7/20/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

class WCCurrencyFieldCell: WCGenericTextFieldAndLabelCell {

    internal var currencyFormatter: NumberFormatter! {
        didSet {
            guard oldValue != nil else {
                return
            }
            if !fieldValueTextField.isFirstResponder, let oldText = fieldValueTextField.text, let valueNumber = oldValue.number(from: oldText) {
                fieldValueTextField.text = currencyFormatter.string(from: valueNumber)
            }
        }
    }

    weak var currencyFieldDelegate: WCCurrencyFieldInputDelegate? = nil

    // MARK: - UITextFieldDelegate functions

    func textFieldDidBeginEditing(_ textField: UITextField) {
        let startingText = textField.text ?? ""
        if let insertionPoint = startingInsertionPoint(for: startingText, in: textField) {
            textField.selectedTextRange = insertionPoint
        }
    }

    func startingInsertionPoint(for text: String, in textField: UITextField) -> UITextRange? {
        if currencyFormatter.maximumFractionDigits == 0 {
            guard let lastNumber = text.rangeOfCharacter(from: CharacterSet.decimalDigits, options: String.CompareOptions.backwards) else {
                return nil
            }
            let lastNumberOffset = text.distance(from: text.startIndex, to: lastNumber.upperBound)
            guard let insertionPostition = textField.position(from: textField.beginningOfDocument, offset: lastNumberOffset) else {
                return nil
            }
            return textField.textRange(from: insertionPostition, to: insertionPostition)
        } else {
            guard let decimalSeparator = currencyFormatter.locale.decimalSeparator,
                let decimalPosition = text.range(of: decimalSeparator) else
            {
                return nil
            }
            let decimalOffset = text.distance(from: text.startIndex, to: decimalPosition.lowerBound)
            guard let insertionPostition = textField.position(from: textField.beginningOfDocument, offset: decimalOffset) else {
                return nil
            }
            return textField.textRange(from: insertionPostition, to: insertionPostition)
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else {
            return true
        }
        let newText = NSString(string: currentText).replacingCharacters(in: range, with: string)
        if let newNumber = currencyFormatter.number(from: newText) {
            currencyFieldDelegate?.viewDidUpdateCurrencyValue(with: newNumber.doubleValue)
            return true
        } else {
            // it wasn't formatted properly, try to make a number out of just the numbers in the string
            if let currencySymbol = currencyFormatter.locale.currencySymbol {
                var currencySymbolSet = CharacterSet.whitespaces
                currencySymbolSet.insert(charactersIn: currencySymbol + currencyFormatter.currencyDecimalSeparator + currencyFormatter.currencyGroupingSeparator)
                if newText.trimmingCharacters(in: currencySymbolSet).isEmpty {
                    //they have deleted all the numbers, so clear out the field
                    textField.text = nil
                    currencyFieldDelegate?.viewDidUpdateCurrencyValue(with: nil)
                    return false
                }
            }
            var prohibitedCharacters = CharacterSet.decimalDigits.inverted
            if let decimalSeparator = currencyFormatter.locale.decimalSeparator {
                prohibitedCharacters.subtract(CharacterSet(charactersIn: decimalSeparator))
            }
            let strippedText = newText.components(separatedBy: prohibitedCharacters).joined(separator: "")
            if let validStrippedDouble = Double(strippedText),
                let newFormattedString = currencyFormatter.string(from: NSNumber(floatLiteral: validStrippedDouble))
            {
                textField.text = newFormattedString
                currencyFieldDelegate?.viewDidUpdateCurrencyValue(with: currencyFormatter.number(from: newFormattedString)?.doubleValue)
                if let insertionPoint = startingInsertionPoint(for: newFormattedString, in: textField) {
                    textField.selectedTextRange = insertionPoint
                }
            }
            return false
        }
    }

    override func textFieldDidEndEditing(_ textField: UITextField) {
        guard let endingText = textField.text else {
            currencyFieldDelegate?.viewDidUpdateCurrencyValue(with: nil)
            return
        }
        if let newNumber = currencyFormatter.number(from: endingText) {
            if let formattedText = currencyFormatter.string(from: newNumber) {
                textField.text = formattedText
                currencyFieldDelegate?.viewDidUpdateCurrencyValue(with: currencyFormatter.number(from: formattedText)?.doubleValue)
            } else {
                textField.text = nil
                currencyFieldDelegate?.viewDidUpdateCurrencyValue(with: nil)
            }
        } else {
            textField.text = nil
            currencyFieldDelegate?.viewDidUpdateCurrencyValue(with: nil)
        }
    }

}
