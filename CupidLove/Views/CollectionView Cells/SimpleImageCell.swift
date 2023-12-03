//
//  SimpleImageCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-29.
//

import UIKit

class SimpleImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: URLImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func config(data: PhotoCellModel, blurred: Bool) {
        imageView.loadImageFromURL(urlString: data.normalUrl, blur: blurred ? .strong : .none)
    }
    
    func config(data: PhotoResponse, blurred: Bool) {
        imageView.loadImageFromURL(urlString: data.photoUrl, blur: blurred ? .strong : .none)
    }
}
