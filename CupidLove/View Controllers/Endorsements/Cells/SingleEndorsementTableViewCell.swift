//
//  SingleReviewTableViewCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-31.
//

import UIKit
import ExpandableLabel

class SingleEndorsementTableViewCell: UITableViewCell, ExpandableLabelDelegate {
    @IBOutlet weak var container: ThemeRoundedBackView!
    @IBOutlet weak var avatar: AvatarImage!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editButton: ThemeBlackButton!
    @IBOutlet weak var bodyLabel: ThemeExpandableLabel!
    
    private var expandAction: Action?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        container.roundCorners(style: .medium)
        editButton.isHidden = true
        bodyLabel.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(data: ReviewRecord, expandAction: Action?) {
        guard let userInfoDto = data.userInfoDto?.first else {
            nameLabel.text = nil
            avatar.config(user: nil)
            bodyLabel.text = nil
            return
        }
        
        nameLabel.text = userInfoDto.firstName
        avatar.config(user: userInfoDto)
        bodyLabel.text = data.content
        self.expandAction = expandAction
    }
    
    func willExpandLabel(_ label: ExpandableLabel) {
        
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        setNeedsLayout()
        expandAction?()
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        expandAction?()
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        setNeedsLayout()
    }
}
