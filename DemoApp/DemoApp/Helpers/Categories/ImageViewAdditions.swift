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

        self.image = placeholderImage
//        guard let url = strUrl, let imageUrl = URL(string: url) else {
//            return
//        }

        //let resource = ImageResource(downloadURL: imageUrl, cacheKey: url)
        //kf.setImage(with: resource)
    }
}

