//
//  GPSLocation.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-15.
//

import Foundation

struct GPSLocation: Codable {
    var coordinates: [Double]
    var type: String = "Point"
    
    func params() -> [String: Any] {
        var params: [String: Any] = [:]
        params["coordinates"] = coordinates
        params["type"] = type
        return params
    }
}
