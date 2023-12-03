//
//  APIRequestsURLs.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-28.
//

import Foundation
import Alamofire

enum APIRequestURLs: String {
    case checkLoginEmail = "checkLoginEmail"
    case checkRegisterEmail = "checkRegisterEmail"
    case login = "login"
    case logout = "logout"
    case register = "register"
    case sendEmailCode = "sendEmailCode"
    
    case upsert = "userDevice/upsert"
    case blockUser = "user/blockUser"
    case saveAppReport = "appReport/saveAppReport"
    case getMatchMakerList = "user/getMatchMakerList"
    case getMyBlockUserList = "user/getMyBlockUserList"
    
    case getMyExploredDaterList = "user/getMyExploredDaterList"
    case getMyFilteredDaterList = "user/getMyFilteredDaterList"
    case getExploredMatchmakerList = "user/getExploredMatchmakerList"
    case getFilteredMatchmakerList = "user/getFilteredMatchmakerList"
    
    case getMyInvitees = "user/getMyInvitees"
    case getMyLikedUser = "user/getMyLikedUser"
    case getMyUserInfo = "user/getMyUserInfo"
    case getMyVipInfo = "user/getMyVipInfo"
    case getUserInfo = "user/getUserInfo"
    case getUserLikedMe = "user/getUserLikedMe"
    case getUserVisitTo = "user/getUserVisitTo"
    case getUserVisitedMe = "user/getUserVisitedMe"
    
    case getChatMessage = "chat/getChatMessage"
    case getLatestMessage = "chat/getLatestMessage"
    case saveChatMessage = "chat/saveChatMessage"
    
    case redeemVipCode = "user/redeemVipCode"
    case saveUserInfo = "user/saveUserInfo"
    case updateUserInfo = "user/updateUserInfo"
    case getUserByInviteCode = "user/getUserByInviteCode"
    case getInvitedUserList = "user/getInvitedUserList"
    case deleteUser = "/user/deleteUser"
    case getMyInviteCode = "user/getMyInviteCode"
    
    case getQuestionList = "common/getQuestionList"
    case getAnswerList = "myQuestion/getAnswerList"
    case updateMyAnswer = "myQuestion/updateMyAnswer"
    
    case getUserCommentList = "userComment/getUserCommentList"
    case saveUserComment = "userComment/save"
    case updateUserComment = "userComment/update"
    
    case changeLikeStatus = "likeRecord/changeLikeStatus"
    
    case getProductPage = "common/getProductPage"
    
    case saveAppFeedback = "appFeedback/saveAppFeedback"
    
    case getVipCouponByCode = "vipCoupon/getVipCouponByCode"
    case saveOrderRecord = "orderRecord/saveOrderRecord"
    case spendCoin = "coinTransaction/spendCoin"
    
    case visit = "visitHistory/visit"
    
    case kill = "user/testDeleteUser"
    
    func getHTTPMethod() -> HTTPMethod {
        switch self {
        case .checkLoginEmail:
            return .get
        case .checkRegisterEmail:
            return .get
        case .login:
            return .get
        case .logout:
            return .get
        case .register:
            return .post
        case .sendEmailCode:
            return .get
            
        case .upsert:
            return .post
            
        case .blockUser:
            return .post
        case .saveAppReport:
            return .post
            
        case .getMatchMakerList:
            return .post
        case .getMyBlockUserList:
            return .post
        case .getMyExploredDaterList,
                .getMyFilteredDaterList,
                .getExploredMatchmakerList,
                .getFilteredMatchmakerList:
            return .post
        case .getMyInvitees:
            return .post
        case .getMyLikedUser:
            return .post
        case .getMyUserInfo:
            return .get
        case .getMyVipInfo:
            return .get
        case .getUserInfo:
            return .get
        case .getUserLikedMe:
            return .post
        case .getUserVisitTo:
            return .post
        case .getUserVisitedMe:
            return .post
        case .redeemVipCode:
            return .get
        case .saveUserInfo:
            return .post
        case .updateUserInfo:
            return .post
        case .getUserByInviteCode:
            return .get
        case .getInvitedUserList:
            return .post
        case .deleteUser:
            return .delete
        case .getMyInviteCode:
            return .get
            
        case .getQuestionList:
            return .get
        case .getAnswerList:
            return .get
        case .updateMyAnswer:
            return .post
            
        case .getChatMessage:
            return .post
        case .getLatestMessage:
            return .post
        case .saveChatMessage:
            return .post
        
        case .getUserCommentList:
            return .post
        case .saveUserComment:
            return .post
        case .updateUserComment:
            return .post
            
        case .changeLikeStatus:
            return .get
        case .getProductPage:
            return .post
            
        case .saveAppFeedback:
            return .post
            
        case .getVipCouponByCode:
            return .get
        case .saveOrderRecord:
            return .post
        case .visit:
            return .get
        case .spendCoin:
            return .get
            
        case .kill:
            return .delete
        }
    }
    
    static func needAuthToken(url: String) -> Bool {
        if url.contains(string: APIRequestURLs.checkLoginEmail.rawValue) ||
            url.contains(string: APIRequestURLs.checkRegisterEmail.rawValue) ||
            url.contains(string: APIRequestURLs.login.rawValue) ||
            url.contains(string: APIRequestURLs.register.rawValue) ||
            url.contains(string: APIRequestURLs.sendEmailCode.rawValue) ||
            url.contains(string: APIRequestURLs.getQuestionList.rawValue) ||
            url.contains(string: APIRequestURLs.getProductPage.rawValue) {
            return false
        }
        return true
    }
}
