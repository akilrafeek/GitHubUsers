//
//  ImageLoader.swift
//  GitHub
//
//  Created by Akil Rafeek on 24/06/2024.
//

import UIKit

class ImageLoader {
    static func loadImage(from urlString: String, into imageView: UIImageView) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data)
            }
        }.resume()
    }
}
