//
//  DataModels.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-04.
//

import Foundation

struct Gallery: Codable {
    var identifier: [String: String]
    var index: [String: String]
    var pending: [String: String]
    var normalImage_fileLink: String
    
    enum CodingKeys: String, CodingKey {
        case identifier = "_id"
        case index
        case pending
        case normalImage_fileLink
    }
    
    func description() -> String {
        var jsonString = "  {\n"
        jsonString = jsonString + "     identifier: \(identifier.values.first ?? "")\n"
        jsonString = jsonString + "     index: \(index.values.first ?? "")\n"
        jsonString = jsonString + "     pending: \(pending.values.first ?? "")\n"
        jsonString = jsonString + "     normalImage_fileLink: \(normalImage_fileLink)\n"
        jsonString = jsonString + " },\n"
        return jsonString
    }
}

struct SiteUserModel: Codable {
    var identifier: String
    var birthDay: String
    var city: String
    var gallery: [Gallery]
    var country: String
    var degree: String
    var email: String
    var ethnicity: String
    var faith: String
    var fieldOfStudy: String
    var firstName: String
    var gender: String
    var hasCar: String
    var hasChildren: String
    var hasProperty: String
    var heightBodyType: String
    var incomeRange: String
    var maritalStatus: String
    var normalImage_fileLink: String
    var occupation: String
    var schoolOfGraduation: String
    var status: String
    var talkAboutSelf: String
    var wantAge: String
    var wantAgeEnd: String
    var wantAgeStart: String
    var wantChildren: String
    var wantCity: String
    var wantOther: String
    var wantIncomeEnd: String
    var wantIncomeStart: String
    var wantRace: String
    
    enum CodingKeys: String, CodingKey {
        case identifier = "_id"
        case birthDay
        case city
        case gallery
        case country
        case degree
        case email
        case ethnicity
        case faith
        case fieldOfStudy
        case firstName
        case gender
        case hasCar
        case hasChildren
        case hasProperty
        case heightBodyType
        case incomeRange
        case maritalStatus
        case normalImage_fileLink
        case occupation
        case schoolOfGraduation
        case status
        case talkAboutSelf
        case wantAge
        case wantAgeEnd
        case wantAgeStart
        case wantChildren
        case wantCity
        case wantOther
        case wantIncomeEnd
        case wantIncomeStart
        case wantRace
    }
    
    func toParams() -> UpdateUserParams {
        var params = UpdateUserParams()
        if !firstName.isEmpty {
            params.firstName = firstName
        }
        
        
        if !birthDay.isEmpty,
           let birthdayDate = DateUtil.produceDate(dateString: birthDay, dateFormat: DateUtil.AppDateFormat.format15.rawValue) {
            params.birthYear = birthdayDate.year()
            params.horoscope = Horoscopes.getHoroscope(date: birthdayDate)
        }
        
        if !city.isEmpty {
            params.cityName = city
        }
        
        if !country.isEmpty {
            params.countryName = country
        }
        
        if !ethnicity.isEmpty {
            if ethnicity == "Asian" {
                params.ethnicity = .ASIAN
            }
        }
        
        if !faith.isEmpty {
            if faith.lowercased() == "christian" || faith == "基督教" {
                params.religion = .CHRISTIAN
            } else if faith.lowercased() == "catholic" {
                params.religion = .CATHOLIC
            } else if faith.lowercased() == "not religion" || faith == "没有信仰" || faith.lowercased() == "none" || faith == "无" || faith.lowercased() == "myself" || faith.lowercased() == "no" {
                params.religion = .NO_RELIGION
            } else if faith.lowercased() == "buddhism" {
                params.religion = .BUDDHIST
            } else {
                params.religion = .OTHERS
            }
        } else {
            params.religion = .NO_RELIGION
        }
        
        if !occupation.isEmpty {
            params.jobTitle = occupation
        }
        
        if !gender.isEmpty {
            if gender.lowercased() == "man" || gender.lowercased() == "male" {
                params.gender = .male
                params.dateGender = .female
            } else if gender.lowercased() == "female" || gender.lowercased() == "woman" {
                params.gender = .female
                params.dateGender = .male
            }
        }
        
        params.asset = []
        if !hasCar.isEmpty {
            if hasCar.lowercased() == "yes" {
                params.asset?.append(.CAR)
            }
        }
        if !hasProperty.isEmpty {
            if hasProperty.lowercased() == "yes" {
                params.asset?.append(Bool.random() ? .CONDO : .HOUSE)
            }
        }
        
        if !heightBodyType.isEmpty, let heightCM = heightBodyType.int {
            let heightEnum = HeightSelections.getHeightFrom(heightCM: heightCM)
            params.height = heightEnum
        }
        
        if !incomeRange.isEmpty, let income = incomeRange.int, let incomeRange = Incomes.getIncomeRangeFrom(income: income) {
            params.minIncome = incomeRange.first!
            params.maxIncome = incomeRange.last!
        }
        
        if !wantIncomeStart.isEmpty, let minIncome = wantIncomeStart.int, let incomeRange = Incomes.getIncomeRangeFrom(income: minIncome) {
            params.desiredMinIncome = incomeRange.first!
        } else {
            params.desiredMinIncome = .income0k
        }
        
        let choices: [RelationshipTypes] = [.MARRIAGE, .RELATIONSHIP, .CASUAL]
        
        if !maritalStatus.isEmpty {
            if maritalStatus.lowercased() == "yes" {
                params.lookingFor = .FRIENDSHIP
            }
        }
        
        if !schoolOfGraduation.isEmpty {
            params.school = schoolOfGraduation
        }
        
        if status.lowercased() == "single" {
            params.lookingFor = choices.randomElement()!
        }
        
        if !talkAboutSelf.isEmpty {
            params.aboutMe = talkAboutSelf
        }
        
        params.desiredReligion = [.DOESNT_MATTER]
        
        if !wantAge.isEmpty && !wantAgeEnd.isEmpty, let wantAgeInt = wantAge.int, let wantAgeEndInt = wantAgeEnd.int {
            params.desiredMinAge = wantAgeInt
            params.desiredMaxAge = wantAgeEndInt
        } else {
            params.desiredMinAge = 20
            params.desiredMaxAge = 40
        }
        
        if wantChildren.lowercased() == "yes" {
            params.child = .want
        } else if wantChildren.lowercased() == "no" {
            params.child = .doNotWant
        } else {
            params.child = .notSure
        }
        
        if !wantCity.isEmpty {
            params.desiredCityName = wantCity.lowercased().capitalizingFirstLetter()
        }
        
        if !wantOther.isEmpty {
            params.desiredDescription = wantOther
        }
        
        if !wantRace.isEmpty, wantRace.lowercased() == "asian" || wantRace.lowercased() == "chinese" {
            params.desiredEthnicity = [.ASIAN]
        }
        
        return params
    }
    
