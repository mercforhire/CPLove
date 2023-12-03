//
//  InvitedByUserInfo.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-15.
//

import Foundation

struct InvitedByUserInfo: Codable, AvatarModel {
    var identifier: String
    var cityName: String?
    var distance: Double?
    var firstName: String?
    var isVipBlur: Bool
    var jobTitle: String?
    var personalPhotos: [PhotoResponse]?
    var location: GPSLocation?
    var userType: UserTypeMode
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case cityName
        case distance
        case firstName
        case isVipBlur
        case jobTitle
        case personalPhotos
        case location
        case userType
    }
    
    func getAvatarIsBlurred() -> Bool {
        return isVipBlur
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
}
