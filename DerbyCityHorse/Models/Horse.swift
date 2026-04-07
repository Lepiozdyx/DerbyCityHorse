//
//  Horse.swift
//  DerbyCityHorse
//
//  Created by test on 14.02.2026.
//

import Foundation
import SwiftUI

struct Horse: Identifiable, Codable {
    var id: UUID
    var name: String
    var breed: String
    var dateOfBirth: Date
    var photoData: Data?
    
    var photo: Image? {
        if let photoData = photoData,
           let uiImage = UIImage(data: photoData) {
            return Image(uiImage: uiImage)
        }
        return nil
    }
    
    init(id: UUID = UUID(), name: String, breed: String, dateOfBirth: Date, photoData: Data? = nil) {
        self.id = id
        self.name = name
        self.breed = breed
        self.dateOfBirth = dateOfBirth
        self.photoData = photoData
    }
}
