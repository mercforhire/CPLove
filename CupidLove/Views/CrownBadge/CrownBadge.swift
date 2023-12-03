//
//  CrownBadge.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-03.
//

import UIKit

class CrownBadge: UIView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.isHidden = true
    }
    
    func config(text: String) {
        titleLabel.text = text
        titleLabel.isHidden = false
    }
}
