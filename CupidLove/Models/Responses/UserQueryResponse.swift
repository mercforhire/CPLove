//
//  UserQueryResponse.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-17.
//

import Foundation

struct UserQuery: Codable, Equatable, AvatarModel {
    var identifier: String
    var cityName: String?
    var countryName: String?
    var location: GPSLocation?
    var distance: Double?
    var birthYear: Int?
    var currentAge: Int?
    var email: String?
    var firstName: String?
    
    var nameAndAge: String {
        if let firstName = firstName, let age = currentAge {
            return "\(firstName), \(age)"
        } else {
            return firstName ?? ""
        }
    }
    
    var isVipBlur: Bool?
    var jobTitle: String?
    var personalPhotos: [PhotoResponse]?
    var userType: UserTypeMode?
    var isLiked: Bool?
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case cityName
        case countryName
        case location
        case distance
        case birthYear
        case currentAge
        case email
        case firstName
        case isVipBlur
        case jobTitle
        case personalPhotos
        case userType
        case isLiked
    }
    
    func getAvatarIsBlurred() -> Bool {
        return isVipBlur ?? false
    }
    
    func getAvatarURL() -> String {
        return personalPhotos?.first?.thumbnailUrl ?? ""
    }
    
    func getUserType() -> UserTypeMode {
        return userType ?? .normal
    }
    
    func getUserId() -> String {
        return identifier
    }
}

struct UserQueryRecords: Codable {
    var current: Int
    var records: [UserQuery]
    var size: Int
    var total: Int
}

struct UserQueryResponse: Codable {
    var data: UserQuery?
    var code: Int
    var message: String
    var succeed: Bool
}

struct UsersQueryResponse: Codable {
    var data: UserQueryRecords?
    var code: Int
    var message: String
    var succeed: Bool
}

struct VisitRecord: Codable {
    var identifier: String
    var userId: String
    var visitTo: String
    var userInfoDto: [UserQuery]
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case userId
        case visitTo
        case userInfoDto
    }
}

struct VisitedUsersRecords: Codable {
    var current: Int
    var records: [VisitRecord]
    var size: Int
    var total: Int
}

struct VisitedUsersResponse: Codable {
    var data: VisitedUsersRecords?
    var code: Int
    var message: String
    var succeed: Bool
}
