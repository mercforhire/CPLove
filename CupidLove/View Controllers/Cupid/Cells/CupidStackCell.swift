//
//  CupidStackCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-24.
//

import UIKit
import DynamicBlurView
import Kingfisher

class CupidStackCell: UITableViewCell {
    @IBOutlet weak var imageView1: URLImageView!
    @IBOutlet weak var imageView2: URLImageView!
    @IBOutlet weak var imageView3: URLImageView!
    @IBOutlet weak var blurViewContainer: UIView!
    @IBOutlet weak var blurView: DynamicBlurView!
    @IBOutlet weak var nameLabel: ThemeBlackTextLabel!
    @IBOutlet weak var cityLabel: ThemeBlackTextLabel!
    @IBOutlet weak var jobLabel: ThemeBlackTextLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageView1.roundCorners(style: .medium)
        imageView2.roundCorners(style: .medium)
        imageView3.roundCorners(style: .medium)
        blurViewContainer.roundCorners(style: .medium)
        
        blurView.blurRadius = 10.0
        blurView.blendColor = UIColor(white: 1.0, alpha: 0.5)
        blurView.isDeepRendering = true
        blurView.trackingMode = .none
        NotificationCenter.default.addObserver(self, selector: #selector(refreshBlurs), name: Notifications.RefreshBlurViews, object: nil)
        
        imageView2.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 20 / 9 * 2))
        imageView3.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 20 / 9 * 4))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func refreshBlurs() {
        blurView.refresh()
    }

    func config(user: UserQuery) {
        nameLabel.text = user.firstName
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
        
        if !(user.personalPhotos?.isEmpty ?? true) {
            imageView1.isHidden = false
            imageView1.loadImageFromURL(urlString: user.personalPhotos?.first!.thumbnailUrl, blur: user.isVipBlur ?? false ? .strong : .none) { [weak self] in
                self?.refreshBlurs()
            }
        } else {
            imageView1.isHidden = true
            imageView2.isHidden = true
            imageView3.isHidden = true
        }
        
        if (user.personalPhotos?.count ?? 0) > 1 {
            imageView2.isHidden = false
            imageView2.loadImageFromURL(urlString: user.personalPhotos?[1].thumbnailUrl, blur: user.isVipBlur ?? false ?? false ? .strong : .none)
        } else {
            imageView2.isHidden = true
            imageView3.isHidden = true
        }
        
        if (user.personalPhotos?.count ?? 0) > 2 {
            imageView3.isHidden = false
            imageView3.loadImageFromURL(urlString: user.personalPhotos?[2].thumbnailUrl, blur: user.isVipBlur ?? false ? .strong : .none)
        } else {
            imageView3.isHidden = true
        }
    }
}
