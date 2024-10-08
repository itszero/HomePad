//
//  Clock.swift
//  HomePad
//
//  Created by Zero Cho on 10/3/24.
//

import SwiftUI

struct Clock: View {
  var label: String? = nil
  var timeZone: TimeZone = .current

  @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  @State var components: DateComponents
  var dateFormatter = DateFormatter()
  
  init(label: String? = nil, timeZone: TimeZone) {
    self.label = label
    self.timeZone = timeZone
    self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    dateFormatter.timeZone = timeZone
    self.components = DateComponents(calendar: Calendar.current, year: 0, month: 0, day:0, hour: 0, minute: 0, second: 0)
    dateFormatter.timeStyle = .none
    dateFormatter.dateStyle = .full
  }
    
  var body: some View {
    HomePadModule(title: label ?? timeZone.localizedName(for: .generic, locale: .current) ?? "Clock") {
      VStack(alignment: .leading) {
        Text(dateFormatter.string(from: components.date!))
          .foregroundStyle(Color(UIColor(white: 0.7, alpha: 1.0)))
        HStack {
          Text("\(String(format: "%02d", components.hour! % 12)):\(String(format: "%02d", components.minute!))")
            .font(.system(size: 48.0))
            .fontWeight(.light)
          Text("\(String(format: "%02d", components.second!))")
            .font(.system(size: 24.0))
            .foregroundStyle(Color(UIColor(white: 0.7, alpha: 1.0)))
            .fontWeight(.light)
          Text(components.hour! < 12 ? "AM" : "PM")
            .font(.system(size: 24.0))
            .fontWeight(.light)
        }
      }.frame(width: 400, alignment: .leading)
    }
    .onReceive(timer) { _ in
      var time = Calendar.current
      time.timeZone = self.timeZone
      components = time
        .dateComponents(
          [.calendar, .timeZone, .year, .month, .day, .hour, .minute, .second],
          from: Date.now
        )
    }
  }
}

#Preview {
  VStack {
    Clock(label: "Taipei", timeZone: .init(identifier: "Asia/Taipei")!)
      .preferredColorScheme(.dark)
    
    Spacer().frame(height: 100)
    
    Clock(label: "San Mateo", timeZone: .init(identifier: "America/Los_Angeles")!)
      .preferredColorScheme(.dark)
  }.frame(width: 400)
}
