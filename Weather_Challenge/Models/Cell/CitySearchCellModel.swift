//
//  CitySearchCellModel.swift
//  Weather_Challenge
//
//  Created by Vladislav on 9/18/23.
//

import Foundation

struct CitySearchCellModel: Hashable {
    let name: String
    let lat, lon: Double
    let country, state: String
}
