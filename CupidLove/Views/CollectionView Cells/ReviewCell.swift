//
//  ReviewCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-24.
//

import UIKit
import Cosmos

class ReviewCell: UICollectionViewCell {
    @IBOutlet weak var container: ThemeRoundedBackView!
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var bodyLabel: ThemeBlackTextLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        container.roundCorners(style: .medium)
    }

    func config(data: ReviewRecord) {
        nameLabel.text = data.userInfoDto?.first?.firstName
        avatar.config(user: data.userInfoDto?.first)
        ratingView.rating = Double(data.rating ?? 0)
        bodyLabel.text = data.content
    }
}
