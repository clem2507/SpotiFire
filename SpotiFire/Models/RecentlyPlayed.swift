//
//  RecentlyPlayed.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 01/09/2022.
//

import Foundation

struct RecentlyPlayedResponse: Codable {
    let items: [RecentTrackResponse]
}

struct RecentTrackResponse: Codable {
    let track: RecentTrack
}

struct RecentTrack: Codable {
    let external_urls: [String: String]
    let id: String
    let name: String
    let artists: [RecentTrackArtist]
    let album: RecentTrackAlbum
}

struct RecentTrackAlbum: Codable {
    let id: String
    let images: [APIImage]
    let name: String
}

struct RecentTrackArtist: Codable {
    let id: String
    let name: String
    let type: String
    let external_urls: [String: String]
}

