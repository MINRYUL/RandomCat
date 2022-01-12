//
//  ViewController.swift
//  RandomCat
//
//  Created by 김민창 on 2022/01/12.
//

import UIKit

class RandomCatViewController: UIViewController {
    lazy private var randomCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }

    private func configureView() {
        self.view.addSubview(self.randomCollectionView)
        
        NSLayoutConstraint.activate([
            self.randomCollectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.randomCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.randomCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.randomCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

}

