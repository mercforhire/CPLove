//
//  UnsplashModels.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-18.
//

import Foundation
import UIKit

/*
 {
     "id": 570883,
     "pageURL": "https://pixabay.com/photos/woman-silhouette-sunset-beach-sea-570883/",
     "type": "photo",
     "tags": "woman, silhouette, sunset",
     "previewURL": "https://cdn.pixabay.com/photo/2014/12/16/22/25/woman-570883_150.jpg",
     "previewWidth": 150,
     "previewHeight": 99,
     "webformatURL": "https://pixabay.com/get/g143a0097d0f87d817c5b9a21d540b730d9775c4bf0ef971d76a0cb309cef32d5fd5f93e9394c52025f1c5fc9a2cd1162_640.jpg",
     "webformatWidth": 640,
     "webformatHeight": 426,
     "largeImageURL": "https://pixabay.com/get/g68c148dd5890b2617903ca0361ca27bf49a25dcf56ccdb002f00af25288d27a90222bb9cf362cd1fdfe70b1fa65658684839e268343b09650ada72c25964f4a3_1280.jpg",
     "imageWidth": 3962,
     "imageHeight": 2641,
     "imageSize": 1886066,
     "views": 1588160,
     "downloads": 649513,
     "collections": 17855,
     "likes": 3632,
     "comments": 817,
     "user_id": 334088,
     "user": "JillWellington",
     "userImageURL": "https://cdn.pixabay.com/user/2018/06/27/01-23-02-27_250x250.jpg"
 }
 */

struct PhotoAPIModel: Codable {
    var identifier: Int
    var previewURL: String
    var webformatURL: String
    var largeImageURL: String
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case previewURL
        case webformatURL
        case largeImageURL
    }
}

struct PixabayResult: Codable {
    var hits: [PhotoAPIModel]
}
