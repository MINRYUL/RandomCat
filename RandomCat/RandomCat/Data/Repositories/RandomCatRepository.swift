//
//  RandomCatRepositiory.swift
//  RandomCat
//
//  Created by 김민창 on 2022/01/13.
//

import Foundation

protocol RandomCatRepository {
    var networkService: NetworkService { get }
    
    func fetchCatDataURL(url: String, completion: @escaping (Result<Data, Error>) -> Void)
}

final class DefaultRandomCatRepository: RandomCatRepository {
    let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func fetchCatDataURL(url: String, completion: @escaping (Result<Data, Error>) -> Void) {
        self.networkService.get(url: url, headers: [String: String](), completion: completion)
    }
}
