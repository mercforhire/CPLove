//
//  UserQueryParams.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-20.
//

import Foundation

struct UserQueryParams: Codable {
    var location: GPSLocation?
    var cityName: String?
    var minAge: Int?
    var maxAge: Int?
    var current: Int = 1
    var daterSort: UserSortMethod?
    var gender: GenderChoice?
    var isBlock: Bool?
    var matchmakerSort: CupidSortMethod?
    var maxIncome: Incomes?
    var minIncome: Incomes?
    var size: Int = 50
    var targetUserId: String?
    var userId: String?
    var userType: UserTypeMode?
    var vipIncomeSort: Bool?
    
    func params() -> [String: Any] {
        var params: [String: Any] = [:]
        
        if let location = location {
            params["location"] = location.params()
        }
        
        if let minAge = minAge {
            params["minAge"] = minAge
        }
        
        if let maxAge = maxAge {
            params["maxAge"] = maxAge
        }
        
        params["current"] = current
        
        if let daterSort = daterSort {
            params["daterSort"] = daterSort.rawValue
        }
        
        if let gender = gender {
            params["gender"] = gender.rawValue
        }
        
        if let isBlock = isBlock {
            params["isBlock"] = isBlock
        }
        
        if let matchmakerSort = matchmakerSort {
            params["matchmakerSort"] = matchmakerSort.rawValue
        }
        
        if let maxIncome = maxIncome {
            params["maxIncome"] = maxIncome.rawValue
        }

        if let minIncome = minIncome {
            params["minIncome"] = minIncome.rawValue == 1 ? 0 : minIncome.rawValue
        }
        
        params["size"] = size
        
        if let targetUserId = targetUserId {
            params["targetUserId"] = targetUserId
        }
        
        if let userId = userId {
            params["userId"] = userId
        }
        
        if let userType = userType {
            params["userType"] = userType.rawValue
        }
        
        if let vipIncomeSort = vipIncomeSort {
            params["vipIncomeSort"] = vipIncomeSort
        }
        
        return params
    }
    
    func encodeToData() -> Data? {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            return encoded
        }
        
        return nil
    }
    
    static func decodeFromData(data: Data) -> UserQueryParams? {
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode(UserQueryParams.self, from: data) {
            return decoded
        }
        
        return nil
    }
}
