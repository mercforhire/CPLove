//
//  ButtonTabsTableCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-24.
//

import UIKit

class ButtonTabsTableCell: UITableViewCell {
    @IBOutlet var buttons: [ThemeBlackButton]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
