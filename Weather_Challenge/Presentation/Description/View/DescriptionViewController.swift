//
//  DescriptionViewController.swift
//  Weather_Challenge
//
//  Created by Vladislav on 9/18/23.
//

import SwiftUI

struct DescriptionViewController: View {
    
    // MARK: - Properties
    @ObservedObject var viewModel: DescriptionViewModel
    var onClose: () -> Void
    
    // MARK: -  Initialization
    init(lat: Double, lon: Double, onClose: @escaping () -> Void) {
        self.viewModel = DescriptionViewModel(lat: lat, lon: lon)
        self.onClose = onClose
    }
    
    // MARK: - Body
    
    var body: some View {
        if let weatherData = viewModel.weatherData {
            VStack(spacing: 20){
                Text(weatherData.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if let weatherIcon = viewModel.weatherIcon {
                    Image(uiImage: weatherIcon)
                        .resizable()
                        .frame(width: 150,height: 150)
                } else {
                    ProgressView() 
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        .frame(width: 150,height: 150)
                }

                Text(weatherData.weather.first?.main ?? "")
                    .font(.title2)
                    .foregroundColor(Color.blue)
                Text(weatherData.weather.first?.description ?? "")
                    .font(.subheadline)
                    .foregroundColor(Color.gray)

              
                    HStack {
                        Image(systemName: "thermometer")
                            .foregroundColor(Color.red)
                        Text("Current temperature:")
                        Text(weatherData.temp != nil ? "\(Int(weatherData.temp!))" : "--")
                    }
                

                if let feelsLikeTemp = weatherData.feelsLike {
                    HStack {
                        Image(systemName: "sun.max")
                            .foregroundColor(Color.orange)
                        Text("Feels like:")
                        Text("\(Int(feelsLikeTemp))")
                    }
                }
                
                if let humidity = weatherData.humidity {
                    HStack {
                        Image(systemName: "cloud.rain")
                            .foregroundColor(Color.blue)
                        Text("Humidity:")
                        Text("\(humidity)")
                    }
                }
            }
            Spacer()
            Button("Save", action: {
                viewModel.save()
                self.onClose()
                
            })
            .padding()
        } else {
            VStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(2)
                Text("Loading...")
                    .font(.headline)
                    .padding(.top,20)
                Spacer()
            }
        }
    }
}

struct DescriptionViewController_Previews: PreviewProvider {
    static var previews: some View {
        DescriptionViewController(lat: 117.9345987, lon: 29.9265985) {}
    }
}
