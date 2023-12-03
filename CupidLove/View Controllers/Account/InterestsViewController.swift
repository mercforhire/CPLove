//
//  InterestsViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-09.
//

import UIKit

class InterestsViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView0: UICollectionView!
    @IBOutlet weak var collectionView0Height: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView1: UICollectionView!
    @IBOutlet weak var collectionView1Height: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView2: UICollectionView!
    @IBOutlet weak var collectionView2Height: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView3: UICollectionView!
    @IBOutlet weak var collectionView3Height: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView4: UICollectionView!
    @IBOutlet weak var collectionView4Height: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView5: UICollectionView!
    @IBOutlet weak var collectionView5Height: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView6: UICollectionView!
    @IBOutlet weak var collectionView6Height: NSLayoutConstraint!
    
    var selected: [Interests] = []
    
    private let kCellHeight: CGFloat = 43
    private let kItemPadding = 15
    private let MaxSelections = 7
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func setup() {
        super.setup()
        
        for word in user.interests ?? [] {
            guard let interest = Interests(rawValue: word) else { continue }
            
            selected.append(interest)
        }
        
        let bubbleLayout1 = MICollectionViewBubbleLayout()
        bubbleLayout1.minimumLineSpacing = 15
        bubbleLayout1.minimumInteritemSpacing = 9
        bubbleLayout1.delegate = self
        let bubbleLayout2 = MICollectionViewBubbleLayout()
        bubbleLayout2.minimumLineSpacing = 15
        bubbleLayout2.minimumInteritemSpacing = 9
        bubbleLayout2.delegate = self
        let bubbleLayout3 = MICollectionViewBubbleLayout()
        bubbleLayout3.minimumLineSpacing = 15
        bubbleLayout3.minimumInteritemSpacing = 9
        bubbleLayout3.delegate = self
        let bubbleLayout4 = MICollectionViewBubbleLayout()
        bubbleLayout4.minimumLineSpacing = 15
        bubbleLayout4.minimumInteritemSpacing = 9
        bubbleLayout4.delegate = self
        let bubbleLayout5 = MICollectionViewBubbleLayout()
        bubbleLayout5.minimumLineSpacing = 15
        bubbleLayout5.minimumInteritemSpacing = 9
        bubbleLayout5.delegate = self
        let bubbleLayout6 = MICollectionViewBubbleLayout()
        bubbleLayout6.minimumLineSpacing = 15
        bubbleLayout6.minimumInteritemSpacing = 9
        bubbleLayout6.delegate = self
        let bubbleLayout7 = MICollectionViewBubbleLayout()
        bubbleLayout7.minimumLineSpacing = 15
        bubbleLayout7.minimumInteritemSpacing = 9
        bubbleLayout7.delegate = self
        collectionView0.setCollectionViewLayout(bubbleLayout1, animated: false)
        collectionView1.setCollectionViewLayout(bubbleLayout2, animated: false)
        collectionView2.setCollectionViewLayout(bubbleLayout3, animated: false)
        collectionView3.setCollectionViewLayout(bubbleLayout4, animated: false)
        collectionView4.setCollectionViewLayout(bubbleLayout5, animated: false)
        collectionView5.setCollectionViewLayout(bubbleLayout6, animated: false)
        collectionView6.setCollectionViewLayout(bubbleLayout7, animated: false)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView0.reloadData()
        collectionView1.reloadData()
        collectionView2.reloadData()
        collectionView3.reloadData()
        collectionView4.reloadData()
        collectionView5.reloadData()
        collectionView6.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
            self?.resizeCollectionViews()
        })
    }

    private func resizeCollectionViews() {
        collectionView0Height.constant = collectionView0.contentSize.height
        collectionView1Height.constant = collectionView1.contentSize.height
        collectionView2Height.constant = collectionView2.contentSize.height
        collectionView3Height.constant = collectionView3.contentSize.height
        collectionView4Height.constant = collectionView4.contentSize.height
        collectionView5Height.constant = collectionView5.contentSize.height
        collectionView6Height.constant = collectionView6.contentSize.height
    }
    
    @IBAction func savePressed(_ sender: ThemeBarButton) {
        var params = UpdateUserParams()
        params.interests = selected.map({$0.rawValue})
        FullScreenSpinner().show()
        userManager.updateProfile(params: params) { [weak self] success in
            FullScreenSpinner().hide()
            if success {
                self?.backPressed(sender)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionView0 {
            return Interests.sports().count
        } else if collectionView == collectionView1 {
            return Interests.arts().count
        } else if collectionView == collectionView2 {
            return Interests.mental().count
        } else if collectionView == collectionView3 {
            return Interests.music().count
        } else if collectionView == collectionView4 {
            return Interests.collecting().count
        } else if collectionView == collectionView5 {
            return Interests.food().count
        } else if collectionView == collectionView6 {
            return Interests.games().count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonTextCollectionViewCell", for: indexPath) as! ButtonTextCollectionViewCell
        
        var interest: Interests!
        
        if collectionView == collectionView0 {
            interest = Interests.sports()[indexPath.row]
        } else if collectionView == collectionView1 {
            interest = Interests.arts()[indexPath.row]
        } else if collectionView == collectionView2 {
            interest = Interests.mental()[indexPath.row]
        } else if collectionView == collectionView3 {
            interest = Interests.music()[indexPath.row]
        } else if collectionView == collectionView4 {
            interest = Interests.collecting()[indexPath.row]
        } else if collectionView == collectionView5 {
            interest = Interests.food()[indexPath.row]
        } else if collectionView == collectionView6 {
            interest = Interests.games()[indexPath.row]
        }
        
        let word = "\(interest.icon())\(interest.title())"
        if !selected.contains(interest) {
            cell.config(text: word, state: .normal, hideIcon: true)
        } else {
            cell.config(text: word, state: .selected, hideIcon: true)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var interest: Interests!
        
        if collectionView == collectionView0 {
            interest = Interests.sports()[indexPath.row]
        } else if collectionView == collectionView1 {
            interest = Interests.arts()[indexPath.row]
        } else if collectionView == collectionView2 {
            interest = Interests.mental()[indexPath.row]
        } else if collectionView == collectionView3 {
            interest = Interests.music()[indexPath.row]
        } else if collectionView == collectionView4 {
            interest = Interests.collecting()[indexPath.row]
        } else if collectionView == collectionView5 {
            interest = Interests.food()[indexPath.row]
        } else if collectionView == collectionView6 {
            interest = Interests.games()[indexPath.row]
        }
        
        if !selected.contains(interest) {
            selected.append(interest)
        } else if let index = selected.firstIndex(of: interest) {
            selected.remove(at: index)
        }
        collectionView.reloadData()
    }
}

extension InterestsViewController: MICollectionViewBubbleLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, itemSizeAt indexPath: NSIndexPath) -> CGSize {
        var interest: Interests!
        
        if collectionView == collectionView0 {
            interest = Interests.sports()[indexPath.row]
        } else if collectionView == collectionView1 {
            interest = Interests.arts()[indexPath.row]
        } else if collectionView == collectionView2 {
            interest = Interests.mental()[indexPath.row]
        } else if collectionView == collectionView3 {
            interest = Interests.music()[indexPath.row]
        } else if collectionView == collectionView4 {
            interest = Interests.collecting()[indexPath.row]
        } else if collectionView == collectionView5 {
            interest = Interests.food()[indexPath.row]
        } else if collectionView == collectionView6 {
            interest = Interests.games()[indexPath.row]
        }
        
        let word = "\(interest.icon())\(interest.title())"
        var size = word.size(withAttributes: [NSAttributedString.Key.font: UIFont(name: "Lato-Regular", size: 19.0)!])
        size.width = CGFloat(ceilf(Float(size.width + CGFloat(kItemPadding * 2)))) + 15
        size.height = kCellHeight
        
        //...Checking if item width is greater than collection view width then set item width == collection view width.
        if size.width > collectionView.frame.size.width {
            size.width = collectionView.frame.size.width
        }
        
        return size
    }
}
