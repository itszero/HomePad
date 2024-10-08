//
//  AVWX.swift
//  HomePad
//
//  Created by Zero Cho on 10/3/24.
//

import SwiftUICore
import Alamofire

public enum WeatherType : String {
  case VFR
  case MVFR
  case IFR
  case LIFR
  case Unknown
  
  func color() -> Color {
    switch self {
    case .VFR:
      return .green
    case .MVFR:
      return .blue
    case .IFR:
      return .red
    case .LIFR:
      return .purple
    case .Unknown:
      return .white
    }
  }
}

public struct METARReport : Identifiable, Decodable {
  public var id: String {
    get {
      self.airport
    }
  }
  
  public let airport: String
  public let wind: String
  public let vis: String
  public let ceiling: String
  public let weatherType: WeatherType
  
  enum CodingKeys: String, CodingKey {
    case station
    case wind_direction, wind_speed, wind_gust
    case visibility
    case clouds
    case flight_rules
  }
  
  private enum ReprCodingKey: String, CodingKey {
    case repr
  }
  
  private struct Cloud: Decodable {
    let repr: String
  }
  
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.airport = try container.decode(String.self, forKey: .station)

    let windDirection = try container.nestedContainer(keyedBy: ReprCodingKey.self, forKey: .wind_direction)
    let windSpeed = try container.nestedContainer(keyedBy: ReprCodingKey.self, forKey: .wind_speed)
    let windGustContainer = try? container.nestedContainer(keyedBy: ReprCodingKey.self, forKey: .wind_gust)
    let directionRepr = try windDirection.decode(String.self, forKey: .repr)
    let speedRepr = try windSpeed.decode(String.self, forKey: .repr)
    let gustRepr = try windGustContainer?.decodeIfPresent(String.self, forKey: .repr)
    let gustReprStr = if let gustRepr = gustRepr { "G\(gustRepr)" } else { "" }
    self.wind = "\(directionRepr)\(speedRepr)\(gustReprStr)KT"

    let visibilityContainer = try container.nestedContainer(keyedBy: ReprCodingKey.self, forKey: .visibility)
    let vis = try visibilityContainer.decode(String.self, forKey: .repr)
    self.vis = "\(String(format: "%02d", Int(vis)!))SM"

    let clouds = try container.decode([Cloud].self, forKey: .clouds)
    self.ceiling = clouds.map { $0.repr }.joined(separator: " ")

    let flightRules = try container.decode(String.self, forKey: .flight_rules)
    self.weatherType = WeatherType(rawValue: flightRules) ?? .Unknown
  }
  
  init(airport: String, wind: String, vis: String, ceiling: String, weatherType: WeatherType) {
    self.airport = airport
    self.wind = wind
    self.vis = vis
    self.ceiling = ceiling
    self.weatherType = weatherType
  }
}

struct AVWX {
  static let API_BASE = "https://avwx.rest/api/metar/"
  
  static func fetch(airportCode: String) async throws -> METARReport {
    let url = "\(AVWX.API_BASE)/\(airportCode)"
    
    let headers: HTTPHeaders = [
      "Authorization": "Bearer \(Config.AVRX_API_KEY)",
      "Accept": "application/json"
    ]
    
    return try await withCheckedThrowingContinuation { continuation in
      AF.request(url, headers: headers)
        .validate()
        .responseDecodable(of: METARReport.self) { response in
          switch response.result {
          case .success(let metarReport):
            continuation.resume(returning: metarReport)
          case .failure(let error):
            continuation.resume(throwing: error)
          }
        }
    }
  }
}

