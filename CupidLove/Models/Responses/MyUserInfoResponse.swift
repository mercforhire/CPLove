//
//  MyUserInfoResponse.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-12.
//

import Foundation

struct MyUserInfo: Codable, Equatable, AvatarModel {
    var identifier: String
    var email: String
    var firstName: String?
    
    var nameAndAge: String {
        if let firstName = firstName, let age = currentAge {
            return "\(firstName), \(age)"
        } else {
            return firstName ?? ""
        }
    }
    
    var userType: UserTypeMode
    var inviteCode: String?
    var matchmakerId: String?
    var asset: [Assets]?
    var birthYear: Int?
    var blockUsers: [String]?
    var invitedBy: String?
    var invitedByUserInfo: InvitedByUserInfo?
    var child: ChildPreference?
    var cityName: String?
    var coins: Int
    var countryName: String?
    var currentAge: Int?
    var dailyLikes: Int?
    var dateGender: GenderChoice?
    var aboutMe: String?
    var desiredAge: [Int]?
    var desiredCityName: String?
    var desiredDescription: String?
    var desiredReligion: [Religions]?
    var desiredEthnicity: [Ethnicities]?
    var desiredMinAge: Int?
    var desiredMaxAge: Int?
    var desiredMinIncome: Incomes?
    var desiredPersonality: [Personality]?
    var ethnicity: Ethnicities?
    var gender: GenderChoice?
    var height: HeightSelections?
    var bodyType: String?
    var horoscope: Horoscopes?
    var interests: [String]?
    var isProfileHide: Bool
    var isUserInfoComplete: Bool
    var isVerified: Bool
    var isVip: Bool
    var isVipBlur: Bool
    var jobTitle: String?
    var likeAmount: Int
    var lookingFor: RelationshipTypes?
    var maxIncome: Incomes?
    var minIncome: Incomes?
    var myAnswerDtoList: [QuestionAnswer]?
    var notificationLevel: Int
    var personalPhotos: [PhotoResponse]?
    var personality: [Personality]?
    var religion: Religions?
    var school: String?
    var sibling: Siblings?
    var verifyPhoto: String?
    var vipExpireDate: String?
    var vipPackageId: String?
    var location: GPSLocation?
    var activeDate: String
    var status: Int
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case email
        case firstName
        case userType
        case inviteCode
        case matchmakerId
        case asset
        case birthYear
        case blockUsers
        case invitedBy
        case invitedByUserInfo
        case child
        case cityName
        case coins
        case countryName
        case currentAge
        case dailyLikes
        case dateGender
        case aboutMe = "description"
        case desiredAge
        case desiredCityName
        case desiredDescription
        case desiredEthnicity
        case desiredReligion
        case desiredMinAge
        case desiredMaxAge
        case desiredMinIncome
        case desiredPersonality
        case ethnicity
        case gender
        case height
        case bodyType
        case horoscope
        case interests
        case isProfileHide
        case isUserInfoComplete
        case isVerified
        case isVip
        case isVipBlur
        case jobTitle
        case likeAmount
        case lookingFor
        case maxIncome
        case minIncome
        case myAnswerDtoList
        case notificationLevel
        case personalPhotos
        case personality
        case religion
        case school
        case sibling
        case verifyPhoto
        case vipExpireDate
        case vipPackageId
        case location
        case activeDate
        case status
    }
    
    mutating func updateUser(params: UpdateUserParams) {
        if let firstName = params.firstName {
            self.firstName = firstName
        }
        
        if let asset = params.asset {
            self.asset = asset
        }
        
        if let birthYear = params.birthYear {
            self.birthYear = birthYear
        }
        
        if let child = params.child {
            self.child = child
        }
        
        if let cityName = params.cityName {
            self.cityName = cityName
        }
        
        if let countryName = params.countryName {
            self.countryName = countryName
        }
        
        if let location = params.location {
            self.location = location
        }
        
        if let dateGender = params.dateGender {
            self.dateGender = dateGender
        }
        
        if let aboutMe = params.aboutMe {
            self.aboutMe = aboutMe
        }
        
        if let desiredCityName = params.desiredCityName {
            self.desiredCityName = desiredCityName
        }
        
        if let desiredDescription = params.desiredDescription {
            self.desiredDescription = desiredDescription
        }
        
        if let desiredEthnicity = params.desiredEthnicity {
            self.desiredEthnicity = desiredEthnicity
        }
        
        if let desiredReligion = params.desiredReligion {
            self.desiredReligion = desiredReligion
        }
        
        if let desiredMinAge = params.desiredMinAge {
            self.desiredMinAge = desiredMinAge
        }
        
        if let desiredMinIncome = params.desiredMinIncome {
            self.desiredMinIncome = desiredMinIncome
        }
        
        if let desiredPersonality = params.desiredPersonality {
            self.desiredPersonality = desiredPersonality
        }
        
        if let gender = params.gender {
            self.gender = gender
        }
        
        if let height = params.height {
            self.height = height
        }
        
        if let bodyType = params.bodyType {
            self.bodyType = bodyType
        }
        
        if let horoscope = params.horoscope {
            self.horoscope = horoscope
        }
        
        if let interests = params.interests {
            self.interests = interests
        }
        
        if let invitedBy = params.invitedBy {
            self.invitedBy = invitedBy
        }
        
        if let isUserInfoComplete = params.isUserInfoComplete {
            self.isUserInfoComplete = isUserInfoComplete
        }
        
        if let jobTitle = params.jobTitle {
            self.jobTitle = jobTitle
        }
        
        if let lookingFor = params.lookingFor {
            self.lookingFor = lookingFor
        }
        
        if let maxIncome = params.maxIncome {
            self.maxIncome = maxIncome
        }
        
        if let minIncome = params.minIncome {
            self.minIncome = minIncome
        }
        
        if let personalPhotos = params.personalPhotos {
            self.personalPhotos = personalPhotos
        }
        
        if let personality = params.personality {
            self.personality = personality
        }
        
        if let religion = params.religion {
            self.religion = religion
        }
        
        if let school = params.school {
            self.school = school
        }
        
        if let sibling = params.sibling {
            self.sibling = sibling
        }
        
        if let isProfileHide = params.isProfileHide {
            self.isProfileHide = isProfileHide
        }
        
        if let notificationLevel = params.notificationLevel {
            self.notificationLevel = notificationLevel
        }
    }
    
    func toUserInfo() -> UserInfo {
        var userInfo = UserInfo()
        userInfo.identifier = identifier
        userInfo.email = email
        userInfo.firstName = firstName
        userInfo.userType = userType
        userInfo.matchmakerId = matchmakerId
        userInfo.asset = asset
        userInfo.birthYear = birthYear
        userInfo.invitedBy = invitedBy
        userInfo.invitedByUserInfo = invitedByUserInfo
        userInfo.child = child
        userInfo.cityName = cityName
        userInfo.countryName = countryName
        userInfo.currentAge = currentAge
        userInfo.dateGender = dateGender
        userInfo.aboutMe = aboutMe
        userInfo.desiredAge = desiredAge
        userInfo.desiredCityName = desiredCityName
        userInfo.desiredDescription = desiredDescription
        userInfo.desiredReligion = desiredReligion
        userInfo.desiredEthnicity = desiredEthnicity
        userInfo.desiredMinAge = desiredMinAge
        userInfo.desiredMaxAge = desiredMaxAge
        userInfo.desiredMinIncome = desiredMinIncome
        userInfo.desiredPersonality = desiredPersonality
        userInfo.ethnicity = ethnicity
        userInfo.gender = gender
        userInfo.height = height
        userInfo.bodyType = bodyType
        userInfo.horoscope = horoscope
        userInfo.interests = interests
        userInfo.isVerified = isVerified
        userInfo.isVip = isVip
        userInfo.isVipBlur = isVipBlur
        userInfo.jobTitle = jobTitle
        userInfo.likeAmount = likeAmount
        userInfo.lookingFor = lookingFor
        userInfo.maxIncome = maxIncome
        userInfo.minIncome = minIncome
        userInfo.myAnswerDtoList = myAnswerDtoList
        userInfo.personalPhotos = personalPhotos
        userInfo.personality = personality
        userInfo.religion = religion
        userInfo.school = school
        userInfo.sibling = sibling
        userInfo.location = location
        return userInfo
    }
    
    func toUserQuery() -> UserQuery {
        let userQuery = UserQuery(identifier: identifier, cityName: cityName, location: location, email: email, firstName: firstName, isVipBlur: isVipBlur, jobTitle: jobTitle, personalPhotos: personalPhotos, userType: userType, isLiked: false)
        return userQuery
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
        return isVipBlur
    }
}

struct MyUserInfoResponse: Codable {
    var data: MyUserInfo?
    var code: Int
    var message: String
    var succeed: Bool
}
