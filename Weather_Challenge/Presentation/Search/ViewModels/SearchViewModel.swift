//
//  SearchViewModel.swift
//  Weather_Challenge
//
//  Created by Vladislav on 9/18/23.
//

import Foundation

class SearchViewModel: ObservableObject  {
    
    // MARK: - Properties
    @Published var searchText: String = ""
    @Published var searchZip: String = ""
    @Published var cities: [CitySearchCellModel] = []
    
    let networkService = NetworkService.shared
    
    // MARK: - Functions
    @MainActor
    func serchCity(searchText: String) async {
        
        let digits = CharacterSet.decimalDigits
        let hasOnlyDigits = searchText.rangeOfCharacter(from: digits.inverted) == nil
        
        if hasOnlyDigits {
            if let fetchedCities = try? await networkService.fetchWeatherByZip(zipCode: searchText, countryCode: "US") {
                cities = [CitySearchCellModel(name: fetchedCities.name,
                                              lat: fetchedCities.lat,
                                              lon: fetchedCities.lon,
                                              country: fetchedCities.country,
                                              state: "")]
            }
        } else {
            if let fetchedCities = try? await networkService.fetchWeatherByCity(cityName: searchText, limit: 20) {
                cities = fetchedCities.map { CitySearchCellModel(name: $0.name,
                                                                 lat: $0.lat,
                                                                 lon: $0.lon,
                                                                 country: $0.country,
                                                                 state: $0.state) }
            }
        }
    }
}

