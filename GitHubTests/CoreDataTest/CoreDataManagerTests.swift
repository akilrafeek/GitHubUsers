//
//  CoreDataManagerTests.swift
//  GitHubTests
//
//  Created by Akil Rafeek on 19/07/2024.
//

import XCTest
@testable import GitHub

class CoreDataManagerTests: XCTestCase {
    
    var coreDataManager: CoreDataManager!
    
    override func setUp() {
        super.setUp()
        // Initialize CoreDataManager with in-memory store for testing
        coreDataManager = CoreDataManager(inMemory: true)
    }
    
    override func tearDown() {
        coreDataManager = nil
        super.tearDown()
    }
    
    func testCreateAndFetchUser() {
        let expectation = self.expectation(description: "Create and fetch user")
        
        let user = User(login: "testuser", id: 1, avatarUrl: "https://example.com/avatar.jpg")
        
        coreDataManager.createUsersList(user: user)
        
        // Wait for the background task to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.coreDataManager.fetchUser(withLogin: "testuser") { fetchedUser in
                XCTAssertNotNil(fetchedUser)
                XCTAssertEqual(fetchedUser?.login, "testuser")
                XCTAssertEqual(fetchedUser?.id, 1)
                XCTAssertEqual(fetchedUser?.avatarUrl, "https://example.com/avatar.jpg")
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testUpdateUser() {
        let createExpectation = self.expectation(description: "Create user")
        let updateExpectation = self.expectation(description: "Update user")
        
        let user = User(login: "testuser", id: 1, avatarUrl: "https://example.com/avatar.jpg")
        coreDataManager.createUsersList(user: user)
        
        // Wait for the create operation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            createExpectation.fulfill()
            
            let updatedUser = UserProfile(login: "testuser", id: 1, avatarUrl: "https://example.com/new_avatar.jpg", followers: 100, following: 50, name: "Test User", company: "Test Company", blog: "https://testblog.com")
            
            self.coreDataManager.updateUser(user: updatedUser)
            
            // Wait for the update operation to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.coreDataManager.fetchUser(withLogin: "testuser") { fetchedUser in
                    XCTAssertNotNil(fetchedUser)
                    XCTAssertEqual(fetchedUser?.name, "Test User")
                    XCTAssertEqual(fetchedUser?.company, "Test Company")
                    XCTAssertEqual(fetchedUser?.blog, "https://testblog.com")
                    XCTAssertEqual(fetchedUser?.followers, 100)
                    XCTAssertEqual(fetchedUser?.following, 50)
                    XCTAssertEqual(fetchedUser?.avatarUrl, "https://example.com/new_avatar.jpg")
                    XCTAssertTrue(fetchedUser?.isSeen ?? false)
                    updateExpectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSaveAndFetchNote() {
        let expectation = self.expectation(description: "Save and fetch note")
        
        let user = User(login: "testuser", id: 1, avatarUrl: "https://example.com/avatar.jpg")
        coreDataManager.createUsersList(user: user)
        
        // Wait for the create operation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.coreDataManager.saveNote(for: "testuser", content: "Test note content") { success in
                XCTAssertTrue(success)
                
                self.coreDataManager.fetchUser(withLogin: "testuser") { fetchedUser in
                    XCTAssertNotNil(fetchedUser)
                    let note = self.coreDataManager.fetchNote(for: fetchedUser!)
                    XCTAssertNotNil(note)
                    XCTAssertEqual(note?.content, "Test note content")
                    expectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
