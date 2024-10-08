//
//  MainViewModel.swift
//  HomePad
//
//  Created by Zero Cho on 10/4/24.
//

import Combine
import VLCUI
import Foundation
import SwiftUICore

@MainActor
class MainViewModel: ObservableObject {
  var vidoePlayerConfiguration: VLCVideoPlayer.Configuration {
    let configuration = VLCVideoPlayer
      .Configuration(url: URL(string: Config.CAM_RTSP_URL)!)
    configuration.autoPlay = true

    return configuration
  }
  
  @Published var metarReports: [METARReport]
  @Published var weatherReport: WeatherReport
  @Published var commuteReports: [CommuteTimeReport]
  @Published var teslaCar: TeslaCar
  @Published var calendarEvents: [CalboxEvent]
  
  let proxy: VLCVideoPlayer.Proxy = .init()
  var vlcLastTick: Date?
  
  var cancellables = Set<AnyCancellable>()
  
  init(useMockData: Bool = false) {
    if (!useMockData) {
      // init fetch
      self.metarReports = []
      self.weatherReport = WeatherReport(
        iconName: "questionmark",
        temperature: 0,
        feelsLikeTemp: 0,
        windDirection: 0,
        windSpeedKts: 0
      )
      self.commuteReports = []
      self.calendarEvents = []
      self.teslaCar = TeslaCar(
        battery: 0,
        odometerInMiles: 0,
        locked: true,
        updateAvailable: false
      )
      
      TeslaMate.shared.setup()
      setupPeriodicFetches()
    } else {
      self.weatherReport = WeatherReport(iconName: "sun.max.fill", temperature: 32, feelsLikeTemp: 38, windDirection: 131, windSpeedKts: 3)
      self.metarReports = [
        METARReport(airport: "KPAO", wind: "30008KT", vis: "10SM", ceiling: "SKC", weatherType: .VFR),
        METARReport(airport: "KHWD", wind: "18010KT", vis: "05SM", ceiling: "SKC", weatherType: .MVFR),
        METARReport(airport: "KSFO", wind: "32004KT", vis: "03SM", ceiling: "OVC004", weatherType: .IFR),
        METARReport(airport: "KSQL", wind: "28004KT", vis: "10SM", ceiling: "OVC002", weatherType: .LIFR),
      ]
      self.commuteReports = [
        CommuteTimeReport(
          label: "💼 Work",
          commuteInMins: 5,
          trafficCondition: .Good
        ),
        CommuteTimeReport(
          label: "🛫 KSQL",
          commuteInMins: 10,
          trafficCondition: .Moderate
        ),
        CommuteTimeReport(
          label: "🛫 KPAO",
          commuteInMins: 20,
          trafficCondition: .Bad
        )
      ]
      self.calendarEvents = [
        CalboxEvent(title: "Event 1", time: Date.now.advanced(by: 60 * 60)),
        CalboxEvent(title: "Event 2", time: Date.now.advanced(by: 90 * 60)),
        CalboxEvent(title: "Event 3", time: Date.now.advanced(by: 28 * 60 * 60))
      ]
      self.teslaCar = TeslaCar(
        battery: 90,
        odometerInMiles: 50000,
        locked: true,
        updateAvailable: false
      )
    }
  }
  
  private func setupPeriodicFetches() {
    Timer.publish(every: 30 * 60, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        Task { [weak self] in
          await self?.fetchMetarReports()
          await self?.fetchCommuteReports()
          await self?.fetchWeatherReport()
        }
      }
      .store(in: &cancellables)
    
    Timer.publish(every: 300, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        Task { [weak self] in
          await self?.fetchTeslaData()
          await self?.fetchCalendarEvents()
        }
      }
      .store(in: &cancellables)
    
    Timer.publish(every: 300, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        self?.ensureVLCIsPlaying()
      }
      .store(in: &cancellables)

    Task {
      await self.fetchAllData()
    }
  }
  
  private func fetchAllData() async {
    await fetchMetarReports()
    await fetchCommuteReports()
    await fetchWeatherReport()
    await fetchTeslaData()
    await fetchCalendarEvents()
  }
  
  private func fetchMetarReports() async {
    print("METAR: Starting fetch")
    var reports : [METARReport] = []

    for airport in Config.METAR_AIRPORTS {
      if let report = try? await AVWX.fetch(airportCode: airport) {
        reports.append(report)
      } else {
        print("METAR: Failed to fetch report for \(airport)")
      }
    }
    
    print("METAR: Fetch done")
    self.metarReports = reports
  }
  
  private func fetchCommuteReports() async {
    print("Commute: Starting fetch")
    var reports : [CommuteTimeReport] = []
    
    for loc in Config.COMMUTE_TIME_LOCATIONS {
      if let report = try? await GoogleMapsCommute.fetch(
        label: loc.label,
        destination: loc.address
      ) {
        reports.append(report)
      } else {
        print("Commute: Failed to fetch report for \(loc)")
      }
    }
    
    print("Commute: Fetch done")
    self.commuteReports = reports
  }
  
  private func fetchWeatherReport() async {
    print("Weather: Starting fetch")
    if let report = try? await TomorrowIo.fetch() {
      self.weatherReport = report
    } else {
      print("Weather: Failed to fetch report")
    }
    print("Weather: Fetch done")
  }
  
  private func fetchTeslaData() async {
    print("Tesla: Starting fetch")
    if let report = try? await TeslaMate.shared.fetch() {
      self.teslaCar = report
    } else {
      print("Tesla: Failed to fetch report")
    }
    print("Tesla: Fetch done")
  }
  
  private func fetchCalendarEvents() async {
    print("Calbox: Starting fetch")
    if let events = try? await Calbox.fetch() {
      self.calendarEvents = events
    } else {
      print("Calbox: Failed to fetch report")
    }
    print("Calbox: Fetch done")
  }

  func onTicksUpdated(_ newTicks: Int, _ playbackInformation: VLCVideoPlayer.PlaybackInformation) {
    self.vlcLastTick = Date.now
  }

  func ensureVLCIsPlaying() {
    if let lastTick = self.vlcLastTick {
      if lastTick.timeIntervalSinceNow < -10 {
        print("VLC: force re-starting playback")
        self.proxy.stop()
        self.proxy.playNewMedia(self.vidoePlayerConfiguration)

        // Set the last tick to now so if it's still not playing, it'll get reset after another 10 sec
        self.vlcLastTick = Date.now
      }
    } else {
      self.vlcLastTick = Date.now
    }
  }
}
