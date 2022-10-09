//
//  PlaylistTrack.swift
//  SpotiFire
//
//  Created by Clement Detry on 19/09/2022.
//

import Foundation

struct PlaylistDetailTracksResponse: Codable {
    let items: [PlaylistItem]
    let next: String?
}
