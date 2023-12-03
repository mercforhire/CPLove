//
//  EndorsementCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-31.
//

import UIKit

class EndorsementCell: UICollectionViewCell {
    @IBOutlet weak var container: ThemeRoundedBackView!
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bodyLabel: ThemeBlackTextLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        container.roundCorners(style: .medium)
    }

    func config(data: ReviewRecord) {
        nameLabel.text = data.userInfoDto?.first?.firstName
        avatar.config(user: data.userInfoDto?.first)
        bodyLabel.text = data.content
    }
}
