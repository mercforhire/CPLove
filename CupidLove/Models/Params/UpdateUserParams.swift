//
//  UpdateUserParams.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-16.
//

import Foundation
import CoreLocation

struct UpdateUserParams {
    var asset: [Assets]?
    var birthYear: Int?
    var child: ChildPreference?
    var cityName: String?
    var countryName: String?
    var location: GPSLocation?
    var dateGender: GenderChoice?
    var aboutMe: String?
    var desiredCityName: String?
    var desiredDescription: String?
    var desiredReligion: [Religions]?
    var desiredEthnicity: [Ethnicities]?
    var desiredMaxAge: Int?
    var desiredMinAge: Int?
    var desiredMinIncome: Incomes?
    var desiredPersonality: [Personality]?
    var ethnicity: Ethnicities?
    var firstName: String?
    var gender: GenderChoice?
    var height: HeightSelections?
    var bodyType: String?
    var horoscope: Horoscopes?
    var interests: [String]?
    var invitedBy: String?
    var isUserInfoComplete: Bool?
    var isVipBlur: Bool?
    var jobTitle: String?
    var lookingFor: RelationshipTypes?
    var maxIncome: Incomes?
    var minIncome: Incomes?
    var personalPhotos: [PhotoResponse]?
    var personality: [Personality]?
    var religion: Religions?
    var school: String?
    var sibling: Siblings?
    var isProfileHide: Bool?
    var notificationLevel: Int?
    
    func params() -> [String: Any] {
        var params: [String: Any] = [:]
        
        if let asset = asset {
            var array: [String] = []
            for ass in asset {
                array.append(ass.rawValue)
            }
            params["asset"] = array
        }
        
        if let birthYear = birthYear {
            params["birthYear"] = birthYear
        }
        
        if let child = child {
            params["child"] = child.rawValue
        }
        
        if let cityName = cityName {
            params["cityName"] = cityName
        }
        
        if let countryName = countryName {
            params["countryName"] = countryName
        }
        
        if let location = location {
            params["location"] = location.params()
        }
        
        if let dateGender = dateGender {
            params["dateGender"] = dateGender.rawValue
        }
        
        if let aboutMe = aboutMe {
            params["description"] = aboutMe
        }
        
        if let desiredCityName = desiredCityName {
            params["desiredCityName"] = desiredCityName
        }
        
        if let desiredDescription = desiredDescription {
            params["desiredDescription"] = desiredDescription
        }
        
        if let desiredReligion = desiredReligion?.first {
            params["desiredReligion"] = [desiredReligion.rawValue]
        }
        
        if let desiredMaxAge = desiredMaxAge {
            params["desiredMaxAge"] = desiredMaxAge
        }
        
        if let desiredMinAge = desiredMinAge {
            params["desiredMinAge"] = desiredMinAge
        }
        
        if let desiredMinIncome = desiredMinIncome {
            params["desiredMinIncome"] = desiredMinIncome.rawValue
        }
        
        if let desiredPersonality = desiredPersonality {
            var array: [String] = []
            for personality in desiredPersonality {
                array.append(personality.rawValue)
            }
            params["desiredPersonality"] = array
        }
        
        if let desiredEthnicity = desiredEthnicity {
            var array: [String] = []
            for race in desiredEthnicity {
                array.append(race.rawValue)
            }
            params["desiredEthnicity"] = array
        }
        
        if let ethnicity = ethnicity {
            params["ethnicity"] = ethnicity.rawValue
        }
        
        if let firstName = firstName {
            params["firstName"] = firstName
        }
        
        if let gender = gender {
            params["gender"] = gender.rawValue
        }
        
        if let height = height {
            params["height"] = height.rawValue
        }
        
        if let bodyType = bodyType {
            params["bodyType"] = bodyType
        }
        
        if let horoscope = horoscope {
            params["horoscope"] = horoscope.rawValue
        }
        
        if let maxIncome = maxIncome {
            params["maxIncome"] = maxIncome.rawValue
        }
        
        if let minIncome = minIncome {
            params["minIncome"] = minIncome.rawValue
        }
        
        if let interests = interests {
            params["interests"] = interests
        }
        
        if let invitedBy = invitedBy {
            params["invitedBy"] = invitedBy
        }
        
        if let isUserInfoComplete = isUserInfoComplete {
            params["isUserInfoComplete"] = isUserInfoComplete
        }
        
        if let isVipBlur = isVipBlur {
            params["isVipBlur"] = isVipBlur
        }
        
        if let jobTitle = jobTitle {
            params["jobTitle"] = jobTitle
        }
        
        if let lookingFor = lookingFor {
            params["lookingFor"] = lookingFor.rawValue
        }
        
        if let personalPhotos = personalPhotos {
            var array: [[String: Any]] = []
            
            for i in personalPhotos {
                array.append(i.params())
            }
            
            params["personalPhotos"] = array
        }
        
        if let personality = personality {
            var array: [String] = []
            for personality in personality {
                array.append(personality.rawValue)
            }
            params["personality"] = array
        }
        
        if let religion = religion {
            params["religion"] = religion.rawValue
        }
        
        if let school = school {
            params["school"] = school
        }
        
        if let sibling = sibling {
            params["sibling"] = sibling.rawValue
        }
        
        if let isProfileHide = isProfileHide {
            params["isProfileHide"] = isProfileHide
        }
        
        if let notificationLevel = notificationLevel {
            params["notificationLevel"] = notificationLevel
        }
        
        return params
    }
    
