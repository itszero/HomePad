//
//  HomePadModule.swift
//  HomePad
//
//  Created by Zero Cho on 10/3/24.
//

import SwiftUI

struct HomePadModule<ModuleView>: View where ModuleView : View {
  var title = "Module Title"
  @ViewBuilder var content: ModuleView
  
  var body: some View {
    VStack(alignment: .leading) {
      VStack(alignment: .leading) {
        Text(title)
          .font(.headline)
          .textCase(.uppercase)
          .kerning(5)
          .padding([.top, .leading, .trailing], 10)
        
        content
          .frame(width: 400, alignment: .leading)
          .padding(.all, 10)
      }
      .padding(.all, 10)
    }
    .background(.thinMaterial)
    .clipShape(.rect(cornerRadius: 10))
    .frame(width: 400)
  }
}

#Preview {
  HomePadModule() {
    Color.red.frame(width: 300, height: 50)
  }
  .preferredColorScheme(.dark)
  .frame(width: 400)
}
