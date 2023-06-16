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
    var position: CGPoint
    var angle: CGFloat
    var fontSize: CGFloat
    
    init(id: String = UUID().uuidString, text: String, position: CGPoint, angle: CGFloat = 0, fontSize: CGFloat = 0) {
        self.id = id
        self.text = text
        self.position = position
        self.angle = angle
        self.fontSize = fontSize
    }
    
}
