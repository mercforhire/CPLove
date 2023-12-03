//
//  WhoLikedMeViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-24.
//

import UIKit
import XLPagerTabStrip
import CRRefresh

class WhoLikedMeViewController: BaseViewController {
    private let itemInfo = IndicatorInfo(title: "Who Liked Me")
    
    static let MaxLockedCells = 2
    
    private enum Cells: Int {
        case user
        case lockedUser
        case emptyLikedCell
        case becomeVIP
        
        static func getRows(numberOfUsers: Int, isVIP: Bool) -> [Cells] {
            var rows: [Cells] = []
            if numberOfUsers == 0 {
                rows.append(.emptyLikedCell)
            }
            if !isVIP {
                for _ in 0..<min(numberOfUsers, WhoLikedMeViewController.MaxLockedCells) {
                    rows.append(.lockedUser)
                }
                rows.append(.becomeVIP)
            } else {
                for _ in 0..<numberOfUsers {
                    rows.append(.user)
                }
            }
            return rows
        }
    }
    
    var isVIP: Bool {
        return user.isVip
    }
    var users: [UserQuery] = []
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    override func setup() {
        super.setup()
        
        collectionView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            /// start refresh
            /// Do anything you want...
            self?.fetchData(complete: { success in
                self?.collectionView.cr.endHeaderRefresh()
            })
        }
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if users.isEmpty {
            fetchData()
        }
    }
    
    private func fetchData(complete: ((Bool) -> Void)? = nil) {
        users.isEmpty ? FullScreenSpinner().show() : nil
        
        api.getUserLikedMe(userId: user.identifier) { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let response):
                if let results = response.data?.records {
                    self.users = results
                    self.collectionView.reloadData()
                    complete?(true)
                } else {
                    showErrorDialog(code: response.code)
                    complete?(false)
                }
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
                complete?(false)
            }
        }
    }
    
    @objc private func becomeVIPPressed() {
        clickOnVIPNavLogo()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name: Notifications.RefreshBlurViews, object: nil)
    }
}

extension WhoLikedMeViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension WhoLikedMeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellType: Cells = Cells.getRows(numberOfUsers: users.count, isVIP: isVIP)[indexPath.row]
        
        switch cellType {
        case .user, .lockedUser:
            let yourWidth = (collectionView.bounds.width - 50.0) / 2.0 - 10.0
            let yourHeight = 235.0

            return CGSize(width: yourWidth, height: yourHeight)
        case .becomeVIP:
            let yourWidth = collectionView.bounds.width - 50.0
            let yourHeight = 450.0

            return CGSize(width: yourWidth, height: yourHeight)
        case .emptyLikedCell:
            return CGSize(width: collectionView.bounds.width - 50.0, height: 350)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 25, bottom: 5, right: 25)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Cells.getRows(numberOfUsers: users.count, isVIP: isVIP).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellType: Cells = Cells.getRows(numberOfUsers: users.count, isVIP: isVIP)[indexPath.row]
        switch cellType {
        case .emptyLikedCell:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyLikedCell", for: indexPath)
            return cell
        case .user:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendationCell", for: indexPath) as! RecommendationCell
            let user = users[indexPath.row]
            cell.config(user: user)
            return cell
        case .lockedUser:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LockedLikedUserCell", for: indexPath) as! LockedUserCell
            let user = users[indexPath.row]
            cell.config(user: user)
            return cell
        case .becomeVIP:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LockedLikesVIPCell", for: indexPath) as! LockedLikesVIPCell
            cell.config(numberOfLikes: users.count)
            cell.vipButton.addTarget(self, action: #selector(becomeVIPPressed), for: .touchUpInside)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellType: Cells = Cells.getRows(numberOfUsers: users.count, isVIP: isVIP)[indexPath.row]
        switch cellType {
        case .user:
            let user = users[indexPath.row]
            openProfile(user: user)
        default:
            break
        }
    }
}
