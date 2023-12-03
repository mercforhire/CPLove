//
//  CupidBecomeVIPCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-25.
//

import UIKit

class CupidBecomeVIPCell: UITableViewCell {

    @IBOutlet weak var upgradeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        upgradeButton.roundCorners(style: .completely)
        upgradeButton.setTitleColor(themeManager.themeData!.blue.hexColor, for: .normal)
        upgradeButton.backgroundColor = .white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
