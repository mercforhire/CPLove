//
//  RegisterParams.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-11.
//

import Foundation

struct RegisterParams {
    var code: Int
    var email: String
    var userType: Int
    
    func params() -> [String: Any] {
        var params: [String: Any] = [:]
        
        params["code"] = code
        params["email"] = email
        params["userType"] = userType
        
        return params
    }
    
    init(code: Int, email: String, userType: UserTypeMode) {
        self.code = code
        self.email = email
        self.userType = userType.rawValue
    }
}
