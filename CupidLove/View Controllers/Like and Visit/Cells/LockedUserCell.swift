//
//  LockedVisitedUserCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-24.
//

import UIKit
import Kingfisher

class LockedUserCell: UICollectionViewCell {
    @IBOutlet weak var container: ThemeRoundedBackView!
    @IBOutlet weak var profileImage: URLImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        container.roundCorners(style: .medium)
    }

    func config(user: UserQuery) {
        loadImageFromURL(urlString: user.personalPhotos?.first?.thumbnailUrl ?? "")
    }
    
    private func loadImageFromURL(urlString: String) {
        profileImage.loadImageFromURL(urlString: urlString, blur: .weak)
    }
}
