//
//  Untitled.swift
//  Networking
//
//  Created by andre mietti on 25/04/25.
//

import Foundation

public enum NetworkError: Error {
    case decode
    case generic
    case invalidURL
    case noResponse
    case unauthorized
    case unexpectedStatusCode
    case unknow
    
    var customMessage: String {
        switch self {
        case .decode:
            "Decode error"
        case .unauthorized:
            "Unauthorized URL"
        case .generic:
            "Something is wrong, please try again later"
        default:
            "Unknow error"
        }
    }
}
