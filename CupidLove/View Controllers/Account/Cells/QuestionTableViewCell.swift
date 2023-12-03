//
//  QuestionTableViewCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-25.
//

import UIKit

class QuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var container: ThemeRoundedPinkView!
    @IBOutlet weak var questionLabel: ThemeBlackTextLabel!
    @IBOutlet weak var answerLabel: ThemeBlackTextLabel!
    
    var tap: UITapGestureRecognizer = UITapGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        container.addGestureRecognizer(tap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
