//
//  AlbumDetails.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 04/09/2022.
//

import Foundation

struct AlbumDetailsResponse: Codable {
    let album_type: String
    let artists: [AlbumArtist]
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]
    let label: String
    let name: String
    let tracks: TrackResponse
}

struct TrackResponse: Codable {
    let items: [AlbumTrack]
    let next: String?
}

struct AlbumTrack: Codable {
    let external_urls: [String: String]
    let id: String
    let name: String
    let artists: [TrackArtist]
}
