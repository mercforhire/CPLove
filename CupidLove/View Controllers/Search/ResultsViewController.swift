//
//  SearchResultsViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-03.
//

import UIKit
import XLPagerTabStrip
import CRRefresh

class ResultsViewController: BaseViewController {
    var resultsType: UserTypeMode = .normal
    var searchParams: UserQueryParams = UserQueryParams()
    
    private let CellIdentifier = "EmptyViewCollectionCell"
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var results: [UserQuery]?
    
    private var areResultsEmpty: Bool {
        return results?.isEmpty ?? false
    }
    
    override func setup() {
        super.setup()
        
        collectionView.register(UINib(nibName: CellIdentifier, bundle: Bundle.main), forCellWithReuseIdentifier: CellIdentifier)
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
        
        searchParams.userType = resultsType
        fetchData()
    }

    private func fetchData(complete: ((Bool) -> Void)? = nil) {
        (results?.isEmpty ?? true) ? FullScreenSpinner().show() : nil
        
        switch resultsType {
        case .normal:
            api.getMyFilteredDaterList(params: searchParams, callBack: { [weak self] result in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                switch result {
                case .success(let response):
                    if let results = response.data?.records {
                        self.results = results
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
            })
        case .cupid:
            api.getFilteredMatchmakerList(params: searchParams, callBack: { [weak self] result in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                switch result {
                case .success(let response):
                    if let results = response.data?.records {
                        self.results = results
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
            })
        case .admin:
            break
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name: Notifications.RefreshBlurViews, object: nil)
    }
}

extension ResultsViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        switch resultsType {
        case .normal:
            return IndicatorInfo(title: "Dating")
        case .cupid:
            return IndicatorInfo(title: "CP Cupid")
        case .admin:
            return IndicatorInfo(title: "CP Admin")
        }
    }
}

extension ResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if areResultsEmpty {
            let yourWidth = collectionView.bounds.width - 50.0
            let yourHeight = 300.0
            return CGSize(width: yourWidth, height: yourHeight)
        }
        
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
        if areResultsEmpty {
            return 1
        }
        
        return results?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if areResultsEmpty {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as? EmptyViewCollectionCell else {
                return EmptyViewCollectionCell()
            }
            cell.config(style: .noSearchResults)
            return cell
        }
        
        if let user = results?[indexPath.row], let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendationCell", for: indexPath) as? RecommendationCell {
            cell.config(user: user)
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if areResultsEmpty {
            return
        }
        
        if let user = results?[indexPath.row] {
            openProfile(user: user)
        }
    }
}
