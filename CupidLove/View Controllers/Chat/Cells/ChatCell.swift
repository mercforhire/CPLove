//
//  ChatCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-03.
//

import UIKit

class ChatCell: UITableViewCell {
    
    @IBOutlet weak var messageContainer: UIView!
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var button: RoundedButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        buttonContainer.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(data: ChatMsg, speaker: UserQuery, clickToOpenProfile: Bool) {
        avatar.config(user: speaker, clickToOpenProfile: clickToOpenProfile)
        messageLabel.text = data.content
        
        if data.isFunction, data.functionType == "REVIEW" {
            buttonContainer.isHidden = false
        } else {
            buttonContainer.isHidden = true
        }
        
        if let dateStamp = data.timeStamp {
            timeLabel.text = timeAgoSince(dateStamp)
        } else {
            timeLabel.text = ""
        }
    }
}
