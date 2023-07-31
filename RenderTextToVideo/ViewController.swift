//
//  ViewController.swift
//  RenderTextToVideo
//
//  Created by haerul.rijal on 05/06/23.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport
import RxCocoa
import RxCocoa_Texture
import RxSwift
import PhotosUI

class ViewController: DisplayNodeViewController {
    
    let files = [
        ( "Landscape", "file:///Users/haerul.rijal/Library/Developer/CoreSimulator/Devices/35F26D74-9B1D-4549-9EE6-318138AE8DFC/data/Media/DCIM/100APPLE/IMG_0007.MP4"),
        ("Portrait", "file:///Users/haerul.rijal/Library/Developer/CoreSimulator/Devices/35F26D74-9B1D-4549-9EE6-318138AE8DFC/data/Media/DCIM/100APPLE/IMG_0008.MP4")
    ]
    
    var videoURLs: [URL] = []
    
    
    var videoSize: CGSize = CGSize(width: 768, height: 1024)
    {
        didSet {
            let size = videoSize.sizeThatFits(in: videoNode.bounds.size)
            self.textNode.style.preferredSize = CGSize(width: ceil(size.width), height: ceil(size.height))
            self.textNode.wrappedView.videoTextState.videoSize = videoSize
            self.textNode.setNeedsLayout()
            self.node.setNeedsLayout()
        }
    }
    
    let videoNode: ASVideoNode = {
        let videoNode = ASVideoNode()
        videoNode.shouldAutoplay = true
        videoNode.shouldAutorepeat = true
        videoNode.backgroundColor = .black
        return videoNode
    }()
    
    let addButtonNode: ASButtonNode = {
        let node = ASButtonNode()
        node.style.height = ASDimensionMake(32)
        node.backgroundColor = .systemGreen
        node.setTitle("➕ Add Text", with: .defaultFont, with: .white, for: .normal)
        return node
    }()
    
    let benchMarkButtonNode: ASButtonNode = {
        let node = ASButtonNode()
        node.style.height = ASDimensionMake(32)
        node.backgroundColor = .systemGreen
        node.setTitle("📝 Benchmark", with: .defaultFont, with: .white, for: .normal)
        return node
    }()
    
    let browseVideoButtonNode: ASButtonNode = {
        let node = ASButtonNode()
        node.style.height = ASDimensionMake(32)
        node.backgroundColor = .systemGreen
        node.setTitle("📂 Open Video", with: .defaultFont, with: .white, for: .normal)
        return node
    }()
    
    let mockTextButtonNode: ASButtonNode = {
        let node = ASButtonNode()
        node.style.height = ASDimensionMake(32)
        node.backgroundColor = .systemGreen
        node.setTitle("📦 Load Mock State", with: .defaultFont, with: .white, for: .normal)
        return node
    }()
    
    let saveButtonNode: ASButtonNode = {
        let node = ASButtonNode()
        node.style.height = ASDimensionMake(32)
        node.backgroundColor = .systemGreen
        node.setTitle("💾 Save Video", with: .defaultFont, with: .white, for: .normal)
        return node
    }()
    
    let clearButtonNode: ASButtonNode = {
        let node = ASButtonNode()
        node.style.height = ASDimensionMake(32)
        node.backgroundColor = .systemRed
        node.setTitle("🔄 Clear All Text", with: .defaultFont, with: .white, for: .normal)
        return node
    }()
    
