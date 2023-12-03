//
//  BlackListCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-25.
//

import UIKit

class BlackListCell: UITableViewCell {
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var nameLabel: ThemeBlackTextLabel!
    @IBOutlet weak var infoLabel: ThemeBlackTextLabel!
    @IBOutlet weak var unblock: ThemeBlackBgWhiteTextButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(user: UserQuery) {
        avatar.config(user: user)
        nameLabel.text = user.firstName
        infoLabel.text = user.jobTitle
        UIView.performWithoutAnimation {
            self.unblock.setTitle("Unblock", for: .normal)
            self.layoutIfNeeded()
        }
    }
}
