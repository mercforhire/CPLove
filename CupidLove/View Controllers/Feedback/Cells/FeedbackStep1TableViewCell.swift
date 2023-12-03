//
//  FeedbackStep1TableViewCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-02.
//

import UIKit

class FeedbackStep1TableViewCell: UITableViewCell {

    @IBOutlet weak var positiveButton: ThemeRoundedPinkButton!
    @IBOutlet weak var negativeButton: ThemeRoundedBlueButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
