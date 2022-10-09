//
//  LikedTracks.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 01/09/2022.
//

import Foundation

struct LikedTracksResponse: Codable {
    let items: [LikedTrackResponse]
    let next: String?
}

struct LikedTrackResponse: Codable {
    let track: LikedTrack
}

struct LikedTrack: Codable {
    let external_urls: [String: String]?
    let id: String?
    let name: String?
    let artists: [LikedTrackArtist]?
    let album: LikedTrackAlbum?
}

struct LikedTrackAlbum: Codable {
    let id: String?
    let images: [APIImage]?
    let name: String?
}

struct LikedTrackArtist: Codable {
    let id: String?
    let name: String?
    let type: String?
    let external_urls: [String: String]?
}

