//
//  UserNote+CoreDataProperties.swift
//  GitHub
//
//  Created by Rizwan Rafeek on 24/06/2024.
//
//

import Foundation
import CoreData


extension UserNote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserNote> {
        return NSFetchRequest<UserNote>(entityName: "UserNote")
    }

    @NSManaged public var username: String?
    @NSManaged public var noteText: String?

}

extension UserNote : Identifiable {

}
