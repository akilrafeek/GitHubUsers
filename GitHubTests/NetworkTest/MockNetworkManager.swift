//
//  MockNetworkManager.swift
//  GitHubTests
//
//  Created by Akil Rafeek on 19/07/2024.
//

import Foundation
@testable import GitHub

class MockNetworkManager: NetworkManagerProtocol {
    var fetchUsersResult: Result<[User], NetworkError> = .success([])
    var isConnected = true
    var connectionChangedHandler: ((Bool) -> Void)?
    
    var shouldReturnSuccess: Bool = true
    var mockUserProfile: UserProfile?
    
    func fetchUsers(since: Int, completion: @escaping (Result<[User], NetworkError>) -> Void) {
        completion(fetchUsersResult)
    }
    
    func startMonitoring() {
        // Implementation not needed for these tests
    }
    
    func fetchUserProfile(username: String, completion: @escaping (Result<UserProfile, NetworkError>) -> Void) {
        if shouldReturnSuccess, let mockProfile = mockUserProfile {
            completion(.success(mockProfile))
        } else {
            completion(.failure(.decodingError))
        }
    }
}
