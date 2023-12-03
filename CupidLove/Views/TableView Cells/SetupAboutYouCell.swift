//
//  SetupAboutYouCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-13.
//

import UIKit

protocol SetupAboutYouCellDelegate: class {
    func aboutMeChanged(text: String)
}

class SetupAboutYouCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: ThemeGrowingTextView!
    
    weak var delegate: SetupAboutYouCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(updateParams: UpdateUserParams) {
        textView.text = updateParams.aboutMe
    }
}

extension SetupAboutYouCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        delegate?.aboutMeChanged(text: textView.text)
    }
}
