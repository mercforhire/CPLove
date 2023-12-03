//
//  TextfieldUnderline.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-22.
//

import UIKit

class TextfieldUnderline: UIView {
    func changeToErrorState() {
        backgroundColor = .red
    }

    func changeToNormalState() {
        backgroundColor = .lightGray
    }
}
