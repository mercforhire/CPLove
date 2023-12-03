//
//  MyProfileCupidViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-25.
//

import UIKit
import CRRefresh

class MyProfileCupidViewController: BaseViewController {
    static let MaxNumberOfReviewsToShow = 10
    
    enum AboutTableRows: Int {
        case photos
        case nameBar
        case tabBar
        case separator
        case about
        case basicInfo
        case recommends
        case write
        
        static func getRows() -> [AboutTableRows] {
            let rows: [AboutTableRows] = [.photos, .nameBar, .tabBar, .separator, .about, .basicInfo, .recommends, .write]
            return rows
        }
    }
    
    private enum ReviewsTableRows: Int {
        case photos
        case tabBar
        case separator
        case seeAll
        case review
        
        static func getRows(reviews: Int) -> [ReviewsTableRows] {
            var rows: [ReviewsTableRows] = [.photos, .tabBar, .separator, .seeAll]
            for _ in 0..<(min(MaxNumberOfReviewsToShow, reviews)) {
                rows.append(.review)
            }
            return rows
        }
    }
    
    private enum Tabs: Int {
        case about
        case reviews
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    private var recommendations: [UserQuery] = []
    private var reviews: [ReviewRecord] = []
    private var selectedReview: ReviewRecord?
    
    private var currentTab: Tabs = .about {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func setup() {
        super.setup()
        
        addAvatarButton()
        
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            /// start refresh
            /// Do anything you want...
            self?.fetchData(complete: { success in
                self?.tableView.cr.endHeaderRefresh()
            })
        }
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData!.paleGray.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }
    
    private func fetchData(complete: ((Bool) -> Void)? = nil) {
        var isSuccess: Bool = true
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.userManager.fetchUser(initialize: false) { success in
                isSuccess = success
                semaphore.signal()
            }
            semaphore.wait()
            
            guard isSuccess else {
                DispatchQueue.main.async {
                    complete?(false)
                }
                return
            }
            
            self.api.getUserCommentList(userId: self.user.identifier) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    if let reviews = response.data?.records {
                        self.reviews = reviews
                    } else {
                        showErrorDialog(code: response.code)
                        isSuccess = false
                    }
                case .failure(let error):
                    if error.responseCode == nil {
                        showNetworkErrorDialog()
                    } else {
                        error.showErrorDialog()
                        print("Error occured \(error)")
                    }
                    isSuccess = false
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            guard isSuccess else {
                DispatchQueue.main.async {
                    complete?(false)
                }
                return
            }
            
            self.api.getInvitedUserList(userId: self.user.identifier) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    if let recommends = response.data?.records {
                        self.recommendations = recommends
                    } else {
                        showErrorDialog(code: response.code)
                        isSuccess = false
                    }
                case .failure(let error):
                    if error.responseCode == nil {
                        showNetworkErrorDialog()
                    } else {
                        error.showErrorDialog()
                        print("Error occured \(error)")
                    }
                    isSuccess = false
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            DispatchQueue.main.async { [weak self] in
                FullScreenSpinner().hide()
                
                self?.tableView.reloadData()
                complete?(true)
            }
        }
    }
    
    @objc func aboutTabPressed(_ sender: UIButton) {
        currentTab = .about
    }
    
    @objc func reviewsTabPressed(_ sender: UIButton) {
        currentTab = .reviews
    }
    
    @objc private func goToRecommendations() {
        performSegue(withIdentifier: "goToRecommendations", sender: self)
    }
    
    @objc private func goToReviews() {
        performSegue(withIdentifier: "goToReviews", sender: self)
    }
    
    @objc override func goToMyProfile(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "goToAccountMenu", sender: self)
    }
    
    @objc func inviteReviewPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToInvite", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RecommendationsViewController {
            vc.cupid = user.toUserInfo()
            vc.recommendations = recommendations
        } else if let vc = segue.destination as? ReviewsViewController {
            vc.forUser = user.toUserInfo()
            vc.reviews = reviews
            vc.ableToWrite = false
        } else if let vc = segue.destination as? ReviewsWriteEditViewController,
                  let review = selectedReview {
            vc.review = review
        }
    }
}

extension MyProfileCupidViewController: RecommendationsCellDelegate {
    func openProfile(profile: UserQuery) {
        openProfile(user: profile)
    }
}

