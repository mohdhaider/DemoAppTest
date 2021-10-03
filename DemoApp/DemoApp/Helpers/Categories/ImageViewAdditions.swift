//
//  ImageViewAdditions.swift
//  DemoApp
//
//  Created by Haider on 02/10/21.
//

import Foundation
import UIKit
import ImageDownloader

extension UIImageView {

    func setImage(forUrl strUrl: String?, placeholderImage: UIImage?) {

        guard let strUrl = strUrl, !strUrl.isEmpty else {
            self.image = placeholderImage
            return
        }
        
        if let image = ImageDownloadManager.manager.loadCachedImage(urlString: strUrl as NSString) {
            self.image = image
        } else {
            self.image = placeholderImage
            
            ImageDownloadManager.manager.load(urlString: strUrl as NSString) { url, image in
                
                if url == (strUrl as NSString) {
                    self.image = image ?? placeholderImage
                }
            }
        }
    }
}

