//
//  VideoRenderer.swift
//  RenderTextToVideo
//
//  Created by haerul.rijal on 19/06/23.
//

import UIKit
import AVFoundation
import Photos

internal enum VideoRenderer {
    
    
    
    internal static func videoOutput(videoAsset: AVAsset, image: UIImage, size: CGSize, completion: @escaping ((URL) -> Void)) {
        
        // Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        let mixComposition = AVMutableComposition()
        
        // Video track
        let videoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        do {
            try videoTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: AVMediaType.video)[0], at: CMTime.zero)
        } catch {
            print("Error selecting video track !!")
        }
        
        // Create AVMutableVideoCompositionInstruction
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRange(start: CMTime.zero, duration: videoAsset.duration)
        
        // Create an AvmutableVideoCompositionLayerInstruction for the video track and fix orientation
        
        let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: videoTrack!)
        let videoAssetTrack = videoAsset.tracks(withMediaType: AVMediaType.video)[0]
        
//        var videoAssetOrientation = UIImage.Orientation.up
//        var isVideoAssetPortrait = false
//        let videoTransform = videoAssetTrack.preferredTransform
//
//        if videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0 {
//            videoAssetOrientation = .right
//            isVideoAssetPortrait = true
//        }
//        if videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0 {
//            videoAssetOrientation = .left
//            isVideoAssetPortrait = true
//        }
//        if videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0 {
//            videoAssetOrientation = .up
//        }
//        if videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0 {
//            videoAssetOrientation = .down
//        }
        
        videoLayerInstruction.setTransform(videoAssetTrack.preferredTransform, at: CMTime.zero)
        videoLayerInstruction.setOpacity(0.0, at: videoAsset.duration)
        
        //Add instructions
        
        mainInstruction.layerInstructions = [videoLayerInstruction]
        let mainCompositionInst = AVMutableVideoComposition()
        let naturalSize = size
//        let naturalSize : CGSize!
//        if isVideoAssetPortrait {
//            naturalSize = CGSize(width: videoAssetTrack.naturalSize.height, height: videoAssetTrack.naturalSize.width)
//        } else {
//            naturalSize = videoAssetTrack.naturalSize
//        }
        
        let renderWidth = naturalSize.width
        let renderHeight = naturalSize.height
        
        mainCompositionInst.renderSize = CGSize(width: renderWidth, height: renderHeight)
        mainCompositionInst.instructions = [mainInstruction]
        mainCompositionInst.frameDuration = CMTime(value: 1, timescale: 30)
        
        applyVideoEffects(to: mainCompositionInst, size: naturalSize, image: image)
        
        
        // Get Path
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let outputPath = documentsURL?.appendingPathComponent("newVideoWithLabel.mp4")
        if FileManager.default.fileExists(atPath: (outputPath?.path)!) {
            do {
                try FileManager.default.removeItem(atPath: (outputPath?.path)!)
            }
            catch {
                print ("Error deleting file")
            }
        }
        // Create exporter
        
        let exporter = AVAssetExportSession.init(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputURL = outputPath
        exporter?.outputFileType = AVFileType.mov
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.videoComposition = mainCompositionInst
        exporter?.exportAsynchronously {
            print(outputPath)
            completion(outputPath!)
        }
    }
    
    internal static func videoOutput(url: URL, videoTextState: VideoTextState, completion: @escaping ((VideoResultInfo) -> Void)) {
        
        let videoAsset = AVAsset(url: url)
        let displaySize = videoTextState.displaySize
        let canvasSize = CGSize(width: ceil(displaySize.width), height: ceil(displaySize.height))
        let scale = videoTextState.videoSize.width / canvasSize.width
        // Create Image
        let format = UIGraphicsImageRendererFormat.preferred()
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: canvasSize, format: format)
        
        let image = renderer.image { context in
            let view = UIView()
            view.frame = CGRect(origin: .zero, size: displaySize)
            videoTextState.texts.forEach { (_, videoText) in
                let label = VideoTextLabel()
                view.addSubview(label)
                label.textColor = videoText.textColor
                label.font = UIFont.systemFont(ofSize: videoText.fontSize, weight: .bold)
                label.text = videoText.text
                
                let labelSize = CGSize(width: displaySize.width-32, height: .infinity)
                let estimatedLabelSize = label.sizeThatFits(labelSize)
                label.frame.size = estimatedLabelSize
                label.transform = videoText.transform
                label.center = videoText.centerPosition
            }
            view.layer.render(in: context.cgContext)
        }
        
        
        // Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        let mixComposition = AVMutableComposition()
        
        // Video track
        let videoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        do {
            try videoTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: AVMediaType.video)[0], at: CMTime.zero)
        } catch {
            print("Error selecting video track !!")
        }
        
        // Audio track
        let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        do {
            try audioTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: AVMediaType.audio)[0], at: CMTime.zero)
        } catch {
            print("Error selecting audio track !!")
        }
        
        
        // Create AVMutableVideoCompositionInstruction
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRange(start: CMTime.zero, duration: videoAsset.duration)
        
        // Create an AvmutableVideoCompositionLayerInstruction for the video track and fix orientation
        
        let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: videoTrack!)
        
        let videoAssetTrack = videoAsset.tracks(withMediaType: AVMediaType.video)[0]
