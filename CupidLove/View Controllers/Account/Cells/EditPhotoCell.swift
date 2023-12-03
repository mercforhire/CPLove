//
//  EditPhotoCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-25.
//

import UIKit
import Kingfisher

class EditPhotoCell: UICollectionViewCell {
    static let PlusSymbolName = "plus.circle.fill"
    static let MinusSymbolName = "minus.circle.fill"
    
    @IBOutlet weak var photoImageView: URLImageView!
    @IBOutlet weak var button: ThemeBlackImageView!
    var buttonTap: UITapGestureRecognizer = UITapGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photoImageView.roundCorners(style: .large)
        resetCell()
        button.addGestureRecognizer(buttonTap)
        photoImageView.addBorder(borderWidth: 3.0, color: themeManager.themeData!.lightGray.hexColor)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCell()
    }
    
    func config(data: PhotoCellModel) {
        photoImageView.loadImageFromURL(urlString: data.smallUrl, blur: .none)
        photoImageView.addBorder(borderWidth: 3.0, color: themeManager.themeData!.pink.hexColor)
        button.image = UIImage(systemName: EditPhotoCell.MinusSymbolName)
    }
    
    func config(data: PhotoResponse) {
        photoImageView.loadImageFromURL(urlString: data.thumbnailUrl, blur: .none)
        photoImageView.addBorder(borderWidth: 3.0, color: themeManager.themeData!.pink.hexColor)
        button.image = UIImage(systemName: EditPhotoCell.MinusSymbolName)
    }
    
    func resetCell() {
        photoImageView.image = nil
        photoImageView.cancelLoading()
        photoImageView.addBorder(borderWidth: 3.0, color: themeManager.themeData!.lightGray.hexColor)
        button.image = UIImage(systemName: EditPhotoCell.PlusSymbolName)
    }
}
