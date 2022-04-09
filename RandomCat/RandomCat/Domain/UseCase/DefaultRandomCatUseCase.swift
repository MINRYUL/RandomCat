//
//  RandomCatUseCase.swift
//  RandomCat
//
//  Created by 김민창 on 2022/01/13.
//

import Foundation

import RxSwift
import RxRelay

protocol RandomCatUseCase {
    var disposeBag: DisposeBag { get set }
    
    var input: RandomCatUseCaseInput { get set }
    var output: RandomCatUSeCaseOutput { get set }
}

struct RandomCatUseCaseInput {
    var loadRandomCat: BehaviorSubject<Void?>
    var refersh: BehaviorSubject<Void?>
}

struct RandomCatUSeCaseOutput {
    var randomCatModel: BehaviorSubject<[CatModel]?>
}


final class DefaultRandomCatUseCase: RandomCatUseCase {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var input: RandomCatUseCaseInput
    var output: RandomCatUSeCaseOutput
    
    private let randomCatRepository: RandomCatRepository
    
    //MARK: - Input
    private let _loadRandomCat = BehaviorSubject<Void?>(value: nil)
    private let _refersh = BehaviorSubject<Void?>(value: nil)
    
    //MARK: - Output
    private let _randomCatModel = BehaviorSubject<[CatModel]?>(value: nil)
    
    //MARK: - Store
    private let _baseImageCount = BehaviorRelay<Int>(value: 20)
    
    init(randomCatRepository: RandomCatRepository) {
        self.randomCatRepository = randomCatRepository
        
        self.input = RandomCatUseCaseInput(
            loadRandomCat: _loadRandomCat.asObserver(),
            refersh: _refersh.asObserver()
        )
        self.output = RandomCatUSeCaseOutput(
            randomCatModel: _randomCatModel.asObserver()
        )
        
        self._bindLoadRandomCat()
        self._bindRefersh()
    }
}


//MARK: - Binding
extension DefaultRandomCatUseCase {
    //MARK: - Input Binding
    private func _bindLoadRandomCat() {
        self._loadRandomCat
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] in
                
            })
            .disposed(by: disposeBag)
    }
    
    private func _bindRefersh() {
        self._refersh
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] in
                self?._randomCatModel.onNext([])
            })
            .disposed(by: disposeBag)
    }
}
