//
//  WCGenericFieldCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

/// A generic field with no field name label
public class WCGenericFieldCell: UITableViewCell {

    /// Outlet to the label for the field value
    @IBOutlet weak var valueLabel: UILabel!

}

/// A generic field with a title label
public class WCGenericFieldWithFieldNameCell: WCGenericFieldCell {

    /// The UILabel for the field name.
    @IBOutlet weak var fieldNameLabel: UILabel!

}
