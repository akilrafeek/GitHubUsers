//
//  UserProfileViewModel.swift
//  GitHub
//
//  Created by Rizwan Rafeek on 24/06/2024.
//

import Foundation
import CoreData
import UIKit

class UserProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var inputNote: String = ""
    let username: String
    let userId: Int16
    var userProfile: NSManagedObject?
    
    init(username: String, userId: Int16) {
        self.username = username
        self.userId = userId
    }
    
    func fetchUserProfile() {
        if Reachability.isConnectedToNetwork() {
            NetworkManager.shared.fetchUserProfile(username: username) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let user):
                        self?.saveUserProfileToLocal(user)
                        self?.loadUserProfileFromLocal()
                    case .failure(_):
                        self?.loadUserProfileFromLocal()
                    }
                }
            }
        } else {
            loadUserProfileFromLocal()
        }
    }
    
    private func saveUserProfileToLocal(_ fetchedUsers: UserProfile) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "UsersList")
        fetchRequest.predicate = NSPredicate(format: "login = %@", username)
        
        do {
            let usersList = try managedContext.fetch(fetchRequest)
            let objectUpdate = usersList[0] as! NSManagedObject
            objectUpdate.setValue(fetchedUsers.blog, forKey: "blog")
            objectUpdate.setValue(fetchedUsers.company, forKey: "company")
            objectUpdate.setValue(fetchedUsers.email, forKey: "email")
            objectUpdate.setValue(fetchedUsers.followers, forKey: "followers")
            objectUpdate.setValue(fetchedUsers.following, forKey: "following")
            objectUpdate.setValue(fetchedUsers.location, forKey: "location")
            do {
                try managedContext.save()
            } catch {
                print("Failed to update UsersList to local: \(error)")
            }
        } catch {
            print("Failed to update UsersList to local: \(error)")
        }
    }
    
    func loadUserProfileFromLocal() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UsersList")
        fetchRequest.predicate = NSPredicate(format: "login = %@", username)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            userProfile = result[0] as? NSManagedObject
            self.inputNote = userProfile?.value(forKey: "notes") as? String ?? ""
        } catch {
            print("Failed to load UsersList from local: \(error)")
        }
    }
    
    func saveNoteToLocal() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "UsersList")
        fetchRequest.predicate = NSPredicate(format: "login = %@", username)
        
        do {
            let userList = try managedContext.fetch(fetchRequest)
            let objectUpdate = userList[0] as! NSManagedObject
            objectUpdate.setValue(self.inputNote, forKey: "notes")
            
            do {
                try managedContext.save()
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
//    func loadNoteFromLocal() {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
//        let managedContext = appDelegate.persistentContainer.viewContext
//        
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UsersList")
//        fetchRequest.predicate = NSPredicate(format: "login = %@", username)
//        
//        do {
//            let result = try managedContext.fetch(fetchRequest)
//            let getNote = result[0] as! NSManagedObject
//            self.inputNote = getNote.value(forKey: "notes") as? String ?? ""
//        } catch {
//            print("Failed to load UsersList from local: \(error)")
//        }
//    }
}
