//
//  Weather.swift
//  Weather_Challenge
//
//  Created by Vladislav on 9/19/23.
//

import Foundation

struct Weather: Codable {
    let name: String
    let lon: Double?
    let lat: Double?
    let temp: Double?
    let feelsLike: Double?
    let tempMin: Double?
    let tempMax: Double?
    let pressure: Int?
    let humidity: Int?
    let weather: [NearestWeather]
    
    internal init(weatherResponse: WeatherResponse) {
        let selectedUnit = TemperatureUnit.celsius
       
        self.name = weatherResponse.name
        self.lon = weatherResponse.coord?.lon
        self.lat = weatherResponse.coord?.lat
        self.temp = selectedUnit.convert(weatherResponse.main.temp)
        self.feelsLike = selectedUnit.convert(weatherResponse.main.feelsLike)
        self.tempMin = selectedUnit.convert(weatherResponse.main.tempMin)
        self.tempMax = selectedUnit.convert(weatherResponse.main.tempMax)
        self.pressure = weatherResponse.main.pressure
        self.humidity = weatherResponse.main.humidity
        self.weather = weatherResponse.weather.map { NearestWeather(nearestWeatherResponse: $0) }
    }
}


struct NearestWeather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
    
    internal init(nearestWeatherResponse: NearestWeatherResponse) {
        self.id = nearestWeatherResponse.id
        self.main = nearestWeatherResponse.main
        self.description = nearestWeatherResponse.description
        self.icon = nearestWeatherResponse.icon
    }
}
