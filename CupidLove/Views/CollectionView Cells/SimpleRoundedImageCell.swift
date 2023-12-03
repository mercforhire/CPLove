//
//  SimpleRoundedImageCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-30.
//

import UIKit

class SimpleRoundedImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: URLImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.roundCorners(style: .medium)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func config(data: PhotoResponse, blurred: Bool) {
        imageView.loadImageFromURL(urlString: data.thumbnailUrl, blur: blurred ? .weak : .none)
    }
}
