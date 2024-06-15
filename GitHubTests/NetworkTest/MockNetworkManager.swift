//
//  MockNetworkManager.swift
//  GitHubTests
//
//  Created by Rizwan Rafeek on 19/07/2024.
//

import Foundation
@testable import GitHub

class MockNetworkManager: NetworkManagerProtocol {
    func fetchUserProfile(username: String, completion: @escaping (Result<UserProfile, NetworkError>) -> Void) {
        //later
    }
    
    var fetchUsersResult: Result<[User], NetworkError> = .success([])
    var isConnected = true
    var connectionChangedHandler: ((Bool) -> Void)?
    
    func fetchUsers(since: Int, completion: @escaping (Result<[User], NetworkError>) -> Void) {
        completion(fetchUsersResult)
    }
    
    func startMonitoring() {
        // Implementation not needed for these tests
    }
}
