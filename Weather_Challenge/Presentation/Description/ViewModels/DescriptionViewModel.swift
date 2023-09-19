//
//  DescriptionViewModel.swift
//  Weather_Challenge
//
//  Created by Vladislav on 9/18/23.
//

import Foundation
import UIKit
 

class DescriptionViewModel: ObservableObject {
    
    // MARK: - Properties
    private let networkService = NetworkService.shared
    private let iconWeatherImageLoader = IconWeatherImageLoader.shared


    @Published var weatherData: Weather?
    @Published var weatherIcon: UIImage?
    
    // MARK: -  Initialization
    init(lat: Double, lon: Double) {
        Task {
            await fetchData(lat: lat, lon: lon)
        }
    }

    // MARK: - Functions
    func save(){
        //The practice is bad, but this is a very small amount of data to connect to a large database.
        UserDefaultsUtility.saveObjectToUserDefaults(object: weatherData, key: UserDefaultsKey.weatherInSelectedCity.rawValue)
    }
    
    // MARK: - Private functions
    
    @MainActor
    private func fetchData(lat: Double, lon: Double) async {
        do {
            let weatherResponse = try await networkService.fetchWeatherByCoords(lat: lat, lon: lon)
            self.weatherData = Weather(weatherResponse: weatherResponse)

            if let iconName = weatherResponse.weather.first?.icon {
                do {
                    self.weatherIcon = try await iconWeatherImageLoader.downloadIcon(name: iconName)
                } catch {
                    print("Failed to load weather icon: \(error)")
                }
            }
        } catch {
            print("Failed to fetch weather data: \(error)")
        }
    }

}
