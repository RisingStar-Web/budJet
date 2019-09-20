//
//  DateSectionHeader.swift
//  budJet
//
//  Created by neko on 30.09.17.
//  Copyright © 2017 Daniil Alferov. All rights reserved.
//

import UIKit

class DateSectionHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!

    func setDate(_ date: Date) -> String {
        let template = "MMMdd"
        let currentLocaleDateFormat = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: Locale.current)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = currentLocaleDateFormat
        return dateFormatter.string(from: date)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor(colorWithHexValue: 0xF6F6F6)
    }

    class func instanceFromNib() -> UIView {
        return UINib(nibName: "DateSectionHeader", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    /*
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context!.setStrokeColor(UIColor(white: 0.0, alpha: 0.4).cgColor)
        context!.setLineWidth(0.50)
        
        context!.move(to: CGPoint(x: 0.0, y: frame.size.height - 0.5))
        context!.addLine(to: CGPoint(x: self.frame.size.width, y: frame.size.height - 0.5))
        context!.strokePath()
    }
    */
}
