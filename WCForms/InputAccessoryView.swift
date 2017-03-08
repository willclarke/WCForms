//
//  InputAccessoryView.swift
//  WCForms
//
//  Created by Will Clarke on 3/8/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

public class InputAccessoryView: UIView {

    @IBOutlet weak var previousButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    weak var fieldDelegate: WCInputField?

    @IBAction func previousButtonTapped(_ sender: Any) {
        fieldDelegate?.previousInputAccessoryButtonTapped(sender)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        fieldDelegate?.nextInputAccessoryButtonTapped(sender)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        fieldDelegate?.doneInputAccessoryButtonTapped(sender)
    }
    
}
