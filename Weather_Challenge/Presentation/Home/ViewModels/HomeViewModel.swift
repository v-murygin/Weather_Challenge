//
//  HomeViewModel.swift
//  Weather_Challenge
//
//  Created by Vladislav on 9/18/23.
//

import Foundation
import Combine
import UIKit

class HomeViewModel: ObservableObject  {
    
    // MARK: - Properties
    private let locationManager = LocationManager.shared
    private let networkService = NetworkService.shared
    private let iconWeatherImageLoader = IconWeatherImageLoader.shared
    private var cancellables = Set<AnyCancellable>()
    private let queue = DispatchQueue(label: "weatherfetch.background", qos: .background)
    
    @Published var weatherData: Weather?
    @Published var weatherIcon: UIImage?
    @Published var locationUnavailable: Bool?

    // MARK: -  Initialization
    init() {
        locationManager.$location
            .sink { [weak self] location in
                self?.queue.async {
                    if let strongSelf = self {
                        Task {
                            await strongSelf.getWeather(lat: location?.coordinate.latitude.magnitude,
                                                       lon: location?.coordinate.longitude.magnitude)
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Functions
    func startAppCheck() {
        if locationManager.checkLocationAuthorizationStatus()  {
            getLocation()
        } else {
            weatherData = UserDefaultsUtility.getObjectFromUserDefaults(key: UserDefaultsKey.weatherInSelectedCity.rawValue)
        }
    }
    
    func getLocation() {
        locationManager.requestLocation()
    }
    
    func dataUpdate() async {
        if let weatherData: Weather? = UserDefaultsUtility.getObjectFromUserDefaults(key: UserDefaultsKey.weatherInSelectedCity.rawValue) {
            await getWeather(lat: weatherData?.lat, lon: weatherData?.lon)
        }
    }
    
    // MARK: - Private functions
    private func getWeather(lat: Double?, lon: Double?) async {
        guard let lat = lat, let lon = lon else { return }
        
        do {
            let weatherResponse = try await networkService.fetchWeatherByCoords(lat: lat, lon: lon)
            self.weatherData = Weather(weatherResponse: weatherResponse)
            
            UserDefaultsUtility.saveObjectToUserDefaults(object: weatherData, key: UserDefaultsKey.weatherInSelectedCity.rawValue)
            
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
