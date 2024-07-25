//
//  User.swift
//  GitHub
//
//  Created by Akil Rafeek on 22/06/2024.
//

import Foundation

struct UserProfile: Codable {
    var login: String
    var id: Int
    var avatarUrl: String
    var followers: Int
    var following: Int
    var name: String
    var company: String?
    var blog: String
    
    enum CodingKeys: String, CodingKey {
        case login
        case id
        case avatarUrl = "avatar_url"
        case followers
        case following
        case name
        case company
        case blog
    }
}
