//
//  URLComponents+Extensions.swift
//  Networking
//
//  Created by andre mietti on 29/04/25.
//

import Foundation

extension URLComponents {
    
    mutating func setQueryItems(with parameters: [String: String]?,
                                encodeValues: Bool = true,
                                skipEmptyValues: Bool = true) {
        queryItems = parameters?.compactMap { key, value in
            if skipEmptyValues && value.isEmpty {
                return nil
            }
            
            let finalValue = encodeValues ?
            value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value :
            value
            
            return URLQueryItem(name: key, value: finalValue)
        }
    }
    
}
