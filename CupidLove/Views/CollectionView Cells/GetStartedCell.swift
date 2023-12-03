//
//  GetStartedCell.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-08.
//

import UIKit

class GetStartedCell: UICollectionViewCell {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var titleLabel: ThemeBlackTextLabel!
    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func config(data: GetStartedSteps) {
        headerLabel.text = data.title()
        titleLabel.text = data.body1()
        textLabel.text = data.body2()
        headerLabel.textColor = data.titleColor()
    }
}
