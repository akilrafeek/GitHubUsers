//
//  ImageLoader.swift
//  GitHub
//
//  Created by Akil Rafeek on 24/06/2024.
//

import UIKit
import CryptoKit

class ImageLoader {
    static let shared = ImageLoader()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        let cacheDirectoryURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.cacheDirectory = cacheDirectoryURL.appendingPathComponent("ImageCache")
        try? fileManager.createDirectory(at: self.cacheDirectory, withIntermediateDirectories: true, attributes: nil)
    }
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let urlString = url.absoluteString
        let cacheKey = NSString(string: urlString)
        
        // Check memory cache
        if let cachedImage = cache.object(forKey: cacheKey) {
            completion(cachedImage)
            return
        }
        
        // Check disk cache
        let filePath = cacheDirectory.appendingPathComponent(urlString.sha256)
        if fileManager.fileExists(atPath: filePath.path),
           let data = try? Data(contentsOf: filePath),
           let image = UIImage(data: data) {
            cache.setObject(image, forKey: cacheKey)
            completion(image)
            return
        }
        
        // Fetch from network
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Save to memory cache
            self.cache.setObject(image, forKey: cacheKey)
            
            // Save to disk cache
            try? data.write(to: filePath)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}

// Extension to generate SHA256 hash for strings (used for file names)
extension String {
    var sha256: String {
        let inputData = Data(self.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        return hashString
    }
}
