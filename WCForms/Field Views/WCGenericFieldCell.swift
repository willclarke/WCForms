//
//  WCGenericFieldCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

/// A generic field with no field name label
internal class WCGenericFieldCell: UITableViewCell {

    /// Outlet to the label for the field value
    @IBOutlet weak var valueLabel: UILabel!

    internal var valueLabelText: String? {
        get {
            return valueLabel.text
        }
        set {
            valueLabel.text = newValue
            textDidChange()
        }
    }

    internal var valueLabelColor: UIColor {
        get {
            return valueLabel.textColor
        }
        set {
            valueLabel.textColor = newValue
        }
    }

    fileprivate func textDidChange() {
        return
    }
}

/// A generic field with a title label
internal class WCGenericFieldWithFieldNameCell: WCGenericFieldCell {

    /// The UILabel for the field name.
    @IBOutlet weak var fieldNameLabel: UILabel!

    internal var fieldNameLabelText: String? {
        get {
            return fieldNameLabel.text
        }
        set {
            fieldNameLabel.text = newValue
            textDidChange()
        }
    }

    internal var fieldNameLabelColor: UIColor {
        get {
            return fieldNameLabel.textColor
        }
        set {
            fieldNameLabel.textColor = newValue
        }
    }

}

internal protocol LabelBalancingStackViewCell: class {
    
    var proportionalWidthConstraint: NSLayoutConstraint? { get set }
    var fieldNameMinimumWidthConstraint: NSLayoutConstraint? { get set }
    var fieldValueMinimumWidthConstraint: NSLayoutConstraint? { get set }
    
    weak var fieldNameAndValueStackView: UIStackView! { get }
    weak var fieldNameLabel: UILabel! { get }
    weak var valueView: UIView! { get }
    var contentView: UIView { get }
    
    var stackViewMarginSpacing: CGFloat { get }
    var minimumLabelWidth: CGFloat { get }
    var valueIsEmpty: Bool { get }
    
}

extension LabelBalancingStackViewCell {
    
    func clearLabelWidthConstraints() {
        if let proportionalWidthConstraint = proportionalWidthConstraint {
            fieldNameAndValueStackView.removeConstraint(proportionalWidthConstraint)
        }
        if let fieldNameMinimumWidthConstraint = fieldNameMinimumWidthConstraint {
            fieldNameLabel.removeConstraint(fieldNameMinimumWidthConstraint)
        }
        if let fieldValueMinimumWidthConstraint = fieldValueMinimumWidthConstraint {
            valueView.removeConstraint(fieldValueMinimumWidthConstraint)
        }
    }
    
    func updateLabelWidthConstraints() {
        guard fieldNameLabel.text != nil && !valueIsEmpty else {
            clearLabelWidthConstraints()
            return //we don't need constraints if the one of the labels is empty
        }
        let preferredFieldNameSize = fieldNameLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude,
                                                                        height: CGFloat.greatestFiniteMagnitude))
        let preferredFieldValueSize = valueView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude,
                                                                    height: CGFloat.greatestFiniteMagnitude))
        let availableStackSpace = contentView.frame.size.width - contentView.layoutMargins.left - contentView.layoutMargins.right
            - fieldNameAndValueStackView.spacing - stackViewMarginSpacing
        guard preferredFieldNameSize.width + preferredFieldValueSize.width > availableStackSpace else {
            // there is enough room for both the value and name to be on one line
            clearLabelWidthConstraints()
            return
        }
        
        let newMinimumFieldNameWidthConstraint = NSLayoutConstraint(item: fieldNameLabel,
                                                                    attribute: .width,
                                                                    relatedBy: .greaterThanOrEqual,
                                                                    toItem: nil,
                                                                    attribute: .notAnAttribute,
                                                                    multiplier: 1.0,
                                                                    constant: min(minimumLabelWidth, preferredFieldNameSize.width))
        
        let newMinimumFieldValueWidthConstraint = NSLayoutConstraint(item: valueView,
                                                                     attribute: .width,
                                                                     relatedBy: .greaterThanOrEqual,
                                                                     toItem: nil,
                                                                     attribute: .notAnAttribute,
                                                                     multiplier: 1.0,
                                                                     constant: min(minimumLabelWidth, preferredFieldValueSize.width))
        
        let fieldNameArea = preferredFieldNameSize.width * preferredFieldNameSize.height
        let fieldValueArea = preferredFieldValueSize.width * preferredFieldValueSize.height
        let maxFieldMultiplier: CGFloat = 0.35
        let fieldNameToValueMultiplier = max(min(fieldNameArea / fieldValueArea, 1 / maxFieldMultiplier), maxFieldMultiplier)
        let newProportionalConstraint = NSLayoutConstraint(item: fieldNameLabel,
                                                           attribute: .width,
                                                           relatedBy: .equal,
                                                           toItem: valueView,
                                                           attribute: .width,
                                                           multiplier: fieldNameToValueMultiplier,
                                                           constant: 0.0)
        newProportionalConstraint.priority = 999 // We want the minimum width constraints to override this
        
        clearLabelWidthConstraints()
        
        fieldNameLabel.addConstraint(newMinimumFieldNameWidthConstraint)
        valueView.addConstraint(newMinimumFieldValueWidthConstraint)
        fieldNameAndValueStackView.addConstraint(newProportionalConstraint)
        
        fieldNameMinimumWidthConstraint = newMinimumFieldNameWidthConstraint
        fieldValueMinimumWidthConstraint = newMinimumFieldValueWidthConstraint
        proportionalWidthConstraint = newProportionalConstraint
    }
    
}

internal class WCGenericFieldRightDetailCell: WCGenericFieldWithFieldNameCell, LabelBalancingStackViewCell {

    @IBOutlet weak var fieldNameAndValueStackView: UIStackView!

    var proportionalWidthConstraint: NSLayoutConstraint? = nil
    var fieldNameMinimumWidthConstraint: NSLayoutConstraint? = nil
    var fieldValueMinimumWidthConstraint: NSLayoutConstraint? = nil

    var valueView: UIView! {
        return valueLabel
    }
    var valueIsEmpty: Bool {
        return valueLabel.text == nil || valueLabel.text == ""
    }

    let minimumLabelWidth: CGFloat = 90.0
    let stackViewMarginSpacing: CGFloat = 16.0

    override func prepareForReuse() {
        super.prepareForReuse()
        clearLabelWidthConstraints()
        fieldNameAndValueStackView.alignment = .firstBaseline
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func textDidChange() {
        super.textDidChange()
        updateLabelWidthConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLabelWidthConstraints()
    }

}
