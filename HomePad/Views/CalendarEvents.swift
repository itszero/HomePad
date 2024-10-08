//
//  CalendarEvents.swift
//  HomePad
//
//  Created by Zero Cho on 10/4/24.
//

import SwiftUI

func dateToString(_ date: Date) -> String {
  let dateFormatter = DateFormatter()
  dateFormatter.timeZone = TimeZone.current
  dateFormatter.locale = Locale(identifier: "en_US_POSIX")
  dateFormatter.dateFormat = "EEEE, hh:mm a"

  return dateFormatter.string(from: date)
}

struct CalendarEvents: View {
  @Binding var events: [CalboxEvent]
  
  var body: some View {
    HomePadModule(title: "Upcoming Events") {
      VStack(spacing: 10) {
        ForEach(events.filter({ e in e.time > Date.now }).prefix(5)) { event in
          HStack {
            Text(event.title)
              .lineLimit(1)
              .truncationMode(.tail)
            Spacer()
            Text(dateToString(event.time))
              .foregroundStyle(Color(UIColor(white: 0.7, alpha: 1.0)))
          }
        }
      }
    }
  }
}

struct CalendarEventsPreview: View {
  @State var events = [
    CalboxEvent(title: "Dinner Plan", time: Date.now.advanced(by: 60 * 60)),
    CalboxEvent(title: "VC Funding", time: Date.now.advanced(by: 90 * 60)),
    CalboxEvent(title: "Mobile Sync", time: Date.now.advanced(by: 120 * 60)),
    CalboxEvent(title: "Airplane Flying", time: Date.now.advanced(by: 180 * 60)),
    CalboxEvent(title: "Eating Eating Eating Eating Eating", time: Date.now.advanced(by: 86400)),
  ]
  
  var body: some View {
    CalendarEvents(events: $events)
      .preferredColorScheme(.dark)
  }
}

#Preview {
  CalendarEventsPreview()
}
