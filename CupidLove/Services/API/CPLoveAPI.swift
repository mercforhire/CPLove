//
//  AuthenticationService.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-28.
//

import Foundation
import Alamofire
import AWSS3
import AWSCore

typealias progressBlock = (_ progress: Double) -> Void
typealias completionBlock = (_ response: Any?, _ error: Error?) -> Void

class CPLoveAPI {
    static let shared = CPLoveAPI()
    
    var environment: Environments {
        return AppSettingsManager.shared.getEnvironment()
    }
    
    var baseURL: String {
        return environment.hostUrl()
    }
    
    var s3RootURL: String {
        return environment.s3RootURL()
    }
    
    var bucketName: String {
        return environment.bucketName()
    }
    
    var s3Key: String {
        return environment.s3Key()
    }
    
    var accessKey: String {
        return environment.accessKey()
    }
    
    private let photoBaseURL = "https://pixabay.com/api/"
    
    let service: NetworkService
    
    init() {
        self.service = NetworkService()
        initializeS3()
    }
    
    func initializeS3() {
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: s3Key, secretKey: accessKey)
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func uploadS3file(fileUrl: URL, fileName: String, progress: progressBlock?, completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?) {
        let expression  = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task: AWSS3TransferUtilityTask, progress: Progress) -> Void in
            print("Downloading: \(progress.fractionCompleted)")
            if progress.isFinished {
                print("Upload Finished...")
            }
        }
        
        expression.setValue("public-read-write", forRequestHeader: "x-amz-acl")
        expression.setValue("public-read-write", forRequestParameter: "x-amz-acl")
        
        AWSS3TransferUtility.default().uploadFile(fileUrl, bucket: bucketName, key: fileName, contentType: "image/jpg", expression: expression, completionHandler: completionHandler).continueWith(block: { task in
            if task.error != nil {
                print("Error uploading file: \(String(describing: task.error?.localizedDescription))")
            }
            if task.result != nil {
                print("Starting upload...")
            }
            return nil
        })
    }
    
    func deleteS3file(fileName: String, progress: progressBlock?, completion: completionBlock?) {
        let request = AWSS3DeleteObjectRequest()!
        request.bucket = bucketName
        request.key = fileName
        
        let s3Service = AWSS3.default()
        s3Service.deleteObject(request).continueWith { task in
            if let error = task.error {
                print("Error occurred: \(error)")
                completion?(task.result, error)
                return nil
            }
            print("Bucket deleted successfully.")
            completion?(task.result, nil)
            return nil
        }
    }
    
    func checkLoginEmail(email: String, callBack: @escaping(Result<DefaultResponse, AFError>) -> Void) {
        let params = ["email": email]
        let url = baseURL + APIRequestURLs.checkLoginEmail.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.checkLoginEmail.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<DefaultResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func checkRegisterEmail(email: String, callBack: @escaping(Result<DefaultResponse, AFError>) -> Void) {
        let params = ["email": email]
        let url = baseURL + APIRequestURLs.checkRegisterEmail.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.checkRegisterEmail.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<DefaultResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func sendEmailCode(email: String, callBack: @escaping(Result<DefaultResponse, AFError>) -> Void) {
        let params = ["email": email]
        let url = baseURL + APIRequestURLs.sendEmailCode.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.sendEmailCode.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<DefaultResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func login(email: String, code: String, callBack: @escaping(Result<RegisterResponse, AFError>) -> Void) {
        let params = ["email": email, "code": code]
        let url = baseURL + APIRequestURLs.login.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.login.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<RegisterResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func register(email: String, code: String, userType: UserTypeMode, callBack: @escaping(Result<RegisterResponse, AFError>) -> Void) {
        let params: [String : Any] = ["email": email, "code": code, "userType": userType.rawValue]
        let url = baseURL + APIRequestURLs.register.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.register.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<RegisterResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getMyInviteCode(callBack: @escaping(Result<String?, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getMyInviteCode.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.getMyInviteCode.getHTTPMethod(), parameters: nil, headers: Headers.defaultHeader()) { (result: AFResult<DefaultStringResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response.data))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func logout(callBack: @escaping(Result<DefaultResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.logout.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.logout.getHTTPMethod(), parameters: nil, headers: Headers.defaultHeader()) { (result: AFResult<DefaultResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func kill(email: String, callBack: @escaping(Result<DefaultResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.kill.rawValue
        let params: [String : Any] = ["email": email]
        
        service.httpRequest(url: url, method: APIRequestURLs.kill.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<DefaultResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getDetailUser(callBack: @escaping(Result<MyUserInfoResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getMyUserInfo.rawValue

        service.httpRequest(url: url, method: APIRequestURLs.getMyUserInfo.getHTTPMethod(), parameters: nil, headers: Headers.defaultHeader()) { (result: AFResult<MyUserInfoResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getMyExploredDaterList(params: UserQueryParams, callBack: @escaping(Result<UsersInfosResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getMyExploredDaterList.rawValue

        service.httpRequest(url: url, method: APIRequestURLs.getMyExploredDaterList.getHTTPMethod(), parameters: params.params(), headers: Headers.defaultHeader()) { (result: AFResult<UsersInfosResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getMyFilteredDaterList(params: UserQueryParams, callBack: @escaping(Result<UsersQueryResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getMyFilteredDaterList.rawValue

        service.httpRequest(url: url, method: APIRequestURLs.getMyFilteredDaterList.getHTTPMethod(), parameters: params.params(), headers: Headers.defaultHeader()) { (result: AFResult<UsersQueryResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getExploredMatchmakerList(params: UserQueryParams, callBack: @escaping(Result<UsersQueryResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getExploredMatchmakerList.rawValue

        service.httpRequest(url: url, method: APIRequestURLs.getExploredMatchmakerList.getHTTPMethod(), parameters: params.params(), headers: Headers.defaultHeader()) { (result: AFResult<UsersQueryResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getFilteredMatchmakerList(params: UserQueryParams, callBack: @escaping(Result<UsersQueryResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getFilteredMatchmakerList.rawValue

        service.httpRequest(url: url, method: APIRequestURLs.getFilteredMatchmakerList.getHTTPMethod(), parameters: params.params(), headers: Headers.defaultHeader()) { (result: AFResult<UsersQueryResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func fetchUserProfile(userId: String, callBack: @escaping(Result<UserInfoResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getUserInfo.rawValue
        let params: [String : Any] = ["userId": userId]
        
        service.httpRequest(url: url, method: APIRequestURLs.getUserInfo.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<UserInfoResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func updateProfileRegistration(params: UpdateUserParams, callBack: @escaping(Result<DefaultResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.saveUserInfo.rawValue

        service.httpRequest(url: url, method: APIRequestURLs.saveUserInfo.getHTTPMethod(), parameters: params.params(), headers: Headers.defaultHeader()) { (result: AFResult<DefaultResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func updateProfile(params: UpdateUserParams, callBack: @escaping(Result<DefaultResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.updateUserInfo.rawValue

        service.httpRequest(url: url, method: APIRequestURLs.updateUserInfo.getHTTPMethod(), parameters: params.params(), headers: Headers.defaultHeader()) { (result: AFResult<DefaultResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getUserByInviteCode(inviteCode: String, callBack: @escaping(Result<UserQueryResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getUserByInviteCode.rawValue
        let params: [String : Any] = ["inviteCode": inviteCode]
        
        service.httpRequest(url: url, method: APIRequestURLs.getUserByInviteCode.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<UserQueryResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getQuestionList(callBack: @escaping(Result<GetQuestionListResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getQuestionList.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.getQuestionList.getHTTPMethod(), parameters: nil, headers: Headers.defaultHeader()) { (result: AFResult<GetQuestionListResponse>) in
            switch result {
            case .success(let response):
                var modify = response
                modify.data = modify.data?.filter( { $0.question != nil } )
                callBack(.success(modify))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func updateMyAnswer(answer: QuestionAnswer, callBack: @escaping(Result<DefaultResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.updateMyAnswer.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.updateMyAnswer.getHTTPMethod(), parameters: answer.params(), headers: Headers.defaultHeader(), callBack: { (result: AFResult<DefaultResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        })
    }
    
    func getUserCommentList(userId: String, callBack: @escaping(Result<GetReviewsResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getUserCommentList.rawValue
        var params = UserQueryParams()
        params.userId = userId
        
        service.httpRequest(url: url, method: APIRequestURLs.getUserCommentList.getHTTPMethod(), parameters: params.params(), headers: Headers.defaultHeader(), callBack: { (result: AFResult<GetReviewsResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        })
    }
    
    func saveUserComment(targetUserId: String, content: String, rating: Int? = nil, type: CommentType, callBack: @escaping(Result<DefaultResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.saveUserComment.rawValue
        let params = ReviewParams(content: content, rating: rating, targetUserId: targetUserId, type: type)
        
        service.httpRequest(url: url, method: APIRequestURLs.saveUserComment.getHTTPMethod(), parameters: params.params(), headers: Headers.defaultHeader(), callBack: { (result: AFResult<DefaultResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        })
    }
    
    func updateUserComment(commentID: String, targetUserId: String, content: String, rating: Int = 0, type: CommentType, callBack: @escaping(Result<DefaultResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.updateUserComment.rawValue
        let params = ReviewParams(identifier: commentID, content: content, rating: rating, targetUserId: targetUserId, type: type)
        
        service.httpRequest(url: url, method: APIRequestURLs.updateUserComment.getHTTPMethod(), parameters: params.params(), headers: Headers.defaultHeader(), callBack: { (result: AFResult<DefaultResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        })
    }
    
    func changeLikeStatus(likeStatus: Int, targetUserId: String, callBack: @escaping(Result<DefaultIntResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.changeLikeStatus.rawValue
        let params: [String : Any] = ["likeStatus": likeStatus, "userId": targetUserId]
        
        service.httpRequest(url: url, method: APIRequestURLs.changeLikeStatus.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader(), callBack: { (result: AFResult<DefaultIntResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        })
    }
    
    func getInvitedUserList(userId: String, callBack: @escaping(Result<UsersQueryResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getInvitedUserList.rawValue
        let params: [String : Any] = ["userId": userId]
        
        service.httpRequest(url: url, method: APIRequestURLs.getInvitedUserList.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader(), callBack: { (result: AFResult<UsersQueryResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        })
    }
    
    func getMyLikedUser(userId: String, callBack: @escaping(Result<UsersQueryResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getMyLikedUser.rawValue
        var params = UserQueryParams()
        params.userType = .normal
        params.targetUserId = userId
        
        service.httpRequest(url: url, method: APIRequestURLs.getMyLikedUser.getHTTPMethod(), parameters: params.params(), headers: Headers.defaultHeader(), callBack: { (result: AFResult<UsersQueryResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        })
    }
    
    func getMyLikedCupids(userId: String, callBack: @escaping(Result<UsersQueryResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getMyLikedUser.rawValue
        var params = UserQueryParams()
        params.userType = .cupid
        params.targetUserId = userId
        
        service.httpRequest(url: url, method: APIRequestURLs.getMyLikedUser.getHTTPMethod(), parameters: params.params(), headers: Headers.defaultHeader(), callBack: { (result: AFResult<UsersQueryResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        })
    }
    
    func getUserLikedMe(userId: String, callBack: @escaping(Result<UsersQueryResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getUserLikedMe.rawValue
        let params = UserQueryParams()
        
        service.httpRequest(url: url, method: APIRequestURLs.getUserLikedMe.getHTTPMethod(), parameters: params.params(), headers: Headers.defaultHeader(), callBack: { (result: AFResult<UsersQueryResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        })
    }
    
    func getUserVisitedMe(userId: String, callBack: @escaping(Result<VisitedUsersResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getUserVisitedMe.rawValue
        let params = UserQueryParams()
        
        service.httpRequest(url: url, method: APIRequestURLs.getUserVisitedMe.getHTTPMethod(), parameters: params.params(), headers: Headers.defaultHeader(), callBack: { (result: AFResult<VisitedUsersResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        })
    }
    
    func visit(userId: String, callBack: @escaping(Result<Bool, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.visit.rawValue
        let params: [String : Any] = ["targetUserId": userId]
        
        service.httpRequestSimple(url: url,
                                  method: APIRequestURLs.visit.getHTTPMethod(),
                                  parameters: params,
                                  headers: Headers.defaultHeader()) { result in
            switch result {
            case .success:
                callBack(.success(true))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func deleteUser(reason: String, callBack: @escaping(Result<DefaultResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.deleteUser.rawValue
        let params: [String : Any] = ["deleteReason": reason]
        
        service.httpRequest(url: url, method: APIRequestURLs.deleteUser.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader(), callBack: { (result: AFResult<DefaultResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        })
    }
    
    func getMyBlockUserList(callBack: @escaping(Result<UsersQueryResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getMyBlockUserList.rawValue
        var params = UserQueryParams()
        
        service.httpRequest(url: url, method: APIRequestURLs.getMyBlockUserList.getHTTPMethod(), parameters: params.params(), headers: Headers.defaultHeader(), callBack: { (result: AFResult<UsersQueryResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        })
    }
    
    func blockUser(userId: String, block: Bool, callBack: @escaping(Result<DefaultResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.blockUser.rawValue
        var params = UserQueryParams()
        params.isBlock = block
        params.targetUserId = userId
        
        service.httpRequest(url: url, method: APIRequestURLs.blockUser.getHTTPMethod(), parameters: params.params(), headers: Headers.defaultHeader(), callBack: { (result: AFResult<DefaultResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        })
    }
    
    func saveAppFeedback(feedback: String, positive: Bool, tags: [String], callBack: @escaping(Result<DefaultResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.saveAppFeedback.rawValue
        var params = FeedbackParams(feedback: feedback, isPositive: positive, tags: tags)
        
        service.httpRequest(url: url, method: APIRequestURLs.saveAppFeedback.getHTTPMethod(), parameters: params.params(), headers: Headers.defaultHeader(), callBack: { (result: AFResult<DefaultResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        })
    }
    
    func getProductPage(callBack: @escaping(Result<ProductResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getProductPage.rawValue
        let params: [String : Any] = ["current": 1, "size": 999];
        
        service.httpRequest(url: url, method: APIRequestURLs.getProductPage.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader(), callBack: { (result: AFResult<ProductResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        })
    }
    
    func getVipCouponByCode(coupon: String, callBack: @escaping(Result<GetVipCouponResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getVipCouponByCode.rawValue
        let params: [String : Any] = ["vipCode": coupon]
        
        service.httpRequest(url: url, method: APIRequestURLs.getVipCouponByCode.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader(), callBack: { (result: AFResult<GetVipCouponResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        })
    }
    
    func redeemVipCode(vipCode: String, callBack: @escaping(Result<RedeemCouponResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.redeemVipCode.rawValue
        let params: [String : Any] = ["vipCode": vipCode]
        
        service.httpRequest(url: url, method: APIRequestURLs.redeemVipCode.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader(), callBack: { (result: AFResult<RedeemCouponResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        })
    }
    
    func saveOrderRecord(saveOrderRecord: SaveOrderRecordParams, callBack: @escaping(Result<DefaultSimpleResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.saveOrderRecord.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.saveOrderRecord.getHTTPMethod(), parameters: saveOrderRecord.params(), headers: Headers.defaultHeader(), callBack: { (result: AFResult<DefaultSimpleResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        })
    }
    
    func saveAppReport(reportType: ReportType, description: String, targetUserId: String, callBack: @escaping(Result<DefaultResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.saveAppReport.rawValue
        let params: [String : Any] = ["reportType": reportType.rawValue, "description": description, "targetUserId": targetUserId];
        
        service.httpRequest(url: url, method: APIRequestURLs.saveAppReport.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader(), callBack: { (result: AFResult<DefaultResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        })
    }
    
    func getMessagesWithUser(params: GetChatMessageParams, callBack: @escaping(Result<ChatListResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getChatMessage.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.getChatMessage.getHTTPMethod(), parameters: params.params(), headers: Headers.defaultHeader(), callBack: { (result: AFResult<ChatListResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        })
    }
    
    func getLatestMessages(callBack: @escaping(Result<ConversationListResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.getLatestMessage.rawValue
        var params = UserQueryParams()
        params.size = 50
        
        service.httpRequest(url: url, method: APIRequestURLs.getLatestMessage.getHTTPMethod(), parameters: params.params(), headers: Headers.defaultHeader(), callBack: { (result: AFResult<ConversationListResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        })
    }
    
    func saveChatMessage(params: SaveChatMsgParams, callBack: @escaping(Result<SentChatResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.saveChatMessage.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.saveChatMessage.getHTTPMethod(), parameters: params.params(), headers: Headers.defaultHeader(), callBack: { (result: AFResult<SentChatResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        })
    }
    
    func updateDeviceToken(deviceToken: String, callBack: @escaping(Result<DefaultResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.upsert.rawValue
        let params: [String : Any] = ["deviceToken": deviceToken]
        
        service.httpRequest(url: url, method: APIRequestURLs.upsert.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<DefaultResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func spendCoin(targetUserId: String, callBack: @escaping(Result<DefaultIntResponse, AFError>) -> Void) {
        let url = baseURL + APIRequestURLs.spendCoin.rawValue
        let params: [String : Any] = ["targetUserId": targetUserId]
        
        service.httpRequest(url: url, method: APIRequestURLs.spendCoin.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<DefaultIntResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    //////////////////////////////////////////////////////////////
    
    private var DefaultParam: [String: Any] {
        return ["key": "25560431-f85e9e607fe6f311b6d329bd0",
                "image_type": "photo",
                "category": "people",
                "q": ["face", "man", "woman", "guy", "asian", "girl", "sexy man"].randomElement()!,
                "per_page": 200,
                "page": Int.random(in: 1...2)]
    }
    
    func getRandomPhotos(gender: GenderChoice, callBack: @escaping(Result<[PhotoAPIModel], AFError>) -> Void) {
        var params: [String: Any] = DefaultParam
        params["page"] = Int.random(in: 1...50)
        params["per_page"] = Int.random(in: 5...9)
        if gender == .male {
            params["q"] = ["man", "guy", "male"].randomElement()!
        } else {
            params["q"] = ["woman", "girl", "female"].randomElement()!
        }
        
        let url = photoBaseURL
        service.httpRequest(url: url, method: .get, parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<PixabayResult>) in
            switch result {
            case .success(let response):
                callBack(.success(response.hits.shuffled()))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
}
