//
//  RandomCatUseCase.swift
//  RandomCat
//
//  Created by 김민창 on 2022/01/13.
//

import Foundation

final class RandomCatUseCase {
    private let randomCatRepository: RandomCatRepository
    private var imageCount = 0
    
    init(randomCatRepository: RandomCatRepository) {
        self.randomCatRepository = randomCatRepository
    }
    
    func fetchCatImage(completion: @escaping (CatModel) -> Void) {
        for _ in self.imageCount...(self.imageCount + 9) {
            self.randomCatRepository.fetchCatImageURL(url: CatImageConstant.cat) { result in
                switch result {
                case .success(let data):
                    guard let result = try? JSONDecoder().decode([CatImageResponseDTO].self, from: data) else { return }
                    guard let catIamge = result.first else { return }
                    let catModel = CatModel(url: catIamge.url)
                    completion(catModel)
                case .failure(let error):
                    guard let _ = error as? NetworkError else { return }
                    break
                }
            }
        }
        self.imageCount += 10
    }
}
