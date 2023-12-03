//
//  MyAccountEditViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-01-25.
//

import UIKit

class EditProfileViewController: BaseTableViewController {

    enum EditTableRows: Int {
        case photos
        case separator
        case blur
        case aboutSelf
        case basicInfo
        case personality
        case questionsHeader
        case questions
        case interests
        case aboutPartner
        case hopeYouAre
        
        func title() -> String {
            switch self {
            case .blur:
                return "Blur my photos"
            case .aboutSelf:
                return "Say something about yourself"
            case .basicInfo:
                return "Basic Info"
            case .personality:
                return "Personality"
            case .questionsHeader:
                return "Questions"
            case .interests:
                return "Interests"
            case .aboutPartner:
                return "Say something about him/her"
            case .hopeYouAre:
                return "Hope you are"
            default:
                return ""
            }
        }
        
        func subtitle() -> String {
            switch self {
            case .blur:
                return "Blur your photos only, your profile information is not blurred."
            case .aboutSelf:
                return "You are unique, share something about your unique self and meet others who are like you."
            case .basicInfo:
                return "Your about me paragraph, assets siblings and child wanted."
            case .aboutPartner:
                return "Share something about what you seek in a partner."
            case .hopeYouAre:
                return "Details on what you seek in a partner."
            default:
                return ""
            }
        }
        
        static func getRows(userType: UserTypeMode, numberOfQuestions: Int = 0) -> [EditTableRows] {
            var rows: [EditTableRows]
            switch userType {
            case .normal:
                rows = [.photos, .blur, .aboutSelf, .basicInfo, .personality, .questionsHeader, .aboutPartner, .hopeYouAre]
                for _ in 0..<numberOfQuestions {
                    rows.insert(.questions, at: 6)
                }
            case .cupid:
                rows = [.photos, .separator, .aboutSelf, .basicInfo]
            case .admin:
                rows = [.photos, .separator, .basicInfo]
            }
            return rows
        }
    }
    
    private var selectedEditScreen: EditScreens?
    
    private let AboutMyselfTextViewTag = 111
    private let AboutPartnerTextViewTag = 222
    
