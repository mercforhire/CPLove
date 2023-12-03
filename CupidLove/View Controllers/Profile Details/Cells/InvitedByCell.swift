//
//  InvitedByCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-24.
//

import UIKit

class InvitedByCell: UICollectionViewCell {
    @IBOutlet weak var topLabel: ThemeBlackTextLabel!
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func config(user: InvitedByUserInfo) {
        avatar.config(user: user)
        nameLabel.text = user.firstName
    }
}