    init() {
        
    }
    
    init(userInfo: MyUserInfo) {
        self.asset = userInfo.asset
        self.birthYear = userInfo.birthYear
        self.child = userInfo.child
        self.cityName = userInfo.cityName
        self.countryName = userInfo.countryName
        self.location = userInfo.location
        self.dateGender = userInfo.dateGender
        self.aboutMe = userInfo.aboutMe
        self.desiredCityName = userInfo.desiredCityName
        self.desiredDescription = userInfo.desiredDescription
        self.desiredReligion = userInfo.desiredReligion
        self.desiredEthnicity = userInfo.desiredEthnicity
        self.desiredMaxAge = userInfo.desiredMaxAge
        self.desiredMinAge = userInfo.desiredMinAge
        self.desiredMinIncome = userInfo.desiredMinIncome
        self.desiredPersonality = userInfo.desiredPersonality
        self.ethnicity = userInfo.ethnicity
        self.firstName = userInfo.firstName
        self.gender = userInfo.gender
        self.height = userInfo.height
        self.bodyType = userInfo.bodyType
        self.horoscope = userInfo.horoscope
        self.interests = userInfo.interests
        self.isVipBlur = userInfo.isVipBlur
        self.jobTitle = userInfo.jobTitle
        self.lookingFor = userInfo.lookingFor
        self.maxIncome = userInfo.maxIncome
        self.minIncome = userInfo.minIncome
        self.religion = userInfo.religion
        self.school = userInfo.school
        self.sibling = userInfo.sibling
    }
    
