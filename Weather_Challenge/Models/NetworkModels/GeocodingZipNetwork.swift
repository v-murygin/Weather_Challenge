//
//  GeocodingZip.swift
//  Weather_Challenge
//
//  Created by Vladislav on 9/18/23.
//

import Foundation

struct GeocodingZipNetwork: Codable {
    let zip, name: String
    let lat, lon: Double
    let country: String
}
