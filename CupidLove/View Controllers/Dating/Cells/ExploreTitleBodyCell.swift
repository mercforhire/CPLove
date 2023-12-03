//
//  ExploreTitleBodyCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-23.
//

import UIKit

class ExploreTitleBodyCell: UITableViewCell {

    @IBOutlet weak var titleLabel: ThemeBlackTextLabel!
    @IBOutlet weak var paragraphLabel: ThemeBlackTextLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(title: String, body: String) {
        titleLabel.text = title
        paragraphLabel.text = body
    }
}