    mutating func randomize() {
        var assets: [Assets] = []
        for asset in Assets.list() {
            if Bool.random() && Bool.random() {
                assets.append(asset)
            }
        }
        self.asset = assets
        
        self.birthYear = Date().getPastOrFutureDate(years: -1 * Int.random(in: 18...50)).year()
        
        self.child = ChildPreference.random()
        
        var cities: [(String, CLLocation)] = []
        cities.append(("Toronto", CLLocation(latitude: 43.6516053, longitude: -79.3831254)))
        cities.append(("Montréal", CLLocation(latitude: 45.5077734, longitude: -73.5544607)))
        cities.append(("Ottawa", CLLocation(latitude: 45.4200146, longitude: -75.6895387)))
        cities.append(("Vancouver", CLLocation(latitude: 49.2604134, longitude: -123.1139456)))
        cities.append(("Calgary", CLLocation(latitude: 51.0453937, longitude: -114.0580874)))
        cities.append(("Winnipeg", CLLocation(latitude: 49.8992719, longitude: -97.1388257)))
        
        let randomCity = cities.randomElement()!
        self.cityName = randomCity.0
        self.countryName = "Canada"
        self.location = GPSLocation(coordinates: [randomCity.1.coordinate.latitude, randomCity.1.coordinate.longitude])
        self.gender = GenderChoice.random()
        
        self.dateGender = GenderChoice.random()
        
        var initialSentence = ""
        switch gender {
        case .male:
            switch dateGender {
            case .male:
                initialSentence = "I am a gay male.\n"
            case .female:
                initialSentence = "I am a straight male.\n"
            default:
                initialSentence = "I am a male seeking a transgender.\n"
            }
        case .female:
            switch dateGender {
            case .male:
                initialSentence = "I am a straight female.\n"
            case .female:
                initialSentence = "I am a lesbian female.\n"
            default:
                initialSentence = "I am a female seeking a transgender.\n"
            }
        default:
            initialSentence = "I am a transgender.\n"
        }
        
        self.aboutMe = initialSentence + faker.lorem.paragraphs(amount: 1)
        
        self.desiredCityName = cityName
        
        self.desiredDescription = faker.lorem.paragraphs(amount: 1)
        
        self.desiredReligion = [Religions.random()]
        
        self.desiredEthnicity = Bool.random() ? [Ethnicities.list().randomElement()!] : [Ethnicities.list().randomElement()!, Ethnicities.list().randomElement()!]
        
        self.desiredMaxAge = Int.random(in: 21...50)
        
        self.desiredMinAge = Int.random(in: 20..<self.desiredMaxAge!)
        
        self.desiredMinIncome = Incomes(rawValue: Int.random(in: 2...Incomes.incomeInfinite.rawValue))!
        
        var personalityArray: [Personality] = []
        for _ in 0...Int.random(in: 2...16) {
            let random = Personality.list().randomElement()!
            if personalityArray.contains(random) {
                continue
            }
            personalityArray.append(random)
        }
        self.desiredPersonality = personalityArray
        
        self.ethnicity = Ethnicities.list().randomElement()!
        
        self.firstName = faker.name.firstName()
        
        self.height = HeightSelections.list().randomElement()!
        
        self.bodyType = BodyTypes.list().randomElement()!.title()
        
        self.horoscope = Horoscopes.list().randomElement()!
        
        var interests: [String] = []
        for _ in 0...Int.random(in: 2...16) {
            let random = Interests.random().title()
            if interests.contains(random) {
                continue
            }
            interests.append(Interests.random().rawValue)
        }
        self.interests = interests
        
        self.isUserInfoComplete = true
        
        self.isVipBlur = Bool.random() && Bool.random()
        self.jobTitle = faker.name.title()
        self.lookingFor = RelationshipTypes.list().randomElement()!
        
        let incomeRange = Incomes.ranges().randomElement()!
        self.maxIncome = incomeRange.last
        self.minIncome = incomeRange.first
        
        self.religion = Religions.random()
        self.school = "School of \(faker.team.state())"
        
        var personalityArray2: [Personality] = []
        for _ in 0...Int.random(in: 2...16) {
            let random = Personality.list().randomElement()!
            if personalityArray.contains(random) {
                continue
            }
            personalityArray2.append(random)
        }
        self.personality = personalityArray2
        
        self.sibling = Siblings.list().randomElement()
    }
    
