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
    let isDefault: String?
    
    enum CodingKeys: String, CodingKey {
        case label = "productLabel"
        case price = "priceLabel"
        case isDefault
    }
}

struct PriceModel: Codable {
    let amount: Int
    let currency: String
    
    enum CodingKeys: String, CodingKey {
        case amount, currency
    }
}

struct ProductModel: Codable {
    let sku: String
    let presentation: PresentationModel
    let price: PriceModel
    
    enum CodingKeys: String, CodingKey {
        case sku, presentation, price
    }
}

struct ScanResult: Codable {
  let vendorScanReference: String
  let dob: String
  let lastName: String
  let time: Int64
  let firstName: String
  let verificationStatus: String
  let rejectReason: String?
  let type: String
  let country: String

  enum CodingKeys: String, CodingKey {
    case vendorScanReference, dob, lastName, time, firstName
    case verificationStatus, rejectReason, type, country
  }
}

struct ScanInformation: Codable {
  let scanId: String
  let status: String

  let scanResult: ScanResult?
    enum CodingKeys: String, CodingKey {
        case scanId, status, scanResult
    }
}
