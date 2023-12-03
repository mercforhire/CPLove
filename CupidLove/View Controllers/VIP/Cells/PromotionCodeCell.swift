//
//  PromotionCodeCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-27.
//

import UIKit

class PromotionCodeCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var codeField: ThemeBorderTextField!
    @IBOutlet weak var codeErrorLabel: UILabel!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        codeErrorLabel.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
