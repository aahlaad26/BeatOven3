//
//  PortfolioViewModel.swift
//  Socialmedia
//
//  Created by mathangy on 17/03/24.
//

import SwiftUI
import Firebase

class PortfolioViewModel: ObservableObject {
  @Published var portfolio: PortfolioData? = nil
  @Published var errorMessage: String? = nil

  let userID: String

  init(userID: String) {
    self.userID = userID
  }

  func fetchPortfolioData() {
    let db = Firestore.firestore()

    let documentReference = db.collection("portfolioData").document(userID)

    documentReference.getDocument { (document, error) in
      if let document = document, document.exists {
        do {
          let portfolioData = try Firestore.Decoder().decode(PortfolioData.self, from: document.data()!)
          self.portfolio = portfolioData
          self.errorMessage = nil
        } catch let error {
          print("Error decoding PortfolioData: \(error)")
          self.errorMessage = "Failed to decode portfolio data."
        }
      } else if let error = error {
        print("Error fetching document: \(error)")
        self.errorMessage = "Failed to fetch portfolio data."
      }
    }
  }
}
