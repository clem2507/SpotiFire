//
//  ToolsManager.swift
//  SpotiFire
//
//  Created by Clement Detry on 19/09/2022.
//

import Foundation
import UIKit

final class ToolsManager {
    static let shared = ToolsManager()
    
    private init() {}
    
    public func slider(
        frame: CGRect,
        text: String,
        minimumValue: Float,
        maximumValue: Float,
        defaultValue: Float) -> (UILabel, UISlider)
    {
        let label = UILabel(frame: frame)
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = text
        let slider = UISlider(frame: CGRect(x: 10, y: frame.origin.y+45, width: 250, height: 80))
        slider.minimumValue = minimumValue
        slider.maximumValue = maximumValue
        slider.value = defaultValue
        slider.isContinuous = true
        slider.tintColor = UIColor.systemBlue
        return (label, slider)
    }
}
