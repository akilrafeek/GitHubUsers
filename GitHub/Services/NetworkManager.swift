//
//  NetworkManager.swift
//  GitHub
//
//  Created by Akil Rafeek on 16/06/2024.
//

import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum Endpoint {
    case usersList(since: Int)
    case userProfile(username: String)
    
    var path: String {
        switch self {
        case .usersList(let since):
            return "/users?since=\(since)"
        case .userProfile(let username):
            return "/users/\(username)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .usersList, .userProfile:
            return .get
        }
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    private let baseURL = "https://api.github.com"
    private var currentTask: URLSessionDataTask?
    private var requestQueue: [URLRequest] = []
    
    private func executeNextRequest() {
        guard currentTask == nil, let nextRequest = requestQueue.first else { return }
        
        currentTask = URLSession.shared.dataTask(with: nextRequest) { [weak self] data, response, error in
            defer {
                self?.currentTask = nil
                self?.requestQueue.removeFirst()
                self?.executeNextRequest()
            }
        }
        currentTask?.resume()
    }
    
    func fetch<T: Decodable>(_ endpoint: Endpoint, completion: @escaping (Result<T, NetworkError>) -> Void) {
        guard let url = URL(string: baseURL + endpoint.path) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        requestQueue.append(request)
        
        if currentTask == nil {
            executeNextRequest()
        }
        
        currentTask = URLSession.shared.dataTask(with: request) { data, response, error in
            defer {
                self.currentTask = nil
                self.requestQueue.removeFirst()
                self.executeNextRequest()
            }
            
            if let error = error {
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decodeObject = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodeObject))
            } catch {
                completion(.failure(.decodingError))
            }
        }
        currentTask?.resume()
    }
    
    func fetchWithRetry<T: Decodable>(_ endpoint: Endpoint, retries: Int = 3, delay: TimeInterval = 1.0, completion: @escaping (Result<T, NetworkError>) -> Void) {
        fetch(endpoint) { [weak self] (result: Result<T, NetworkError>) in
            switch result {
            case .success:
                completion(result)
            case .failure(let error):
                if retries > 0 {
                    print("Request failed. Retrying in \(delay) seconds...")
                    DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                        self?.fetchWithRetry(endpoint, retries: retries - 1, delay: delay * 2, completion: completion)
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchUsers(since: Int, completion: @escaping (Result<[User], NetworkError>) -> Void) {
        fetch(.usersList(since: since)) { (result: Result<[User], NetworkError>) in
            completion(result)
        }
    }
    
    func fetchUserProfile(username: String, completion: @escaping (Result<UserProfile, NetworkError>) -> Void) {
        fetch(.userProfile(username: username)) { (result: Result<UserProfile, NetworkError>) in
            completion(result)
        }
    }
}
