//
//  User.swift
//  GitHub
//
//  Created by Akil Rafeek on 22/06/2024.
//

import Foundation

struct User: Codable {
    var login: String
    var id: Int
    var avatarUrl: String
    
    enum CodingKeys: String, CodingKey {
        case login
        case id
        case avatarUrl = "avatar_url"
    }
}
