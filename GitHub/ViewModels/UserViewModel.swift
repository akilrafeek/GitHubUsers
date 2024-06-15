//
//  UserViewModel.swift
//  GitHub
//
//  Created by Rizwan Rafeek on 22/06/2024.
//

import Foundation
import CoreData
import UIKit

class UserViewModel {
    
    private let managedContext: NSManagedObjectContext
    
    init(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
    }
    
    
    @Published var user: [NSManagedObject] = []
    @Published var isError: Bool = false
    var onUserFetched: (() -> Void)?
    let customIndicatorView = UIActivityIndicatorView(style: .medium)
    
    func fetchUser(searchUsername: String? = nil) {
        if Reachability.isConnectedToNetwork() {
            NetworkManager.shared.fetchUsers(since: 0) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fetchedUsers):
                        self.saveUsersToLocal(fetchedUsers)
                        self.loadUserFromLocal(searchUsername: searchUsername)
                        self.customIndicatorView.startAnimating()
                    case .failure(_):
                        self.isError = true
                        self.loadUserFromLocal(searchUsername: searchUsername)
                    }
                    self.onUserFetched?()
                }
            }
        } else {
            loadUserFromLocal(searchUsername: searchUsername)
            customIndicatorView.startAnimating()
        }
    }
    
    private func saveUsersToLocal(_ fetchedUsers: [User]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let userEntity = NSEntityDescription.entity(forEntityName: "UsersList", in: managedContext)!
        
        for userData in fetchedUsers {
            let usersList = NSManagedObject(entity: userEntity, insertInto: managedContext)
            usersList.setValue(userData.id, forKey: "userId")
            usersList.setValue(userData.login, forKey: "login")
            usersList.setValue(userData.avatarUrl, forKey: "avatarUrl")
        }
        do {
            try managedContext.save()
        } catch {
            print("Failed to save UsersList to local: \(error)")
        }
    }
    
    private func loadUserFromLocal(searchUsername: String? = nil) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UsersList")
        
//        if let username = searchUsername, !username.isEmpty {
//            fetchRequest.predicate = NSPredicate(format: "login CONTAINS[cd] %@", username)
//        }
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            user = result as! [NSManagedObject]
        } catch {
            print("Failed to load UsersList from local: \(error)")
        }
    }
}
