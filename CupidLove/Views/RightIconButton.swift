//
//  RightIconButton.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-03.
//

import UIKit

class RightIconButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView != nil {
            let margin: CGFloat = 20.0
            imageEdgeInsets = UIEdgeInsets(top: margin, left: (bounds.width - 35 - margin), bottom: margin, right: margin)
            titleEdgeInsets = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: (imageView?.frame.width)! + margin)
        }
    }

}