//                var videoAssetOrientation = UIImage.Orientation.up
//                var isVideoAssetPortrait = false
//                let videoTransform = videoAssetTrack.preferredTransform
//        
//                if videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0 {
//                    videoAssetOrientation = .right
//                    isVideoAssetPortrait = true
//                }
//                if videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0 {
//                    videoAssetOrientation = .left
//                    isVideoAssetPortrait = true
//                }
//                if videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0 {
//                    videoAssetOrientation = .up
//                }
//                if videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0 {
//                    videoAssetOrientation = .down
//                }
        
        videoLayerInstruction.setTransform(videoAssetTrack.preferredTransform, at: CMTime.zero)
        videoLayerInstruction.setOpacity(0.0, at: videoAsset.duration)
        
        //Add instructions
        
        mainInstruction.layerInstructions = [videoLayerInstruction]
        let mainCompositionInst = AVMutableVideoComposition()
        let naturalSize = videoTextState.videoSize
        //        let naturalSize : CGSize!
        //        if isVideoAssetPortrait {
        //            naturalSize = CGSize(width: videoAssetTrack.naturalSize.height, height: videoAssetTrack.naturalSize.width)
        //        } else {
        //            naturalSize = videoAssetTrack.naturalSize
        //        }
        
        let renderWidth = naturalSize.width
        let renderHeight = naturalSize.height
        
        mainCompositionInst.renderSize = CGSize(width: renderWidth, height: renderHeight)
        mainCompositionInst.instructions = [mainInstruction]
        mainCompositionInst.frameDuration = CMTime(value: 1, timescale: 30)
        
        applyVideoEffects(to: mainCompositionInst, size: naturalSize, image: image)
        
        
        // Get Path
        
        var benchmarkData = VideoResultInfo(
            videoSize: naturalSize,
            fileSize: url.fileSize,
            startDate: Date(),
            duration: url.duration
        )
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let outputPath = documentsURL?.appendingPathComponent("\(benchmarkData.id)-result.mp4")
        if FileManager.default.fileExists(atPath: (outputPath?.path)!) {
            do {
                try FileManager.default.removeItem(atPath: (outputPath?.path)!)
            }
            catch {
                print ("Error deleting file")
            }
        }
        // Create exporter
        
        let exporter = AVAssetExportSession.init(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputURL = outputPath
        exporter?.outputFileType = AVFileType.mp4
        exporter?.shouldOptimizeForNetworkUse = false
        exporter?.videoComposition = mainCompositionInst
        exporter?.exportAsynchronously {
            print(outputPath)
            benchmarkData.outputVideoUrl = outputPath
            benchmarkData.flattenedFileSize = outputPath?.fileSize ?? 0
            benchmarkData.endDate = Date()
            completion(benchmarkData)
        }
    }
    
    private static func applyVideoEffects(to composition: AVMutableVideoComposition, size: CGSize, image: UIImage) {
        
        let overlayLayer = CALayer()
        
        overlayLayer.contents = image.cgImage
        overlayLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        overlayLayer.masksToBounds = true
        
        
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        videoLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(overlayLayer)
        // 3 - apply magic
        composition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
    }
    
//    internal static func exportDidFinish(session: AVAssetExportSession) {
//        if session.status == .completed {
//            let outputURL: URL? = session.outputURL
//            PHPhotoLibrary.shared().performChanges({
//                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL!)
//            }) { saved, error in
//                if saved {
//                    let fetchOptions = PHFetchOptions()
//                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
//                    let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
//                    PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
//                        let newObj = avurlAsset as! AVURLAsset
//                        print(newObj.url)
//                        DispatchQueue.main.async(execute: {
//                            print(newObj.url.absoluteString)
//                        })
//                    })
//                    print (fetchResult!)
//                }
//            }
//        }
//    }
}
