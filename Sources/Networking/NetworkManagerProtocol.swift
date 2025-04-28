//
//  NetworkManagerProtocol.swift
//  Networking
//
//  Created by andre mietti on 25/04/25.
//

import Foundation
import Combine

public protocol NetworkManagerProtocol {
    func request<T: Decodable>(endPoint: EndPoint) async throws -> T
    func request<T: Decodable>(endPoint: EndPoint, resultHandler: @escaping (Result<T, NetworkError>) -> Void)
    func request<T: Decodable>(endPoint: EndPoint, type: T.Type) -> AnyPublisher<T, NetworkError>
}


public final class NetworkService: NetworkManagerProtocol {
    
    public init() {}
    
    public func request<T>(endPoint: any EndPoint) async throws -> T where T : Decodable {
        guard let urlRequest = buildRequest(endPoint: endPoint) else {
            throw NetworkError.decode
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let task = URLSession(configuration: .default, delegate: nil, delegateQueue: .main).dataTask(with: urlRequest) { data, response, _ in
                guard response is HTTPURLResponse else {
                    continuation.resume(throwing: NetworkError.unexpectedStatusCode)
                    return
                }
                guard let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode else {
                    continuation.resume(throwing: NetworkError.unknow)
                    return
                }
                guard let data = data else {
                    continuation.resume(throwing: NetworkError.unknow)
                    return
                }
                guard let decodedResponse = try? JSONDecoder().decode(T.self, from: data) else {
                    continuation.resume(throwing: NetworkError.decode)
                    return
                }
                continuation.resume(returning: decodedResponse)
            }
            
            task.resume()
        }
    }
    
    public func request<T>(endPoint: any EndPoint, resultHandler: @escaping (Result<T, NetworkError>) -> Void) where T : Decodable {
        guard let request = buildRequest(endPoint: endPoint) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                resultHandler(.failure(.invalidURL))
                return
            }
            
            guard let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode else {
                resultHandler(.failure(.unexpectedStatusCode))
                return
            }
            
            guard let data = data else {
                resultHandler(.failure(.unknow))
                return
            }
            
            guard let decodedResponse = try? JSONDecoder().decode(T.self, from: data) else {
                resultHandler(.failure(.decode))
                return
            }
            
            resultHandler(.success(decodedResponse))
        }
        
        task.resume()
    }
    
    public func request<T>(endPoint: any EndPoint, type: T.Type) -> AnyPublisher<T, NetworkError> where T : Decodable {
        guard let request = buildRequest(endPoint: endPoint) else {
            precondition(false, "Failed URLRequest")
        }
        return URLSession.shared.dataTaskPublisher(for: request)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .tryMap { data, response -> Data in
                guard let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode else {
                    throw NetworkError.invalidURL
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> NetworkError in
                if error is DecodingError {
                    return NetworkError.decode
                } else if let error = error as? NetworkError {
                    return error
                } else {
                    return NetworkError.unknow
                }
            }
            .eraseToAnyPublisher()
    }
    
    
}

extension NetworkManagerProtocol {
    fileprivate func buildRequest(endPoint: EndPoint) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = endPoint.scheme
        urlComponents.host = endPoint.host
        urlComponents.path = endPoint.path
        
        guard let url = urlComponents.url else { return nil }
        
        let encoder = JSONEncoder()
        var request = URLRequest(url: url)
        request.httpMethod = endPoint.method.rawValue
        request.allHTTPHeaderFields = endPoint.header
        
        if let body = endPoint.body {
            request.httpBody = try? encoder.encode(body)
        }
        
        return request
    }
    
}
