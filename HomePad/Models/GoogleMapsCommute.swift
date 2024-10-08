//
//  GoogleMapsCommute.swift
//  HomePad
//
//  Created by Zero Cho on 10/3/24.
//

import Foundation
import Alamofire
import SwiftUICore

struct CommuteLocation {
  var label: String
  var address: String
  
  init(label: String, address: String) {
    self.label = label
    self.address = address
  }
}

public enum TrafficCondition {
  case Good
  case Moderate
  case Bad
  
  func color() -> Color {
    switch self {
    case .Good:
      return .green
    case .Moderate:
      return .yellow
    case .Bad:
      return .red
    }
  }
}

public struct CommuteTimeReport: Identifiable, Decodable {
  public var id: String { get { label } }
  
  public var label: String
  public var commuteInMins: Int
  public var trafficCondition: TrafficCondition
  
  enum CodingKeys: String, CodingKey {
    case routes
  }
  
  enum RoutesKeys: String, CodingKey {
    case legs
  }
  
  enum LegsKeys: String, CodingKey {
    case duration
    case durationInTraffic = "duration_in_traffic"
  }
  
  enum DurationKeys: String, CodingKey {
    case value
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    var routesContainer = try container.nestedUnkeyedContainer(forKey: .routes)
    let routeContainer = try routesContainer.nestedContainer(keyedBy: RoutesKeys.self)
    var legsContainer = try routeContainer.nestedUnkeyedContainer(forKey: .legs)
    let legContainer = try legsContainer.nestedContainer(keyedBy: LegsKeys.self)
    
    let durationValue = try legContainer.nestedContainer(keyedBy: DurationKeys.self, forKey: .duration).decode(Int.self, forKey: .value)
    let durationInTrafficValue = try legContainer.nestedContainer(keyedBy: DurationKeys.self, forKey: .durationInTraffic).decode(Int.self, forKey: .value)
    
    commuteInMins = durationInTrafficValue / 60
    label = ""
    
    let trafficRatio = Double(durationInTrafficValue) / Double(durationValue)
    if trafficRatio <= 1.1 {
      trafficCondition = .Good
    } else if trafficRatio <= 1.3 {
      trafficCondition = .Moderate
    } else {
      trafficCondition = .Bad
    }
  }
  
  public init (label: String, commuteInMins: Int, trafficCondition: TrafficCondition) {
    self.label = label
    self.commuteInMins = commuteInMins
    self.trafficCondition = trafficCondition
  }
}

struct GoogleMapsCommute {
  static let API_BASE = "https://avwx.rest/api/metar/"
  
  static func fetch(label: String, destination: String) async throws -> CommuteTimeReport {
    var url = URL.init(string: "https://maps.googleapis.com/maps/api/directions/json")!
    url.append(queryItems: [
      URLQueryItem.init(name: "origin", value: Config.HOME_LOCATION_STR),
      URLQueryItem.init(name: "destination", value: destination),
      URLQueryItem.init(name: "mode", value: "driving"),
      URLQueryItem.init(name: "departure_time", value: "now"),
      URLQueryItem.init(name: "key", value: Config.GOOGLE_MAPS_API_KEY),
    ])
    
    return try await withCheckedThrowingContinuation { continuation in
      AF.request(url)
        .validate()
        .responseDecodable(of: CommuteTimeReport.self) { response in
          switch response.result {
          case .success(let commuteTimeReport):
            var report = commuteTimeReport
            report.label = label
            continuation.resume(returning: report)
          case .failure(let error):
            continuation.resume(throwing: error)
          }
        }
    }
  }
}
