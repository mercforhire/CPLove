//
//  LockedLikesVIPCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-24.
//

import UIKit

class LockedLikesVIPCell: UICollectionViewCell {
    private let text = "You received [X] likes"
    
    @IBOutlet weak var containerView: ThemeRoundedBackView!
    @IBOutlet weak var titleLabel: ThemeBlackTextLabel!
    @IBOutlet weak var vipButton: ThemeRoundedBlueButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.text = text
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = text
    }

    func config(numberOfLikes: Int) {
        titleLabel.text = text.replacingOccurrences(of: "[X]", with: "\(numberOfLikes)")
    }
}
