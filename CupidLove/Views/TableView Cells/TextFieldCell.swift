//
//  TextFieldCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-04-29.
//

import UIKit

class TextFieldCell: UITableViewCell {
    
    @IBOutlet weak var textField: ThemeBorderTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
