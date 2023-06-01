//
//  MainView.swift
//  PhotoOCR
//
//  Created by tunko on 2023/05/25.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView {
            WriteView()
        }
        .navigationViewStyle(.stack)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
