//
//  CalendarCell.swift
//  budJet
//
//  Created by neko on 06.10.17.
//  Copyright © 2017 Daniil Alferov. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarCell: JTAppleCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