    func description() -> String {
        var jsonString = "{\n"
        jsonString = jsonString + "identifier: \(identifier)\n"
        jsonString = jsonString + "birthDay: \(birthDay)\n"
        jsonString = jsonString + "city: \(city)\n"
        
        jsonString = jsonString + "gallery:\n"
        for g in gallery {
            jsonString = jsonString + g.description()
        }
        
        jsonString = jsonString + "country: \(country)\n"
        jsonString = jsonString + "degree: \(degree)\n"
        jsonString = jsonString + "email: \(email)\n"
        jsonString = jsonString + "ethnicity: \(ethnicity)\n"
        jsonString = jsonString + "faith: \(faith)\n"
        jsonString = jsonString + "fieldOfStudy: \(fieldOfStudy)\n"
        jsonString = jsonString + "firstName: \(firstName)\n"
        jsonString = jsonString + "gender: \(gender)\n"
        jsonString = jsonString + "hasCar: \(hasCar)\n"
        jsonString = jsonString + "hasChildren: \(hasChildren)\n"
        jsonString = jsonString + "hasProperty: \(hasProperty)\n"
        jsonString = jsonString + "heightBodyType: \(heightBodyType)\n"
        jsonString = jsonString + "incomeRange: \(incomeRange)\n"
        jsonString = jsonString + "maritalStatus: \(maritalStatus)\n"
        jsonString = jsonString + "normalImage_fileLink: \(normalImage_fileLink)\n"
        jsonString = jsonString + "occupation: \(occupation)\n"
        jsonString = jsonString + "schoolOfGraduation: \(schoolOfGraduation)\n"
        jsonString = jsonString + "status: \(status)\n"
        jsonString = jsonString + "talkAboutSelf: \(talkAboutSelf)\n"
        jsonString = jsonString + "wantAge: \(wantAge)\n"
        jsonString = jsonString + "wantAgeEnd: \(wantAgeEnd)\n"
        jsonString = jsonString + "wantAgeStart: \(wantAgeStart)\n"
        jsonString = jsonString + "wantChildren: \(wantChildren)\n"
        jsonString = jsonString + "wantOther: \(wantOther)\n"
        jsonString = jsonString + "wantIncomeEnd: \(wantIncomeEnd)\n"
        jsonString = jsonString + "wantIncomeStart: \(wantIncomeStart)\n"
        jsonString = jsonString + "wantRace: \(wantRace)\n"
        jsonString = jsonString + "\n}\n"
        return jsonString
    }
}

struct SiteUserModelRoot: Codable {
    var users: [SiteUserModel]
    
    enum CodingKeys: String, CodingKey {
        case users = "RECORDS"
    }
}

struct PhotoCellModel: Codable {
    var identifier: Int
    var normalUrl: String
    var smallUrl: String
    
    init(data: PhotoAPIModel) {
        self.identifier = data.identifier
        self.normalUrl = data.largeImageURL
        self.smallUrl = data.webformatURL
    }
}
