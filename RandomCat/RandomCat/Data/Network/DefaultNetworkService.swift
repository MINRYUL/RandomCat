//
//  DefaultNetworkService.swift
//  RandomCat
//
//  Created by 김민창 on 2022/01/13.
//

import Foundation

protocol NetworkService {
    func get(url: String)
    func request(urlRequest: URLRequest)
}

public final class DefaultNetworkService: NetworkService {
    
    func get(url: String) {
        
    }
    
    func request(urlRequest: URLRequest) {
        
    }
}
