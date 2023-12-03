//
//  AdminUserInfoResponse.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-03-27.
//

import Foundation

struct AdminUserInfo: Codable, Equatable, AvatarModel {
    var identifier: String
    var email: String
    var firstName: String?
    var personalPhotos: [PhotoResponse]?
    var userType: UserTypeMode
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case email
        case firstName
        case personalPhotos
        case userType
    }
    
    func getAvatarURL() -> String {
        return personalPhotos?.first?.thumbnailUrl ?? ""
    }
    
    func getUserType() -> UserTypeMode {
        return userType
    }
    
    func getUserId() -> String {
        return identifier
    }
    
    func getAvatarIsBlurred() -> Bool {
        return false
    }
}

struct AdminInfoResponse: Codable {
    var data: AdminUserInfo?
    var code: Int
    var message: String
    var succeed: Bool
}
