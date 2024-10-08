//
//  MainView.swift
//  HomePad
//
//  Created by Zero Cho on 10/3/24.
//

import SwiftUI
import VLCUI

struct VLCLogger: VLCVideoPlayerLogger {
  func vlcVideoPlayer(didLog message: String, at level: VLCVideoPlayer.LoggingLevel) {
    print("VLC: \(message)")
  }
}

struct MainView: View {
  @ObservedObject private var viewModel: MainViewModel
  var inPreviewMode: Bool = false
  
  let screenWidth = UIScreen.main.bounds.width
  let screenHeight = UIScreen.main.bounds.height
  
  init(inPreviewMode: Bool) {
    self.viewModel = MainViewModel(useMockData: inPreviewMode)
    self.inPreviewMode = inPreviewMode
  }

  var body: some View {
    ZStack(alignment: .top) {
      Color.black
        .frame(width: screenWidth, height: screenHeight, alignment: .topLeading)
      
      // Don't play video while in preview mode
      if self.inPreviewMode {
        Color.white
          .aspectRatio(1.78, contentMode: .fit)
          .frame(width: screenWidth, height: screenHeight, alignment: .topLeading)
      } else {
        VLCVideoPlayer(configuration: viewModel.vidoePlayerConfiguration)
          .proxy(viewModel.proxy)
          .onTicksUpdated(viewModel.onTicksUpdated)
          .aspectRatio(1.78, contentMode: .fit)
          .frame(width: screenWidth, height: screenHeight, alignment: .topLeading)
      }

      Grid {
        GridRow(alignment: .top) {
          VStack(spacing: 20.0) {
            Clock(label: "San Mateo", timeZone: .init(identifier: "America/Los_Angeles")!)
            
            Weather(report: $viewModel.weatherReport)
            
            CalendarEvents(events: $viewModel.calendarEvents)
          }.frame(width: 400)
          
          Spacer()
          
          VStack(spacing: 20.0) {
            Clock(label: "Taipei", timeZone: .init(identifier: "Asia/Taipei")!)
            
            METAR(reports: $viewModel.metarReports)
            
            CommuteTime(reports: $viewModel.commuteReports)
            
            Spacer()
            
            Tesla(teslaCar: $viewModel.teslaCar)
          }.frame(width: 400)
        }
      }
      .padding(EdgeInsets(top: 40.0, leading: 30.0, bottom: 30.0, trailing: 30.0))
    }
    .padding([.top, .bottom], 50)
    .preferredColorScheme(.dark)
    .onAppear {
      UIApplication.shared.isIdleTimerDisabled = true
    }
  }
}

#Preview {
  MainView(inPreviewMode: true)
}
