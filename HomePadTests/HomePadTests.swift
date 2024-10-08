//
//  HomdPadTests.swift
//  HomePad
//
//  Created by Zero Cho on 10/4/24.
//

import Testing
import Foundation
import HomePad

struct HomdPadTests {

  @Test func decode_avwx_metar() async throws {
    let input = """
{
  "altimeter": {
    "repr": "A2993",
    "spoken": "two nine point nine three",
    "value": 29.93
  },
  "clouds": [
    {
      "altitude": 100,
      "modifier": null,
      "repr": "FEW100",
      "type": "FEW"
    }
  ],
  "density_altitude": 715,
  "dewpoint": {
    "repr": "16",
    "spoken": "one six",
    "value": 16
  },
  "flight_rules": "VFR",
  "meta": {
    "stations_updated": "2024-06-12",
    "timestamp": "2024-10-04T17:24:17.520292Z"
  },
  "other": [],
  "pressure_altitude": -6,
  "raw": "KPAO 041647Z VRB04KT 10SM FEW100 21/16 A2993",
  "relative_humidity": 0.7309345308433759,
  "remarks": "",
  "remarks_info": null,
  "runway_visibility": [],
  "sanitized": "KPAO 041647Z VRB04KT 10SM FEW100 21/16 A2993",
  "station": "KPAO",
  "temperature": {
    "repr": "21",
    "spoken": "two one",
    "value": 21
  },
  "time": {
    "dt": "2024-10-04T16:47:00Z",
    "repr": "041647Z"
  },
  "units": {
    "accumulation": "in",
    "altimeter": "inHg",
    "altitude": "ft",
    "temperature": "C",
    "visibility": "sm",
    "wind_speed": "kt"
  },
  "visibility": {
    "repr": "10",
    "spoken": "one zero",
    "value": 10
  },
  "wind_direction": {
    "repr": "VRB",
    "spoken": "variable",
    "value": null
  },
  "wind_gust": null,
  "wind_speed": {
    "repr": "04",
    "spoken": "four",
    "value": 4
  },
  "wind_variable_direction": [],
  "wx_codes": []
}
""";

    let metar = try JSONDecoder().decode(METARReport.self, from: input.data(using: .utf8)!)
    #expect(metar.airport == "KPAO")
    #expect(metar.vis == "10SM")
    #expect(metar.ceiling == "FEW100")
    #expect(metar.wind == "VRB04KT")
    #expect(metar.weatherType == .VFR)
  }

  @Test func decode_tomorrow_io() async throws {
    let input = """
{
  "data": {
    "timelines": [
      {
        "timestep": "1h",
        "endTime": "2024-10-04T08:00:00Z",
        "startTime": "2024-10-04T07:00:00Z",
        "intervals": [
          {
            "startTime": "2024-10-04T07:00:00Z",
            "values": {
              "humidity": 74,
              "precipitationType": 0,
              "temperature": 16.38,
              "temperatureApparent": 16.38,
              "weatherCode": 1000,
              "windDirection": 319.5,
              "windSpeed": 1.19
            }
          },
          {
            "startTime": "2024-10-04T08:00:00Z",
            "values": {
              "humidity": 64.16,
              "precipitationType": 0,
              "temperature": 17.63,
              "temperatureApparent": 17.63,
              "weatherCode": 1000,
              "windDirection": 331.7,
              "windSpeed": 2.35
            }
          }
        ]
      }
    ]
  }
}
""";

    let report = try JSONDecoder().decode(WeatherReport.self, from: input.data(using: .utf8)!)
    #expect(report.iconName == "sun.max.fill")
    #expect(report.temperature == 16)
    #expect(report.feelsLikeTemp == 16)
    #expect(report.windDirection == 320)
    #expect(report.windSpeedKts == 2)
  }

  @Test func decode_commute_time() async throws {
    let input = """
{
  "geocoded_waypoints": [
  ],
  "routes": [
    {
      "bounds": {
      },
      "copyrights": "Map data ©2024 Google",
      "legs": [
        {
          "distance": {
            "text": "13.0 mi",
            "value": 20900
          },
          "duration": {
            "text": "17 mins",
            "value": 991
          },
          "duration_in_traffic": {
            "text": "16 mins",
            "value": 980
          },
          "steps": [],
        }
      ],
      "overview_polyline": {
      },
      "summary": "US-101 S",
      "warnings": [],
      "waypoint_order": []
    }
  ],
  "status": "OK"
}
""";

    let report = try JSONDecoder().decode(CommuteTimeReport.self, from: input.data(using: .utf8)!)
    #expect(report.label == "")
    #expect(report.commuteInMins == 16)
    #expect(report.trafficCondition == .Good)
  }
}
