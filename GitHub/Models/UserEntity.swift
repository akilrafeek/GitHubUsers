//
//  UserEntity.swift
//  GitHub
//
//  Created by Akil Rafeek on 18/06/2024.
//

import Foundation
import CoreData

@objc(UserEntity)
protocol UserEntityProtocol {
    var id: Int64 { get set }
    var login: String { get set }
    var avatarUrl: String { get set }
    var blog: String? { get set }
    var company: String? { get set }
    var followers: Int32 { get set }
    var following: Int32 { get set }
    var isSeen: Bool { get set }
    var name: String { get set }
    var note: NoteEntity? { get set }
}

public class UserEntity: NSManagedObject, UserEntityProtocol {
    @NSManaged public var id: Int64
    @NSManaged public var login: String
    @NSManaged public var avatarUrl: String
    @NSManaged public var blog: String?
    @NSManaged public var company: String?
    @NSManaged public var followers: Int32
    @NSManaged public var following: Int32
    @NSManaged public var isSeen: Bool
    @NSManaged public var name: String
    @NSManaged public var note: NoteEntity?
    
    static func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }
}
