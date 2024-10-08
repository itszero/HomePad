//
//  Calbox.swift
//  HomePad
//
//  Created by Zero Cho on 10/4/24.
//

import Foundation
import Alamofire

struct CalboxEvent : Identifiable, Decodable {
  var id: String {
    get {
      "\(title)_\(time)"
    }
  }

  var title: String
  var time: Date

  enum CodingKeys: String, CodingKey {
    case title
    case start
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    title = try container.decode(String.self, forKey: .title)

    let dateString = try container.decode(String.self, forKey: .start)
    guard let date = ISO8601DateFormatter().date(from: dateString.replacingOccurrences(of: ".000", with: "")) else {
      throw DecodingError.dataCorruptedError(forKey: .start, in: container, debugDescription: "Date string does not match expected format")
    }
    time = date
  }

  init(title: String, time: Date) {
    self.title = title
    self.time = time
  }
}

struct Calbox {
  static func fetch() async throws -> [CalboxEvent] {
    let headers: HTTPHeaders = [
      "Accept": "application/json"
    ]

    return try await withCheckedThrowingContinuation { continuation in
      AF.request(Config.CALENDAR_URL, headers: headers)
        .validate()
        .responseDecodable(of: [CalboxEvent].self) { response in
          switch response.result {
          case .success(let events):
            continuation.resume(returning: events)
          case .failure(let error):
            print(error)
            continuation.resume(throwing: error)
          }
        }
    }
  }
}
