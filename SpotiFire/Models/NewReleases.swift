//
//  NewReleases.swift
//  SpotiFire
//
//  Created by Clement Detry on 14/09/2022.
//

import Foundation

struct NewReleasesResponse: Codable {
    let albums: NewReleasesItems
}

struct NewReleasesItems: Codable {
    let items: [Album]
}
