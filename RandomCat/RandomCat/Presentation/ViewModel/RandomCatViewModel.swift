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
    
    func appendDefaultCatImage() {
        for i in 0...9 {
            let catModel = CatModel(imageURL: "", imageNumber: i)
            self.catModels.append(catModel)
        }
    }
    
    func fetchCatImage() {
        self.randomCatUseCase.fetchCatImage() { [weak self] catModel in
            guard let catModels = self?.catModels else { return }
            
            self?.catModels[catModel.imageNumber] = CatModel(id: catModels[catModel.imageNumber].id, imageURL: catModel.imageURL, imageNumber: catModel.imageNumber)
        }
    }
}
