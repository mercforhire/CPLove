//
//  ButtonTextCollectionViewCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-25.
//

import UIKit

enum ButtonTextState {
    case normal
    case selected
    case disabled
    
    func icon() -> UIImage? {
        switch self {
        case .normal:
            return UIImage(systemName: "plus")!
        case .selected:
            return UIImage(systemName: "checkmark")!
        case .disabled:
            return UIImage(systemName: "plus")!
        }
    }
    
    func color() -> UIColor {
        switch self {
        case .normal:
            return ThemeManager.shared.themeData!.lightPink.hexColor
        case .selected:
            return ThemeManager.shared.themeData!.pink.hexColor
        case .disabled:
            return ThemeManager.shared.themeData!.lightGray.hexColor
        }
    }
    
    func textColor() -> UIColor {
        switch self {
        case .normal:
            return ThemeManager.shared.themeData!.textLabel.hexColor
        case .selected:
            return ThemeManager.shared.themeData!.whiteBackground.hexColor
        case .disabled:
            return .lightGray
        }
    }
}

class ButtonTextCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var labelButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func config(text: String, state: ButtonTextState, hideIcon: Bool = false) {
        labelButton.setTitle(text, for: .normal)
        labelButton.backgroundColor = state.color()
        UIView.performWithoutAnimation {
            self.labelButton.setTitleColor(state.textColor(), for: .normal)
            self.labelButton.tintColor = state.textColor()
            if hideIcon {
                self.labelButton.setImage(nil, for: .normal)
            }
            self.layoutIfNeeded()
        }
    }
}
