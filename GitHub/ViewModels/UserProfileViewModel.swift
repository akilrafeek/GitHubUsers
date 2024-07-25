//
//  UserProfileViewModel.swift
//  GitHub
//
//  Created by Akil Rafeek on 24/06/2024.
//

import Foundation
import Combine

class UserProfileViewModel: ObservableObject {
    private let userLogin: String
    private let coreDataManager: CoreDataManagerProtocol
    private let networkManager: NetworkManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    
    @Published var showSnackbar = false
    @Published var snackbarMessage = ""
    @Published var isSuccessMessage = false
    
    @Published var avatarUrl: String = ""
    @Published var login: String = ""
    @Published var blog: String = ""
    @Published var company: String = ""
    @Published var followers: Int = 0
    @Published var following: Int = 0
    @Published var name: String = ""
    @Published var note: String?
    
    init(userLogin: String, coreDataManager: CoreDataManagerProtocol, networkManager: NetworkManagerProtocol) {
        self.userLogin = userLogin
        self.coreDataManager = coreDataManager
        self.networkManager = networkManager
    }
    
    func loadUserProfile() {
        coreDataManager.fetchUser(withLogin: userLogin) { [weak self] userEntity in
            if let user = userEntity, user.name != "" {
                self?.updateFromUserEntity(user)
            } else {
                self?.fetchUserProfile()
            }
        }
    }
    
    private func fetchUserProfile() {
        networkManager.fetchUserProfile(username: userLogin) { [weak self] result in
            switch result {
            case .success(let userProfile):
                self?.updateFromUserProfile(userProfile)
                self?.saveUserProfileToLocal(userProfile)
            case .failure(let error):
                print("Error fetching user profile: \(error)")
            }
        }
    }
    
    private func updateFromUserEntity(_ user: UserEntityProtocol) {
        DispatchQueue.main.async {
            self.avatarUrl = user.avatarUrl
            self.login = user.login
            self.blog = user.blog ?? "-"
            self.followers = Int(user.followers)
            self.following = Int(user.following)
            self.company = user.company ?? "-"
            self.name = user.name
            self.note = user.note?.content
        }
    }
    
    private func updateFromUserProfile(_ user: UserProfile) {
        DispatchQueue.main.async {
            self.avatarUrl = user.avatarUrl
            self.login = user.login
            self.blog = user.blog
            self.followers = user.followers
            self.following = user.following
            self.company = user.company ?? "-"
            self.name = user.name
        }
    }
    
    private func saveUserProfileToLocal(_ userProfile: UserProfile) {
        coreDataManager.updateUser(user: userProfile)
    }
    
    func saveNote(_ noteContent: String) {
        coreDataManager.saveNote(for: userLogin, content: noteContent) { success in
            DispatchQueue.main.async {
                self.note = noteContent
                if success {
                    self.snackbarMessage = "Note saved successfully!"
                    self.isSuccessMessage = true
                } else {
                    self.snackbarMessage = "Error saving note!"
                    self.isSuccessMessage = false
                }
                self.showSnackbar = true
                
                // Hide the snackbar after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.showSnackbar = false
                }
            }
        }
    }
}
