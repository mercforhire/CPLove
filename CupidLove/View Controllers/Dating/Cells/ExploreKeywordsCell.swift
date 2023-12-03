//
//  ExploreKeywordsCell.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-23.
//

import UIKit

class ExploreKeywordsCell: UITableViewCell {
    var personalities: [Personality] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    var showAdd: Bool = false
    weak var viewController: UIViewController?
    
    @IBOutlet weak var titleLabel: ThemeBlackTextLabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    private let kCellHeight: CGFloat = 35
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
    
    func config(personalities: [Personality]? = [], showAdd: Bool, finishAction: Action?) {
        self.personalities = personalities ?? []
        self.showAdd = showAdd
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { [weak self] in
            self?.resizeCollectionViews()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            finishAction?()
        })
    }

    private func resizeCollectionViews() {
        guard collectionViewHeight != nil, collectionView != nil else { return }
        
        collectionViewHeight.constant = collectionView.contentSize.height
    }
}

extension ExploreKeywordsCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return personalities.count + (showAdd ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MIBubbleCollectionViewCell", for: indexPath) as! MIBubbleCollectionViewCell
        if indexPath.row < personalities.count {
            let personality = personalities[indexPath.row]
            cell.lblTitle.text = personality.title()
            cell.contentView.backgroundColor = themeManager.themeData!.pink.hexColor
            cell.lblTitle.textColor = .white
        } else {
            cell.lblTitle.text = "+ Add"
            cell.contentView.backgroundColor = themeManager.themeData!.textLabel.hexColor
            cell.lblTitle.textColor = themeManager.themeData!.whiteBackground.hexColor
        }
        cell.contentView.roundCorners(style: .completely)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= personalities.count {
            viewController?.performSegue(withIdentifier: "goToPersonality", sender: self)
        }
    }
}

extension ExploreKeywordsCell: MICollectionViewBubbleLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: NSIndexPath) -> CGSize {
        let personality = indexPath.row < personalities.count ? personalities[indexPath.row].title() : "+ Add"
        var size = personality.size(withAttributes: [NSAttributedString.Key.font: UIFont(name: "Lato-Regular", size: 17.0)!])
        size.width = CGFloat(ceilf(Float(size.width + CGFloat(kItemPadding * 2))))
        size.height = kCellHeight
        
        //...Checking if item width is greater than collection view width then set item width == collection view width.
        if size.width > collectionView.frame.size.width {
            size.width = collectionView.frame.size.width
        }
        
        return size
    }
}
