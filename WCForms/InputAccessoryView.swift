//
//  InputAccessoryView.swift
//  WCForms
//
//  Created by Will Clarke on 3/8/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

/// An accessory view for text fields that can navigate between previous and next fields, and dismiss the keyboard. The accessory view uses a UIToolbar and
/// UIBarButtonItems.
public class InputAccessoryView: UIView {

    public override func awakeFromNib() {
        super.awakeFromNib()
        if let appDelegate = UIApplication.shared.delegate, let mainWindow = appDelegate.window as? UIWindow {
            self.tintColor = mainWindow.tintColor
        }
    }

    /// Outlet to the previous button.
    @IBOutlet weak var previousButton: UIBarButtonItem!

    /// Outlet to the next button.
    @IBOutlet weak var nextButton: UIBarButtonItem!

    /// Outlet to the done button.
    @IBOutlet weak var doneButton: UIBarButtonItem!

    /// Delegate that is used to handle user interaction.
    weak var fieldDelegate: WCInputField?

    /// IBAction for when the previous button is tapped.
    ///
    /// - Parameter sender: the previous button that was tapped.
    @IBAction func previousButtonTapped(_ sender: Any) {
        fieldDelegate?.makePreviousVisibleResponderFirstResponder()
    }

    /// IBAction for when the next button is tapped.
    ///
    /// - Parameter sender: the next button that was tapped.
    @IBAction func nextButtonTapped(_ sender: Any) {
        fieldDelegate?.makeNextVisibleResponderFirstResponder()
    }

    /// IBAction for when the done button is tapped.
    ///
    /// - Parameter sender: the done button that was tapped.
    @IBAction func doneButtonTapped(_ sender: Any) {
        fieldDelegate?.resignFirstResponder()
    }

}
