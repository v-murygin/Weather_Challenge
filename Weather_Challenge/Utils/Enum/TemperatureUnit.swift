//
//  TemperatureUnit.swift
//  Weather_Challenge
//
//  Created by Vladislav on 9/19/23.
//

import Foundation

enum TemperatureUnit {
    case kelvin
    case celsius
    case fahrenheit

    //Converting Kelvins to another temperature
    func convert(_ temperature: Double?) -> Double? {
        guard let temperature = temperature else {
            return nil
        }
        switch self {
        case .kelvin:
            return temperature
        case .celsius:
            return temperature - 273.15
        case .fahrenheit:
            return (temperature - 273.15) * 9/5 + 32
        }
    }
}
