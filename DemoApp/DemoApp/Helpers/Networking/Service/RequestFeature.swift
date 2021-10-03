//
//  RequestParametersInfo.swift
//  DemoApp
//
//  Created by Haider on 02/10/21.
//

import Foundation

enum RequestFeature {
    case request
    case requestWithParameters(encoding: ParametersEncodign, urlParameters: Parameters, bodyParameters: Parameters, headers: Parameters)
}
