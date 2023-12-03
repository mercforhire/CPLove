//
//  VerifyStep2Cell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-05.
//

import UIKit

class VerifyStep2Cell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var confirmButton: ThemeRoundedBlueButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
