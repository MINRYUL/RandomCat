//
//  TabBarController.swift
//  RandomCat
//
//  Created by 김민창 on 2022/01/12.
//

import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func configureController() {
        let randomCatViewController = UINavigationController(rootViewController: RandomCatViewController())
        randomCatViewController.title = "RandomCat"
        
        self.viewControllers = [randomCatViewController]
    }

}
