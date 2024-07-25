//
//  UserViewModelTests.swift
//  GitHubTests
//
//  Created by Akil Rafeek on 19/07/2024.
//

import XCTest
import CoreData
@testable import GitHub

class UserViewModelTests: XCTestCase {
    
    var viewModel: UserViewModel!
    var mockCoreDataManager: MockCoreDataManager!
    var coreDataManager: CoreDataManager!
    var managedObjectContext: NSManagedObjectContext!
    var mockNetworkManager: MockNetworkManager!
    
    override func setUp() {
        super.setUp()
        // Manually load the managed object model
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: "GitHub", withExtension: "momd") else {
            XCTFail("Failed to find the Core Data model file")
            return
        }
                
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            XCTFail("Failed to create managed object model")
            return
        }
        
        coreDataManager = CoreDataManager(inMemory: true, managedObjectModel: mom)
        managedObjectContext = coreDataManager.mainContext
        mockNetworkManager = MockNetworkManager()
        mockCoreDataManager = MockCoreDataManager()
        viewModel = UserViewModel(coreDataManager: coreDataManager, networkManager: mockNetworkManager)
    }
    
    override func tearDown() {
        viewModel = nil
        coreDataManager = nil
        mockCoreDataManager = nil
        mockNetworkManager = nil
        super.tearDown()
    }
    
    func testFetchUsersFromNetwork() {
        let expectation = self.expectation(description: "Fetch users from network")
        
        viewModel.fetchUsers()
        
        mockNetworkManager.isConnected = true
        mockNetworkManager.fetchUsers(since: 0) { result in
            switch result {
            case .success(let users):
                XCTAssertEqual(users.count, 0)
                expectation.fulfill()
            case .failure:
                XCTFail("Expected successful fetch but failed")
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testLoadUserFromLocal() {
        let userEntity1 = UserEntity(context: managedObjectContext)
        userEntity1.login = "localUser1"
        let userEntity2 = UserEntity(context: managedObjectContext)
        userEntity2.login = "localUser2"
        
        mockCoreDataManager.fetchUsersResult = [userEntity1, userEntity2]
        
        let expectation = self.expectation(description: "Load users from local")
        
        viewModel.onUserFetched = {
            XCTAssertEqual(self.viewModel.numberOfUsers, 2)
            XCTAssertEqual(self.viewModel.user(at: 0).login, "localUser1")
            XCTAssertEqual(self.viewModel.user(at: 1).login, "localUser2")
            expectation.fulfill()
        }
        
        viewModel.loadUserFromLocal()
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}

class MockManagedObjectContext: NSManagedObjectContext {
    override init(concurrencyType: NSManagedObjectContextConcurrencyType) {
        super.init(concurrencyType: concurrencyType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
