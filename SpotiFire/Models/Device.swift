//
//  Device.swift
//  SpotiFire
//
//  Created by Clement Detry on 07/09/2022.
//

import Foundation

struct UserDeviceResponse: Codable {
    let devices: [Device]
}

struct Device: Codable {
    let id: String
    let is_active: Bool
    let name: String
    let type: String
}
