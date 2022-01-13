//
//  DefaultNetworkService.swift
//  RandomCat
//
//  Created by 김민창 on 2022/01/13.
//

import Foundation

enum NetworkError: Error {
    case error(statusCode: Int, data: Data)
    case notConnected
}

protocol NetworkService {
    typealias CompletionHandler = (Result<Data, Error>) -> Void
    
    func get(url: String, headers: [String: String], completion: @escaping CompletionHandler)
    func request(urlRequest: URLRequest, completion: @escaping CompletionHandler)
}

public final class DefaultNetworkService: NetworkService {
    typealias CompletionHandler = (Result<Data, Error>) -> Void
    
    func get(url: String, headers: [String: String], completion: @escaping CompletionHandler) {
        guard let url = URL(string: url) else { return }
        let urlRequest = DefaultHTTPRequest(baseURL: url, headers: headers, httpMethod: HTTPMethodType.get)
        
        request(urlRequest: urlRequest.request, completion: completion)
    }
    
    func request(urlRequest: URLRequest, completion: @escaping CompletionHandler) {
        URLSession.shared.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            guard let data = data,
                  let response = response as? HTTPURLResponse,
                  let _ = error else {
                completion(.failure(NetworkError.notConnected))
                return
            }
            guard 200...299 ~= response.statusCode else {
                completion(.failure(NetworkError.error(statusCode: response.statusCode, data: data)))
                return
            }
            
            completion(.success(data))
        }.resume()
    }
}
