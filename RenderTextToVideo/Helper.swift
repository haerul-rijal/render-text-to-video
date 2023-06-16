//
//  Helper.swift
//  RenderTextToVideo
//
//  Created by haerul.rijal on 15/06/23.
//

import AVFoundation
import CoreGraphics

extension CGSize {
    /// Normalize the `width` and `height` so that it doesn't exceed the `maxWidth` while maintaining the aspect ratio.
    internal static func normalizedSize(width: CGFloat, height: CGFloat, maxWidth: CGFloat) -> CGSize {
        let normalizedHeight: CGFloat
        
        // Prevents division by zero.
        if width > 0 {
            let calculatedHeight = height * (maxWidth / width)
            normalizedHeight = calculatedHeight > 0 ? calculatedHeight : maxWidth /// If calculated height is less than 0, we use the `maxWidth` instead.
        } else {
            normalizedHeight = maxWidth
        }
        
        return CGSize(width: maxWidth, height: normalizedHeight)
    }
    
    /** If `self` is `CGSize.zero`, `AVMakeRect` func returns `NaN` value,
     so we replace it using `CGRect.zero`  */
    
    internal func sizeThatFits(in size: CGSize) -> CGSize {
        guard self != .zero else { return .zero }
        return AVMakeRect(aspectRatio: self, insideRect: CGRect(origin: .zero, size: size)).size
    }
    
    internal func rectThatFits(in rect: CGRect) -> CGRect {
        guard self != .zero else { return .zero }
        return AVMakeRect(aspectRatio: self, insideRect: rect)
    }
    
    internal func cornerRadius(fraction: CGFloat) -> CGFloat {
        min(width, height) * fraction
    }
}
