//
//  WCGenericFieldTableViewCell.swift
//  WCForms
//
//  Created by Will Clarke on 3/1/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import UIKit

public class WCGenericFieldNoLabelTableViewCell: UITableViewCell {

    @IBOutlet weak var valueLabel: UILabel!

}

public class WCGenericFieldTableViewCell: WCGenericFieldNoLabelTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!

}
