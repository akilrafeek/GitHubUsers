//
//  MockCoreDataManager.swift
//  GitHubTests
//
//  Created by Akil Rafeek on 19/07/2024.
//

import Foundation
@testable import GitHub

class MockCoreDataManager: CoreDataManagerProtocol {
    var shouldReturnUser: UserEntityProtocol?
    var fetchUsersResult: [UserEntity] = []
    var users: [MockUserEntity] = []
    
    func updateUser(user: UserProfile) {
        //later
    }
    
    func fetchUser(withLogin login: String, completion: @escaping (UserEntityProtocol?) -> Void) {
//        completion(users[0])
    }
    
    func fetchUsers(completion: @escaping ([UserEntity]) -> Void) {
        completion(fetchUsersResult)
    }
    
    func createUsersList(user: User) {
        let context = MockManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let userEntity = UserEntity(context: context)
        userEntity.id = Int64(user.id)
        userEntity.login = user.login
        userEntity.avatarUrl = user.avatarUrl
        fetchUsersResult.append(userEntity)
    }
    
    func saveNote(for userLogin: String, content: String, completion: @escaping (Bool) -> Void) {
        completion(true)
    }
}
