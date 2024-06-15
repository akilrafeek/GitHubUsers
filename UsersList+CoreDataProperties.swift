//
//  UsersList+CoreDataProperties.swift
//  GitHub
//
//  Created by Rizwan Rafeek on 18/07/2024.
//
//

import Foundation
import CoreData


extension UsersList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UsersList> {
        return NSFetchRequest<UsersList>(entityName: "UserEntity")
    }

    @NSManaged public var avatarUrl: String?
    @NSManaged public var blog: String?
    @NSManaged public var company: String?
    @NSManaged public var email: String?
    @NSManaged public var followers: Int32
    @NSManaged public var following: Int32
    @NSManaged public var id: Int64
    @NSManaged public var isSeen: Bool
    @NSManaged public var location: String?
    @NSManaged public var login: String?
    @NSManaged public var note: NotesEntity?

}

extension UsersList : Identifiable {

}
