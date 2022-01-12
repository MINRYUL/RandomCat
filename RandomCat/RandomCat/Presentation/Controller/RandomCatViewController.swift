//
//  ViewController.swift
//  RandomCat
//
//  Created by 김민창 on 2022/01/12.
//

import UIKit
import SwiftUI

class RandomCatViewController: UIViewController {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.configureView()
        self.configureCollectionView()
        self.configureDataSource()
        self.configureBinding()
    }
    
    private func bindSnapShotApply(section: RandomCatSection, item: [AnyHashable]) {
        DispatchQueue.main.async { [weak self] in
            var snapshot = RandomCatSnapshot()
            snapshot.appendSections([.main])
            item.forEach {
                snapshot.appendItems([$0], toSection: section)
            }
            self?.dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func configureBinding() {
        let data = [1, 2, 3, 4, 5, 6, 7]
        self.bindSnapShotApply(section: .main, item: data)
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
            guard let item = item as? RandomCatCollectionViewCell else { return cell }
            
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

