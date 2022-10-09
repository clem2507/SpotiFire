//
//  UserAlbums.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 26/08/2022.
//

import Foundation

struct UserAlbumsResponse: Codable {
    let items: [AlbumsResponse]
}

struct AlbumsResponse: Codable {
    let album: Album
}

struct Album: Codable {
    let album_type: String
    let id: String
    let images: [APIImage]
    let name: String
    let artists: [AlbumArtist]
}

struct AlbumArtist: Codable {
    let id: String
    let name: String
    let type: String
    let external_urls: [String: String]
}
