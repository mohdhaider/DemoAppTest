//
//  ImageDownloadManager.swift
//  DemoApp
//
//  Created by Haider on 03/10/21.
//

import UIKit

class ImageDownloadManager: NSObject {

    // MARK:- Variables -
    
    static let manager = ImageDownloadManager()
    private let cachedImages = NSCache<NSString, UIImage>()
    private var loadingResponses = [NSString: [(NSString, UIImage?) -> Void]]()
    
    private func image(urlString: NSString) -> UIImage? {
        return cachedImages.object(forKey: urlString)
    }
    
    func loadCachedImage(urlString: NSString) -> UIImage? {
        return image(urlString: urlString)
    }
    
    func load(urlString: NSString, completion: @escaping (NSString, UIImage?) -> Void) {
        
        // Check for a cached image.
        if let cachedImage = image(urlString: urlString) {
            moveToMainThread {
                completion(urlString, cachedImage)
            }
            return
        }
        
        // In case there are more than one requestor for the image, we append their completion block.
        if loadingResponses[urlString] != nil {
            loadingResponses[urlString]?.append(completion)
            return
        } else {
            loadingResponses[urlString] = [completion]
        }
        
        // Go fetch the image.
        ImageNetworkLayer.shared.get(url: urlString as String) { request, response, data, error in
            
            guard let responseData = data, let image = UIImage(data: responseData),
                  let blocks = self.loadingResponses[urlString],
                  error == nil else {
                      
                      self.moveToMainThread({
                          completion(urlString, nil)
                      })
                      return
                  }
            
            // Cache the image.
            self.cachedImages.setObject(image, forKey: urlString, cost: responseData.count)
            
            // Iterate over each requestor for the image and pass it back.
            for block in blocks {
                DispatchQueue.main.async {
                    block(urlString, image)
                }
                return
            }
        }
    }
}
