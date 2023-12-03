//
//  TestViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-23.
//

import UIKit

class TestViewController: BaseViewController {

    private enum Rows: Int {
        case photos
        case about
        case personality
        case aboutMe
        case questions
        case interests
        case aboutPartnerParagraph
        case aboutPartnerDetails
        
        static func getSections() -> Int {
            return 3
        }
        
        static func getRows(section: Int, numQuestions: Int) -> [Rows] {
            switch section {
            case 0:
                return [.photos, .about, .aboutMe, .personality]
            case 1:
                var rows: [Rows] = []
                for _ in 0..<numQuestions {
                    rows.append(.questions)
                }
                return rows
            case 2:
                return [.interests, .aboutPartnerParagraph, .aboutPartnerDetails]
            default:
                return []
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var email: String? {
        didSet {
            title = email
        }
    }
    
    var userType: UserTypeMode = .normal
    var gender: GenderChoice = .male
    var profileQuestions: [QuestionData]? {
        didSet {
            guard let profileQuestions = profileQuestions else {
                return
            }
            
            var answersArray: [QuestionAnswer] = []
            for _ in 0...Int.random(in: 0..<profileQuestions.count) {
                let random = profileQuestions.randomElement()!
                if !answersArray.filter({$0.questionId == random.identifier}).isEmpty {
                    continue
                }
                
                answersArray.append(QuestionAnswer(questionId: random.identifier, answer: faker.lorem.sentences()))
            }
            self.myAnswers = answersArray
        }
    }
    var myAnswers: [QuestionAnswer]?
    var params: UpdateUserParams?
    var myUserInfo: MyUserInfo? {
        didSet {
            if !loop, let myUserInfo = myUserInfo {
                openProfile(user: myUserInfo)
            }
        }
    }
    
    private var loop = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        api.service.accessToken = "6236afe389dec76e7c3fd7c8d43a8d3b85a14fa5b3141398294e72a9"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        randomPressed(UIButton())
    }
    
    @IBAction func randomPressed(_ sender: Any) {
        FullScreenSpinner().show()
        
        email = "\(faker.internet.username())@\(faker.internet.domainName())"
        userType = UserTypeMode.random()
        gender = GenderChoice.random()
        var isSuccess: Bool = true
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.api.getQuestionList { result in
                switch result {
                case .success(let response):
                    if let questionsData = response.data {
                        self.profileQuestions = questionsData
                    } else {
                        isSuccess = false
                        showErrorDialog(code: response.code)
                    }
                case .failure(let error):
                    guard let _ = error.responseCode else {
                        showNetworkErrorDialog()
                        isSuccess = false
                        return
                    }
                    error.showErrorDialog()
                    isSuccess = false
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            guard isSuccess else {
                DispatchQueue.main.async {
                    FullScreenSpinner().hide()
                }
                return
            }
            
            var photoModels: [PhotoAPIModel] = []
            self.api.getRandomPhotos(gender: self.gender) { result in
                switch result {
                case .success(let response):
                    photoModels = response
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
                }
                return
            }
            
            self.params = UpdateUserParams(type: self.userType, photos: photoModels)
            
            DispatchQueue.main.async { [weak self] in
                FullScreenSpinner().hide()
                
                self?.tableView.reloadData()
                
                if self?.loop ?? false {
                    self?.savePressed(UIBarButtonItem())
                    //sleep(3)
                }
            }
        }
    }
    
    @IBAction func savePressed(_ sender: Any) {
        guard let params = params, let email = email else { return }
        
        FullScreenSpinner().show()
        
        var isSuccess: Bool = true
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.api.checkRegisterEmail(email: email) { result in
                switch result {
                case .success(let result):
                    if !(result.data ?? false) {
                        isSuccess = false
                        showErrorDialog(code: result.code)
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
                }
                return
            }
            
            self.api.register(email: email, code: "999999", userType: self.userType) { result in
                switch result {
                case .success(let response):
                    if let loginInfo = response.data, !loginInfo.token.isEmpty {
                        self.api.service.accessToken = loginInfo.token
                    } else {
                        isSuccess = false
                        showErrorDialog(code: response.code)
                    }
                case .failure(let error):
                    guard let _ = error.responseCode else {
                        showNetworkErrorDialog()
                        isSuccess = false
                        return
                    }
                    error.showErrorDialog()
                    isSuccess = false
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            guard isSuccess else {
                DispatchQueue.main.async {
                    FullScreenSpinner().hide()
                }
                return
            }
            
            self.api.updateProfileRegistration(params: params) { result in
                switch result {
                case .success(let response):
                    if response.data == nil {
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
                semaphore.signal()
            }
            semaphore.wait()
            
            guard isSuccess else {
                DispatchQueue.main.async {
                    FullScreenSpinner().hide()
                }
                return
            }
            
            self.api.getDetailUser { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    if let user = response.data {
                        self.myUserInfo = user
                    } else {
                        showErrorDialog(code: response.code)
                    }
                case .failure(let error):
                    error.showErrorDialog()
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            DispatchQueue.main.async { [weak self] in
                FullScreenSpinner().hide()
                
                self?.tableView.reloadData()
                
                if self?.loop ?? false {
                    sleep(2)
                    self?.randomPressed(UIBarButtonItem())
                }
            }
        }
    }
}

extension TestViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let _ = params else { return 0 }
        
        return Rows.getSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = params else { return 0 }
        
        return Rows.getRows(section: section, numQuestions: myAnswers?.count ?? 0).count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let _ = params else { return 0.0 }
        
        let row = Rows.getRows(section: indexPath.section, numQuestions: myAnswers?.count ?? 0)[indexPath.row]
        
        switch row {
        case .personality:
            if userType == .cupid {
                return 0.0
            }
        case .questions:
            if userType == .cupid {
                return 0.0
            }
        case .interests:
            if userType == .cupid {
                return 0.0
            }
        case .aboutPartnerParagraph:
            if userType == .cupid {
                return 0.0
            }
        case .aboutPartnerDetails:
            if userType == .cupid {
                return 0.0
            }
        default:
            break
        }
        
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let params = params else { return UITableViewCell() }
        
        let row = Rows.getRows(section: indexPath.section, numQuestions: myAnswers?.count ?? 0)[indexPath.row]
        
        switch row {
        case .photos:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyProfileHeadPhotoCell", for: indexPath) as? MyProfileHeadPhotoCell else {
                return MyProfileHeadPhotoCell()
            }
            cell.config(params: params)
            cell.viewController = self
            return cell
        case .about:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreParagraphCell", for: indexPath) as? ExploreParagraphCell else {
                return ExploreParagraphCell()
            }
            cell.paragraphLabel.text = params.aboutMe
            return cell
        case .personality:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreKeywordsCell", for: indexPath) as? ExploreKeywordsCell else {
                return ExploreKeywordsCell()
            }
            cell.viewController = self
            cell.titleLabel.text = "Personality"
            cell.config(personalities: params.personality, showAdd: false, finishAction: { [weak self] in
                guard let tableView = self?.tableView else { return }
                
                self?.refreshTableCellHeights(tableView: tableView)
            })
            return cell
        case .aboutMe:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreTitleBodyCell", for: indexPath) as? ExploreTitleBodyCell else {
                return ExploreTitleBodyCell()
            }
            cell.titleLabel.text = "About Me"
            if userType == .normal {
                cell.paragraphLabel.text = "\(params.aboutMeParagragh(userType: userType))\n\n\(params.aboutMeParagragh2())"
            } else {
                cell.paragraphLabel.text = "\(params.aboutMeParagragh(userType: userType))"
            }
            
            return cell
        case .questions:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreTitleBodyCell", for: indexPath) as? ExploreTitleBodyCell, let myAnswers = myAnswers else {
                return ExploreTitleBodyCell()
            }
            let answer = myAnswers[indexPath.row]
            if let question = profileQuestions!.first(where: { $0.identifier == answer.questionId }) {
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
            cell.config(interests: params.interests, showAdd: false, finishAction: { [weak self] in
                guard let tableView = self?.tableView else { return }
                
                self?.refreshTableCellHeights(tableView: tableView)
            })
            return cell
        case .aboutPartnerParagraph:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreParagraphCell", for: indexPath) as? ExploreParagraphCell else {
                return ExploreParagraphCell()
            }
            cell.paragraphLabel.text = params.desiredDescription
            return cell
        case .aboutPartnerDetails:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExploreTitleBodyCell", for: indexPath) as? ExploreTitleBodyCell else {
                return ExploreTitleBodyCell()
            }
            cell.titleLabel.text = "About her/him"
            cell.paragraphLabel.text = params.aboutPartnerParagraph()
            return cell
        }
    }
}
