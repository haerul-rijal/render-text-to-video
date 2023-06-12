//
//  VideoTextPreviewNode.swift
//  RenderTextToVideo
//
//  Created by haerul.rijal on 07/06/23.
//

import AsyncDisplayKit

internal final class VideoTextPreviewNode: ASDisplayNode {
    
    internal var wrappedView: VideoTextPreview {
        guard let view = view as? VideoTextPreview else {
            fatalError("Expecting to convert \(type(of: view)) to \(VideoTextPreview.description()) but failed")
        }
        return view
    }
    
    internal override init() {
        super.init()
        setViewBlock { VideoTextPreview() }
    }
}
