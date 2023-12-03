//
//  AvatarImage.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-04-12.
//

import UIKit
import Kingfisher

protocol AvatarModel {
    func getAvatarIsBlurred() -> Bool
    func getAvatarURL() -> String
    func getUserType() -> UserTypeMode
    func getUserId() -> String
}

class AvatarImage: UIView {
    private var user: AvatarModel?
    private var clickToOpenProfile: Bool = false
    private let imageView = URLImageView(frame: .zero)
    private var rounded: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        setupImage()
        backgroundColor = themeManager.themeData?.whiteBackground.hexColor
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        roundCorners()
        layer.masksToBounds = true
    }
    
    private func setImage(image: UIImage) {
        UIView.transition(
            with: imageView,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
                self?.imageView.image = image
            },
            completion: nil)
        setupShadows()
    }

    func config(user: AvatarModel?, rounded: Bool = false, clickToOpenProfile: Bool = false) {
        guard let user = user else {
            clearImage()
            return
        }
        
        self.user = user
        self.rounded = rounded
        if !user.getAvatarURL().isEmpty {
            imageView.loadImageFromURL(urlString: user.getAvatarURL(), blur: user.getAvatarIsBlurred() ? .weak : .none)
        } else {
            imageView.image = UIImage(named: Bool.random() ? "illustration_male" : "illustration_woman")!
        }
        imageView.backgroundColor = backgroundColor
        setupShadows()
        
        if clickToOpenProfile {
            let tap = UITapGestureRecognizer(target: self, action: #selector(openProfile))
            addGestureRecognizer(tap)
        }
    }
    
    func hasImage() -> Bool {
        return imageView.image != nil
    }
    
    func clearImage() {
        user = nil
        setupShadows()
        imageView.image = nil
    }
    
    @objc func openProfile() {
        guard let user = user else { return }
        
        NotificationCenter.default.post(name: Notifications.OpenProfile,
                                        object: nil,
                                        userInfo: ["userId": user.getUserId(),
                                                   "userType": user.getUserType()])
    }
}

extension AvatarImage {
    private func setupImage() {
        fill(with: imageView)
    }
    
    private func setupShadows() {
        let cornerRadius: CGFloat = rounded ? (frame.width / 2.0) : 8.0
        clipsToBounds = false
        layer.shadowColor = UIColor.systemGray4.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 4
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath

        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = cornerRadius
        if rounded {
            imageView.addBorder(borderWidth: 2.0, color: themeManager.themeData!.pink.hexColor)
        } else {
            imageView.addBorder(borderWidth: 0, color: .clear)
        }
    }
}
