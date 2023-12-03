//
//  OptionRowTableViewCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-26.
//

import UIKit

class OptionRowTableViewCell: UITableViewCell {

    @IBOutlet weak var label: ThemeBlackTextLabel!
    @IBOutlet weak var rightArrow: ThemeBlackImageView!
    @IBOutlet weak var divider: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
