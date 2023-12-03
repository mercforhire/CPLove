//
//  InviteCodeTableViewCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-12.
//

import UIKit

class InviteCodeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var codeField: ThemeBorderTextField!
    @IBOutlet weak var copyButton: ThemePinkButton!
    
    @IBOutlet weak var emailButton: ThemeRoundedPinkButton!
    @IBOutlet weak var smsButton: ThemeRoundedPinkButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        copyButton.roundCorners(style: .small)
        codeField.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
