//
//  DefaultNetworkService.swift
//  RandomCat
//
//  Created by 김민창 on 2022/01/13.
//

import Foundation

import RxSwift

enum NetworkError: Error {
    case error(statusCode: Int, data: Data)
    case notConnected
    case unknownError
}

final class DefaultNetworkService {
    typealias CompletionHandler = (Data?, Error?) -> Void
    
    static let instance = DefaultNetworkService()
    
    private init() { }
    
    func get<T: Codable>(url: String, headers: [String: String] = [:]) -> Observable<T> {
        return Observable.create { [weak self] observer -> Disposable in
            guard let url = URL(string: url) else {
                observer.onError(NetworkError.unknownError)
                return Disposables.create()
            }
            
            let urlRequest = DefaultHTTPRequest(baseURL: url, headers: headers, httpMethod: HTTPMethodType.get)
            self?.request(urlRequest: urlRequest.request) { data, error in
                guard let data = data,
                      let result = try? JSONDecoder().decode(T.self, from: data)
                else {
                    guard let error = error else {
                        observer.onError(NetworkError.unknownError)
                        return
                    }
                    
                    observer.onError(error)
                    return
                }
                
                observer.onNext(result)
            }
            return Disposables.create()
        }
    }
    
    private func request(urlRequest: URLRequest, completion: @escaping CompletionHandler) {
        URLSession.shared.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            guard let data = data,
                  let response = response as? HTTPURLResponse else {
                completion(nil, NetworkError.notConnected)
                return
            }
            
            guard error == nil else {
                completion(nil, NetworkError.unknownError)
                return
            }
            
            guard 200...299 ~= response.statusCode else {
                completion(nil, NetworkError.error(statusCode: response.statusCode, data: data))
                return
            }
            
            completion(data, nil)
        }.resume()
    }
}
