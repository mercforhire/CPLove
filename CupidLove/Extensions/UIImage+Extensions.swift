//
//  UIImage+Extensions.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-21.
//

import Foundation
import UIKit

extension UIImage {
    var jpeg: Data? { jpegData(compressionQuality: 0.9) }  // QUALITY min = 0 / max = 1
    var png: Data? { pngData() }
    
    static func saveImageToDocumentDirectory(filename: String, jpegData: Data) -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "\(filename).jpg" // name of the image to be saved
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try? FileManager.default.removeItem(atPath: fileURL.path)
        }
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try jpegData.write(to: fileURL)
                print("JPEG saved to \(fileURL)")
                return fileURL
            } catch {
                print("error saving file: \(fileURL)", error)
            }
        }
        return nil
    }
    
    static func loadImageFromDocumentDirectory(nameOfImage: String) -> UIImage? {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath = paths.first{
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(nameOfImage)
            let image = UIImage(contentsOfFile: imageURL.path)
            return image!
        }
        return nil
    }
}
