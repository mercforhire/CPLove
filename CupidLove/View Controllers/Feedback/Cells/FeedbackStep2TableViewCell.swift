//
//  FeedbackStep2TableViewCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-02.
//

import UIKit

class FeedbackStep2TableViewCell: UITableViewCell {

    @IBOutlet weak var textField: ThemeRoundedBorderedTextView!
    @IBOutlet weak var submitButton: ThemeRoundedPinkButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
