//
//  PortfolioStartView.swift
//  Socialmedia
//
//  Created by mathangy on 18/03/24.
//

import SwiftUI
import Lottie

struct PortfolioStartView: View {
    var body: some View {
        VStack {
            LottieView(name: "portfolio.json")
            Text("Be the one among the million,\n make your voice be heard")
           
        }
    }
}

#Preview {
    PortfolioStartView()
}
