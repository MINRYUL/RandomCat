//
//  RandomCatRepositiory.swift
//  RandomCat
//
//  Created by 김민창 on 2022/01/13.
//

import Foundation

import RxSwift
import RxCocoa

protocol RandomCatRepository {
    var disposeBag: DisposeBag { get set }
    
    var input: RandomCatRepositoryInput { get set }
    var output: RandomCatRepositoryOutput { get set }
}

struct RandomCatRepositoryInput {
    var loadRandomCat: BehaviorSubject<Void?>
}

struct RandomCatRepositoryOutput {
    var randomCatModel: BehaviorSubject<CatImageResponseDTO?>
    var error: BehaviorSubject<Error?>
}

final class DefaultRandomCatRepository: RandomCatRepository {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var input: RandomCatRepositoryInput
    var output: RandomCatRepositoryOutput
    
    //MARK: - Input
    private let _loadRandomCat = BehaviorSubject<Void?>(value: nil)
    
    //MARK: - Output
    private let _randomCatModel = BehaviorSubject<CatImageResponseDTO?>(value: nil)
    private let _error = BehaviorSubject<Error?>(value: nil)
    
    init() {
        self.input = RandomCatRepositoryInput(
            loadRandomCat: _loadRandomCat
        )
        self.output = RandomCatRepositoryOutput(
            randomCatModel: _randomCatModel,
            error: _error
        )
        
        self._bindLoadRandomCat()
    }
}

//MARK: - Binding
extension DefaultRandomCatRepository {
    //MARK: - Input
    private func _bindLoadRandomCat() {
        self._loadRandomCat
            .compactMap { $0 }
            .flatMapLatest {
                return DefaultNetworkService.instance.get(url: CatImageConstant.cat, headers: [:])
            }
            .subscribe(onNext: { [weak self] data in
                self?._makeRandomCatModel(data: data)
            },onError: { [weak self] error in
                 
                guard let error = error as? NetworkError else {
                    return
                }
                self?._error.onNext(error)
            })
            .disposed(by: disposeBag)
    }
}

//MARK: - Making
extension DefaultRandomCatRepository {
    private func _makeRandomCatModel(data: [CatImageResponseDTO]) {
        guard let firstCatModel = data.first else { return }
        self._randomCatModel.onNext(firstCatModel)
    }
}

