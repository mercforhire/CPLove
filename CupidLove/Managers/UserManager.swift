//
//  UserManager.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-27.
//

import Foundation
import Valet
import Alamofire
import Toucan

class UserManager {
    var realUser: MyUserInfo?
    var profileQuestions: [QuestionData]?
    var products: [Product]?
    var loginInfo: LoginInfo?
    var talkingWithUserID: String?
    var blacklistedUserIds: [String] = []
    
    static let shared = UserManager()
    
    private let myValet = Valet.valet(with: Identifier(nonEmpty: "CPLove")!, accessibility: .whenUnlocked)
    
    private var api: CPLoveAPI {
        return CPLoveAPI.shared
    }
    
    init() {
        if let data = try? myValet.object(forKey: "login") {
            loginInfo = LoginInfo.decodeFromData(data: data)
            api.service.accessToken = loginInfo?.token
        }
    }
    
    func isLoggedIn() -> Bool {
        return !(loginInfo?.token.isEmpty ?? true)
    }
    
    func currentMembership() -> Product? {
        guard let productId = realUser?.vipPackageId else { return nil }
        
        return products?.filter({ $0.identifier == productId }).first
    }
    
    func sendCode(email: String, login: Bool, completion: @escaping (Bool) -> Void) {
        var isSuccess: Bool = true
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            if login {
                self.api.checkLoginEmail(email: email) { result in
                    switch result {
                    case .success(let result):
                        if !(result.data ?? false) {
                            isSuccess = false
                            showErrorDialog(error: "Account with such email not found.")
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
            } else {
                self.api.checkRegisterEmail(email: email) { result in
                    switch result {
                    case .success(let result):
                        if !(result.data ?? false) {
                            isSuccess = false
                            showErrorDialog(error: "Account with such email not found.")
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
                    completion(false)
                }
                return
            }
            
            self.api.sendEmailCode(email: email) { result in
                switch result {
                case .success(let response):
                    if !(response.data ?? false) {
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
            
            DispatchQueue.main.async {
                completion(isSuccess)
            }
        }
    }
    
    func login(email: String, code: String, completion: @escaping (Bool) -> Void) {
        var isSuccess: Bool = true
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.api.checkLoginEmail(email: email) { result in
                switch result {
                case .success(let result):
                    if !(result.data ?? false) {
                        isSuccess = false
                        showErrorDialog(error: "Account with such email not found.")
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
                    completion(false)
                }
                return
            }
            
            self.api.login(email: email, code: code) { result in
                switch result {
                case .success(let response):
                    if let loginInfo = response.data, !loginInfo.token.isEmpty {
                        self.loginInfo = loginInfo
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
                    completion(false)
                }
                return
            }
            
            self.fetchUser(initialize: true) { success in
                isSuccess = success
                semaphore.signal()
            }
            semaphore.wait()
            
            DispatchQueue.main.async {
                if isSuccess {
                    self.saveLoginInfo()
                }
                completion(isSuccess)
            }
        }
    }
    
    func register(email: String, code: String, userType: UserTypeMode, completion: @escaping (Bool) -> Void) {
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
                        showErrorDialog(error: "This email has already been registered")
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
                    completion(false)
                }
                return
            }
            
            self.api.register(email: email, code: code, userType: userType) { result in
                switch result {
                case .success(let response):
                    if let loginInfo = response.data, !loginInfo.token.isEmpty {
                        self.loginInfo = loginInfo
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
                    completion(false)
                }
                return
            }
            
            self.fetchUser(initialize: true) { success in
                isSuccess = success
                semaphore.signal()
            }
            semaphore.wait()
            
            DispatchQueue.main.async {
                completion(isSuccess)
            }
        }
    }
    
    func proceedPassLogin() {
        guard let user = realUser else { return }
        
        if user.isUserInfoComplete {
            goToMain()
        } else {
            StoryboardManager.load(storyboard: "SetupProfile")
        }
    }
    
    func goToMain() {
        guard let user = realUser else { return }
        
        let type = user.userType
        
        switch type {
        case .normal:
            StoryboardManager.load(storyboard: "Main")
        case .cupid:
            StoryboardManager.load(storyboard: "MainCupid")
        default:
            StoryboardManager.load(storyboard: "MainCupid")
        }
    }
    
    func fetchUser(initialize: Bool, completion: @escaping (Bool) -> Void) {
        var isSuccess: Bool = true
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            if initialize {
                self.initializeData { success in
                    isSuccess = success
                    semaphore.signal()
                }
                semaphore.wait()
                
                if let token = AppSettingsManager.shared.getDeviceToken() {
                    self.api.updateDeviceToken(deviceToken: token) { result in
                        switch result {
                        case .success:
                            print("saveToken success")
                            AppSettingsManager.shared.setLastSetActiveTime(date: Date())
                        case .failure(let error):
                            print("saveToken error: \(error.errorDescription ?? "")")
                        }
                        semaphore.signal()
                    }
                    semaphore.wait()
                }
            }
            
            self.api.getDetailUser { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    if let user = response.data {
                        self.realUser = user
                        completion(true)
                    } else {
                        showErrorDialog(code: response.code)
                        completion(false)
                    }
                case .failure(let error):
                    error.showErrorDialog()
                    completion(false)
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            self.fetchBlocked { success in
                semaphore.signal()
            }
            semaphore.wait()
            
            DispatchQueue.main.async {
                if isSuccess {
                    self.saveLoginInfo()
                }
                completion(isSuccess)
            }
        }
    }
    
    func fetchBlocked(completion: @escaping (Bool) -> Void) {
        api.getMyBlockUserList { [weak self]  result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if let results = response.data?.records {
                    self.blacklistedUserIds = results.map { query in
                        return query.identifier
                    }
                    completion(true)
                } else {
                    completion(false)
                }
            case .failure(let _):
                completion(false)
            }
        }
    }
    
    private func initializeData(completion: @escaping (Bool) -> Void) {
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
                completion(false)
                return
            }
            
            self.api.getProductPage { [weak self] result in
                switch result {
                case .success(let response):
                    if let products = response.data?.records {
                        self?.products = products
                    } else {
                        showErrorDialog(code: response.code)
                        isSuccess = false
                    }
                case .failure(let error):
                    guard let _ = error.responseCode else {
                        showNetworkErrorDialog()
                        return
                    }
                    error.showErrorDialog()
                    isSuccess = false
                }
            }
            
            completion(isSuccess)
        }
    }
    
    func updateProfileRegistration(params: UpdateUserParams, completion: @escaping (Bool) -> Void) {
        api.updateProfileRegistration(params: params) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if response.data ?? false {
                    self.realUser?.updateUser(params: params)
                    completion(true)
                } else {
                    showErrorDialog(code: response.code)
                    completion(false)
                }
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
                
                completion(false)
            }
        }
    }
    
    func updateProfile(params: UpdateUserParams, completion: @escaping (Bool) -> Void) {
        api.updateProfile(params: params) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if response.data ?? false {
                    self.realUser?.updateUser(params: params)
                    completion(true)
                } else {
                    showErrorDialog(code: response.code)
                    completion(false)
                }
            case .failure(let error):
                if error.responseCode == nil {
                    showNetworkErrorDialog()
                } else {
                    error.showErrorDialog()
                    print("Error occured \(error)")
                }
                
                completion(false)
            }
        }
    }
    
    func uploadProfilePhoto(userID: String, photo: UIImage, updateProfile: Bool, completion: @escaping (PhotoResponse?) -> Void) {
        let filename = String.randomString(length: 5)
        let thumbnailFileName = "\(filename)-thumb.jpg"
        let fullFileName = "\(filename)-full.jpg"
        
        guard let thumbnail = Toucan(image: photo).resize(CGSize(width: 250, height: 250), fitMode: Toucan.Resize.FitMode.clip).image,
              let fullSize = Toucan(image: photo).resize(CGSize(width: 750, height: 750), fitMode: Toucan.Resize.FitMode.clip).image,
              let thumbnailData = thumbnail.jpeg,
              let fullSizeData = fullSize.jpeg,
              let thumbnailDataUrl = UIImage.saveImageToDocumentDirectory(filename: thumbnailFileName, jpegData: thumbnailData),
              let fullSizeDataUrl = UIImage.saveImageToDocumentDirectory(filename: fullFileName, jpegData: fullSizeData)
        else { return }
        
        let finalThumbnailName = "\(userID)/\(thumbnailFileName)"
        let finalFullName = "\(userID)/\(fullFileName)"
        let finalThumbnailURL = "\(api.s3RootURL)\(finalThumbnailName)"
        let finalFullURL = "\(api.s3RootURL)\(finalFullName)"
        
        var isSuccess: Bool = true
        
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.api.uploadS3file(fileUrl: thumbnailDataUrl,
                                  fileName: finalThumbnailName,
                                  progress: nil,
                                  completionHandler: { task, error in
                if error != nil {
                    isSuccess = false
                }
                semaphore.signal()
            })
            semaphore.wait()
            
            guard isSuccess else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            self.api.uploadS3file(fileUrl: fullSizeDataUrl,
                                  fileName: finalFullName,
                                  progress: nil,
                                  completionHandler: { task, error in
                if error != nil {
                    isSuccess = false
                }
                semaphore.signal()
            })
            semaphore.wait()
            
            guard isSuccess else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            if updateProfile, let user = self.realUser {
                var currentPhotos: [PhotoResponse] = user.personalPhotos ?? []
                currentPhotos.append(PhotoResponse(photoName: finalFullName,
                                                   photoUrl: finalFullURL,
                                                   thumbnailName: finalThumbnailName,
                                                   thumbnailUrl: finalThumbnailURL))
                
                var params = UpdateUserParams()
                params.personalPhotos = currentPhotos
                
                self.api.updateProfile(params: params) { result in
                    switch result {
                    case .success(let response):
                        if response.data == nil {
                            isSuccess = false
                        }
                    case .failure:
                        isSuccess = false
                    }
                    semaphore.signal()
                }
                semaphore.wait()
                
                guard isSuccess else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                self.api.getDetailUser { result in
                    switch result {
                    case .success(let response):
                        if let user = response.data {
                            self.realUser = user
                        } else {
                            isSuccess = false
                        }
                    case .failure:
                        isSuccess = false
                    }
                    semaphore.signal()
                }
                semaphore.wait()
            }
            
            DispatchQueue.main.async {
                if isSuccess {
                    completion(PhotoResponse(photoName: finalFullName,
                                             photoUrl: finalFullURL,
                                             thumbnailName: finalThumbnailName,
                                             thumbnailUrl: finalThumbnailURL))
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func deleteProfilePhoto(index: Int, updateProfile: Bool, completion: @escaping (Bool) -> Void) {
        guard let user = realUser,
        index < (user.personalPhotos?.count ?? 0),
        let photo = user.personalPhotos?[index] else { return }
        
        var isSuccess: Bool = true
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.api.deleteS3file(fileName: photo.thumbnailName, progress: nil) { response, error in
                if error != nil {
                    isSuccess = false
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            guard isSuccess else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            self.api.deleteS3file(fileName: photo.photoName, progress: nil) { response, error in
                if error != nil {
                    isSuccess = false
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            if updateProfile {
                var currentPhotos: [PhotoResponse] = user.personalPhotos ?? []
                currentPhotos.remove(at: index)
                
                var params = UpdateUserParams()
                params.personalPhotos = currentPhotos
                
                self.api.updateProfile(params: params) { result in
                    switch result {
                    case .success(let response):
                        if response.data == nil {
                            isSuccess = false
                        }
                    case .failure:
                        isSuccess = false
                    }
                    semaphore.signal()
                }
                semaphore.wait()
                
                guard isSuccess else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                    return
                }
                
                self.api.getDetailUser { result in
                    switch result {
                    case .success(let response):
                        if let user = response.data {
                            self.realUser = user
                        } else {
                            isSuccess = false
                        }
                    case .failure:
                        isSuccess = false
                    }
                    semaphore.signal()
                }
                semaphore.wait()
            }
            
            DispatchQueue.main.async {
                completion(isSuccess)
            }
        }
    }
    
    func updateAnswer(question: QuestionData, answer: QuestionAnswer?) {
        guard realUser != nil else { return }
        
        if let index = realUser!.myAnswerDtoList?.firstIndex(where: { $0.questionId == question.identifier }) {
            if let answer = answer {
                realUser!.myAnswerDtoList?[index] = answer
            } else {
                realUser!.myAnswerDtoList?.remove(at: index)
            }
        } else if let answer = answer {
            realUser!.myAnswerDtoList?.append(answer)
        }
    }
    
    func saveOrderRecord(params: SaveOrderRecordParams, completion: @escaping (Bool) -> Void) {
        guard realUser != nil else { return }
        
        api.saveOrderRecord(saveOrderRecord: params) { result in
            switch result {
            case .success(let response):
                if response.succeed {
                    completion(true)
                } else {
                    showErrorDialog(code: response.code)
                    completion(false)
                }
            case .failure(let error):
                error.showErrorDialog()
                completion(false)
            }
        }
    }
    
    func sendChatMessage(conversationId: String, msg: String, toUser: UserQuery, completion: @escaping (Bool) -> Void) {
        guard realUser != nil else { return }
        
        let pushNotiMessage = msg
        let params = SaveChatMsgParams(conversationId: conversationId, content: msg, isFunction: false, toUserId: toUser.identifier, pushContent: pushNotiMessage, functionType: "CHAT")
        api.saveChatMessage(params: params) { result in
            switch result {
            case .success(let response):
                if response.succeed {
                    completion(true)
                } else {
                    showErrorDialog(code: response.code)
                    completion(false)
                }
            case .failure(let error):
                error.showErrorDialog()
                completion(false)
            }
        }
    }
    
    func sendReviewRequest(conversationId: String, toUser: UserQuery, completion: @escaping (Bool) -> Void) {
        guard let realUser = realUser else { return }
        
        let commentType: String = toUser.userType == .normal ? "Endorsement" : "Review"
        let pushNotiMessage = "\(realUser.firstName ?? "User A") has invited you to write a \(commentType)"
        let params = SaveChatMsgParams(conversationId: conversationId, content: pushNotiMessage, isFunction: true, toUserId: toUser.identifier, pushContent: pushNotiMessage, functionType: "REVIEW")
        api.saveChatMessage(params: params) { result in
            switch result {
            case .success(let response):
                if response.succeed {
                    completion(true)
                } else {
                    showErrorDialog(code: response.code)
                    completion(false)
                }
            case .failure(let error):
                error.showErrorDialog()
                completion(false)
            }
        }
    }
    
    func logout() {
        api.logout { [weak self] _ in
            self?.realUser = nil
            AppSettingsManager.shared.resetSettings()
            self?.loginInfo = nil
            try? self?.myValet.removeAllObjects()
            self?.saveLoginInfo()
            StoryboardManager.load(storyboard: "Login", animated: true, completion: nil)
        }
    }
    
    func clearSavedInformation() {
        api.logout { [weak self] _ in
            self?.realUser = nil
            AppSettingsManager.shared.resetSettings()
            self?.loginInfo = nil
            try? self?.myValet.removeAllObjects()
            self?.saveLoginInfo()
        }
    }
    
    func saveLoginInfo() {
        if let loginInfo = loginInfo, let data = loginInfo.encodeToData() {
            try? myValet.setObject(data, forKey: "login")
        }
    }
}
