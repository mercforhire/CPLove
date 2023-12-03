//
//  GetUserInfoResponse.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-20.
//

import Foundation

struct UserInfo: Codable, Equatable, AvatarModel {
    var identifier: String = ""
    var email: String = ""
    var firstName: String?
    
    var nameAndAge: String {
        if let firstName = firstName, let age = currentAge {
            return "\(firstName), \(age)"
        } else {
            return firstName ?? ""
        }
    }
    
    var userType: UserTypeMode = .normal
    var matchmakerId: String?
    var asset: [Assets]?
    var birthYear: Int?
    var invitedBy: String?
    var invitedByUserInfo: InvitedByUserInfo?
    var child: ChildPreference?
    var cityName: String?
    var countryName: String?
    var currentAge: Int?
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
    var isLiked: Bool?
    var isVerified: Bool?
    var isVip: Bool?
    var isVipBlur: Bool?
    var jobTitle: String?
    var likeAmount: Int?
    var lookingFor: RelationshipTypes?
    var maxIncome: Incomes?
    var minIncome: Incomes?
    var myAnswerDtoList: [QuestionAnswer]?
    var personalPhotos: [PhotoResponse]?
    var personality: [Personality]?
    var religion: Religions?
    var school: String?
    var sibling: Siblings?
    var location: GPSLocation?
    var isBlocked: Bool?
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case email
        case firstName
        case userType
        case matchmakerId
        case asset
        case birthYear
        case invitedBy
        case invitedByUserInfo
        case child
        case cityName
        case countryName
        case currentAge
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
        case isLiked
        case isVerified
        case isVip
        case isVipBlur
        case jobTitle
        case likeAmount
        case lookingFor
        case maxIncome
        case minIncome
        case myAnswerDtoList
        case personalPhotos
        case personality
        case religion
        case school
        case sibling
        case location
        case isBlocked
    }
    
    func toUserQuery() -> UserQuery {
        let userQuery = UserQuery(identifier: identifier, cityName: cityName, location: location, email: email, firstName: firstName, isVipBlur: isVipBlur, jobTitle: jobTitle, personalPhotos: personalPhotos, userType: userType, isLiked: false)
        return userQuery
    }
    
    func aboutMeParagragh() -> String {
        /*
         I am a Leo - born in July 1990.
         I am 175cm tall, white and I am a christian.
         I studied in The University of Toronto.
         I am looking for a woman and a serious relationship.
         */
        let sentence1: String = "I am a \(horoscope?.title() ?? "[unknown horoscope]") - born in \(birthYear != nil ? "\(birthYear!)" : "[uknown year]")."
        let sentence2: String = " I am \(height?.title() ?? "[unknown height]") tall, \(bodyType?.lowercased() ?? "unknown") body type,  \(ethnicity?.title().lowercased() ?? "[unknown]") ethnicity and I am of \(religion?.title().lowercased() ?? "[unknown]") religion."
        
        let sentence2Cupid: String = " I am of \(ethnicity?.title().lowercased() ?? "[unknown]") ethnicity and I am of \(religion?.title() ?? "[unknown]") religion."
        
        let sentence3: String = " I studied in the \(school ?? "[unknown school]")"
        
        var sentence4 = "."
        if let minIncome = minIncome, let maxIncome = maxIncome, minIncome != .unknown, maxIncome != .unknown {
            if minIncome == maxIncome {
                sentence4 = ", and I make \(minIncome.shortTitle().lowercased()). "
            } else {
                sentence4 = ", and I make \(minIncome.shortTitle().lowercased()) - \(maxIncome.shortTitle().lowercased()). "
            }
        }
        
        let sentence5: String = " I am looking for a \(dateGender?.casualTitle().lowercased() ?? "[unknown gender]") for \(lookingFor?.title().lowercased() ?? "[unknown relationship type]")."
        
        return userType == .normal ? sentence1 + sentence2 + sentence3 + sentence4 + sentence5 : sentence1 + sentence2Cupid + sentence3 + sentence4
    }
    
    func aboutMeParagragh2() -> String {
        /*
         I have a condo, house, boat and a car.
         I have a brother and a sister, and I want to have a child.
         */
        var sentence1: String = ""
        if asset?.isEmpty ?? true {
            sentence1 = "I have no assets."
        } else {
            sentence1 = "I have "
            for ass in asset! where ass != .UNKNOWN {
                if ass == asset?.first {
                    sentence1 = sentence1 + "a \(ass.title().lowercased())"
                } else if ass == asset?.last {
                    sentence1 = sentence1 + ", and a \(ass.title().lowercased())"
                } else {
                    sentence1 = sentence1 + ", a \(ass.title().lowercased())"
                }
            }
            sentence1 = sentence1 + ". "
        }
        
        var sentence2: String = ""
        if sibling == nil {
            sentence2 = "I have not indicated my siblings"
        } else if let sibling = sibling {
            switch sibling {
            case .onlyChild:
                sentence2 = "I am the only child"
            case .brother:
                sentence2 = "I have brother(s)"
            case .sister:
                sentence2 = "I have sister(s)"
            case .brotherAndSister:
                sentence2 = "I have brother(s) and sister(s)"
            }
        }
        
        var sentence3: String = ", and I not sure about wanting a child."
        if child == nil {
            sentence3 = "."
        } else if let child = child {
            switch child {
            case .want:
                sentence3 = ", and I want to have a child."
            case .doNotWant:
                sentence3 = ", and I don't want to have a child."
            case .notSure:
                break
            }
        }
        return sentence1 + sentence2 + sentence3
    }
    
    func aboutPartnerParagraph() -> String {
        /*
         You are a white female from age 30 - 34,
         who is kind and funny.
         You live in Toronto and you make 500k+.
         */
        var race: String = "a"
        if !(desiredEthnicity?.isEmpty ?? true) {
            let races = desiredEthnicity!.map({ $0.title().lowercased() })
            race = "a " + races.joined(separator: " or ")
        }
        var ageRange = "any age"
        if desiredMinAge == nil, let desiredMaxAge = desiredMaxAge {
            ageRange = "up to age \(desiredMaxAge)"
        } else if let desiredMinAge = desiredMinAge, desiredMaxAge == nil {
            ageRange = "at least age \(desiredMinAge)"
        } else if let desiredMinAge = desiredMinAge, let desiredMaxAge = desiredMaxAge {
            ageRange = "age \(desiredMinAge) to \(desiredMaxAge)"
        }
        let sentence1: String = "You are \(race) \(dateGender?.casualTitle().lowercased() ?? "") of \(ageRange), "
        
        var sentence2: String = "any personality."
        if !(desiredPersonality?.isEmpty ?? true) {
            let personalities = desiredPersonality!.map({ $0.title().lowercased() })
            sentence2 = "who is " + personalities.joined(separator: " and ") + ". "
        }
        
        var sentence3 = "Doesn't where you live "
        if !(desiredCityName?.isEmpty ?? true) {
            sentence3 = "You live in \(desiredCityName!) "
        }
        
        var sentence4 = "and doesn't matter how much you make."
        if let desiredMinIncome = desiredMinIncome, desiredMinIncome != .unknown && desiredMinIncome != .income0k {
            sentence4 = "and you make \(desiredMinIncome.shortTitle()) or higher. "
        }
        
        return sentence1 + sentence2 + sentence3 + sentence4
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
        return isVipBlur ?? false
    }
}

struct UsersInfosRecords: Codable {
    var current: Int
    var records: [UserInfo]
    var size: Int
    var total: Int
}


struct UserInfoResponse: Codable {
    var data: UserInfo?
    var code: Int
    var message: String
    var succeed: Bool
}

struct UsersInfosResponse: Codable {
    var data: UsersInfosRecords?
    var code: Int
    var message: String
    var succeed: Bool
}
