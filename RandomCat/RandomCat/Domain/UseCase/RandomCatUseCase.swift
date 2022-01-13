//
//  RandomCatUseCase.swift
//  RandomCat
//
//  Created by 김민창 on 2022/01/13.
//

import Foundation

final class RandomCatUseCase {
    let randomCatRepository: RandomCatRepository
    
    init(randomCatRepository: RandomCatRepository) {
        self.randomCatRepository = randomCatRepository
    }
    
    func fetchCatImage(completion: @escaping (Result<Data, Error>) -> Void) {
        self.randomCatRepository.fetchCatImageURL(url: CatImageConstant.cat, completion: completion)
    }
}
