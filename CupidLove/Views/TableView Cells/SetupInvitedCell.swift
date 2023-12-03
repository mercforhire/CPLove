//
//  SetupInvitedCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-05.
//

import UIKit

class SetupInvitedCell: UITableViewCell {
    static let text = "You are invited by your friend [X]! \nLet's set up your profile and start connecting."
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var bodyLabel: ThemeBlackTextLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(user: UserQuery) {
        avatar.config(user: user, rounded: true)
        bodyLabel.text = SetupInvitedCell.text.replacingOccurrences(of: "[X]", with: user.firstName ?? "")
    }
}
