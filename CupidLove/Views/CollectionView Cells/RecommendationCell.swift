//
//  RecommendationCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-01.
//

import UIKit
import DynamicBlurView
import Kingfisher

class RecommendationCell: UICollectionViewCell {
    @IBOutlet weak var container: ThemeRoundedBackView!
    @IBOutlet weak var profileImage: URLImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: ThemeBlackTextLabel!
    @IBOutlet weak var jobTitleLabel: ThemeBlackTextLabel!
    @IBOutlet weak var heartIcon: UIImageView!
    @IBOutlet weak var blurView: DynamicBlurView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        container.roundCorners(style: .medium)
        blurView.blurRadius = 10.0
        blurView.isDeepRendering = true
        blurView.trackingMode = .none
        NotificationCenter.default.addObserver(self, selector: #selector(refreshBlurs), name: Notifications.RefreshBlurViews, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func config(user: UserQuery) {
        switch user.userType {
        case .normal:
            blurView.blendColor = themeManager.themeData!.pink.hexColor
        case .cupid:
            blurView.blendColor = themeManager.themeData!.blue.hexColor
        default:
            break
        }
        
        nameLabel.text = user.nameAndAge
        
        if let city = user.cityName, !city.isEmpty {
            locationLabel.text = city
            locationLabel.isHidden = false
        } else {
            locationLabel.isHidden = true
        }
        
        if let jobTitle = user.jobTitle, !jobTitle.isEmpty {
            jobTitleLabel.text = jobTitle
            jobTitleLabel.isHidden = false
        } else {
            jobTitleLabel.isHidden = true
        }
        heartIcon.isHidden = !(user.isLiked ?? false)
        
        profileImage.loadImageFromURL(urlString: user.personalPhotos?.first?.thumbnailUrl ?? "", blur: user.isVipBlur ?? false ? .weak : .none) { [weak self] in
            self?.refreshBlurs()
        }
    }
    
    @objc func refreshBlurs() {
        blurView.refresh()
    }
}
