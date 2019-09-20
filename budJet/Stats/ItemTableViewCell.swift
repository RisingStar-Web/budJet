//
//  ItemTableViewCell.swift
//  budJet
//
//  Created by neko on 30.09.17.
//  Copyright © 2017 Daniil Alferov. All rights reserved.
//

import UIKit
import SwipeCellKit

class ItemTableViewCell: SwipeTableViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var ammountLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    var item: Record! {
        didSet {
            categoryLabel.text = NSLocalizedString((item.typers?.key!)!, comment: "")
            
            ammountLabel.text = item.ammount.formattedWithSeparator
            if let comment = item.comment {
                infoLabel.text = comment
                infoLabel.isHidden = comment.isEmpty
            } else {
                infoLabel.text = ""
                infoLabel.isHidden = true
            }
            if let type = item.typers, let icon = type.key {
                iconImageView.image = UIImage(named: icon)
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()

        //contentView.backgroundColor = UIColor.white
        //backgroundColor = UIColor.white
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
