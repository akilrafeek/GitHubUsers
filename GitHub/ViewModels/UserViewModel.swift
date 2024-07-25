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
    private let coreDataManager: CoreDataManagerProtocol
    private var networkManager: NetworkManagerProtocol
    
    var users: [UserEntity] = []
    private var filteredUsers: [UserEntity] = []
    private var isSearchActive = false
    private var currentPage = 0
    private var pageSize = 15
    
    var isLoading = false
    var onUserFetched: (() -> Void)?
    
    @Published var isOffline = false
    private var retryTimer: Timer?
    
    init(coreDataManager: CoreDataManagerProtocol, networkManager: NetworkManagerProtocol) {
        self.coreDataManager = coreDataManager
        self.networkManager = networkManager
    }
    
    var numberOfUsers: Int {
        return isSearchActive ? filteredUsers.count : users.count
    }
    
    func user(at index: Int) -> UserCellViewModel {
        let user = isSearchActive ? filteredUsers[index] : users[index]
        return UserCellViewModelImpl(user: user)
    }
    
//    private func setupNetworkMonitorting() {
//        networkManager.connectionChangedHandler = { [weak self] isConnected in
//            DispatchQueue.main.async {
//                self?.isOffline = !isConnected
//                if isConnected {
//                    self?.fetchUsers()
//                } else {
//                    self?.startRetryTimer()
//                }
//            }
//        }
//        networkManager.startMonitoring()
//    }
    
    private func setupNetworkMonitoring() {
        networkManager.connectionChangedHandler = { [weak self] isConnected in
            DispatchQueue.main.async {
                self?.isOffline = !isConnected
                if isConnected {
                    self?.retryTimer?.invalidate()
                    self?.retryTimer = nil
                    self?.fetchUsers()
                } else {
                    self?.startRetryTimer()
                }
            }
        }
        networkManager.startMonitoring()
    }
    
    private func startRetryTimer() {
        retryTimer?.invalidate()
        retryTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.checkConnectionAndFetch()
        }
    }
    
    private func checkConnectionAndFetch() {
        if networkManager.isConnected {
            retryTimer?.invalidate()
            retryTimer = nil
            fetchUsers()
        }
    }
    
    func fetchUsers() {
        guard !isLoading else { return }
        guard networkManager.isConnected else {
            isOffline = true
            return
        }
        
        isLoading = true
        let since = users.last?.id ?? 0
        networkManager.fetchUsers(since: Int(since), limit: pageSize) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let data):
                self.currentPage += 1
                self.saveUsersToLocal(data)
                self.isOffline = false
            case .failure(let error):
                print("Error fetching users: \(error)")
                if !self.networkManager.isConnected {
                    self.startRetryTimer()
                }
            }
        }
    }
    
    private func saveUsersToLocal(_ data: [User]) {
        for userData in data {
            coreDataManager.createUsersList(user: userData)
        }
        coreDataManager.fetchUsers { [weak self] fetchedUsers in
            self?.users = fetchedUsers
            self?.onUserFetched?()
        }
    }
    
//    func loadUserFromLocal() {
//        isLoading = true
//        coreDataManager.fetchUsers { [weak self] fetchedUsers in
//            if fetchedUsers.isEmpty {
//                self?.setupNetworkMonitorting()
//            } else {
//                self?.users = fetchedUsers
//                self?.onUserFetched?()
//                self?.isLoading = false
//            }
//        }
//    }
    
    func loadUserFromLocal() {
        isLoading = true
        coreDataManager.fetchUsers { [weak self] fetchedUsers in
            self?.users = fetchedUsers
            self?.onUserFetched?()
            self?.isLoading = false
            self?.setupNetworkMonitoring() // Always setup network monitoring
        }
    }
    
    func fetchMoreUser() {
        guard !isLoading && !isSearchActive else { return }
        fetchUsers()
    }
    
    func searchUsers(with query: String) {
        isSearchActive = true
        filteredUsers = users.filter { $0.login.lowercased().contains(query.lowercased()) || $0.note?.content.lowercased().contains(query.lowercased()) ?? false }
        onUserFetched?()
    }
    
    func resetSearch() {
        isSearchActive = false
        filteredUsers.removeAll()
        onUserFetched?()
    }
}

struct UserCellViewModelImpl: UserCellViewModel {
    let login: String
    let note: String
    let avatarUrl: String
    let hasNote: Bool
    let isSeen: Bool
    
    init(user: UserEntity) {
        self.login = user.login
        self.note = user.note?.content ?? ""
        self.avatarUrl = user.avatarUrl
        self.hasNote = (user.note != nil && user.note?.content != "")
        self.isSeen = user.isSeen
    }
}
