//
//  ImageLoader.swift
//  Weather_Challenge
//
//  Created by Vladislav on 9/18/23.
//

import UIKit

class IconWeatherImageLoader {
    // MARK: - Properties
    static let shared = IconWeatherImageLoader()
    
    private let cache = NSCache<NSURL, UIImage>()
    
    // MARK: - Methods
    
    // Downloads an image from the provided URL
    func downloadIcon(name: String) async throws -> UIImage {
        let urlString = "https://openweathermap.org/img/wn/\(name)@2x.png"
        
        guard let url = URL(string: urlString) else {
            throw ImageError.invalidURL
        }
        if let cachedImage = cache.object(forKey: url as NSURL) {
            return cachedImage
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw ImageError.invalidImageData
        }
        cache.setObject(image, forKey: url as NSURL)
        return image
    }
    
    // Caches an image for a given URL string
    func cacheImage(_ image: UIImage, for urlString: String) {
         guard let url = URL(string: urlString) else {
             return
         }
         cache.setObject(image, forKey: url as NSURL)
     }
}