extension MyProfileCupidViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentTab == .about {
            return AboutTableRows.getRows().count
        } else {
            return ReviewsTableRows.getRows(reviews: reviews.count).count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = user.toUserInfo()
        
        switch currentTab {
        case .about:
            let row = AboutTableRows.getRows()[indexPath.row]
            switch row {
            case .photos:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyProfileCupidHeadPhotoCell", for: indexPath) as? MyProfileCupidHeadPhotoCell else {
                    return MyProfileCupidHeadPhotoCell()
                }
                cell.config(user: user)
                cell.viewController = self
                cell.selectionStyle = .none
                return cell
            case .nameBar:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyProfileCupidNameCell", for: indexPath) as? MyProfileCupidNameCell else {
                    return MyProfileCupidNameCell()
                }
                cell.config(user: user)
                cell.selectionStyle = .none
                return cell
            case .tabBar:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "CupidProfileTabsCell", for: indexPath) as? ButtonTabsTableCell else {
                    return ButtonTabsTableCell()
                }
                let selected = currentTab.rawValue
                for button in cell.buttons {
                    if button.tag == Tabs.about.rawValue {
                        button.addTarget(self, action: #selector(aboutTabPressed), for: .touchUpInside)
                    } else if button.tag == Tabs.reviews.rawValue {
                        button.addTarget(self, action: #selector(reviewsTabPressed), for: .touchUpInside)
                    }
                
                    if button.tag == selected {
                        button.insertSeparator(height: 4.0,
                                               color: themeManager.themeData!.textLabel.hexColor,
                                               inset: 0.0,
                                               position: .bottom)
                    } else {
                        button.removeSeparator()
                    }
                }
                cell.selectionStyle = .none
                return cell
            case .about:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreTitleBodyCell", for: indexPath) as? ExploreTitleBodyCell else {
                    return ExploreTitleBodyCell()
                }
                cell.titleLabel.text = "About Me"
                cell.paragraphLabel.text = user.aboutMe
                cell.selectionStyle = .none
                return cell
            case .basicInfo:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreTitleBodyCell", for: indexPath) as? ExploreTitleBodyCell else {
                    return ExploreTitleBodyCell()
                }
                cell.titleLabel.text = "Basic Info"
                cell.paragraphLabel.text = user.aboutMeParagragh()
                cell.selectionStyle = .none
                return cell
            case .recommends:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecommendationsCell", for: indexPath) as? RecommendationsCell else {
                    return RecommendationsCell()
                }
                cell.seeAllButton.addTarget(self, action: #selector(goToRecommendations), for: .touchUpInside)
                cell.config(recommendations: recommendations) { [weak self] in
                    self?.tableView.beginUpdates()
                    self?.tableView.endUpdates()
                }
                cell.delegate = self
                cell.selectionStyle = .none
                return cell
            case .separator:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SeparatorCell", for: indexPath) as? SeparatorCell else {
                    return SeparatorCell()
                }
                cell.selectionStyle = .none
                return cell
            case .write:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "WriteCell", for: indexPath) as? ButtonTableCell else {
                    return ButtonTableCell()
                }
                cell.button.addTarget(self, action: #selector(inviteReviewPressed), for: .touchUpInside)
                return cell
            }
        case .reviews:
            let row = ReviewsTableRows.getRows(reviews: reviews.count)[indexPath.row]
            switch row {
            case .photos:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyProfileCupidHeadPhotoCell", for: indexPath) as? MyProfileCupidHeadPhotoCell else {
                    return MyProfileCupidHeadPhotoCell()
                }
                cell.config(user: user)
                cell.viewController = self
                cell.selectionStyle = .none
                return cell
            case .tabBar:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "CupidProfileTabsCell", for: indexPath) as? ButtonTabsTableCell else {
                    return ButtonTabsTableCell()
                }
                let selected = currentTab.rawValue
                for button in cell.buttons {
                    if button.tag == Tabs.about.rawValue {
                        button.addTarget(self, action: #selector(aboutTabPressed), for: .touchUpInside)
                    } else if button.tag == Tabs.reviews.rawValue {
                        button.addTarget(self, action: #selector(reviewsTabPressed), for: .touchUpInside)
                    }
                
                    if button.tag == selected {
                        button.insertSeparator(height: 4.0,
                                               color: themeManager.themeData!.textLabel.hexColor,
                                               inset: 0.0,
                                               position: .bottom)
                    } else {
                        button.removeSeparator()
                    }
                }
                cell.selectionStyle = .none
                return cell
            case .seeAll:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SeeAllReviewsCell", for: indexPath) as? ButtonTableCell else {
                    return ButtonTableCell()
                }
                cell.button.addTarget(self, action: #selector(goToReviews), for: .touchUpInside)
                cell.selectionStyle = .none
                return cell
            case .review:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SingleReviewTableViewCell", for: indexPath) as? SingleReviewTableViewCell else {
                    return SingleReviewTableViewCell()
                }
                let review = reviews[indexPath.row - ReviewsTableRows.review.rawValue]
                cell.config(data: review, expandAction: { [weak self] in
                    self?.tableView.beginUpdates()
                    self?.tableView.endUpdates()
                })
                cell.selectionStyle = .none
                return cell
            case .separator:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SeparatorCell", for: indexPath) as? SeparatorCell else {
                    return SeparatorCell()
                }
                cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch currentTab {
        case .reviews:
            let row = ReviewsTableRows.getRows(reviews: reviews.count)[indexPath.row]
            switch row {
            case .review:
                let review = reviews[indexPath.row - ReviewsTableRows.review.rawValue]
                selectedReview = review
                performSegue(withIdentifier: "openReview", sender: self)
            default:
                break
            }
        default:
            break
        }
    }
}
