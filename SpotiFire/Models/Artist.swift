//
//  Artist.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 25/08/2022.
//

import Foundation

struct UserArtistsResponse: Codable {
    let items: [Artist]
}

struct Artist: Codable {
    let id: String
    let name: String
    let type: String
    let external_urls: [String: String]
    let images: [APIImage]
}
