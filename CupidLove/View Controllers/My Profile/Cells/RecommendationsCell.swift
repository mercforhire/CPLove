//
//  RecommendationsCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-30.
//

import UIKit

protocol RecommendationsCellDelegate: class {
    func openProfile(profile: UserQuery)
}

class RecommendationsCell: UITableViewCell {
    let MaxCellsCount = 9
    
    var recommendations: [UserQuery] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    weak var delegate: RecommendationsCellDelegate?
    
    @IBOutlet weak var seeAllButton: ThemeBlackButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    private let Gap: CGFloat = 9.0
    private let CellHeight: CGFloat = 94.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(recommendations: [UserQuery]? = [], finishAction: Action?) {
        self.recommendations = recommendations ?? []
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { [weak self] in
            self?.resizeCollectionViews()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            finishAction?()
        })
    }
    
    private func resizeCollectionViews() {
        let cellsCount = min(recommendations.count, MaxCellsCount)
        let rowsCount = ceil(Double(cellsCount) / 3.0)
        collectionViewHeight.constant = CellHeight * rowsCount + max(0, rowsCount - 1) * Gap
    }
}

extension RecommendationsCell: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = (collectionView.frame.width - (9.0 * 2)) / 3.0
        let yourHeight = CellHeight

        return CGSize(width: yourWidth, height: yourHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Gap
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Gap
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(MaxCellsCount, recommendations.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let user = recommendations[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SimpleRoundedImageCell", for: indexPath) as! SimpleRoundedImageCell
        if let photo = user.personalPhotos?.first {
            cell.config(data: photo, blurred: user.isVipBlur ?? false)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = recommendations[indexPath.row]
        delegate?.openProfile(profile: user)
    }
}
