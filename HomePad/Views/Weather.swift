//
//  Weather.swift
//  HomePad
//
//  Created by Zero Cho on 10/3/24.
//

import SwiftUI

struct Weather: View {
  @Binding var report: WeatherReport
  
  var body: some View {
    HomePadModule(title: "Weather") {
      HStack {
        HStack(spacing: 20) {
          Image(systemName: report.iconName)
            .font(.system(size: 48.0))
          
          VStack {
            Text("\(report.temperature)°C")
              .font(.largeTitle)
            
            HStack {
              Image(systemName: "person.circle")
                .font(.headline)
              Text("\(report.feelsLikeTemp)°C")
                .font(.headline)
            }
          }
        }
        
        Spacer()
        
        HStack(spacing: 30) {
          VStack(spacing: 10) {
            Image(systemName: "location.north")
              .font(.system(size: 36.0))
              .rotationEffect(.degrees(Double(180 + report.windDirection)))
            
            Text("\(report.windDirection)°")
          }
            
          HStack {
            Text("\(report.windSpeedKts)")
              .font(.largeTitle)
            
            Text("kts")
          }
        }
      }
    }
  }
}

struct WeatherPreview: View {
  @State var report1 = WeatherReport(iconName: "cloud.sun.rain", temperature: 18, feelsLikeTemp: 24, windDirection: 252, windSpeedKts: 12)
  @State var report2 = WeatherReport(iconName: "sun.max.fill", temperature: 32, feelsLikeTemp: 38, windDirection: 131, windSpeedKts: 3)

  var body: some View {
    VStack(spacing: 50) {
      Weather(report: $report1)
        .frame(width: 400)
        .preferredColorScheme(.dark)
      
      Weather(report: $report2)
        .frame(width: 400)
        .preferredColorScheme(.dark)
    }
  }
}

#Preview {
  WeatherPreview()
}
