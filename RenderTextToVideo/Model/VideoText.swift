//
//  VideoText.swift
//  RenderTextToVideo
//
//  Created by haerul.rijal on 07/06/23.
//

import CoreGraphics
import UIKit

enum GlobalColor {
    static func colors() -> [UIColor] {
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
    var initialSize: CGSize = .zero
    var position: CGPoint
    var size: CGSize
    
    init(id: String = UUID().uuidString, text: String, position: CGPoint, size: CGSize = .zero) {
        self.id = id
        self.text = text
        self.position = position
        self.size = size
    }
    
}
