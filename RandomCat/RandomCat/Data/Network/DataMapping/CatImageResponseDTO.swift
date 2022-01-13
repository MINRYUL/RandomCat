//
//  CatImageResponseDTO.swift
//  RandomCat
//
//  Created by 김민창 on 2022/01/13.
//

import Foundation

struct CatImageResponseDTO: Codable {
    let breeds: String?
    let id: String
    let url: String
    let width: Int
    let height: Int
}
