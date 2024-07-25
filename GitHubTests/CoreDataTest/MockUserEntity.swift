//
//  MockUserEntity.swift
//  GitHubTests
//
//  Created by Rizwan Rafeek on 25/07/2024.
//

import XCTest
@testable import GitHub

class MockUserEntity: UserEntityProtocol {
    var id: Int64
    var login: String
    var avatarUrl: String
    var blog: String?
    var company: String?
    var followers: Int32
    var following: Int32
    var isSeen: Bool
    var name: String
    var note: NoteEntity?
    
    required init(id: Int64, login: String, avatarUrl: String, blog: String?, company: String?, followers: Int32, following: Int32, isSeen: Bool, name: String, note: NoteEntity?) {
        self.id = id
        self.login = login
        self.avatarUrl = avatarUrl
        self.blog = blog
        self.company = company
        self.followers = followers
        self.following = following
        self.isSeen = isSeen
        self.name = name
        self.note = note
    }
}
