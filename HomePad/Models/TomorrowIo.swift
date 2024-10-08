//
//  TomorrowIo.swift
//  HomePad
//
//  Created by Zero Cho on 10/3/24.
//

import Alamofire

let weatherCodeLookup: [Int: String] = [
  0: "questionmark", // Unknown
  1000: "sun.max.fill", // Clear, Sunny
  1100: "cloud.sun.fill", // Mostly Clear
  1101: "cloud.fill", // Partly Cloudy
  1102: "smoke.fill", // Mostly Cloudy
  1001: "cloud.fill", // Cloudy
  2000: "cloud.fog.fill", // Fog
  2100: "cloud.drizzle.fill", // Light Fog
  4000: "cloud.drizzle.fill", // Drizzle
  4001: "cloud.rain.fill", // Rain
  4200: "cloud.drizzle.fill", // Light Rain
  4201: "cloud.heavyrain.fill", // Heavy Rain
  5000: "snow", // Snow
  5001: "snowflake", // Flurries
  5100: "cloud.snow.fill", // Light Snow
  5101: "snowflake", // Heavy Snow
  6000: "cloud.hail.fill", // Freezing Drizzle
  6001: "cloud.sleet.fill", // Freezing Rain
  6200: "cloud.sleet.fill", // Light Freezing Rain
  6201: "cloud.sleet.fill", // Heavy Freezing Rain
  7000: "cloud.hail.fill", // Ice Pellets
  7101: "cloud.hail.fill", // Heavy Ice Pellets
  7102: "cloud.hail.fill", // Light Ice Pellets
  8000: "cloud.bolt.fill" // Thunderstorm
]

public struct WeatherReport: Decodable {
  public var iconName: String
  public var temperature: Int
  public var feelsLikeTemp: Int
  public var windDirection: Int
  public var windSpeedKts: Int
  
  enum CodingKeys: String, CodingKey {
    case data
  }
  
  enum DataKeys: String, CodingKey {
    case timelines
  }
  
  enum TimelinesKeys: String, CodingKey {
    case intervals
  }
  
  enum IntervalKeys: String, CodingKey {
    case values
  }
  
  enum ValuesKeys: String, CodingKey {
    case weatherCode, temperature, temperatureApparent, windDirection, windSpeed
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let dataContainer = try container.nestedContainer(keyedBy: DataKeys.self, forKey: .data)
    var timelinesContainer = try dataContainer.nestedUnkeyedContainer(forKey: .timelines)
    let timelineContainer = try timelinesContainer.nestedContainer(keyedBy: TimelinesKeys.self)
    var intervalsContainer = try timelineContainer.nestedUnkeyedContainer(forKey: .intervals)
    let intervalContainer = try intervalsContainer.nestedContainer(keyedBy: IntervalKeys.self)
    let valuesContainer = try intervalContainer.nestedContainer(keyedBy: ValuesKeys.self, forKey: .values)
    
    let weatherCode = try valuesContainer.decode(Int.self, forKey: .weatherCode)
    iconName = weatherCodeLookup[weatherCode] ?? "unknown"
    
    temperature = Int(try valuesContainer.decode(Double.self, forKey: .temperature).rounded())
    feelsLikeTemp = Int(try valuesContainer.decode(Double.self, forKey: .temperatureApparent).rounded())
    windDirection = Int(try valuesContainer.decode(Double.self, forKey: .windDirection).rounded())
    let windSpeedMetersPerSecond = try valuesContainer.decode(Double.self, forKey: .windSpeed)
    windSpeedKts = Int((windSpeedMetersPerSecond * 1.94384).rounded())
  }
  
  init(iconName: String, temperature: Int, feelsLikeTemp: Int, windDirection: Int, windSpeedKts: Int) {
    self.iconName = iconName
    self.temperature = temperature
    self.feelsLikeTemp = feelsLikeTemp
    self.windDirection = windDirection
    self.windSpeedKts = windSpeedKts
  }
}

struct TomorrowIo {
  static let API_URL = "https://data.climacell.co/v4/timelines?timesteps=1h&endTime=nowPlus1h&units=metric&location=\(Config.HOME_LOCATION.0),\(Config.HOME_LOCATION.1)&fields=temperature,temperatureApparent,precipitationType,humidity,windSpeed,windDirection,weatherCode&apikey=\(Config.TOMORROW_IO_API_KEY)"
  
  static func fetch() async throws -> WeatherReport {
    let headers: HTTPHeaders = [
      "Accept": "application/json"
    ]
    
    return try await withCheckedThrowingContinuation { continuation in
      AF.request(TomorrowIo.API_URL, headers: headers)
        .validate()
        .responseDecodable(of: WeatherReport.self) { response in
          switch response.result {
          case .success(let WeatherReport):
            continuation.resume(returning: WeatherReport)
          case .failure(let error):
            print(error)
            continuation.resume(throwing: error)
          }
        }
    }
  }
}
