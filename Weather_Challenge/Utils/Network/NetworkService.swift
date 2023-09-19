//
//  NetworkService.swift
//  Weather_Challenge
//
//  Created by Vladislav on 9/18/23.
//

import Foundation

class NetworkService {
    // MARK: - Properties
    static let shared = NetworkService()
    
    let apiKey = "ff44140cad60201831b5e45bbf195cff"
    let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    let geocoderURL = "https://api.openweathermap.org/geo/1.0"
    
    // MARK: - Methods
    
    // Requests weather by longitude and latitude coordinates.
    func fetchWeatherByCoords(lat: Double, lon: Double) async throws -> WeatherResponse {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "lat", value: String(lat)))
        queryItems.append(URLQueryItem(name: "lon", value: String(lon)))
        queryItems.append(URLQueryItem(name: "appid", value: apiKey))
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }

        return try await performRequest(URL: url)
    }
    
    //Requests city, with an optional limit on the number of results.
    func fetchWeatherByCity(cityName: String, limit: Int = 5) async throws -> [GeocodingElementNetwork] {
        let resourceURL = geocoderURL + "/direct"
        guard var urlComponents = URLComponents(string: resourceURL) else {
            throw URLError(.badURL)
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: cityName),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        return try await performRequest(URL: url)
    }
    
    // Requests city by zip code
    func fetchWeatherByZip(zipCode: String, countryCode: String?) async throws -> GeocodingZipNetwork {
        let resourceURL = geocoderURL + "/zip"
        guard var urlComponents = URLComponents(string: resourceURL) else {
            throw URLError(.badURL)
        }
        
        let zipQueryParamValue: String = countryCode != nil ? "\(zipCode),\(countryCode!)" : zipCode
        
        urlComponents.queryItems = [
            URLQueryItem(name: "zip", value: zipQueryParamValue),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        return try await performRequest(URL: url)
    }
    
    //Requests weather by city name, with optional state code and country code parameters.
    func fetchWeather(cityName: String, stateCode: String?, countryCode: String?) async throws -> WeatherResponse {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw URLError(.badURL)
        }
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "q", value: cityName))
        
        if let stateCode = stateCode {
            queryItems.append(URLQueryItem(name: "stateCode", value: stateCode))
        }
        
        if let countryCode = countryCode {
            queryItems.append(URLQueryItem(name: "countryCode", value: countryCode))
        }
        
        queryItems.append(URLQueryItem(name: "appid", value: apiKey))
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        return try await performRequest(URL: url)
    }

    
    // Performs a generic network request and decodes the response
    private func performRequest<T: Decodable>(URL: URL) async throws -> T {
        let (data, _) = try await URLSession.shared.data(from: URL)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
