//
//  TestReviewViewController.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-24.
//

import UIKit
import Fakery

class TestReviewViewController: BaseViewController {
    enum Mode {
        case writeReview
        case like
        case visit
        case invite
        case delete
        case fixProfile
        case fixPhotos
        case fixBodyType
        case randomChats
        case myChats
        
        static func random() -> Mode {
            return [Mode.writeReview, Mode.like, Mode.visit, Mode.invite].randomElement()!
        }
    }
    
    var users: [UserQuery] = []
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var loop = true
    private var mode: Mode = .randomChats
    
    override func setup() {
        super.setup()
        
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        api.service.accessToken = "6236afe389dec76e7c3fd7c8d43a8d3b85a14fa5b3141398294e72a9"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FullScreenSpinner().show()
        userManager.fetchUser(initialize: true) { [weak self] success in
            FullScreenSpinner().hide()
            
            if success {
                self?.randomPressed(UIButton())
            }
        }
    }
    
    @IBAction func randomPressed(_ sender: Any) {
        FullScreenSpinner().show()
        
        var params = UserQueryParams()
        params.gender = GenderChoice.random()
        
        if Bool.random() {
            api.getMyFilteredDaterList(params: params) { [weak self] result in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                switch result {
                case .success(let response):
                    if let recommendations = response.data?.records {
                        self.users = recommendations
                        self.collectionView.reloadData()
                        if self.loop {
                            self.savePressed(UIBarButtonItem())
                        }
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
        } else {
            api.getFilteredMatchmakerList(params: params) { [weak self] result in
                guard let self = self else { return }
                
                FullScreenSpinner().hide()
                
                switch result {
                case .success(let response):
                    if let recommendations = response.data?.records {
                        self.users = recommendations
                        self.collectionView.reloadData()
                        if self.loop {
                            self.savePressed(UIBarButtonItem())
                        }
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
    }
    
    @IBAction func savePressed(_ sender: Any) {
        guard !users.isEmpty else { return }
        
        let fromUser = users.randomElement()!
        let toUser = users.randomElement()!
        
        guard fromUser != toUser else {
            sleep(1)
            randomPressed(sender)
            return
        }
        
        FullScreenSpinner().show()
        
        var isSuccess: Bool = true
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
        
            switch self.mode {
                
            case .writeReview:
                self.api.login(email: fromUser.email!, code: "999999") { result in
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
                
                self.api.saveUserComment(targetUserId: toUser.identifier,
                                    content: faker.lorem.paragraph(),
                                    rating: toUser.userType == .cupid ? Int.random(in: 1...5) : nil,
                                    type: toUser.userType == .cupid ? .review : .endorsement) { result in

                    switch result {
                    case .success(let response):
                        if response.data ?? false {
                            
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
                
            case .like:
                self.api.login(email: fromUser.email!, code: "999999") { result in
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
                
                let product = self.userManager.products!.first(where: {$0.identifier == "61ee47677797047396285152"})!
                let params = product.toSaveOrderRecordParams(currency: "CAD",
                                                              orderId: faker.bank.iban(),
                                                              orderStatus: 0)
                
                self.api.saveOrderRecord(saveOrderRecord: params) { result in
                    switch result {
                    case .success(let response):
                        if !response.succeed {
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
                
                self.api.changeLikeStatus(likeStatus: 1, targetUserId: toUser.identifier) { result in

                    switch result {
                    case .success(let response):
                        if response.data != nil {
                            
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
                    }
                    return
                }
                
            case .visit:
                self.api.login(email: fromUser.email!, code: "999999") { result in
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
                
                self.api.visit(userId: toUser.identifier) { result in
                    switch result {
                    case .success:
                        break
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
                
            case .invite:
                
                self.api.login(email: toUser.email!, code: "999999") { result in
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
                
                var params = UpdateUserParams()
                params.invitedBy = fromUser.identifier
                self.api.updateProfileRegistration(params: params) { result in
                    switch result {
                    case .success:
                        break
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
            case .delete:
                break
                
            case .fixPhotos:
                guard let fixMe = self.users.filter({
                    return $0.personalPhotos?.first?.photoUrl.contains(string: "get") ?? false
                }).first else {
                    
                    DispatchQueue.main.async { [weak self] in
                        FullScreenSpinner().hide()
                        
                        if self?.loop ?? false {
                            sleep(1)
                            self?.randomPressed(UIBarButtonItem())
                        }
                    }
                    
                    return
                }
                
                self.api.login(email: fixMe.email!, code: "999999") { result in
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
                
                var photoModels: [PhotoAPIModel] = []
                self.api.getRandomPhotos(gender: .male) { result in
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
                
                var params = UpdateUserParams()
                var photoResponses: [PhotoResponse] = []
                for i in photoModels {
                    photoResponses.append(PhotoResponse(photoName: i.previewURL.components(separatedBy: "/").last!,
                                                     photoUrl: i.previewURL,
                                                     thumbnailName: i.previewURL.components(separatedBy: "/").last!,
                                                     thumbnailUrl: i.previewURL))
                }
                params.personalPhotos = photoResponses
                
                self.api.updateProfile(params: params) { result in
                    switch result {
                    case .success:
                        break
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
                
            case .fixProfile:
                var fullUser: UserInfo?
                self.api.fetchUserProfile(userId: toUser.identifier) { result in
                    switch result {
                    case .success(let response):
                        if let user = response.data {
                            fullUser = user
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
                
                if let fullUser = fullUser, fullUser.horoscope != nil {
                    break
                }
                
                self.api.login(email: toUser.email!, code: "999999") { result in
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
                
                var params = UpdateUserParams()
                params.randomize()
                self.api.updateProfile(params: params) { result in
                    switch result {
                    case .success:
                        break
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
                
            case .fixBodyType:
                var fullUser: UserInfo?
                self.api.fetchUserProfile(userId: toUser.identifier) { result in
                    switch result {
                    case .success(let response):
                        if let user = response.data {
                            fullUser = user
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
                
                if let fullUser = fullUser, fullUser.bodyType != nil {
                    break
                }
                
                self.api.login(email: toUser.email!, code: "999999") { result in
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
                
                var params = UpdateUserParams()
                params.bodyType = BodyTypes.list().randomElement()!.title()
                
                self.api.updateProfile(params: params) { result in
                    switch result {
                    case .success:
                        break
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
                
            case .randomChats:
                self.api.login(email: fromUser.email!, code: "999999") { result in
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
                
                var chatListResponse: ChatListResponse?
                
                let params = GetChatMessageParams(current: 1, size: 100, targetUserId: toUser.identifier, userId: fromUser.identifier)
                self.api.getMessagesWithUser(params: params) { result in
                    switch result {
                    case .success(let response):
                        chatListResponse = response
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
                
                guard isSuccess, let conversationId = chatListResponse?.data?.conversationId else {
                    DispatchQueue.main.async {
                        FullScreenSpinner().hide()
                    }
                    return
                }
                
                let params2 = SaveChatMsgParams(conversationId: conversationId, content: faker.lorem.sentences(amount: Int.random(in: 1...4)), isFunction: false, toUserId: toUser.identifier, pushContent: faker.lorem.sentences(amount: Int.random(in: 1...4)))
                self.api.saveChatMessage(params: params2) { result in
                    switch result {
                    case .success(let response):
                        if !response.succeed {
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
                
            case .myChats:
//                self.api.login(email: iAMSpeaking ? "feiyangca@yahoo.ca" : fromUser.email!, code: "999999") { result in
//                    switch result {
//                    case .success(let response):
//                        if let loginInfo = response.data, !loginInfo.token.isEmpty {
//                            self.api.service.accessToken = loginInfo.token
//                            speakerID = loginInfo.identifier
//                        } else {
//                            isSuccess = false
//                            showErrorDialog(code: response.code)
//                        }
//                    case .failure(let error):
//                        guard let _ = error.responseCode else {
//                            showNetworkErrorDialog()
//                            isSuccess = false
//                            return
//                        }
//                        error.showErrorDialog()
//                        isSuccess = false
//                    }
//                    semaphore.signal()
//                }
//                semaphore.wait()
//
//                guard isSuccess else {
//                    DispatchQueue.main.async {
//                        FullScreenSpinner().hide()
//                    }
//                    return
//                }
                
                var chatListResponse: ChatListResponse?
                
                let params = GetChatMessageParams(current: 1, size: 100, targetUserId: fromUser.identifier, userId: toUser.identifier)
                self.api.getMessagesWithUser(params: params) { result in
                    switch result {
                    case .success(let response):
                        chatListResponse = response
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
                
                guard isSuccess, let conversationId = chatListResponse?.data?.conversationId else {
                    DispatchQueue.main.async {
                        FullScreenSpinner().hide()
                    }
                    return
                }
                
                let params2 = SaveChatMsgParams(conversationId: conversationId, content: faker.lorem.sentences(amount: Int.random(in: 1...4)), isFunction: false, toUserId: toUser.identifier, pushContent: faker.lorem.sentences(amount: Int.random(in: 1...4)))
                self.api.saveChatMessage(params: params2) { result in
                    switch result {
                    case .success(let response):
                        if !response.succeed {
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
            }
            
            DispatchQueue.main.async { [weak self] in
                FullScreenSpinner().hide()
                
                if self?.loop ?? false {
                    //sleep(3)
                    self?.randomPressed(UIBarButtonItem())
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name: Notifications.RefreshBlurViews, object: nil)
    }
}

extension TestReviewViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let user = users[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendationCell", for: indexPath) as! RecommendationCell
        cell.config(user: user)
        return cell
    }
}
