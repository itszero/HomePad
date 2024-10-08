//
//  Config.swift
//  HomePad
//
//  Created by Zero Cho on 10/3/24.
//

struct Config {
  static let TOMORROW_IO_API_KEY = "<redacted>"
  static let AVRX_API_KEY = "<redacted>"
  static let GOOGLE_MAPS_API_KEY = "<redacted>"
  static let MQTT_SERVER = ("<redacted>", 1883)

  static let HOME_LOCATION = (<redacted>, <redacted>)
  static let HOME_LOCATION_STR = "<redacted>"

  static let METAR_AIRPORTS = ["KSFO"]

  static let COMMUTE_TIME_LOCATIONS = [
    CommuteLocation(label: "💼 Work", address: "<redacted>"),
  ]

  static let CAM_RTSP_URL = "<redacted>"

  static let CALENDAR_URL = "<redacted>"

  static let TESLAMATE_CAR_ID = <redacted>
}