    let textNode: VideoTextPreviewNode = {
        let node = VideoTextPreviewNode(state: .init())
        node.style.height = ASDimensionMake("100%")
        node.style.flexGrow = 1
        node.style.flexShrink = 1
        return node
    }()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Add Text To Video"
        navigationItem.title = title
//        node.backgroundColor = .white
        //videoNode.style.preferredSize = videoSize.sizeThatFits(in: node.bounds.size)
        setupHandler()
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(didPannn))
        videoNode.view.addGestureRecognizer(gesture)
    }
    
    @objc func didPannn() {
        print("...")
    }
    
    private func setupHandler() {
        addButtonNode.rx.tap
            .asDriver()
            .drive { [weak self] _ in
                guard let self else { return }
                self.textNode.wrappedView.addNewText()
            }
            .disposed(by: self.disposeBag)
        
        clearButtonNode.rx.tap
            .asDriver()
            .drive { [weak self] _ in
                guard let self else { return }
                self.textNode.wrappedView.clearAllText()
            }
            .disposed(by: self.disposeBag)
        
        browseVideoButtonNode.rx.tap
            .asDriver()
            .drive { [weak self] _ in
                guard let self else { return }
                //self.showImageActionSheet()
                self.presentImagePicker()
                //self.loadMultipleVideos()
            }
            .disposed(by: self.disposeBag)
        
        benchMarkButtonNode.rx.tap
            .asDriver()
            .drive { [weak self] _ in
                guard let self else { return }
                self.openBenchmark()
            }
            .disposed(by: self.disposeBag)
        
        mockTextButtonNode.rx.tap
            .asDriver()
            .drive { [weak self] _ in
                guard let self, self.videoNode.asset != nil else { return }
                self.textNode.wrappedView.loadMockData(.mockState)
            }
            .disposed(by: self.disposeBag)
        
        saveButtonNode.rx.tap
            .asDriver()
            .drive { [weak self] _ in
                guard let self, let assetUrl = self.videoNode.assetURL else { return }
                /*
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                print(documentsDirectory)

                let size = textNode.bounds.size
                let canvasSize = CGSize(width: ceil(size.width), height: ceil(size.height))
                let scale = videoSize.width / canvasSize.width

                let format = UIGraphicsImageRendererFormat.preferred()
                format.scale = scale
                let renderer = UIGraphicsImageRenderer(size: canvasSize, format: format)

                let image = renderer.image { context in
                    self.textNode.wrappedView.layer.render(in: context.cgContext)
                }

                self.saveImageToDocumentDirectory(image: image)

                VideoRenderer.videoOutput(videoAsset: asset, image: image, size: videoSize) { url in
                    print("videoUrl: ", url.absoluteString)
                    let vc = SecondViewController(url: url.absoluteString)
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    self.saveVideo(url: url)

                }
                */
                
                VideoRenderer.videoOutput(url: assetUrl, videoTextState: self.textNode.wrappedView.videoTextState) { data in
                    let url = data.outputVideoUrl!
                    print("videoUrl: ", url)
                    let vc = SecondViewController(url: url.absoluteString)
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    self.saveVideo(url: url)
                }
            }
            .disposed(by: self.disposeBag)
    }
    
    func saveImageToDocumentDirectory(image: UIImage) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "result.png"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            if FileManager.default.isDeletableFile(atPath: fileURL.path) {
                do {
                    try FileManager.default.removeItem(atPath: fileURL.path)
                } catch {
                    print("error saving file:", error)
                    return
                }
            }
        }
        if let data = image.pngData(),!FileManager.default.fileExists(atPath: fileURL.path){
            do {
                try data.write(to: fileURL)
                print("file saved")
                print(fileURL)
            } catch {
                print("error saving file:", error)
            }
        }
    }
    
    func saveVideo(url: URL) {
        DispatchQueue.main.async {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }) { saved, error in
                if saved {
                    print("Saved to library")
                    //let fetchOptions = PHFetchOptions()
                    //fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    
                    //let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).firstObject
                    // fetchResult is your latest video PHAsset
                    // To fetch latest image  replace .video with .image
                } else {
                    let message = error?.localizedDescription ?? "Not saved"
                    print(message)
                }
            }
        }
    }
    
    private func loadVideo(_ fileUrl: String) {
        guard
            let videoURL = URL(string: fileUrl),
            let naturalSize = videoURL.naturalSize
        else { return }
        videoNode.assetURL = videoURL
        videoSize = naturalSize
        //node.setNeedsLayout()
//        let aSize = CGSize(width: node.bounds.width, height: CGFloat.infinity)
//        let scale = node.bounds.width / videoSize.width
        
    }
    
    private func openBenchmark() {
        let vc = BenchmarkLogVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .savedPhotosAlbum
        //picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum)!
        picker.mediaTypes = ["public.movie"]
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }
    
    private func showImageActionSheet() {
        // create an actionSheet
        let actionSheetController: UIAlertController = UIAlertController(title: "Select Video", message: nil, preferredStyle: .actionSheet)
        
        files.forEach { video in
            let action: UIAlertAction = UIAlertAction(title: video.0, style: .default) { action -> Void in
                self.loadVideo(video.1)
            }
            actionSheetController.addAction(action)
        }

        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        actionSheetController.addAction(cancelAction)
        actionSheetController.popoverPresentationController?.sourceView = node.view
        
        present(actionSheetController, animated: true, completion: nil)
    }
    
    override init() {
        super.init()
        node.automaticallyManagesSubnodes = true
        node.automaticallyRelayoutOnSafeAreaChanges = true
        textNode.wrappedView.backgroundColor = .clear
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            VStackLayout {
                ZStackLayout {
                    CenterLayout {
                        videoNode
                    }
                    CenterLayout {
                        textNode
                    }
                }
                .flexGrow(1)
                .flexShrink(1)
                
                HStackLayout(spacing: 8) {
                    addButtonNode
                        .flexGrow(1)
                    browseVideoButtonNode
                        .flexGrow(1)
                    mockTextButtonNode
                        .flexGrow(1)
                }
                .padding(.vertical, 8)
                
                HStackLayout(spacing: 8) {
                    benchMarkButtonNode
                        .flexGrow(1)
                    saveButtonNode
                        .flexGrow(1)
                    clearButtonNode
                        .flexGrow(1)
                }
                .padding(.bottom, 8)
            }
            .padding(.top, self.node.safeAreaInsets.top)
            .padding(.bottom, self.node.safeAreaInsets.bottom)
        }
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info)
        if let videoUrl = info[.mediaURL] as? URL {
            self.loadVideo(videoUrl.absoluteString)
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
