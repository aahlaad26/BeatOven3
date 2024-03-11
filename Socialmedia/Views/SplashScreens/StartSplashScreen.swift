//
//  StartSplashView.swift
//  SplashScreen
//
//  Created by user2 on 01/02/24.
//

import SwiftUI

struct StartSplashView: View {
    @State private var showSplashScreen = true
    var body: some View {
        ZStack {
                    if showSplashScreen {
                        SplashScreenView()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        showSplashScreen = false
                                    }
                                }
                    }
            } else {
                NavigationView {
                    Screen1()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    StartSplashView()
}
