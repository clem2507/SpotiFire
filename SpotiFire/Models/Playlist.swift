//
//  Playlist.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 25/08/2022.
//

import Foundation

struct UserPlaylistsResponse: Codable {
    let items: [Playlist]
}

struct Playlist: Codable {
    let description: String
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]
    let name: String
    let owner: User
}

struct User: Codable {
    let display_name: String
    let external_urls: [String: String]
    let id: String
}
