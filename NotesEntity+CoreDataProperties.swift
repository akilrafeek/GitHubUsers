//
//  NotesEntity+CoreDataProperties.swift
//  GitHub
//
//  Created by Rizwan Rafeek on 18/07/2024.
//
//

import Foundation
import CoreData


extension NotesEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotesEntity> {
        return NSFetchRequest<NotesEntity>(entityName: "NotesEntity")
    }

    @NSManaged public var content: String?
    @NSManaged public var id: Int64
    @NSManaged public var user: UsersList?

}

extension NotesEntity : Identifiable {

}
