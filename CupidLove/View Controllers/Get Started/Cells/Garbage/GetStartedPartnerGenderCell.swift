//
//  GetStartedPartnerGenderCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-13.
//

import UIKit

class GetStartedPartnerGenderCell: UITableViewCell {

    @IBOutlet var selectionButtons: [ThemeRoundedWhiteButton]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func selectionPressed(_ sender: UIButton) {
    }
    
}