    override func setup() {
        super.setup()
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        tableView.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
                complete?(isSuccess)
            }
        }
    }

    @objc func blurSwitchChanged(sender: UISwitch) {
        
        if !user.isVip {
            showBecomeVIPDialog(forceShow: true)
            sender.isOn = false
            return
        }
        
        print("Blur switch is \(sender.isOn ? "ON" : "OFF")")
        let oldSetting = !sender.isOn
        
        var params: UpdateUserParams = UpdateUserParams()
        params.isVipBlur = sender.isOn
        
        FullScreenSpinner().show()
        userManager.updateProfile(params: params) { [weak self] success in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            
            if !success {
                sender.isOn = oldSetting
            } else {
                self.userManager.realUser?.isVipBlur = sender.isOn
                sender.isOn = !oldSetting
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditBasicInfoViewController, let selectedEditScreen = selectedEditScreen {
            vc.screen = selectedEditScreen
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EditTableRows.getRows(userType: user.userType,
                                     numberOfQuestions: user.myAnswerDtoList?.count ?? 0).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = EditTableRows.getRows(userType: user.userType,
                                        numberOfQuestions: user.myAnswerDtoList?.count ?? 0)[indexPath.row]

        switch row {
        case .photos:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PhotosCell", for: indexPath) as? EditInfoPhotosCell else {
                return EditInfoPhotosCell()
            }
            cell.parentVC = self
            cell.config(userManager: userManager)
            cell.selectionStyle = .none
            return cell
        case .blur:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ToggleCell", for: indexPath) as? ToggleSettingssCell else {
                return ToggleSettingssCell()
            }
            cell.topLabel.text = row.title()
            cell.bottomLabel.text = row.subtitle()
            cell.toggleSwitch.addTarget(self, action: #selector(blurSwitchChanged), for: .valueChanged)
            cell.divider.isHidden = true
            cell.toggleSwitch.isOn = user.isVipBlur
            cell.selectionStyle = .none
            return cell
        case .separator:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SeparatorCell", for: indexPath) as? SeparatorCell else {
                return SeparatorCell()
            }
            cell.selectionStyle = .none
            return cell
        case .aboutSelf:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewTableCell", for: indexPath) as? LabelsTextViewDividerTableCell else {
                return LabelsTextViewDividerTableCell()
            }
            cell.label.text = row.title()
            cell.label2.text = row.subtitle()
            cell.textView.text = user.aboutMe
            cell.textView.tag = AboutMyselfTextViewTag
            cell.textView.delegate = self
            cell.selectionStyle = .none
            return cell
        case .basicInfo:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditTableCell", for: indexPath) as? LabelsDividerTableCell else {
                return LabelsDividerTableCell()
            }
            cell.label.text = row.title()
            cell.label2.text = row.subtitle()
            cell.selectionStyle = .none
            return cell
        case .personality:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PersonalityCell", for: indexPath) as? ExploreKeywordsCell else {
                return ExploreKeywordsCell()
            }
            cell.titleLabel.text = row.title()
            cell.config(personalities: user.personality, showAdd: false, finishAction: { [weak self] in
                guard let tableView = self?.tableView else { return }
                
                self?.refreshTableCellHeights(tableView: tableView)
            })
            cell.selectionStyle = .none
            return cell
        case .questionsHeader:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as? LabelTableCell else {
                return LabelTableCell()
            }
            cell.headerLabel.text = row.title()
            cell.selectionStyle = .none
            return cell
        case .questions:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionTableCell", for: indexPath) as? LabelsDividerTableCell,
                    let answers = user.myAnswerDtoList else {
                return LabelsDividerTableCell()
            }
            let answer = answers[indexPath.row - 6]
            if let question = userManager.profileQuestions?.first(where: { $0.identifier == answer.questionId }) {
                cell.label.text = question.question
                cell.label2.text = answer.answer
            } else {
                cell.label.text = ""
                cell.label2.text = ""
            }
            cell.divider.isHidden = answer != answers.last
            cell.selectionStyle = .none
            return cell
        case .interests:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InterestsCell", for: indexPath) as? ExploreInterestsCell else {
                return ExploreInterestsCell()
            }
            cell.config(interests: user.interests, showAdd: false, finishAction: { [weak self] in
                guard let tableView = self?.tableView else { return }
                
                self?.refreshTableCellHeights(tableView: tableView)
            })
            cell.selectionStyle = .none
            return cell
        case .aboutPartner:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewTableCell", for: indexPath) as? LabelsTextViewDividerTableCell else {
                return LabelsTextViewDividerTableCell()
            }
            cell.label.text = row.title()
            cell.label2.text = row.subtitle()
            cell.textView.text = user.desiredDescription
            cell.textView.tag = AboutPartnerTextViewTag
            cell.textView.delegate = self
            cell.selectionStyle = .none
            return cell
        case .hopeYouAre:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditTableCell", for: indexPath) as? LabelsDividerTableCell else {
                return LabelsDividerTableCell()
            }
            cell.label.text = row.title()
            cell.label2.text = row.subtitle()
            cell.selectionStyle = .none
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = EditTableRows.getRows(userType: user.userType,
                                        numberOfQuestions: user.myAnswerDtoList?.count ?? 0)[indexPath.row]
        switch row {
        case .basicInfo:
            selectedEditScreen = .aboutMe
            performSegue(withIdentifier: "goToEditInfo", sender: self)
        case .questionsHeader, .questions:
            performSegue(withIdentifier: "goToQuestions", sender: self)
        case .interests:
            performSegue(withIdentifier: "goToInterests", sender: self)
        case .personality:
            performSegue(withIdentifier: "goToPersonalities", sender: self)
        case .hopeYouAre:
            selectedEditScreen = .aboutHer
            performSegue(withIdentifier: "goToEditInfo", sender: self)
            break
        default:
            break
        }
    }
}

extension EditProfileViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.tag == AboutMyselfTextViewTag {
            let oldText = user.aboutMe
            
            var params: UpdateUserParams = UpdateUserParams()
            params.aboutMe = textView.text
            
            FullScreenSpinner().show()
            userManager.updateProfile(params: params) { [weak self] success in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                if !success {
                    textView.text =  oldText
                } else {
                    self.userManager.realUser?.aboutMe = textView.text
                }
            }
            
        } else if textView.tag == AboutPartnerTextViewTag {
            let oldText = user.desiredDescription
            
            var params: UpdateUserParams = UpdateUserParams()
            params.desiredDescription = textView.text
            
            FullScreenSpinner().show()
            userManager.updateProfile(params: params) { [weak self] success in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                if !success {
                    textView.text =  oldText
                } else {
                    self.userManager.realUser?.desiredDescription = textView.text
                }
            }
        }
    }
}
