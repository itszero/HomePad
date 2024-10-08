//
//  METAR.swift
//  HomePad
//
//  Created by Zero Cho on 10/4/24.
//

import SwiftUI

struct METAR: View {
  @Binding var reports: [METARReport]
  
  var body: some View {
    HomePadModule(title: "METAR") {
      Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 10) {
        ForEach(reports) { report in
          GridRow {
            Text(report.airport)
              .bold()
              .monospaced()
              .foregroundStyle(report.weatherType.color())
            Text(report.wind)
              .monospaced()
            Text(report.vis)
              .monospaced()
            Text(report.ceiling)
              .monospaced()
              .lineLimit(1)
          }
        }
      }
    }
  }
}

struct METARPreview : View {
  @State var data = [
    METARReport(airport: "KPAO", wind: "30008KT", vis: "10SM", ceiling: "SKC", weatherType: .VFR),
    METARReport(airport: "KHWD", wind: "18010KT", vis: "05SM", ceiling: "SKC", weatherType: .MVFR),
    METARReport(airport: "KSFO", wind: "32004KT", vis: "03SM", ceiling: "OVC004", weatherType: .IFR),
    METARReport(airport: "KSQL", wind: "28004G12KT", vis: "10SM", ceiling: "OVC002 FEW050 BRK150", weatherType: .LIFR),
  ]

  var body: some View {
    METAR(reports: $data)
      .frame(width: 400)
      .preferredColorScheme(.dark)
  }
}

#Preview {
  METARPreview()
}
