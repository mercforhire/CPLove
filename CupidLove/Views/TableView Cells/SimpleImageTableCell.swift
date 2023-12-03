//
//  SimpleImageTableCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-31.
//

import UIKit

class SimpleImageTableCell: UITableViewCell {
    @IBOutlet weak var picture: URLImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(data: PhotoResponse, blurred: Bool) {
        picture.loadImageFromURL(urlString: data.photoUrl, blur: blurred ? .strong : .none)
    }
}
