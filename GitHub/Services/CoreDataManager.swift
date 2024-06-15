//
//  CoreDataStack.swift
//  GitHub
//
//  Created by Akil Rafeek on 16/06/2024.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    private let writeQueue = DispatchQueue(label: "com.GitHub.coredata.writequeue")
    
    lazy var mainContext: NSManagedObjectContext = {
        return (UIApplication.shared.delegate as! AppDelegate).mainContext
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        return (UIApplication.shared.delegate as! AppDelegate).backgroundContext
    }()
    
    func saveContext(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        DispatchQueue.main.async {
            let context = self.backgroundContext
            block(context)
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print("Error saving context: \(error)")
                }
            }
        }
    }
    
//    func createUsers(user: User) {
//        performBackgroundTask { context in
//            let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "id == %d", user.id)
//            
//            do {
//                let results = try context.fetch(fetchRequest)
//                let userEntity = results.first ?? UserEntity(context: context)
//                userEntity.id = Int64(user.id)
//                userEntity.login = user.login
//                userEntity.avatarUrl = user.avatarUrl
//            } catch {
//                print("Error fetching user: \(error)")
//            }
//        }
//    }
    
    func createUsersList(user: User) {
        performBackgroundTask { context in
            let userEntity = UserEntity(context: context)
            userEntity.id = Int64(user.id)
            userEntity.login = user.login
            userEntity.avatarUrl = user.avatarUrl
            
            do {
                try context.save()
            } catch {
                print("Error saving new users: \(error)")
            }
        }
    }
    
    func updateUser(user: UserProfile) {
        performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "login == %@", user.login)
            
            do {
                let results = try context.fetch(fetchRequest)
                if let userEntity = results.first {
                    userEntity.id = Int64(user.id)
                    userEntity.login = user.login
                    userEntity.avatarUrl = user.avatarUrl
                    userEntity.name = user.name
                    userEntity.company = user.company
                    userEntity.blog = user.blog
                    
                    try context.save()
                    
                    DispatchQueue.main.async {
                        self.mainContext.performAndWait {
                            self.mainContext.refreshAllObjects()
                        }
                    }
                } else {
                    print("User not found")
                }
            } catch {
                print("Error updating user: \(error)")
            }
        }
    }
    
    func fetchUsers(completion: @escaping ([UserEntity]) -> Void) {
        mainContext.perform {
            let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            do {
                let users = try self.mainContext.fetch(fetchRequest)
                completion(users)
            } catch {
                print("Error fetching users: \(error)")
                completion([])
            }
        }
    }
    
    func fetchUser(withLogin login: String, completion: @escaping (UserEntity?) -> Void) {
        mainContext.perform {
            let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "login == %@", login)
            fetchRequest.fetchLimit = 1
            
            do {
                let results = try self.mainContext.fetch(fetchRequest)
                completion(results.first)
            } catch {
                print("Error fetching user: \(error)")
                completion(nil)
            }
        }
    }
    
    func saveNote(for userLogin: String, content: String) {
        performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "login == %@", userLogin)
            
            do {
                let results = try context.fetch(fetchRequest)
                if let user = results.first {
                    let note = user.note ?? NoteEntity(context: context)
                    note.content = content
                    note.user = user
                    try context.save()
                    
                    DispatchQueue.main.async {
                        self.mainContext.performAndWait {
                            self.mainContext.refreshAllObjects()
                        }
                    }
                }
            } catch {
                print("Error saving note: \(error)")
            }
            
            
        }
    }
    
    func fetchNote(for user: UserEntity) -> NoteEntity? {
        return user.note
    }
}
