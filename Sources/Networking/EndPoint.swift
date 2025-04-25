//
//  EndPoint.swift
//  Networking
//
//  Created by andre mietti on 25/04/25.
//

import Foundation

public protocol EndPoint {
    var host: String { get }
    var scheme: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var header: [String: String]? { get }
    var body: [String: String]? { get }
}

extension EndPoint {
    var scheme: String {
        return "https"
    }
    
    var host: String {
        return ""
    }
}
