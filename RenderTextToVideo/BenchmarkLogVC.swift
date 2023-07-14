//
//  BenchmarkLogVC.swift
//  RenderTextToVideo
//
//  Created by haerul.rijal on 12/07/23.
//

import AsyncDisplayKit
import TextureSwiftSupport
import RxSwift
import RxCocoa
import PhotosUI
import Photos
import MBProgressHUD

class BenchmarkLogVC: DisplayNodeViewController {
    
    private let disposeBag = DisposeBag()
    private var selectedVideoCount = 0
    private var benchmarks: [VideoResultInfo] = []
    private let benchmarkCount = PublishSubject<Int>()
    
    private var startDate: Date = .init()
    private var endDate: Date = .init()
    
    internal var benchmarkCountDriver: Driver<Int> {
        benchmarkCount.asDriver(onErrorJustReturn: 0)
    }
    
    let benchMarkButtonNode: ASButtonNode = {
        let node = ASButtonNode()
        node.style.height = ASDimensionMake(32)
        node.backgroundColor = .systemGreen
        node.setTitle("📂 Open videos for Benchmark", with: .defaultFont, with: .white, for: .normal)
        return node
    }()
    
    let copyButton: ASButtonNode = {
        let node = ASButtonNode()
        node.style.height = ASDimensionMake(32)
        node.backgroundColor = .systemGreen
        node.setTitle("📋 Copy", with: .defaultFont, with: .white, for: .normal)
        return node
    }()
    
    private lazy var toggleParallelProcess: ViewWrapperNode<UISwitch> = {
        let wrapper = ViewWrapperNode<UISwitch> { () -> UISwitch in
            let toggleSwitch = UISwitch()
            toggleSwitch.isOn = false
            return toggleSwitch
        }
        wrapper.style.width = ASDimensionMake(64)
        wrapper.style.height = ASDimensionMake(40)
        return wrapper
    }()
    
    private let textNode: ASTextNode2 = {
        let textNode = ASTextNode2()
        textNode.style.flexGrow = 1
        textNode.style.flexShrink = 1
        textNode.style.height = ASDimensionMake(32)
        textNode.style.width = ASDimensionMake("100%")
        textNode.attributedText = NSAttributedString(string: "Parallel Processing")
        return textNode
    }()
    
    private let logViewNode: ASEditableTextNode = {
        let textNode = ASEditableTextNode()
        textNode.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textNode.style.width = ASDimensionMake("100%")
        textNode.style.height = ASDimensionMake("100%")
        textNode.style.flexGrow = 1
        textNode.style.flexShrink = 1
        return textNode
    }()
    
    override init() {
        super.init()
        
        node.automaticallyManagesSubnodes = true
        node.automaticallyRelayoutOnSafeAreaChanges = true
        node.backgroundColor = .white
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Benchmark for Video Flattening"
        navigationItem.title = title
        
        benchmarkCountDriver
            .filter({ [weak self] value in
                return value == (self?.selectedVideoCount ?? 0)
            })
        .drive { [weak self] _ in
            guard let self else { return }
            if self.toggleParallelProcess.wrappedView.isOn {
                let totalFlattenedTime = self.endDate.seconds(from: self.startDate)
                var textResult = self.logViewNode.attributedText?.string ?? ""
                textResult += "\(textResult)\n\n Total Time = \(totalFlattenedTime) seconds"
                self.logViewNode.attributedText = NSAttributedString(string: textResult)
            }
            
            MBProgressHUD.hide(for: self.node.view, animated: true)
            
        }
        .disposed(by: self.disposeBag)
        
        logViewNode.borderColor = UIColor.darkGray.cgColor
        logViewNode.borderWidth = 1
        
        benchMarkButtonNode.rx.tap
            .asDriver()
            .drive { [weak self] _ in
                guard let self else { return }
                self.loadMultipleVideos()
            }
            .disposed(by: self.disposeBag)
        
        copyButton.rx.tap
            .asDriver()
            .drive { [weak self] _ in
                guard let self, let text = self.logViewNode.attributedText?.string, !text.isEmpty else { return }
                let pasteboard = UIPasteboard.general
                pasteboard.string = text
            }
            .disposed(by: self.disposeBag)
        
        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            VStackLayout(spacing: 8) {
                HStackLayout(spacing: 8) {
                    benchMarkButtonNode
                        .flexGrow(1)
                    copyButton
                        .flexGrow(1)
                }
                HStackLayout(spacing: 8) {
                    textNode
                    toggleParallelProcess
                }
                logViewNode
            }
            .padding(.horizontal, 16)
            .padding(.top, self.node.safeAreaInsets.top)
            .padding(.bottom, 16 + self.node.safeAreaInsets.bottom)
        }
    }
    
    
    private func loadMultipleVideos() {
        if #available(iOS 14.0, *) {
            var config = PHPickerConfiguration()
            config.selectionLimit = 0
            config.filter = PHPickerFilter.videos
            let pickerVC = PHPickerViewController(configuration: config)
            pickerVC.delegate = self
            present(pickerVC, animated: true)
        }
    }
}


