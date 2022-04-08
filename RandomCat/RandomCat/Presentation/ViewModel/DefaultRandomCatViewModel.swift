//
//  RandomCatViewModel.swift
//  RandomCat
//
//  Created by 김민창 on 2022/01/12.
//

import Foundation

import RxSwift
import RxCocoa
import Combine

protocol RandomCatViewModel {
    var disposeBag: DisposeBag { get set }
    
    var input: RandomCatInput { get set }
    var output: RandomCatOutput { get set }
}

struct RandomCatInput {
    var loadRandomCat: BehaviorSubject<Void?>
}

struct RandomCatOutput {
    var randomCatModel: Driver<[CatModel]>
}

final class DefaultRandomCatViewModel {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var input: RandomCatInput
    var output: RandomCatOutput
    
    
    private let _loadRandomCat = BehaviorSubject<Void?>(value: nil)
    private let _randomCatModel = BehaviorSubject<[CatModel]>(value: [])
    
    @Published var catModels = [CatModel]()
    private let randomCatUseCase: RandomCatUseCase
    
    init(randomCatUseCase: RandomCatUseCase) {
        self.randomCatUseCase = randomCatUseCase
        
        self.input = RandomCatInput(
            loadRandomCat: _loadRandomCat.asObserver()
        )
        self.output = RandomCatOutput(
            randomCatModel: _randomCatModel.asDriver(onErrorJustReturn: [])
        )
        
        self._bindLoadRandomCat()
    }
    
    func fetchCatData() {
        self.randomCatUseCase.fetchCatData() { [weak self] catModel in
            self?.catModels.append(catModel)
        }
    }
}

//MARK: - Binding
extension DefaultRandomCatViewModel {
    //MARK: - Input
    private func _bindLoadRandomCat() {
        self._loadRandomCat
            .compactMap { $0 }
            .subscribe(onNext: {
                
            })
            .disposed(by: disposeBag)
    }
}
