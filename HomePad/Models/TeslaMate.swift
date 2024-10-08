//
//  TeslaHome.swift
//  HomePad
//
//  Created by Zero Cho on 10/4/24.
//

import SwiftUICore
import MQTTNIO
import Combine

struct TeslaCar {
  var battery: Int
  var odometerInMiles: Int
  var locked: Bool
  var updateAvailable: Bool
  
  func batteryIcon() -> String {
    if battery > 88 {
      "battery.100percent"
    } else if battery > 63 {
      "battery.75percent"
    } else if battery > 38 {
      "battery.50percent"
    } else if battery > 13 {
      "battery.25percent"
    } else {
      "battery.0percent"
    }
  }
  
  func batteryColor() -> Color {
    if battery > 50 {
      Color.green
    } else if battery > 30 {
      Color.yellow
    } else {
      Color.red
    }
  }
}

class TeslaMate {
  static var shared = TeslaMate()

  var mqttClient : MQTTClient = MQTTClient(
    configuration: MQTTConfiguration(
      target: .host(Config.MQTT_SERVER.0, port: Config.MQTT_SERVER.1)
    ),
    eventLoopGroup: .singletonNIOTSEventLoopGroup
  )
  var cancellables = Set<AnyCancellable>()
  var report = TeslaCar(
    battery: 0,
    odometerInMiles: 0,
    locked: false,
    updateAvailable: false
  )

  public func setup() {
    print("Tesla: setup")
    Task { [weak self] in
      print("Tesla: in task")
      if let self = self {
        print("Tesla: connect")
        if ((try? await self.mqttClient.connect()) != nil) {
          print("Tesla: connect ok")
          self.mqttClient.messagePublisher
            .sink { message in
              switch message.topic {
              case "teslamate/cars/\(Config.TESLAMATE_CAR_ID)/battery_level":
                self.report.battery = Int(message.payload.string!)!
              case "teslamate/cars/\(Config.TESLAMATE_CAR_ID)/locked":
                self.report.locked = message.payload.string!.lowercased() == "true"
              case "teslamate/cars/\(Config.TESLAMATE_CAR_ID)/odometer":
                let odometer = Double(message.payload.string!)!
                self.report.odometerInMiles = Int(odometer * 0.6214 /* km to mi */)
              case "teslamate/cars/\(Config.TESLAMATE_CAR_ID)/update_available":
                let updateAvailable = message.payload.string!.lowercased() == "true"
                self.report.updateAvailable = updateAvailable
              default:
                print("Tesla: unknown topic \(message.topic)")
              }
              print("Tesla: \(message.topic) \(self.report)")
            }
            .store(in: &self.cancellables)
          print("Tesla: subscribe")
          if (try? await self.mqttClient.subscribe(to: [
            "teslamate/cars/\(Config.TESLAMATE_CAR_ID)/battery_level",
            "teslamate/cars/\(Config.TESLAMATE_CAR_ID)/locked",
            "teslamate/cars/\(Config.TESLAMATE_CAR_ID)/odometer",
            "teslamate/cars/\(Config.TESLAMATE_CAR_ID)/update_available",
          ])) == nil {
            print("Tesla: Failed to subscribe to MQTT topics.")
          }
        }
      }
    }
  }
  
  public func fetch() async throws -> TeslaCar {
    return report
  }
}
