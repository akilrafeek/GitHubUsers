//
//  Profile.swift
//  GitHub
//
//  Created by Rizwan Rafeek on 25/06/2024.
//

import Foundation

struct Profile: Codable {
    
    var avatarUrl: String
    var followers: Int16
    var following: Int16
    var name: String?
    var company: String?
    var blog: String?
    var notes: String?
    
    enum CodingKeys: String, CodingKey {
        case avatarUrl = "avatar_url"
        case followers
        case following
        case name
        case company
        case blog
        case notes
    }
}
