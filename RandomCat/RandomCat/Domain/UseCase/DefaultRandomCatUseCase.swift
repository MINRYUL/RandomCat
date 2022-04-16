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
    var randomCatModel: BehaviorSubject<[CatModel]>
    var isLoading: BehaviorSubject<Bool?>
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
    private let _randomCatModel = BehaviorSubject<[CatModel]>(value: [])
    private let _isLoading = BehaviorSubject<Bool?>(value: nil)
    
    //MARK: - Store
    private let _baseImageCount = BehaviorRelay<Int>(value: 20)
    
    init(randomCatRepository: RandomCatRepository) {
        self.randomCatRepository = randomCatRepository
        
        self.input = RandomCatUseCaseInput(
            loadRandomCat: _loadRandomCat.asObserver(),
            refersh: _refersh.asObserver()
        )
        self.output = RandomCatUSeCaseOutput(
            randomCatModel: _randomCatModel.asObserver(),
            isLoading: _isLoading.asObserver()
        )
        
        self._bindLoadRandomCat()
        self._bindRefersh()
        self._bindRandomCatModel()
        self._bindError()
    }
}


//MARK: - Binding
extension DefaultRandomCatUseCase {
    //MARK: - Input Binding
    private func _bindLoadRandomCat() {
        self._loadRandomCat
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] in
                self?._isLoading.onNext(false)
                for _ in 0..<(self?._baseImageCount.value ?? 0) {
                    self?.randomCatRepository.input.loadRandomCat.onNext(())
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func _bindRefersh() {
        self._refersh
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] in
                self?._randomCatModel.onNext([])
                self?._isLoading.onNext(false)
                for _ in 0..<(self?._baseImageCount.value ?? 0) {
                    self?.randomCatRepository.input.loadRandomCat.onNext(())
                }
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Output Binding
    private func _bindRandomCatModel() {
        self.randomCatRepository.output.randomCatModel
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] catModel in
                guard let self = self else { return }
                guard var randomCatModel = try? self._randomCatModel.value() else { return }
                randomCatModel.append(self._makeCatModel(catModel: catModel))
                self._randomCatModel.onNext(randomCatModel)
                guard randomCatModel.count % self._baseImageCount.value == 0 else {
                    self._isLoading.onNext(true)
                    return
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func _bindError() {
        self.randomCatRepository.output.error
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] error in
                guard let error = error as? NetworkError  else { return }
                self?._isLoading.onNext(true)
                switch error {
                case .error(let statusCode, let data):
                    dump(statusCode)
                    dump(data)
                case .notConnected:
                    break
                case .unknownError:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
}

//MARK: - Making
extension DefaultRandomCatUseCase {
    private func _makeCatModel(catModel: CatImageResponseDTO) -> CatModel {
        return CatModel(id: UUID(), url: catModel.url)
    }
}
