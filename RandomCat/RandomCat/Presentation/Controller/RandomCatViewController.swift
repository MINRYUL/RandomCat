//
//  ViewController.swift
//  RandomCat
//
//  Created by 김민창 on 2022/01/12.
//

import UIKit
import Combine

import RxSwift
import RxCocoa

final class RandomCatViewController: UIViewController {
    enum RandomCatSection: Int, CaseIterable {
        case main
    }
    
    private var disposeBag: DisposeBag = DisposeBag()
    
    typealias RandomCatDataSource = UICollectionViewDiffableDataSource<RandomCatSection, AnyHashable>
    typealias RandomCatSnapshot = NSDiffableDataSourceSnapshot<RandomCatSection, AnyHashable>
    
    lazy private var randomCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    lazy private var navigationOptionItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(
            image: .init(systemName: "list.bullet"),
            style: .plain,
            target: self,
            action: #selector(optionButtonPressed(_:))
        )
        buttonItem.tag = 1
        buttonItem.tintColor = .label
        return buttonItem
    }()
    
    lazy private var progressView: ProgressView = {
        let view = ProgressView(color: .systemGray, lineWidth: 5)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private var dataSource: RandomCatDataSource?
    private var snapShot: RandomCatSnapshot?
    private var viewModel: DefaultRandomCatViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureViewModel()
        self.configureView()
        self.configureCollectionView()
        self.configureSnapShot()
        self.configureDataSource()
        
        self._bindRandomCatModel()
        self._bindIsLoading()
    }
    
    @objc private func optionButtonPressed(_ sender: Any) {
    
    }
    
    private func bindSnapShotApply(section: RandomCatSection, item: [AnyHashable]) {
        DispatchQueue.main.async { [weak self] in
            guard var snapShot = self?.snapShot else { return }
            item.forEach {
                snapShot.appendItems([$0], toSection: section)
            }
            self?.dataSource?.apply(snapShot, animatingDifferences: true)
        }
    }
    
    private func reloadCellSnapShotApply(section: RandomCatSection, item: AnyHashable) {
        DispatchQueue.main.async { [weak self] in
            guard var snapShot = self?.snapShot else { return }
            snapShot.reloadItems([item])
            self?.dataSource?.apply(snapShot, animatingDifferences: true)
        }
    }
    
    private func configureSnapShot() {
        self.snapShot = RandomCatSnapshot()
        self.snapShot?.appendSections([.main])
    }
    
    private func _bindRandomCatModel() {
        self.viewModel?.output.randomCatModel
            .drive { [weak self] catModels in
                self?.bindSnapShotApply(section: .main, item: catModels)
            }
            .disposed(by: disposeBag)
    }
    
    private func _bindIsLoading() {
        self.viewModel?.output.isLoading
            .drive { [weak self] isLoading in
                self?.progressView.isHidden = isLoading
            }
            .disposed(by: disposeBag)
    }
    
    private func configureViewModel() {
        self.viewModel = DefaultRandomCatViewModel(
            randomCatUseCase: DefaultRandomCatUseCase(
                randomCatRepository: DefaultRandomCatRepository()
            )
        )
    }

    private func configureView() {
        self.view.addSubview(self.randomCollectionView)
        self.view.addSubview(self.progressView)
        self.view.backgroundColor = .systemBackground
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.topItem?.title = "고양이"
        
        self.navigationItem.rightBarButtonItem = self.navigationOptionItem
        
        NSLayoutConstraint.activate([
            self.randomCollectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.randomCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.randomCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.randomCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.progressView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.progressView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.progressView.widthAnchor.constraint(equalToConstant: 30),
            self.progressView.heightAnchor.constraint(equalTo: self.progressView.widthAnchor)
        ])
    }
    
    private func configureCollectionView() {
        self.randomCollectionView.collectionViewLayout = self.configureCompositionalLayout()
        
        self.randomCollectionView.register(RandomCatCollectionViewCell.self, forCellWithReuseIdentifier: RandomCatCollectionViewCell.identifier)
        
        guard let viewModel = self.viewModel else { return }
        
        self.randomCollectionView.rx
            .reachedBottom()
            .skip(1)
            .bind(to: viewModel.input.loadRandomCat)
            .disposed(by: disposeBag)
    }
    
    private func configureCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(0.5),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            item.contentInsets = .init(top: 3, leading: 3, bottom: 3, trailing: 3)
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalWidth(0.5)
                ),
                subitems: [item]
            )
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .none
            section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            return section
        }
    }
    
    private func configureDataSource() {
        let datasource = RandomCatDataSource(collectionView: self.randomCollectionView, cellProvider: {
            (collectionView, indexPath, item) -> UICollectionViewCell in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RandomCatCollectionViewCell.identifier, for: indexPath) as? RandomCatCollectionViewCell else {
                return UICollectionViewCell()
            }
            guard let item = item as? CatModel else { return cell }
            cell.update(catModel: item)
            return cell
        })
        
        self.dataSource = datasource
        self.randomCollectionView.dataSource = datasource
    }
}

