//
//  WineModel.swift
//  Vintrace
//
//  Created by Debashree Joshi on 30/6/2023.
//

import Foundation

struct WineModel: Codable {
    let id: Int?
    let code: String?
    let description: String?
    let secondaryDescription: String?
    let type: ItemType?
    let beverageProperties: BeverageProperties?
    let unit: Unit?
    let unitRequired: Bool?
    let quantity: Quantity?
    let owner: Owner?
    let images: [Image]?
    let components: [Component]?
}

struct ItemType: Codable {
    let name: String?
    let code: String?
}

struct BeverageProperties: Codable {
    let colour: String?
    let description: String?
}

struct Unit: Codable {
    let name: String?
    let abbreviation: String?
    let precision: Int?
}

struct Quantity: Codable {
    let onHand: Int?
    let committed: Int?
    let ordered: Int?
}

struct Owner: Codable {
    let id: Int?
    let name: String?
}

struct Image: Codable {
    let endpoint: String?
}

struct Component: Codable {
    let endpoint: String?
    let id: Int?
    let code: String?
    let description: String?
    let unit: ComponentUnit?
    let unitRequired: Bool?
    let quantity: Int?
}

struct ComponentUnit: Codable {
    let description: String?
    let abbreviation: String?
    let precision: Int?
}

