//
//  OptionFieldTypes.swift
//  WCFormsApp
//
//  Created by Will Clarke on 4/9/17.
//  Copyright © 2017 Will Clarke. All rights reserved.
//

import Foundation
import WCForms

struct Ringtone: OptionFieldItem {
    var name: String
    var isClassic: Bool = false
    
    init(name: String, isClassic: Bool = false) {
        self.name = name
        self.isClassic = isClassic
    }
    
    var localizedValue: String {
        return name
    }

    static var classicRingtones: [Ringtone] {
        let classicRingtoneNames = ["Alarm", "Blues", "Digital", "Duck", "Marimba", "Piano Riff"]
        var allClassicRingtones = [Ringtone]()
        for classicName in classicRingtoneNames {
            allClassicRingtones.append(Ringtone(name: classicName, isClassic: true))
        }
        return allClassicRingtones
    }

    static var defaultRingtones: [Ringtone] {
        let defaultRingtoneNames = ["Apex", "Beacon", "Chimes", "Crystals", "Illuminate", "Night Owl", "Radar", "Signal", "Summit", "Uplift"]
        var allDefaultRingtones = [Ringtone]()
        for defaultName in defaultRingtoneNames {
            allDefaultRingtones.append(Ringtone(name: defaultName))
        }
        return allDefaultRingtones
    }
}

enum RelationshipType: String, OptionFieldItem {
    
    case partner = "Partner/Spouse"
    case colleague = "Colleague"
    case friend = "Friend"
    case family = "Family Member"
    case acquaintance = "Acquaintance"
    case enemy = "Enemy"
    case other = "Other"
    
    var localizedAbbreviation: String {
        switch self {
        case.family:
            return "Family"
        case .partner:
            return "Partner"
        default:
            return rawValue
        }
    }
    
    var localizedValue: String {
        return rawValue
    }
    
    static var allValues: [RelationshipType] {
        return [.partner, .colleague, .friend, .family, .acquaintance, .enemy, .other]
    }
    
}

class OptionFieldController: WCFormController {

    var preferredAppearance = WCOptionFieldAppearance.default {
        didSet {
            for formSection in formModel.formSections {
                for case let optionField as WCOptionAppearanceSettable in formSection.formFields {
                    optionField.appearance = preferredAppearance
                }
            }
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func actionButtonTapped(_ sender: UIBarButtonItem) {
        let appearancePicker = UIAlertController(title: "Change Appearance",
                                                 message: "Choose the desired field appearance",
                                                 preferredStyle: .actionSheet)
        let stackedOption = UIAlertAction(title: "Stacked", style: .default) { (action: UIAlertAction) in
            self.preferredAppearance = .stacked
        }
        let stackedCaptionOption = UIAlertAction(title: "Stacked Caption", style: .default) { (action: UIAlertAction) in
            self.preferredAppearance = .stackedCaption
        }
        let rightDetailOption = UIAlertAction(title: "Right Detail", style: .default) { (action: UIAlertAction) in
            self.preferredAppearance = .rightDetail
        }
        let cancelOption = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        appearancePicker.addAction(stackedOption)
        appearancePicker.addAction(stackedCaptionOption)
        appearancePicker.addAction(rightDetailOption)
        appearancePicker.addAction(cancelOption)
        if let popoverController = appearancePicker.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        self.present(appearancePicker, animated: true, completion: nil)
    }

}
