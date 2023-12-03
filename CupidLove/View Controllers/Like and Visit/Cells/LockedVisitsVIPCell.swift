//
//  LockedVisitsVIPCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-24.
//

import UIKit

class LockedVisitsVIPCell: UICollectionViewCell {
    private let text = "You received [X] visits"
    
    @IBOutlet weak var containerView: ThemeRoundedBackView!
    @IBOutlet weak var titleLabel: ThemeBlackTextLabel!
    @IBOutlet weak var vipButton: ThemeRoundedBlueButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = text
    }

    func config(numberOfVisits: Int) {
        titleLabel.text = text.replacingOccurrences(of: "[X]", with: "\(numberOfVisits)")
    }
}
