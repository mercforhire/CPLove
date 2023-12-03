//
//  MyProfileViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-24.
//

import UIKit
import CRRefresh

class MyProfileUserViewController: BaseViewController {

    private enum AboutTableRows: Int {
        case photos
        case separator1
        case tabBar
        case about
        case personality
        case aboutMe
        case questions
        case addQuestion
        case interests
        case endorsements
        case write
        
        static func getRows(numberOfQuestions: Int) -> [AboutTableRows] {
            var rows: [AboutTableRows] = [.photos, .separator1, .tabBar, .about, .personality, .aboutMe, .addQuestion, .interests, .endorsements, .write]
            for _ in 0..<numberOfQuestions {
                rows.insert(.questions, at: AboutTableRows.aboutMe.rawValue + 1)
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
        case separator2
        case editLookingFor
        
        static func getRows() -> [HopeYouAreTableRows] {
            let rows: [HopeYouAreTableRows] = [.photos, .separator1, .tabBar, .aboutPartnerParagraph, .aboutPartnerDetails, .separator2, .editLookingFor]
            return rows
        }
    }
    
    private enum Tabs: Int {
        case about
        case hopeYouAre
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    private var me: UserInfo?
    private var endorsements: [ReviewRecord] = []
    private var selectedEndorsement: ReviewRecord?
    
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
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        me = user.toUserInfo()
        tableView.reloadData()
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
                    if let endorsements = response.data?.records {
                        self.endorsements = endorsements
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
                self?.me = self?.user.toUserInfo()
                self?.tableView.reloadData()
                complete?(isSuccess)
            }
        }
    }
    
    @objc func aboutTabPressed(_ sender: UIButton) {
        currentTab = .about
    }
    
    @objc func hopeYouAreTabPressed(_ sender: UIButton) {
        currentTab = .hopeYouAre
    }
    
    @objc func addQuestionPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToQuestions", sender: self)
    }
    
    @objc func editLookingForPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToEditProfile", sender: self)
    }
    
    @objc override func goToMyProfile(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "goToAccountMenu", sender: self)
    }
    
    @objc func seeEndorsementPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToEndorsements", sender: self)
    }
    
    @objc func inviteEndorsementPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToInvite", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EndorsementsViewController {
            vc.forUser = me
            vc.endorsements = endorsements
            vc.ableToWrite = false
        } else if let vc = segue.destination as? EndorsementsWriteEditViewController,
                  let endorsement = selectedEndorsement {
            vc.endor = endorsement
        }
    }
}

extension MyProfileUserViewController: EndorsementsTableCellDelegate {
    func openEndorsement(endorsement: ReviewRecord) {
        selectedEndorsement = endorsement
        performSegue(withIdentifier: "openEndorsement", sender: self)
    }
}

extension MyProfileUserViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch currentTab {
        case .about:
            let row = AboutTableRows.getRows(numberOfQuestions: user.myAnswerDtoList?.count ?? 0)[indexPath.row]
            switch row {
            case .endorsements:
                if endorsements.isEmpty {
                    return 0
                }
            default:
                break
            }
        default:
            break
        }
        
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentTab == .about {
            return AboutTableRows.getRows(numberOfQuestions: user.myAnswerDtoList?.count ?? 0).count
        } else {
            return HopeYouAreTableRows.getRows().count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let user = me else { return UITableViewCell() }
        
        switch currentTab {
        case .about:
            let row = AboutTableRows.getRows(numberOfQuestions: user.myAnswerDtoList?.count ?? 0)[indexPath.row]
            switch row {
            case .photos:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyProfileHeadPhotoCell", for: indexPath) as? MyProfileHeadPhotoCell else {
                    return MyProfileHeadPhotoCell()
                }
                cell.config(user: user)
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
                cell.config(personalities: user.personality, showAdd: true, finishAction: { [weak self] in
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
            case .addQuestion:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyProfileButtonCell1", for: indexPath) as? ButtonTableCell else {
                    return ButtonTableCell()
                }
                cell.button.addTarget(self, action: #selector(addQuestionPressed), for: .touchUpInside)
                return cell
            case .interests:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreInterestsCell", for: indexPath) as? ExploreInterestsCell else {
                    return ExploreInterestsCell()
                }
                cell.viewController = self
                cell.config(interests: user.interests, showAdd: true, finishAction: { [weak self] in
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
            case .write:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "WriteCell", for: indexPath) as? ButtonTableCell else {
                    return ButtonTableCell()
                }
                cell.button.addTarget(self, action: #selector(inviteEndorsementPressed), for: .touchUpInside)
                return cell
            }
        case .hopeYouAre:
            let row = HopeYouAreTableRows.getRows()[indexPath.row]
            switch row {
            case .photos:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyProfileHeadPhotoCell", for: indexPath) as? MyProfileHeadPhotoCell else {
                    return MyProfileHeadPhotoCell()
                }
                cell.config(user: user)
                cell.viewController = self
                return cell
            case .tabBar:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "DatingProfileTabsCell", for: indexPath) as? ButtonTabsTableCell else {
                    return ButtonTabsTableCell()
                }
                let selected = currentTab.rawValue
                for button in cell.buttons {
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
            case .separator1, .separator2:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SeparatorCell", for: indexPath) as? SeparatorCell else {
                    return SeparatorCell()
                }
                return cell
            case .editLookingFor:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyProfileButtonCell2", for: indexPath) as? ButtonTableCell else {
                    return ButtonTableCell()
                }
                cell.button.addTarget(self, action: #selector(editLookingForPressed), for: .touchUpInside)
                return cell
            }
        }
    }
}
