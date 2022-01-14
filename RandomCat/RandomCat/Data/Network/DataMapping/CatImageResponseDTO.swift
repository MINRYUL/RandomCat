//
//  CatImageResponseDTO.swift
//  RandomCat
//
//  Created by 김민창 on 2022/01/13.
//

import Foundation

struct CatImageResponseDTO: Codable, Hashable {
    var identify = UUID()
    
    let id: String
    let url: String
    let width: Int
    let height: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CatImageResponseDTO, rhs: CatImageResponseDTO) -> Bool {
        lhs.id == rhs.id
    }
}
