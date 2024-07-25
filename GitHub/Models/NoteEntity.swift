//
//  NoteEntity.swift
//  GitHub
//
//  Created by Akil Rafeek on 18/07/2024.
//

import Foundation
import CoreData

@objc(NoteEntity)
public class NoteEntity: NSManagedObject {
    @NSManaged public var id: Int64
    @NSManaged public var content: String
    @NSManaged public var user: UserEntity
}

extension NoteEntity {
    static func fetchRequest() -> NSFetchRequest<NoteEntity> {
        return NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
    }
}
