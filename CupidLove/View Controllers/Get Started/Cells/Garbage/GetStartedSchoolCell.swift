//
//  GetStartedSchoolCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-13.
//

import UIKit

class GetStartedSchoolCell: UITableViewCell {

    @IBOutlet weak var schoolField: ThemePaddedTextField!
    @IBOutlet weak var degreeField: ThemePaddedTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
