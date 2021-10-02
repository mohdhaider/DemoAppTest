//
//  RequestParametersInfo.swift
//  SearchApp
//
//  Created by Haider on 25/09/21.
//

import Foundation

enum RequestFeature {
    case request
    case requestWithParameters(encoding: ParametersEncodign, urlParameters: Parameters, bodyParameters: Parameters, headers: Parameters)
}
