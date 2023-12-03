//
//  RegisterResponse.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-11.
//

import Foundation

struct LoginInfo: Codable {
    var identifier: String
    var token: String
    var isUserInfoComplete: Bool?
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case token
        case isUserInfoComplete
    }
    
    func encodeToData() -> Data? {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            return encoded
        }
        
        return nil
    }
    
    static func decodeFromData(data: Data) -> LoginInfo? {
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode(LoginInfo.self, from: data) {
            return decoded
        }
        
        return nil
    }
}

struct RegisterResponse: Codable {
    var data: LoginInfo?
    var code: Int
    var message: String
    var succeed: Bool
}
