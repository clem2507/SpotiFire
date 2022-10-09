//
//  Track.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 25/08/2022.
//

import Foundation 

struct UserTracksResponse: Codable {
    let items: [Track]
}

struct Track: Codable {
    let external_urls: [String: String]
    let id: String
    let name: String
    let artists: [TrackArtist]
    let album: TrackAlbum
}

struct TrackAlbum: Codable {
    let album_type: String
    let id: String
    let images: [APIImage]
    let name: String
}

struct TrackArtist: Codable {
    let id: String
    let name: String
    let type: String
    let external_urls: [String: String]
}

