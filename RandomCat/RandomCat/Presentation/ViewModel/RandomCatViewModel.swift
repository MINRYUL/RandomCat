//
//  RandomCatViewModel.swift
//  RandomCat
//
//  Created by 김민창 on 2022/01/12.
//

import Foundation
import Combine

final class RandomCatViewModel {
    @Published var catModels = [CatModel]()
    private let randomCatUseCase: RandomCatUseCase
    
    init(randomCatUseCase: RandomCatUseCase) {
        self.randomCatUseCase = randomCatUseCase
    }
    
    func fetchCatData() {
        self.randomCatUseCase.fetchCatData() { [weak self] catModel in
            self?.catModels.append(catModel)
        }
    }
}
