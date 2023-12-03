//
//  RecommendationsViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-01.
//

import UIKit
import CRRefresh

class RecommendationsViewController: BaseViewController {
    var cupid: UserInfo!
    var recommendations: [UserQuery] = []
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    override func setup() {
        super.setup()
        
        title = "\(cupid.firstName ?? "")'s Recommendations"
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
        
        if recommendations.isEmpty {
            fetchData()
        }
    }
    
    private func fetchData(complete: ((Bool) -> Void)? = nil) {
        recommendations.isEmpty ? FullScreenSpinner().show() : nil
        
        api.getInvitedUserList(userId: cupid.identifier) { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let response):
                if let recommendations = response.data?.records {
                    self.recommendations = recommendations
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name: Notifications.RefreshBlurViews, object: nil)
    }
}

extension RecommendationsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = (collectionView.bounds.width - 50.0) / 2.0 - 10.0
        let yourHeight = 235.0

        return CGSize(width: yourWidth, height: yourHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let user = recommendations[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendationCell", for: indexPath) as! RecommendationCell
        cell.config(user: user)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = recommendations[indexPath.row]
        openProfile(user: user)
    }
}
