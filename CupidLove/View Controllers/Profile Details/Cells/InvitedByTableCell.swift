//
//  InvitedByTableCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-24.
//

import UIKit

protocol InvitedByTableCellDelegate: class {
    func openProfile(profile: InvitedByUserInfo)
}

class InvitedByTableCell: UITableViewCell {
    var user: InvitedByUserInfo?
    weak var delegate: InvitedByTableCellDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(user: InvitedByUserInfo) {
        self.user = user
        collectionView.reloadData()
    }
}

extension InvitedByTableCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return user == nil ? 0 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let user = user else { return UICollectionViewCell() }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InvitedByCell", for: indexPath) as! InvitedByCell
        cell.config(user: user)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.openProfile(profile: user!)
    }
}
