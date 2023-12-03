//
//  PersonalityViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-25.
//

import UIKit

class PersonalityViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    private var selected: [String: Personality] = [:]
    private let kCellHeight: CGFloat = 43
    private let kItemPadding = 15
    private let MaxSelections = 7
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func setup() {
        super.setup()
        
        for personality in Personality.list() {
            if user.personality?.contains(personality) ?? false {
                selected[personality.rawValue] = personality
            }
        }
        
        let bubbleLayout = MICollectionViewBubbleLayout()
        bubbleLayout.minimumLineSpacing = 10
        bubbleLayout.minimumInteritemSpacing = 5
        bubbleLayout.sectionInset = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        bubbleLayout.delegate = self
        collectionView.setCollectionViewLayout(bubbleLayout, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.reloadData()
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        let personalities = Array(selected.values)
        var params = UpdateUserParams()
        params.personality = personalities
        FullScreenSpinner().show()
        userManager.updateProfile(params: params) { [weak self] success in
            FullScreenSpinner().hide()
            if success {
                self?.backPressed(sender)
            }
        }
    }

    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Personality.list().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let personality = Personality.list()[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonTextCollectionViewCell", for: indexPath) as! ButtonTextCollectionViewCell
        
        if selected[personality.rawValue] != nil {
            cell.config(text: personality.title(), state: .selected)
        } else {
            cell.config(text: personality.title(), state: selected.count < MaxSelections ? .normal : .disabled)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let personality = Personality.list()[indexPath.row]
        if selected[personality.rawValue] != nil {
            selected[personality.rawValue] = nil
        } else if selected.count < MaxSelections {
            selected[personality.rawValue] = personality
        }
        collectionView.reloadData()
    }
}

extension PersonalityViewController: MICollectionViewBubbleLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: NSIndexPath) -> CGSize {
        let text = "  \(Personality.list()[indexPath.row].title())"
        var size = text.size(withAttributes: [NSAttributedString.Key.font: UIFont(name: "Lato-Regular", size: 19.0)!])
        size.width = CGFloat(ceilf(Float(size.width + CGFloat(kItemPadding * 2)))) + 15
        size.height = kCellHeight
        
        //...Checking if item width is greater than collection view width then set item width == collection view width.
        if size.width > collectionView.frame.size.width {
            size.width = collectionView.frame.size.width
        }
        
        return size
    }
}
