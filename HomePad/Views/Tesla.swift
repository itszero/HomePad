//
//  Tesla.swift
//  HomePad
//
//  Created by Zero Cho on 10/4/24.
//

import SwiftUI

struct Tesla: View {
  @Binding var teslaCar: TeslaCar
  
  var body: some View {
    HomePadModule(title: "Tesla") {
      VStack(spacing: 10) {
        HStack {
          Image(systemName: "car.fill")
            .font(.system(size: 36))

          HStack {
            if !teslaCar.locked {
              Image(systemName: "lock.open.trianglebadge.exclamationmark")
                .font(.system(size: 24))
            }
            
            if teslaCar.updateAvailable {
              Image(systemName: "arrow.clockwise.circle")
                .font(.system(size: 24))
            }
          }

          Spacer()
                    
          HStack {
            Image(systemName: teslaCar.batteryIcon())
            Text("\(teslaCar.battery) %")
              .foregroundStyle(teslaCar.batteryColor())
              .font(.system(size: 36))
              .fontWeight(.light)
          }
        }
        
        HStack {
          Image(systemName: "car.circle")
          Text("Odometer")
          
          Spacer()
          
          Text("\(teslaCar.odometerInMiles) mi")
        }
      }
    }
  }
}

struct TeslaPreview: View {
  @State var teslaCarHighBattery = TeslaCar(
    battery: 90,
    odometerInMiles: 30000,
    locked: true,
    updateAvailable: false
  )
  @State var teslaCarMedBattery = TeslaCar(
    battery: 50,
    odometerInMiles: 50000,
    locked: false,
    updateAvailable: true
  )
  @State var teslaCarLowBattery = TeslaCar(
    battery: 20,
    odometerInMiles: 70000,
    locked: false,
    updateAvailable: false
  )
  
  var body: some View {
    VStack(spacing: 50) {
      Tesla(teslaCar: $teslaCarHighBattery)
      Tesla(teslaCar: $teslaCarMedBattery)
      Tesla(teslaCar: $teslaCarLowBattery)
    }.preferredColorScheme(.dark)
  }
}

#Preview {
  TeslaPreview()
}
