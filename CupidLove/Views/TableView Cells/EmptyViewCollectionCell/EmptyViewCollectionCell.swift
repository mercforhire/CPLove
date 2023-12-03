//
//  EmptyViewCollectionCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-03-13.
//

import UIKit

class EmptyViewCollectionCell: UICollectionViewCell {
    @IBOutlet private var iconView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func config(style: EmptyViewStyle) {
        iconView.image = UIImage(named: style.imageName())
        titleLabel.text = style.title()
    }
}
