//
//  CupidProfileViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-25.
//

import UIKit
import ImageViewer
import CRRefresh

class CupidProfileViewController: BaseViewController {
    static let MaxNumberOfReviewsToShow = 10
    
    var userId: String!
    var forUser: UserInfo? {
        didSet {
            userId = forUser?.identifier
            title = forUser?.firstName
        }
    }
    
    enum AboutTableRows: Int {
        case photos
        case nameBar
        case tabBar
        case separator
        case about
        case basicInfo
        case recommends
        
        static func getRows() -> [AboutTableRows] {
            let rows: [AboutTableRows] = [.photos, .nameBar, .tabBar, .separator, .about, .basicInfo, .recommends]
            return rows
        }
    }
    
    private enum ReviewsTableRows: Int {
        case photos
        case tabBar
        case separator
        case write
        case seeAll
        case review
        
        static func getRows(reviews: Int) -> [ReviewsTableRows] {
            var rows: [ReviewsTableRows] = [.photos, .tabBar, .separator, .write, .seeAll]
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
    
    private var timer: Timer?
    
    override func setup() {
        super.setup()
        
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) { [weak self] in
            /// start refresh
            /// Do anything you want...
            self?.fetchData(complete: { success in
                self?.tableView.cr.endHeaderRefresh()
            })
        }
        
        tableView.contentInset = .init(top: 0, left: 0, bottom: 100, right: 0)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
        timer = nil
    }
    
    private func fetchData(complete: ((Bool) -> Void)? = nil) {
        forUser == nil ? FullScreenSpinner().show() : nil
        
        var isSuccess: Bool = true
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            if self.forUser == nil {
                self.api.fetchUserProfile(userId: self.userId) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let response):
                        if let user = response.data {
                            self.forUser = user
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
            }
            
            guard isSuccess else {
                DispatchQueue.main.async {
                    FullScreenSpinner().hide()
                    complete?(false)
                }
                return
            }
            
            self.api.getUserCommentList(userId: self.userId) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    if let reviews = response.data {
                        self.reviews = reviews.records
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
                    FullScreenSpinner().hide()
                    complete?(false)
                }
                return
            }
            
            self.api.getInvitedUserList(userId: self.userId) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    if let reviews = response.data {
                        self.recommendations = reviews.records
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
                self?.resetVisitTimer()
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
        guard forUser != nil else { return }
        
        performSegue(withIdentifier: "goToRecommendations", sender: self)
    }
    
    @objc private func goToReviews() {
        guard forUser != nil else { return }
        
        performSegue(withIdentifier: "goToReviews", sender: self)
    }
    
    @objc private func openReview() {
        guard selectedReview != nil else { return }
        
        performSegue(withIdentifier: "openReview", sender: self)
    }
    
    @objc private func goToWriteReview() {
        selectedReview = nil
        performSegue(withIdentifier: "openReview", sender: self)
    }
    
    @objc func heartPressed(_ sender: UITapGestureRecognizer)  {
        guard let user = forUser else { return }
        
        api.changeLikeStatus(likeStatus: user.isLiked ?? false ? 0 : 1, targetUserId: user.identifier) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if response.data != nil {
                    self.forUser?.isLiked = !(user.isLiked ?? false)
                    self.forUser?.likeAmount = (user.likeAmount ?? 0) + (user.isLiked ?? false ? -1 : 1)
                    sender.view?.tintColor = (self.forUser?.isLiked ?? false) ? self.themeManager.themeData!.pink.hexColor : .white
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                } else {
                    showErrorDialog(code: response.code)
                }
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
            }
        }
    }
    
    @objc func goToChatPressed(_ sender: UIButton)  {
        guard let user = forUser else { return }
        
        openToChat(userId: user.identifier)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let user = forUser else { return }
        
        if let vc = segue.destination as? RecommendationsViewController {
            vc.cupid = user
            vc.recommendations = recommendations
        } else if let vc = segue.destination as? ReviewsViewController {
            vc.forUser = user
            vc.reviews = reviews
            vc.ableToWrite = true
        } else if let vc = segue.destination as? ReviewsWriteEditViewController {
            vc.targetUserId = user.identifier
            vc.review = selectedReview
        } else if let vc = segue.destination as? UserOptionsViewController {
            vc.targetUserId = user.identifier
        }
    }
    
    @objc private func fireVisit() {
        guard let user = forUser else { return }
        
        api.visit(userId: user.identifier) { result in
            switch result {
            case .success(let success):
                if success {
                    print("Visited user \(user.identifier)")
                }
            default:
                break;
            }
        }
    }
    
    private func resetVisitTimer() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
        timer = Timer.scheduledTimer(timeInterval: SecondsBeforeCallingVisit,
                                     target: self,
                                     selector: #selector(fireVisit),
                                     userInfo: nil,
                                     repeats: false)
    }
}

extension CupidProfileViewController: RecommendationsCellDelegate {
    func openProfile(profile: UserQuery) {
        openProfile(user: profile)
    }
}

extension CupidProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard forUser != nil else { return 0 }
        
        if currentTab == .about {
            return AboutTableRows.getRows().count
        } else {
            return ReviewsTableRows.getRows(reviews: reviews.count).count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch currentTab {
        case .reviews:
            let row = ReviewsTableRows.getRows(reviews: reviews.count)[indexPath.row]
            switch row {
            case .write:
                if let _ = reviews.filter({ $0.userId == userManager.realUser!.identifier }).first {
                    return 0.0
                }
            default:
                break
            }
        default:
            break
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let user = forUser else { return UITableViewCell() }
        
        switch currentTab {
        case .about:
            let row = AboutTableRows.getRows()[indexPath.row]
            switch row {
            case .photos:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "CupidProfilePhotosCell", for: indexPath) as? CupidProfilePhotosCell else {
                    return CupidProfilePhotosCell()
                }
                cell.config(user: user)
                cell.heartTapGesture.addTarget(self, action: #selector(heartPressed))
                cell.chatTapGesture.addTarget(self, action: #selector(goToChatPressed))
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
            }
        case .reviews:
            let row = ReviewsTableRows.getRows(reviews: reviews.count)[indexPath.row]
            switch row {
            case .photos:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "CupidProfilePhotosCell", for: indexPath) as? CupidProfilePhotosCell else {
                    return CupidProfilePhotosCell()
                }
                cell.config(user: user)
                cell.heartTapGesture.addTarget(self, action: #selector(heartPressed))
                cell.chatTapGesture.addTarget(self, action: #selector(goToChatPressed))
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
            case .write:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "WriteReviewButtonCell", for: indexPath) as? ButtonTableCell else {
                    return ButtonTableCell()
                }
                cell.button.addTarget(self, action: #selector(goToWriteReview), for: .touchUpInside)
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
                openReview()
            default:
                break
            }
        default:
            break
        }
    }
}
