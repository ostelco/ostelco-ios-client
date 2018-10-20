//
//  ProductModel.swift
//  ostelco-ios-client
//
//  Created by mac on 10/20/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation

struct PresentationModel: Codable {
    let label: String
    let price: String
    
    enum CodingKeys: String, CodingKey {
        case label = "productLabel"
        case price = "priceLabel"
    }
}

struct ProductModel: Codable {
    let presentation: PresentationModel
    
    enum CodingKeys: String, CodingKey {
        case presentation
    }
}
