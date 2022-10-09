//
//  RecommendedTrack.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 03/09/2022.
//

import Foundation

struct RecommendedTracksResponse: Codable {
    let tracks: [RecommendedTrack]
}

struct RecommendedTrack: Codable {
    let external_urls: [String: String]?
    let id: String?
    let name: String?
    let artists: [RecommendedTrackArtist]?
    let album: RecommendedTrackAlbum?
}

struct RecommendedTrackAlbum: Codable {
    let album_type: String?
    let id: String?
    let images: [APIImage]?
    let name: String?
}

struct RecommendedTrackArtist: Codable {
    let id: String?
    let name: String?
    let type: String?
    let external_urls: [String: String]?
}

