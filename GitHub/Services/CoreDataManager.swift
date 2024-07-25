//
//  CoreDataStack.swift
//  GitHub
//
//  Created by Akil Rafeek on 16/06/2024.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager: CoreDataManagerProtocol {
    
    static let shared = CoreDataManager()
    
    private let persistentContainer: NSPersistentContainer
    
    internal init(inMemory: Bool = false, managedObjectModel: NSManagedObjectModel? = nil) {
        if let model = managedObjectModel {
            persistentContainer = NSPersistentContainer(name: "GitHub", managedObjectModel: model)
        } else {
            persistentContainer = NSPersistentContainer(name: "GitHub")
        }
        
        if inMemory {
            persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    private let writeQueue = DispatchQueue(label: "com.GitHub.coredata.writequeue")
    
    lazy var mainContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
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
                    userEntity.followers = Int32(user.followers)
                    userEntity.following = Int32(user.following)
                    userEntity.isSeen = true
                    
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
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            do {
                let users = try self.mainContext.fetch(fetchRequest)
                completion(users)
            } catch {
                print("Error fetching users: \(error)")
                completion([])
            }
        }
    }
    
    func fetchUser(withLogin login: String, completion: @escaping (UserEntityProtocol?) -> Void) {
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
    
    func saveNote(for userLogin: String, content: String, completion: @escaping (Bool) -> Void) {
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
                        completion(true)
                    }
                }
            } catch {
                print("Error saving note: \(error)")
                completion(false)
            }
            
            
        }
    }
    
    func fetchNote(for user: UserEntityProtocol) -> NoteEntity? {
        return user.note
    }
}

protocol CoreDataManagerProtocol {
    func updateUser(user: UserProfile)
    func fetchUser(withLogin login: String, completion: @escaping (UserEntityProtocol?) -> Void)
    func fetchUsers(completion: @escaping ([UserEntity]) -> Void)
    func createUsersList(user: User)
    func saveNote(for userLogin: String, content: String, completion: @escaping (Bool) -> Void)
}
