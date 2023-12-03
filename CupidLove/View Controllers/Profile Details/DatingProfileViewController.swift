//
//  DatingProfileViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-24.
//

import UIKit
import CRRefresh

class DatingProfileViewController: BaseViewController {
    var userId: String!
    var forUser: UserInfo? {
        didSet {
            userId = forUser?.identifier
            title = forUser?.firstName
        }
    }
    
    private enum AboutTableRows: Int {
        case photos
        case separator1
        case tabBar
        case about
        case personality
        case aboutMe
        case photo1
        case questions
        case interests
        case photo2
        case endorsements
        case writeEndorsement
        case invitedBy
        
        static func getRows(numberOfQuestions: Int, invitedBy: Bool) -> [AboutTableRows] {
            var rows: [AboutTableRows] = [.photos, .separator1, .tabBar, .about, .personality, .aboutMe, .photo1, .interests, .photo2, .endorsements, .writeEndorsement]
            for _ in 0..<numberOfQuestions {
                rows.insert(.questions, at: AboutTableRows.photo1.rawValue + 1)
            }
            if invitedBy {
                rows.append(.invitedBy)
            }
            return rows
        }
    }
    
    private enum HopeYouAreTableRows: Int {
        case photos
        case separator1
        case tabBar
        case aboutPartnerParagraph
        case aboutPartnerDetails
        
        static func getRows() -> [HopeYouAreTableRows] {
            let rows: [HopeYouAreTableRows] = [.photos, .separator1, .tabBar, .aboutPartnerParagraph, .aboutPartnerDetails]
            return rows
        }
    }
    
    private enum Tabs: Int {
        case about
        case hopeYouAre
    }
    
    @IBOutlet weak var tableView: UITableView!

    private var endorsements: [ReviewRecord] = []
    private var selectedEndorsement: ReviewRecord?
    
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

        view.backgroundColor = themeManager.themeData!.lightPink.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                    if let endorsements = response.data {
                        self.endorsements = endorsements.records
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
    
    @objc func hopeYouAreTabPressed(_ sender: UIButton) {
        currentTab = .hopeYouAre
    }
    
    @objc func seeEndorsementPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToEndorsements", sender: self)
    }
    
