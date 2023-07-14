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
            .systemRed,
            .systemYellow,
            .systemBlue,
            .white
        ]
    }
}

struct VideoText: Equatable, Identifiable {
    var id: String
    
    var text: String
    var centerPosition: CGPoint
    var fontSize: CGFloat
    var textColor: UIColor
    var transform: CGAffineTransform
    
    init(
        id: String = UUID().uuidString,
        text: String,
        centerPosition: CGPoint,
        fontSize: CGFloat = 0,
        textColor: UIColor = .white,
        transform: CGAffineTransform = .identity
    ) {
        self.id = id
        self.text = text
        self.fontSize = fontSize
        self.transform = transform
        self.textColor = textColor
        self.centerPosition = centerPosition
    }
    
}

struct VideoTextState: Equatable {
    var texts: [String: VideoText] = [:]
    var videoSize: CGSize = .zero
    var displaySize: CGSize = .zero
    var initialFontSize: CGFloat = 18
    
}

struct VideoResultInfo: Equatable {
    var id: String = UUID().uuidString
    var videoSize: CGSize = .zero
    var fileSize: Int64 = 0
    var startDate: Date = .init()
    var endDate: Date = .init()
    var flattenedFileSize: Int64 = 0
    var duration: CGFloat = 0
    var outputVideoUrl: URL? = nil
    
    var flattenedTime: Int {
        endDate.seconds(from: startDate)
    }
}

extension Date {
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
}
