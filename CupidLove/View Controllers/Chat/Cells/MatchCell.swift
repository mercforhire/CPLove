//
//  MatchCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-03.
//

import UIKit

class MatchCell: UITableViewCell {
    static let CellText = "You and [X] liked each other, start chatting now."
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var myself: AvatarImage!
    @IBOutlet weak var match: AvatarImage!
    @IBOutlet weak var label: ThemeGreyTextLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        container.addShadow(style: .small)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(myself: MyUserInfo, match: UserQuery) {
        self.myself.config(user: myself, rounded: true)
        self.match.config(user: match, rounded: true)
        label.text = MatchCell.CellText.replacingOccurrences(of: "[X]", with: match.firstName ?? "")
    }
}
