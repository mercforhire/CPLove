//
//  ExploreInterestsCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-23.
//

import UIKit

class ExploreInterestsCell: UITableViewCell {
    var interests: [Interests] = []
    var showAdd: Bool = false
    weak var viewController: UIViewController?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    private let kCellHeight: CGFloat = 37
    private let kItemPadding = 12
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let bubbleLayout = MICollectionViewBubbleLayout()
        bubbleLayout.minimumLineSpacing = 10
        bubbleLayout.minimumInteritemSpacing = 5
        bubbleLayout.delegate = self
        collectionView.setCollectionViewLayout(bubbleLayout, animated: false)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(interests: [String]? = [], showAdd: Bool, finishAction: Action?) {
        self.interests = []
        for word in interests ?? [] {
            guard let interest = Interests(rawValue: word) else { continue }
            
            self.interests.append(interest)
        }
        self.showAdd = showAdd
        collectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { [weak self] in
            self?.resizeCollectionViews()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            finishAction?()
        })
    }
    
    private func resizeCollectionViews() {
        collectionViewHeight.constant = collectionView.contentSize.height
    }
}

extension ExploreInterestsCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return interests.count + (showAdd ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MIBubbleCollectionViewCell", for: indexPath) as! MIBubbleCollectionViewCell
        if indexPath.row < interests.count {
            let keyword = interests[indexPath.row]
            cell.lblTitle.text = keyword.iconAndTitle()
            cell.lblTitle.textColor = .white
            cell.contentView.backgroundColor = themeManager.themeData!.pink.hexColor
        } else {
            cell.lblTitle.text = "+ Add"
            cell.lblTitle.textColor = themeManager.themeData!.whiteBackground.hexColor
            cell.contentView.backgroundColor = themeManager.themeData!.textLabel.hexColor
        }
        cell.contentView.roundCorners(style: .completely)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= interests.count {
            viewController?.performSegue(withIdentifier: "goToInterests", sender: self)
        }
    }
}

extension ExploreInterestsCell: MICollectionViewBubbleLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: NSIndexPath) -> CGSize {
        let interest = indexPath.row < interests.count ? interests[indexPath.row].iconAndTitle() : "+ Add"
        var size = interest.size(withAttributes: [NSAttributedString.Key.font: UIFont(name: "Lato-Regular", size: 17.0)!])
        size.width = CGFloat(ceilf(Float(size.width + CGFloat(kItemPadding * 2))))
        size.height = kCellHeight
        
        //...Checking if item width is greater than collection view width then set item width == collection view width.
        if size.width > collectionView.frame.size.width {
            size.width = collectionView.frame.size.width
        }
        
        return size
    }
}
