//
//  ContentView.swift
//  Shared
//
//  Created by anthony lim on 4/20/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HSplitView{
            Text("Hello, world!")
                .padding()
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
