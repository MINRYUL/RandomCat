//
//  CatModel.swift
//  RandomCat
//
//  Created by 김민창 on 2022/01/16.
//

import Foundation

struct CatModel: Hashable {
    var id = UUID()

    let url: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CatModel, rhs: CatModel) -> Bool {
        lhs.id == rhs.id
    }
}
