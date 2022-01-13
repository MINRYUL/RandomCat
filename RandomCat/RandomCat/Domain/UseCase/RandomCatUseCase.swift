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
        for i in self.imageCount...(self.imageCount + 9) {
            self.randomCatRepository.fetchCatImageURL(url: CatImageConstant.cat) { result in
                switch result {
                case .success(let data):
                    guard let result = try? JSONDecoder().decode(CatImageResponseDTO.self, from: data) else { return }
                    completion(CatModel(imageURL: result.url, imageNumber: i))
                case .failure(let error):
                    guard let error = error as? NetworkError else { return }
                    break
                }
            }
        }
        self.imageCount += 10
    }
}
