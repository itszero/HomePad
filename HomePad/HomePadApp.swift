//
//  HomePadApp.swift
//  HomePad
//
//  Created by Zero Cho on 10/3/24.
//

import SwiftUI

@main
struct HomePadApp: App {
  var body: some Scene {
    WindowGroup {
      MainView(inPreviewMode: false)
        .edgesIgnoringSafeArea(.all)
        .statusBar(hidden: true)
    }
  }
}
