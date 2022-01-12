//
//  RandomCatCollectionViewCell.swift
//  RandomCat
//
//  Created by 김민창 on 2022/01/12.
//

import UIKit

final class RandomCatCollectionViewCell: UICollectionViewCell {
    static let identifier = "RandomCatCell"
    
    lazy private var catImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "CatLogo")?.withAlignmentRectInsets(UIEdgeInsets(top: -50, left: -50, bottom: -50, right: -50))
        imageView.tintColor = .label
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        self.addSubview(self.catImage)
        self.backgroundColor = .systemGray6
        NSLayoutConstraint.activate([
            self.catImage.topAnchor.constraint(equalTo: self.topAnchor),
            self.catImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.catImage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.catImage.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
