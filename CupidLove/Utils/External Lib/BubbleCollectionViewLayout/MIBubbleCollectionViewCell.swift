//
//  MIBubbleCollectionViewCell.swift
//  SwiftDemo
//
//  Created by mac-0007 on 05/12/17.
//  Copyright © 2017 Jignesh-0007. All rights reserved.
//

import UIKit

class MIBubbleCollectionViewCell: UICollectionViewCell {
    @IBOutlet var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundCorners()
        unhighlight()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func highlight() {
        contentView.backgroundColor = themeManager.themeData!.pink.hexColor
        lblTitle.textColor = .white
        
    }
    
    func unhighlight() {
        contentView.backgroundColor = themeManager.themeData!.textFieldBackground.hexColor
        lblTitle.textColor = themeManager.themeData!.textLabel.hexColor
    }
}