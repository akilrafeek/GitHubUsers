//
//  NoteEntity+CoreDataProperties.swift
//  GitHub
//
//  Created by Rizwan Rafeek on 18/07/2024.
//
//

import Foundation
import CoreData


extension NoteEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteEntity> {
        return NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var content: String?
    @NSManaged public var user: UsersList?

}

extension NoteEntity : Identifiable {

}
