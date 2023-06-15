//
//  VideoText.swift
//  RenderTextToVideo
//
//  Created by haerul.rijal on 07/06/23.
//

import CoreGraphics
import UIKit

enum GlobalColor {
    static var colors: [UIColor] {
        return [
            .systemGreen,
            .systemPink,
            .systemRed,
            .systemTeal,
            .systemBlue,
            .systemBrown,
            .systemGray
        ]
    }
}

struct VideoText: Equatable, Identifiable {
    var id: String
    
    var text: String
    var initialSize: CGSize
    var position: CGPoint
    var size: CGSize
    var angle: CGFloat
    var fontSize: CGFloat
    
    init(id: String = UUID().uuidString, text: String, initialSize: CGSize = .zero, position: CGPoint, size: CGSize = .zero, angle: CGFloat = 0, fontSize: CGFloat = 0) {
        self.id = id
        self.text = text
        self.position = position
        self.size = size
        self.angle = angle
        self.fontSize = fontSize
        self.initialSize = initialSize
    }
    
}
