//
//  Define.swift
//  SearchApp
//
//  Created by Haider on 25/09/21.
//

import Foundation

enum Apis: String {
    case baseUrl = "https://api.punkapi.com/v2/"
    case taskApi = "beers"
}

enum AppMessages: String {
    case noDataAvailable = "Sorry, couldn't find anything."
    case noConnectionCancelButtonTitle = "Ok"
    case noConnectionTitle = "No Connection!"
    case noConnectionMessage = "You seem to be having trouble with your WiFi connection. Switching it off could help"
}

struct XibIdentifiers {
    static let contentCell = "contentCell"
    static let defaultCell = "defaultCell"
}
