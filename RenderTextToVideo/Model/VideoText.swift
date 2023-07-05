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
    var centerPosition: CGPoint
    var fontSize: CGFloat
    var transform: CGAffineTransform
    
    init(
        id: String = UUID().uuidString,
        text: String,
        centerPosition: CGPoint,
        fontSize: CGFloat = 0,
        transform: CGAffineTransform = .identity
    ) {
        self.id = id
        self.text = text
        self.fontSize = fontSize
        self.transform = transform
        self.centerPosition = centerPosition
    }
    
}

struct VideoTextState: Equatable {
    var texts: [String: VideoText] = [:]
    var videoSize: CGSize = CGSize(width: 1024, height: 768)
    var initialFontSize: CGFloat = 18
    
}
