//
//  NetworkManagerTests.swift
//  GitHub
//
//  Created by Akil Rafeek on 19/07/2024.
//

import XCTest
@testable import GitHub

class NetworkManagerTests: XCTestCase {
    
    var networkManager: NetworkManager!
    
    override func setUp() {
        super.setUp()
        networkManager = NetworkManager.shared
        networkManager.startMonitoring()
    }
    
    override func tearDown() {
        networkManager = nil
        super.tearDown()
    }
    
    func testFetchUsers() {
        let expectation = self.expectation(description: "Fetch users")
        
        networkManager.fetchUsers(since: 0) { result in
            switch result {
            case .success(let users):
                XCTAssertFalse(users.isEmpty)
                XCTAssertNotNil(users.first?.id)
                XCTAssertNotNil(users.first?.login)
                XCTAssertNotNil(users.first?.avatarUrl)
            case .failure(let error):
                XCTFail("Failed to fetch users: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testFetchUserProfile() {
        let expectation = self.expectation(description: "Fetch user profile")
        
        networkManager.fetchUserProfile(username: "octocat") { result in
            switch result {
            case .success(let userProfile):
                XCTAssertEqual(userProfile.login, "octocat")
                XCTAssertNotNil(userProfile.id)
                XCTAssertNotNil(userProfile.avatarUrl)
            case .failure(let error):
                XCTFail("Failed to fetch user profile: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testFetchWithRetry() {
        let expectation = self.expectation(description: "Fetch with retry")
        
        // Using a non-existent username to force a failure and test retry mechanism
        networkManager.fetchWithRetry(.userProfile(username: "non_existent_user_12345"), retries: 2) { (result: Result<UserProfile, NetworkError>) in
            switch result {
            case .success:
                XCTFail("Expected failure for non-existent user")
            case .failure(let error):
                XCTAssertEqual(error, .invalidURL)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 20, handler: nil) // Increased timeout to account for retries
    }
    
    func testNetworkMonitoring() {
        let notificationExpectation = expectation(forNotification: NSNotification.Name("com.apple.system.config.network_change"), object: nil, handler: nil)
        
        var connectionChangedCalled = false
        
        networkManager.connectionChangedHandler = { isConnected in
            connectionChangedCalled = true
            XCTAssertTrue(isConnected)
        }
        
        // Simulate a network change
        NotificationCenter.default.post(name: .init("com.apple.system.config.network_change"), object: nil)
        
        wait(for: [notificationExpectation], timeout: 5)
        
        XCTAssertTrue(connectionChangedCalled)
    }
    
    func testInvalidURL() {
        let expectation = self.expectation(description: "Invalid URL")
        
        let invalidEndpoint = Endpoint.userProfile(username: "user with spaces")
        
        networkManager.fetch(invalidEndpoint) { (result: Result<UserProfile, NetworkError>) in
            switch result {
            case .success:
                XCTFail("Expected failure for invalid URL")
            case .failure(let error):
                XCTAssertEqual(error, .invalidURL)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
