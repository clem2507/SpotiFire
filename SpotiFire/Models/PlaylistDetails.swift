//
//  PlaylistDetails.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 04/09/2022.
//

import Foundation

struct PlaylistDetailsResponse: Codable {
    let description: String
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]
    let name: String
    let tracks: PlaylistTracksResponse
}

struct PlaylistTracksResponse: Codable {
    let items: [PlaylistItem]
    let next: String?
}

struct PlaylistItem: Codable {
    let track: PlaylistTrack?
}

struct PlaylistTrack: Codable {
    let external_urls: [String: String]?
    let id: String?
    let name: String?
    let artists: [PlaylistTrackArtist]?
    let album: PlaylistTrackAlbum?
}

struct PlaylistTrackAlbum: Codable {
    let album_type: String?
    let id: String?
    let images: [APIImage]?
    let name: String?
}

struct PlaylistTrackArtist: Codable {
    let id: String?
    let name: String?
    let type: String?
    let external_urls: [String: String]?
}
