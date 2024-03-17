//
//  PortfolioData.swift
//  Socialmedia
//
//  Created by mathangy on 15/03/24.
//


import Foundation
import Firebase

struct PortfolioData: Codable, Identifiable {
    var id: String
    var userId: String
    var userName: String
    var name: String
    var cityCountry: String
    var instrument1: String
    var instrument2: String
    var instrument3: String
    var song1: String
    var song2: String
    var song3: String
    var aboutMe: String
    var metalink: String
    var instalink: String
    var ytlink: String
}
