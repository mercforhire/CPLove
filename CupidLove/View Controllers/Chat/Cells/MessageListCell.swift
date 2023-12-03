//
//  MessageListCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-03.
//

import UIKit
import BadgeSwift

class MessageListCell: UITableViewCell {
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var matchIcon: ThemePinkImageView!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var badge: BadgeSwift!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.text = ""
        bodyLabel.text = ""
        timeLabel.text = ""
        badge.text = ""
        badge.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatar.clearImage()
        titleLabel.text = ""
        bodyLabel.text = ""
        timeLabel.text = ""
        badge.text = ""
        badge.isHidden = true
    }

    func config(data: Conversation) {
        avatar.config(user: data.targetUserInfo)
        matchIcon.isHidden = !(data.isLikeEachOther ?? false)
        titleLabel.text = data.targetUserInfo?.firstName
        bodyLabel.text = data.latestChatMessage?.content
        
        if let timeStamp = data.latestChatMessage?.timeStamp {
            timeLabel.text = timeAgoSince(timeStamp)
        } else {
            timeLabel.text = ""
        }
        
        let unreadMessages = data.totalUnread
        badge.text = "\(unreadMessages ?? 0)"
        badge.isHidden = unreadMessages == 0
    }
}
