//
//  ImageViewAdditions.swift
//  SearchApp
//
//  Created by Haider on 25/09/21.
//

import Foundation
import UIKit
//import Kingfisher
//
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
        }
    }
}

