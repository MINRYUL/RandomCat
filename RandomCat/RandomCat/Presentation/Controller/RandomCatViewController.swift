//
//  ViewController.swift
//  RandomCat
//
//  Created by 김민창 on 2022/01/12.
//

import UIKit
import Combine

final class RandomCatViewController: UIViewController {
    enum RandomCatSection: Int, CaseIterable {
        case main
    }
    
    typealias RandomCatDataSource = UICollectionViewDiffableDataSource<RandomCatSection, AnyHashable>
    typealias RandomCatSnapshot = NSDiffableDataSourceSnapshot<RandomCatSection, AnyHashable>
    
    lazy private var randomCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private var dataSource: RandomCatDataSource?
    private var snapShot: RandomCatSnapshot?
    private var viewModel: RandomCatViewModel?
    private var cancellables = Set<AnyCancellable>()
    private var imageCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViewModel()
        self.configureView()
        self.configureCollectionView()
        self.configureSnapShot()
        self.configureDataSource()
        self.configureBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewDidAppear(animated)
        self.viewModel?.fetchCatData()
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
    
    private func configureBinding() {
        self.viewModel?.$catModels
            .receive(on: DispatchQueue.main)
            .sink( receiveValue: { [weak self] catModels in
                self?.bindSnapShotApply(section: .main, item: catModels)
            })
            .store(in: &self.cancellables)
    }
    
    private func configureViewModel() {
        self.viewModel = RandomCatViewModel(randomCatUseCase: RandomCatUseCase(randomCatRepository: DefaultRandomCatRepository(networkService: DefaultNetworkService())))
    }

    private func configureView() {
        self.view.addSubview(self.randomCollectionView)
        self.view.backgroundColor = .systemBackground
        NSLayoutConstraint.activate([
            self.randomCollectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.randomCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.randomCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.randomCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureCollectionView() {
        self.randomCollectionView.delegate = self
        self.randomCollectionView.collectionViewLayout = self.configureCompositionalLayout()
        
        self.randomCollectionView.register(RandomCatCollectionViewCell.self, forCellWithReuseIdentifier: RandomCatCollectionViewCell.identifier)
    }
    
    private func configureCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = .init(top: 3, leading: 3, bottom: 3, trailing: 3)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.5)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .none
            section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            return section
        }
    }
    
    private func configureDataSource() {
        let datasource = RandomCatDataSource(collectionView: self.randomCollectionView, cellProvider: {(collectionView, indexPath, item) -> UICollectionViewCell in
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

extension RandomCatViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
}

