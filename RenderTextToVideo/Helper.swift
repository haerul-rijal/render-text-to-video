//
//  Helper.swift
//  RenderTextToVideo
//
//  Created by haerul.rijal on 15/06/23.
//

import AVFoundation
import CoreGraphics
import UIKit

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


extension URL {
    /// Asynchronously generate a thumbnail image from the given video URL.
    /// - Parameters:
    ///   - isLastTimeFrame: If set to `true` will generate the thumbnail from the last frame of the video. Otherwise will generate the first frame.
    ///   - completion: A completion handler returning the generated thumbnail image and the duration of the video in seconds.
    internal func getVideoThumbnail(isLastTimeFrame: Bool = true, completion: @escaping (UIImage?, CGFloat) -> Void) {
        DispatchQueue.global().async {
            let asset = AVAsset(url: self)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            
            // Apply track transformation, otherwise it will end up rotated.
            imageGenerator.appliesPreferredTrackTransform = true
            
            let time: CMTime
            if isLastTimeFrame {
                // Get the last time frame. After experimenting, using a timescale of 2 works to get the last time frame.
                let lastFrameTime = CMTimeGetSeconds(asset.duration) * 60.0
                time = CMTimeMake(value: Int64(lastFrameTime), timescale: 2)
            } else {
                // Get the first time frame (1/60 seconds).
                time = CMTimeMake(value: 1, timescale: 60)
            }
            
            guard let thumbnailImage = try? imageGenerator.copyCGImage(at: time, actualTime: nil) else {
                DispatchQueue.main.async {
                    completion(nil, 0)
                }
                return
            }
            
            let image = UIImage(cgImage: thumbnailImage)
            
            DispatchQueue.main.async {
                completion(image, asset.duration.seconds)
            }
        }
    }
    
    internal var naturalSize: CGSize? {
        guard let track = AVURLAsset(url: self).tracks(withMediaType: .video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
    
    internal var duration: CGFloat {
        let asset = AVURLAsset(url: self)
        return asset.duration.seconds
    }
}


extension UILabel {
    
    /// creates an array containing one entry for each line of text the label has
    var lines: [String]? {
        
        guard let text = text, let font = font else { return nil }
        
        let attStr = NSMutableAttributedString(string: text)
        attStr.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: attStr.length))
        
        let frameSetter = CTFramesetterCreateWithAttributedString(attStr as CFAttributedString)
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.frame.width, height: .greatestFiniteMagnitude))
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attStr.length), path.cgPath, nil)
        guard let lines = CTFrameGetLines(frame) as? [Any] else { return nil }
        
        var linesArray: [String] = []
        
        for line in lines {
            let lineRef = line as! CTLine
            let lineRange = CTLineGetStringRange(lineRef)
            let range = NSRange(location: lineRange.location, length: lineRange.length)
            let lineString = (text as NSString).substring(with: range)
            linesArray.append(lineString)
        }
        return linesArray
    }
}


extension UIFont {
    public func sizeOfString (string: String, constrainedToWidth width: CGFloat) -> CGSize {
        let attributes = [NSAttributedString.Key.font:self]
        let attString = NSAttributedString(string: string,attributes: attributes)
        let framesetter = CTFramesetterCreateWithAttributedString(attString)
        return CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0,length: 0), nil, CGSize(width: width, height: .greatestFiniteMagnitude), nil)
    }
    
    static var defaultFont: UIFont {
        return UIFont.systemFont(ofSize: 11)
    }
}
