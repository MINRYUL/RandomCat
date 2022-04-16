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
    
    var input: RandomCatViewModelInput { get set }
    var output: RandomCatViewModelOutput { get set }
}

struct RandomCatViewModelInput {
    var loadRandomCat: BehaviorSubject<Void?>
    var refersh: BehaviorSubject<Void?>
}

struct RandomCatViewModelOutput {
    var randomCatModel: Driver<[CatModel]>
    var isLoading: Driver<Bool>
}

final class DefaultRandomCatViewModel: RandomCatViewModel {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var input: RandomCatViewModelInput
    var output: RandomCatViewModelOutput
    
    //MARK: - Input
    private let _loadRandomCat = BehaviorSubject<Void?>(value: nil)
    private let _refersh = BehaviorSubject<Void?>(value: nil)
    
    //MARK: - Output
    private let _randomCatModel = BehaviorSubject<[CatModel]>(value: [])
    private let _isLoading = BehaviorSubject<Bool>(value: true)
    
    private let usecase: RandomCatUseCase
    
    init(randomCatUseCase: RandomCatUseCase) {
        self.usecase = randomCatUseCase
        
        self.input = RandomCatViewModelInput(
            loadRandomCat: _loadRandomCat.asObserver(),
            refersh: _refersh.asObserver()
        )
        self.output = RandomCatViewModelOutput(
            randomCatModel: _randomCatModel.asDriver(onErrorJustReturn: []),
            isLoading: _isLoading.asDriver(onErrorJustReturn: false)
        )
        
        self._bindLoadRandomCat()
        self._bindRefersh()
        self._bindRandomCatModel()
        self._bindIsLoading()
    }
}

//MARK: - Binding
extension DefaultRandomCatViewModel {
    //MARK: - Input Binding
    private func _bindLoadRandomCat() {
        self._loadRandomCat
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] in
                self?.usecase.input.loadRandomCat.onNext(())
            })
            .disposed(by: disposeBag)
    }
    
    private func _bindRefersh() {
        self._refersh
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] in
                self?.usecase.input.refersh.onNext(())
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Output Binding
    private func _bindRandomCatModel() {
        self.usecase.output.randomCatModel
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] catModel in
                self?._randomCatModel.onNext(catModel)
            })
            .disposed(by: disposeBag)
    }
    
    private func _bindIsLoading() {
        self.usecase.output.isLoading
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] isLoading in
                self?._isLoading.onNext(isLoading)
            })
            .disposed(by: disposeBag)
    }
}
