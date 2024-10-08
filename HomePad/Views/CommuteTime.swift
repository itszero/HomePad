//
//  CommuteTime.swift
//  HomePad
//
//  Created by Zero Cho on 10/4/24.
//

import SwiftUI

struct CommuteTime: View {
  @Binding var reports: [CommuteTimeReport]
  
  var body: some View {
    HomePadModule(title: "Commute Time") {
      VStack(spacing: 10) {
        ForEach(reports) { report in
          HStack {
            Text(report.label)
              .bold()
            
            Spacer()
            
            Text("\(report.commuteInMins) min")
              .foregroundStyle(report.trafficCondition.color())
          }
        }
      }
    }
  }
}

struct CommuteTimePreview : View {
  @State var data = [
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
  
  var body: some View {
    CommuteTime(reports: $data)
      .frame(width: 400)
      .preferredColorScheme(.dark)
  }
}

#Preview {
  CommuteTimePreview()
}