    @objc func writeEndorsementPressed(_ sender: UIButton) {
        selectedEndorsement = nil
        performSegue(withIdentifier: "goToWriteEndorsement", sender: self)
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
        if let vc = segue.destination as? EndorsementsViewController {
            vc.forUser = forUser
            vc.endorsements = endorsements
            vc.ableToWrite = true
        } else if let vc = segue.destination as? EndorsementsWriteEditViewController {
            vc.endor = selectedEndorsement
            vc.targetUserId = forUser?.identifier
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

extension DatingProfileViewController: EndorsementsTableCellDelegate {
    func openEndorsement(endorsement: ReviewRecord) {
        selectedEndorsement = endorsement
        performSegue(withIdentifier: "goToWriteEndorsement", sender: self)
    }
}

extension DatingProfileViewController: InvitedByTableCellDelegate {
    func openProfile(profile: InvitedByUserInfo) {
        openProfile(user: profile)
    }
}

extension DatingProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let user = forUser else { return 0 }
        
        if currentTab == .about {
            return AboutTableRows.getRows(numberOfQuestions: user.myAnswerDtoList?.count ?? 0, invitedBy: !(user.invitedBy?.isEmpty ?? true)).count
        } else {
            return HopeYouAreTableRows.getRows().count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let user = forUser else { return 0.0 }
        
        switch currentTab {
        case .about:
            let row = AboutTableRows.getRows(numberOfQuestions: user.myAnswerDtoList?.count ?? 0, invitedBy: !(user.invitedBy?.isEmpty ?? true))[indexPath.row]
            switch row {
            case .photo1:
                if (user.personalPhotos?.count ?? 0) < 2 {
                    return 0.0
                }
            case .photo2:
                if (user.personalPhotos?.count ?? 0) < 3 {
                    return 0.0
                }
            case .writeEndorsement:
                if let _ = endorsements.filter({ $0.userId == userManager.realUser!.identifier }).first {
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
            let row = AboutTableRows.getRows(numberOfQuestions: user.myAnswerDtoList?.count ?? 0, invitedBy: !(user.invitedBy?.isEmpty ?? true))[indexPath.row]
            switch row {
            case .photos:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "DatingProfilePhotosCell", for: indexPath) as? DatingProfilePhotosCell else {
                    return DatingProfilePhotosCell()
                }
                cell.config(user: user)
                cell.heartTapGesture.addTarget(self, action: #selector(heartPressed))
                cell.chatTapGesture.addTarget(self, action: #selector(goToChatPressed))
                cell.viewController = self
                return cell
            case .separator1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SeparatorCell", for: indexPath) as? SeparatorCell else {
                    return SeparatorCell()
                }
                return cell
            case .tabBar:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "DatingProfileTabsCell", for: indexPath) as? ButtonTabsTableCell else {
                    return ButtonTabsTableCell()
                }
                let selected = currentTab.rawValue
                for button in cell.buttons {
                    if button.tag == Tabs.about.rawValue {
                        button.addTarget(self, action: #selector(aboutTabPressed), for: .touchUpInside)
                    } else if button.tag == Tabs.hopeYouAre.rawValue {
                        button.addTarget(self, action: #selector(hopeYouAreTabPressed), for: .touchUpInside)
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
                return cell
            case .about:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreParagraphCell", for: indexPath) as? ExploreParagraphCell else {
                    return ExploreParagraphCell()
                }
                cell.paragraphLabel.text = user.aboutMe
                return cell
            case .personality:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreKeywordsCell", for: indexPath) as? ExploreKeywordsCell else {
                    return ExploreKeywordsCell()
                }
                cell.viewController = self
                cell.titleLabel.text = "Personality"
                cell.config(personalities: user.personality, showAdd: false, finishAction: { [weak self] in
                    guard let tableView = self?.tableView else { return }
                    
                    self?.refreshTableCellHeights(tableView: tableView)
                })
                return cell
            case .aboutMe:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreTitleBodyCell", for: indexPath) as? ExploreTitleBodyCell else {
                    return ExploreTitleBodyCell()
                }
                cell.titleLabel.text = "About Me"
                cell.paragraphLabel.text = "\(user.aboutMeParagragh())\n\n\(user.aboutMeParagragh2())"
                return cell
            case .photo1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleImageTableCell", for: indexPath) as? SimpleImageTableCell else {
                    return SimpleImageTableCell()
                }
                if (user.personalPhotos?.count ?? 0) >= 2 {
                    let secondPhoto = user.personalPhotos![1]
                    cell.config(data: secondPhoto, blurred: user.isVipBlur ?? false)
                } else {
                    cell.picture.image = nil
                }
                return cell
            case .photo2:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleImageTableCell", for: indexPath) as? SimpleImageTableCell else {
                    return SimpleImageTableCell()
                }
                if (user.personalPhotos?.count ?? 0) >= 3 {
                    let thirdPhoto = user.personalPhotos![2]
                    cell.config(data: thirdPhoto, blurred: user.isVipBlur ?? false)
                } else {
                    cell.picture.image = nil
                }
                return cell
            case .questions:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreTitleBodyCell", for: indexPath) as? ExploreTitleBodyCell, let myAnswerDtoList = user.myAnswerDtoList else {
                    return ExploreTitleBodyCell()
                }
                let answer = myAnswerDtoList[indexPath.row - AboutTableRows.questions.rawValue]
                if let question = userManager.profileQuestions?.first(where: { $0.identifier == answer.questionId }) {
                    cell.titleLabel.text = question.question
                    cell.paragraphLabel.text = answer.answer
                } else {
                    cell.titleLabel.text = ""
                    cell.paragraphLabel.text = ""
                }
                return cell
            case .interests:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreInterestsCell", for: indexPath) as? ExploreInterestsCell else {
                    return ExploreInterestsCell()
                }
                cell.viewController = self
                cell.config(interests: user.interests, showAdd: false, finishAction: { [weak self] in
                    guard let tableView = self?.tableView else { return }
                    
                    self?.refreshTableCellHeights(tableView: tableView)
                })
                return cell
            case .endorsements:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "EndorsementsTableCell", for: indexPath) as? EndorsementsTableCell else {
                    return EndorsementsTableCell()
                }
                cell.topRightButton.addTarget(self, action: #selector(seeEndorsementPressed), for: .touchUpInside)
                cell.config(data: endorsements)
                cell.delegate = self
                return cell
            case .writeEndorsement:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "WriteEndorsementCell", for: indexPath) as? ButtonTableCell else {
                    return ButtonTableCell()
                }
                cell.button.addTarget(self, action: #selector(writeEndorsementPressed), for: .touchUpInside)
                return cell
            case .invitedBy:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "InvitedByTableCell", for: indexPath) as? InvitedByTableCell,
                      let invitedBy = user.invitedByUserInfo else {
                    return InvitedByTableCell()
                }
                cell.config(user: invitedBy)
                cell.delegate = self
                return cell
            }
        case .hopeYouAre:
            let row = HopeYouAreTableRows.getRows()[indexPath.row]
            switch row {
            case .photos:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "DatingProfilePhotosCell", for: indexPath) as? DatingProfilePhotosCell else {
                    return MyProfileHeadPhotoCell()
                }
                cell.config(user: user)
                cell.heartTapGesture.addTarget(self, action: #selector(heartPressed))
                cell.chatTapGesture.addTarget(self, action: #selector(goToChatPressed))
                cell.viewController = self
                return cell
            case .separator1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SeparatorCell", for: indexPath) as? SeparatorCell else {
                    return SeparatorCell()
                }
                return cell
            case .tabBar:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "DatingProfileTabsCell", for: indexPath) as? ButtonTabsTableCell else {
                    return ButtonTabsTableCell()
                }
                let selected = currentTab.rawValue
                for button in cell.buttons {
                    if button.tag == Tabs.about.rawValue {
                        button.addTarget(self, action: #selector(aboutTabPressed), for: .touchUpInside)
                    } else if button.tag == Tabs.hopeYouAre.rawValue {
                        button.addTarget(self, action: #selector(hopeYouAreTabPressed), for: .touchUpInside)
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
                return cell
            case .aboutPartnerParagraph:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreParagraphCell", for: indexPath) as? ExploreParagraphCell else {
                    return ExploreParagraphCell()
                }
                cell.paragraphLabel.text = user.desiredDescription
                return cell
            case .aboutPartnerDetails:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreTitleBodyCell", for: indexPath) as? ExploreTitleBodyCell else {
                    return ExploreTitleBodyCell()
                }
                cell.titleLabel.text = "About her/him"
                cell.paragraphLabel.text = user.aboutPartnerParagraph()
                return cell
            }
        }
    }
}
