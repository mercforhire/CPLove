//
//  DefaultResponse.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-11.
//

import Foundation

struct DefaultStringResponse: Codable {
    var data: String?
    var code: Int
    var message: String
    var succeed: Bool
}

struct DefaultIntResponse: Codable {
    var data: Int?
    var code: Int
    var message: String
    var succeed: Bool
}

struct DefaultResponse: Codable {
    var data: Bool?
    var code: Int
    var message: String
    var succeed: Bool
}

struct DefaultSimpleResponse: Codable {
    var code: Int
    var message: String
    var succeed: Bool
}
