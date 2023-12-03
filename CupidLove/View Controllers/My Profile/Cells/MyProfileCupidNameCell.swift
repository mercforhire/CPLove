//
//  MyProfileCupidNameCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-25.
//

import UIKit


class MyProfileCupidNameCell: UITableViewCell {
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var verifyIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(user: UserInfo) {
        firstNameLabel.text = user.nameAndAge
        
        if let city = user.cityName, !city.isEmpty {
            cityLabel.text = city
            cityLabel.isHidden = false
        } else {
            cityLabel.isHidden = true
        }
        
        if let jobTitle = user.jobTitle, !jobTitle.isEmpty {
            jobLabel.text = jobTitle
            jobLabel.isHidden = false
        } else {
            jobLabel.isHidden = true
        }
        
        verifyIcon.isHidden = !(user.isVerified ?? false)
    }
}
