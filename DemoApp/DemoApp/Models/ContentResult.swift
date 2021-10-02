//
//  ContentResult.swift
//  DemoApp
//
//  Created by Haider on 02/10/21.
//

import Foundation

struct ContentResult : Codable {
    let id : Int?
    let name : String?
    let tagline : String?
    let description : String?
    let image_url : String?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case name = "name"
        case tagline = "tagline"
        case description = "description"
        case image_url = "image_url"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        tagline = try values.decodeIfPresent(String.self, forKey: .tagline)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        image_url = try values.decodeIfPresent(String.self, forKey: .image_url)
    }
}

extension ContentResult: ContentCellInfoProtocol {
    
    var imageUrl: String? {
        return image_url
    }
    
    var resultTitle: String? {
        return name
    }
    
    var resultDescription: String? {
        return tagline
    }
}
