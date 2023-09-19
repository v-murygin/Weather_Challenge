//
//  GeocodingElement.swift
//  Weather_Challenge
//
//  Created by Vladislav on 9/18/23.
//

import Foundation

struct GeocodingElementNetwork: Codable {
    let name: String
    let localNames: [String: String]?
    let lat, lon: Double
    let country, state: String

    enum CodingKeys: String, CodingKey {
        case name
        case localNames = "local_names"
        case lat, lon, country, state
    }
}
