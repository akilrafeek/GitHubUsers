//
//  Note+CoreDataProperties.swift
//  GitHub
//
//  Created by Rizwan Rafeek on 27/06/2024.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var content: String?
    @NSManaged public var usersList: UsersList?

}

extension Note : Identifiable {

}
