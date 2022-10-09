//
//  UserProfile.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 26/08/2022.
//

import Foundation

struct UserProfile: Codable {
    let id: String
    let display_name: String
    let images: [APIImage]
}