    init(type: UserTypeMode, photos: [PhotoAPIModel]) {
        var assets: [Assets] = []
        for asset in Assets.list() {
            if Bool.random() && Bool.random() {
                assets.append(asset)
            }
        }
        self.asset = assets
        
        self.birthYear = Date().getPastOrFutureDate(years: -1 * Int.random(in: 18...50)).year()
        
        self.child = ChildPreference.random()
        
        var cities: [(String, CLLocation)] = []
        cities.append(("Toronto", CLLocation(latitude: 43.6516053, longitude: -79.3831254)))
        cities.append(("Montréal", CLLocation(latitude: 45.5077734, longitude: -73.5544607)))
        cities.append(("Ottawa", CLLocation(latitude: 45.4200146, longitude: -75.6895387)))
        cities.append(("Vancouver", CLLocation(latitude: 49.2604134, longitude: -123.1139456)))
        cities.append(("Calgary", CLLocation(latitude: 51.0453937, longitude: -114.0580874)))
        cities.append(("Winnipeg", CLLocation(latitude: 49.8992719, longitude: -97.1388257)))
        
        let randomCity = cities.randomElement()!
        self.cityName = randomCity.0
        self.countryName = "Canada"
        self.location = GPSLocation(coordinates: [randomCity.1.coordinate.latitude, randomCity.1.coordinate.longitude])
        
        self.gender = GenderChoice.random()
        self.dateGender = GenderChoice.random()
        
        var initialSentence = ""
        switch type {
        case .normal:
            switch gender {
            case .male:
                switch dateGender {
                case .male:
                    initialSentence = "I am a gay male.\n"
                case .female:
                    initialSentence = "I am a straight male.\n"
                default:
                    initialSentence = "I am a male seeking a transgender.\n"
                }
            case .female:
                switch dateGender {
                case .male:
                    initialSentence = "I am a straight female.\n"
                case .female:
                    initialSentence = "I am a lesbian female.\n"
                default:
                    initialSentence = "I am a female seeking a transgender.\n"
                }
            default:
                initialSentence = "I am a transgender.\n"
            }
        case .cupid:
            switch gender {
            case .male:
                initialSentence = "I am a male.\n"
            case .female:
                initialSentence = "I am a female.\n"
            default:
                initialSentence = ""
            }
        default:
            initialSentence = ""
        }
        
        var secondSentence = ""
        switch type {
        case .normal:
            secondSentence = "I am looking to date.\n"
        case .cupid:
            secondSentence = "I am a cupid.\n"
        default:
            secondSentence = ""
        }
        
        self.aboutMe = initialSentence + secondSentence + faker.lorem.paragraphs(amount: 1)
        
        self.desiredCityName = cityName
        
        self.desiredDescription = faker.lorem.paragraphs(amount: 1)
        
        self.desiredReligion = [Religions.random()]
        
        self.desiredEthnicity = Bool.random() ? [Ethnicities.list().randomElement()!] : [Ethnicities.list().randomElement()!, Ethnicities.list().randomElement()!]
        
        self.desiredMaxAge = Int.random(in: 21...50)
        
        self.desiredMinAge = Int.random(in: 20..<self.desiredMaxAge!)
        
        self.desiredMinIncome = Incomes(rawValue: Int.random(in: 2...Incomes.incomeInfinite.rawValue))!
        
        var personalityArray: [Personality] = []
        for _ in 0...Int.random(in: 0...16) {
            let random = Personality.list().randomElement()!
            if personalityArray.contains(random) {
                continue
            }
            personalityArray.append(random)
        }
        self.desiredPersonality = personalityArray
        
        self.ethnicity = Ethnicities.list().randomElement()!
        
        self.firstName = faker.name.firstName()
        
        self.height = HeightSelections.list().randomElement()!
        
        self.bodyType = BodyTypes.list().randomElement()!.title()
        
        self.horoscope = Horoscopes.list().randomElement()!
        
        var interests: [String] = []
        for _ in 0...Int.random(in: 0...16) {
            let random = Interests.random().title()
            if interests.contains(random) {
                continue
            }
            interests.append(Interests.random().rawValue)
        }
        self.interests = interests
        
        self.isUserInfoComplete = true
        
        self.isVipBlur = Bool.random() && Bool.random()
        self.jobTitle = faker.name.title()
        self.lookingFor = RelationshipTypes.list().randomElement()!
        
        let incomeRange = Incomes.ranges().randomElement()!
        self.maxIncome = incomeRange.last
        self.minIncome = incomeRange.first
        
        var photoModels: [PhotoResponse] = []
        for i in photos {
            photoModels.append(PhotoResponse(photoName: i.previewURL.components(separatedBy: "/").last!,
                                             photoUrl: i.previewURL,
                                             thumbnailName: i.previewURL.components(separatedBy: "/").last!,
                                             thumbnailUrl: i.previewURL))
        }
        self.personalPhotos = photoModels
        self.religion = Religions.random()
        self.school = "School of \(faker.team.state())"
        
        if type == .normal {            
            var personalityArray2: [Personality] = []
            for _ in 0...Int.random(in: 0...16) {
                let random = Personality.list().randomElement()!
                if personalityArray.contains(random) {
                    continue
                }
                personalityArray2.append(random)
            }
            self.personality = personalityArray2
            
            self.sibling = Siblings.list().randomElement()
        }
    }
    
    func aboutMeParagragh(userType: UserTypeMode) -> String {
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
}