extension BenchmarkLogVC: PHPickerViewControllerDelegate {
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        self.benchmarks.removeAll()
        self.selectedVideoCount = results.count
        dismiss(animated: true)
        if selectedVideoCount > 0 {
            MBProgressHUD.showAdded(to: self.node.view, animated: true)
        }
        var logText = ""
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        let dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let frameSize = self.node.frame.size
        let isParallelProcessing = self.toggleParallelProcess.wrappedView.isOn
        self.startDate = Date()
        DispatchQueue.global(qos: .userInitiated).async {
            for result in results {
                
                if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] videoFile, error in
                        if let videoUrl = videoFile, let naturalSize = videoUrl.naturalSize {
                            var videoTextState = VideoTextState.mockState
                            videoTextState.videoSize = naturalSize
                            videoTextState.displaySize = naturalSize.sizeThatFits(in: frameSize)
                            let semaphore = DispatchSemaphore(value: 0)
                            VideoRenderer.videoOutput(url: videoUrl, videoTextState: videoTextState) { benchmarkData in
                                
                                let duration = ceil(benchmarkData.duration)
                                let seconds: Int = Int(duration) % 60
                                let minutes: Int = Int(duration) / 60
                                let durationString = String(format: "%02d:%02d", minutes, seconds)
                                
                                logText +=
                                """
                                Video Resolution: \(Int(benchmarkData.videoSize.width))x\(Int(benchmarkData.videoSize.height))
                                Video Duration: \(benchmarkData.duration) -> \(durationString)
                                File Size: \(benchmarkData.fileSize) -> \(formatter.string(fromByteCount: benchmarkData.fileSize))
                                Process Duration: \(benchmarkData.flattenedTime) (s)
                                File Size After Flatten: \(benchmarkData.flattenedFileSize) -> \(formatter.string(fromByteCount: benchmarkData.flattenedFileSize))
                                \n
                                """
                                DispatchQueue.main.async {
                                    self?.endDate = Date()
                                    if !isParallelProcessing {
                                        defer { semaphore.signal() } /// Ensure `signal()` will always be called to prevent deadlocks.
                                    }
                                   
                                    self?.logViewNode.attributedText = NSAttributedString(string: logText)
                                    self?.benchmarks.append(benchmarkData)
                                    self?.benchmarkCount.onNext(self?.benchmarks.count ?? 0)
                                    PHPhotoLibrary.shared().performChanges({
                                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: benchmarkData.outputVideoUrl!)
                                    }) { saved, error in
                                        if saved {
                                            print("Saved to library")
                                        } else {
                                            let message = error?.localizedDescription ?? "Not saved"
                                            print(message)
                                        }
                                    }
                                }
                            }
                            if !isParallelProcessing {
                                semaphore.wait() // It's ok since we're in background thread (needed to maintain ordering).
                            }
                            
                        }
                    }
                }
                
            } // Global Dispatch
        }
        
        
        
        
    }
}
