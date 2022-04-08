//
//  ImageCacheManager.swift
//  RandomCat
//
//  Created by 김민창 on 2022/01/16.
//

import Foundation
import UIKit

public protocol Item {
    var image: UIImage? { get set }
    var imageUrl: URL { get }
    var identifier: String { get }
}

final class ImageCacheManager {
    static let shared = ImageCacheManager()
    private init() { }
    
    private let cachedImages = NSCache<NSURL, UIImage>()
    private var loadingResponses = [NSURL: [(Item, UIImage) -> Void]]()
    
    private final func image(url: NSURL) -> UIImage? {
        return cachedImages.object(forKey: url)
    }
    
    final func load(url: NSURL, item: Item, completion: @escaping (Item, UIImage?) -> Swift.Void) {
        if let cachedImage = image(url: url) {
            DispatchQueue.main.async {
                completion(item, cachedImage)
            }
            return
        }
        if loadingResponses[url] != nil {
            loadingResponses[url]?.append(completion)
            return
        } else {
            loadingResponses[url] = [completion]
        }
        
        URLSession(configuration: .ephemeral).dataTask(with: url as URL) { (data, response, error) in
            guard let responseData = data, let image = UIImage(data: responseData),
                let blocks = self.loadingResponses[url], error == nil else {
                DispatchQueue.main.async {
                    completion(item, nil)
                }
                return
            }
            
            self.cachedImages.setObject(image, forKey: url, cost: responseData.count)
            for block in blocks {
                DispatchQueue.main.async {
                    block(item, image)
                }
                return
            }
        }.resume()
    }
}
