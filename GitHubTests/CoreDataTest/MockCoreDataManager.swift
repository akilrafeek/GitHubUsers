//
//  MockCoreDataManager.swift
//  GitHubTests
//
//  Created by Rizwan Rafeek on 19/07/2024.
//

import Foundation
@testable import GitHub

class MockCoreDataManager: CoreDataManagerProtocol {
    var fetchUsersResult: [UserEntity] = []
    
    func updateUser(user: UserProfile) {
        //later
    }
    
    func fetchUser(withLogin login: String, completion: @escaping (UserEntity?) -> Void) {
        completion(fetchUsersResult[0])
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
}
