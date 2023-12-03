//
//  VIPProductCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-26.
//

import UIKit

class VIPProductCell: UITableViewCell {

    @IBOutlet weak var box: UIView!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var checkmark: ThemeWhiteImageView!
    @IBOutlet weak var priceLabel: ThemeBlackTextLabel!
    @IBOutlet weak var priceLabel2: ThemeBlackTextLabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var detailsButton: RoundedButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(data: Product, selected: Bool) {
        productLabel.text = data.name
        productLabel.textColor = selected ? .white : .black
        priceLabel.text = "$\(String(format: "%.2f", data.price))"
        priceLabel2.text = " / \(data.amount) \(data.unit)"
        descriptionLabel.text = data.productDescription
        box.backgroundColor = selected ? .black : UIColor(white: 0.95, alpha: 1.0)
        checkmark.isHidden = !selected
    }
}
