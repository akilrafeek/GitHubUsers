//
//  NetworkManager.swift
//  GitHub
//
//  Created by Akil Rafeek on 16/06/2024.
//

import Foundation
import Network
import Reachability

enum NetworkError: Error, Equatable {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.noData, .noData),
             (.decodingError, .decodingError):
            return true
        case (.serverError(let lhsString), .serverError(let rhsString)):
            return lhsString == rhsString
        default:
            return false
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum Endpoint {
    case usersList(since: Int, limit: Int)
    case userProfile(username: String)
    
    var path: String {
        switch self {
        case .usersList(let since, let limit):
            return "/users?since=\(since)&per_page=\(limit)"
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

class NetworkManager: NetworkManagerProtocol {
    
    static let shared = NetworkManager()
    private init() {}
    
    private let baseURL = "https://api.github.com"
    private var currentTask: URLSessionDataTask?
    private var requestQueue: [URLRequest] = []
    
    private let reachability = try! Reachability()
    private(set) var isConnected = false
    var connectionChangedHandler: ((Bool) -> Void)?
    
    func startMonitoring() {
        reachability.whenReachable = { [weak self] reachability in
            self?.isConnected = true
            self?.connectionChangedHandler?(true)
        }
        reachability.whenUnreachable = { [weak self] _ in
            self?.isConnected = false
            self?.connectionChangedHandler?(false)
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    deinit {
        reachability.stopNotifier()
    }
    
//    private func retryFailedRequests() {
//        DispatchQueue.main.async {
//            self.executeNextRequest()
//        }
//    }
    
    private func executeNextRequest() {
        guard currentTask == nil, let nextRequest = requestQueue.first else { return }
        
        currentTask = URLSession.shared.dataTask(with: nextRequest) { [weak self] data, response, error in
            do {
                self?.currentTask = nil
                if !(self?.requestQueue.isEmpty)! {
                    self?.requestQueue.removeFirst()
                    self?.executeNextRequest()
                }
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
            do {
                self.currentTask = nil
                if !self.requestQueue.isEmpty {
                    self.requestQueue.removeFirst()
                    self.executeNextRequest()
                }
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
                completion(.failure(.invalidURL))
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
    
    func fetchUsers(since: Int, limit: Int, completion: @escaping (Result<[User], NetworkError>) -> Void) {
        fetch(.usersList(since: since, limit: limit)) { (result: Result<[User], NetworkError>) in
            completion(result)
        }
    }
    
    func fetchUserProfile(username: String, completion: @escaping (Result<UserProfile, NetworkError>) -> Void) {
        fetch(.userProfile(username: username)) { (result: Result<UserProfile, NetworkError>) in
            completion(result)
        }
    }
}

protocol NetworkManagerProtocol {
    var isConnected: Bool { get }
    var connectionChangedHandler: ((Bool) -> Void)? { get set }
    
    func fetchUsers(since: Int, limit: Int, completion: @escaping (Result<[User], NetworkError>) -> Void)
    func fetchUserProfile(username: String, completion: @escaping (Result<UserProfile, NetworkError>) -> Void)
    func startMonitoring()
}
