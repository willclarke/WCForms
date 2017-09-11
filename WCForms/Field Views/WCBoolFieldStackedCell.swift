//
//  WCBoolFieldStackedCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/2/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

/// A table view cell for an editable boolean field with the `stacked` appearance.
internal class WCBoolFieldStackedCell: WCBoolFieldCell {

    /// The label displaying the off label.
    @IBOutlet weak var offDisplayValueLabel: UILabel!

    /// The label displaying the on label.
    @IBOutlet weak var onDisplayValueLabel: UILabel!

    /// A stack view containing the bool labels
    @IBOutlet weak var boolLabelStackView: UIStackView!

    /// A proportional width constraint between the on and off display value labels
    private var proportionalWidthConstraint: NSLayoutConstraint? = nil {
        didSet {
            if let oldConstraint = oldValue {
                //remove the old proportional constraint from the view
                boolLabelStackView.removeConstraint(oldConstraint)
            }
            if let newConstraint = proportionalWidthConstraint {
                boolLabelStackView.addConstraint(newConstraint)
            }
        }
    }

    /// A trailing constraint between the stack view and the cell `contentView`
    private var stackViewTrailingConstraint: NSLayoutConstraint? = nil {
        didSet {
            if let oldConstraint = oldValue {
                //remove the old constraint from the view
                contentView.removeConstraint(oldConstraint)
            }
            if let newConstraint = stackViewTrailingConstraint {
                contentView.addConstraint(newConstraint)
            }
        }
    }

    private var offLabelWidthConstraint: NSLayoutConstraint? = nil {
        didSet {
            if let oldConstraint = oldValue {
                //remove the old constraint from the view
                offDisplayValueLabel.removeConstraint(oldConstraint)
            }
            if let newConstraint = offLabelWidthConstraint {
                offDisplayValueLabel.addConstraint(newConstraint)
            }
        }
    }

    private var onLabelWidthConstraint: NSLayoutConstraint? = nil {
        didSet {
            if let oldConstraint = oldValue {
                //remove the old constraint from the view
                onDisplayValueLabel.removeConstraint(oldConstraint)
            }
            if let newConstraint = onLabelWidthConstraint {
                onDisplayValueLabel.addConstraint(newConstraint)
            }
        }
    }

    /// IBAction for when the switch value changes.
    ///
    /// - Parameter sender: The switch that changed.
    @IBAction override func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            onDisplayValueLabel.textColor = offDisplayValueLabel.textColor
            offDisplayValueLabel.textColor = UIColor.lightGray
        } else {
            offDisplayValueLabel.textColor = onDisplayValueLabel.textColor
            onDisplayValueLabel.textColor = UIColor.lightGray
        }
        delegate?.viewDidUpdateValue(newValue: sender.isOn)
    }

    internal func updateStackViewConstraints() {
        let preferredOnLabelSize = onDisplayValueLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude,
                                                                           height: CGFloat.greatestFiniteMagnitude))
        let preferredOffLabelSize = offDisplayValueLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude,
                                                                             height: CGFloat.greatestFiniteMagnitude))
        let preferredTotalLabelWidth = preferredOnLabelSize.width + preferredOffLabelSize.width
        let leftRightMarginSpace = contentView.layoutMargins.left + contentView.layoutMargins.right
        let availableStackSpace = contentView.frame.width - leftRightMarginSpace - boolLabelStackView.spacing - 16.0
        let maxFieldMultiplier: CGFloat = 0.35
        if preferredTotalLabelWidth <= availableStackSpace {
            //The labels can both fit on one line
            proportionalWidthConstraint = nil
            stackViewTrailingConstraint = nil
            onLabelWidthConstraint = nil
            offLabelWidthConstraint = nil
            offDisplayValueLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
            onDisplayValueLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
            boolLabelStackView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        } else {
            boolLabelStackView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: .horizontal)
            if preferredOffLabelSize.width <= (maxFieldMultiplier * availableStackSpace) {
                onLabelWidthConstraint = nil
                proportionalWidthConstraint = nil
                offDisplayValueLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
                onDisplayValueLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: .horizontal)
                offLabelWidthConstraint = NSLayoutConstraint(item: offDisplayValueLabel,
                                                             attribute: .width,
                                                             relatedBy: .equal,
                                                             toItem: nil,
                                                             attribute: .notAnAttribute,
                                                             multiplier: 1.0,
                                                             constant: preferredOffLabelSize.width)
            } else if preferredOnLabelSize.width <= (maxFieldMultiplier * availableStackSpace) {
                offLabelWidthConstraint = nil
                proportionalWidthConstraint = nil
                offDisplayValueLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: .horizontal)
                onDisplayValueLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
                onLabelWidthConstraint = NSLayoutConstraint(item: onDisplayValueLabel,
                                                             attribute: .width,
                                                             relatedBy: .equal,
                                                             toItem: nil,
                                                             attribute: .notAnAttribute,
                                                             multiplier: 1.0,
                                                             constant: preferredOnLabelSize.width)
            } else {
                onLabelWidthConstraint = nil
                offLabelWidthConstraint = nil
                offDisplayValueLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: .horizontal)
                onDisplayValueLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: .horizontal)
                let onLabelArea = preferredOnLabelSize.height * preferredOnLabelSize.width
                let offLabelArea = preferredOffLabelSize.height * preferredOffLabelSize.width
                let onToOffLabelMultiplier = max(min(onLabelArea / offLabelArea, 1 / maxFieldMultiplier), maxFieldMultiplier)
                proportionalWidthConstraint = NSLayoutConstraint(item: onDisplayValueLabel,
                                                                 attribute: .width,
                                                                 relatedBy: .equal,
                                                                 toItem: offDisplayValueLabel,
                                                                 attribute: .width,
                                                                 multiplier: onToOffLabelMultiplier,
                                                                 constant: 0.0)
            }
            stackViewTrailingConstraint = NSLayoutConstraint(item: contentView,
                                                             attribute: .trailingMargin,
                                                             relatedBy: .equal,
                                                             toItem: boolLabelStackView,
                                                             attribute: .trailing,
                                                             multiplier: 1.0,
                                                             constant: 8.0)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateStackViewConstraints()
    }
}
