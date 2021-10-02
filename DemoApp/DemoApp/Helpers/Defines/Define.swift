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
    case fetchingResults = "Fetching results"
    case noMoreRecordsAvailable = "No more records available"
    case noConnectionCancelButtonTitle = "Ok"
    case noConnectionTitle = "No Connection!"
    case noConnectionMessage = "You seem to be having trouble with your internet connection. Please check it."
}

struct XibIdentifiers {
    static let contentCell = "contentCell"
    static let defaultCell = "defaultCell"
    static let statusCell = "statusCell"
}

enum NetworkingKeys: String {
    case internetStatusChanged
}

enum ScreenTitles:String {
    case contents = "Contents"
}
