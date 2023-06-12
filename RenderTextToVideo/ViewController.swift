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

class ViewController: DisplayNodeViewController {
    
    let addButtonNode: ASButtonNode = {
        let node = ASButtonNode()
        node.style.height = ASDimensionMake(32)
        node.backgroundColor = .systemGreen
        node.setTitle("➕ Add", with: nil, with: .white, for: .normal)
        return node
    }()
    
    let clearButtonNode: ASButtonNode = {
        let node = ASButtonNode()
        node.style.height = ASDimensionMake(32)
        node.backgroundColor = .systemRed
        node.setTitle("🔄 Clear", with: nil, with: .white, for: .normal)
        return node
    }()
    let textNode: VideoTextPreviewNode = {
        let node = VideoTextPreviewNode()
        node.style.height = ASDimensionMake("100%")
        node.style.flexGrow = 1
        node.style.flexShrink = 1
        return node
    }()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Add Text"
        setupHandler()
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
    }
    
    
    
    override init() {
        super.init()
        node.automaticallyManagesSubnodes = true
        node.automaticallyRelayoutOnSafeAreaChanges = true
        node.backgroundColor = .white
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            VStackLayout {
                textNode
                HStackLayout(spacing: 8) {
                    addButtonNode
                        .flexGrow(1)
                    clearButtonNode
                        .flexGrow(1)
                }
                .padding(8)
            }
            .padding(.top, self.node.safeAreaInsets.top)
            .padding(.bottom, self.node.safeAreaInsets.bottom)
        }
    }
    
}

