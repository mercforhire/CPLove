//
//  EmptyViewCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-03-13.
//

import UIKit

class EmptyViewCell: UITableViewCell {
    @IBOutlet private var iconView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(style: EmptyViewStyle) {
        iconView.image = UIImage(named: style.imageName())
        titleLabel.text = style.title()
    }
}
