//
//  SecondViewController.swift
//  RenderTextToVideo
//
//  Created by haerul.rijal on 05/07/23.
//

import UIKit
import AsyncDisplayKit
import TextureSwiftSupport

class SecondViewController: DisplayNodeViewController {
    
    private var url = ""
    
    
    let videoNode: ASVideoNode = {
        let videoNode = ASVideoNode()
        videoNode.shouldAutoplay = true
        videoNode.shouldAutorepeat = true
        videoNode.backgroundColor = .black
        videoNode.style.width = ASDimensionMake("100%")
        videoNode.style.height = ASDimensionMake("100%")
        return videoNode
    }()
    
    init(url: String) {
        super.init()
        self.url = url
        node.automaticallyManagesSubnodes = true
        node.automaticallyRelayoutOnSafeAreaChanges = true
        node.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Result"
        videoNode.assetURL = URL(string: self.url)
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            VStackLayout {
                videoNode
                    .flexGrow(1)
                    .flexShrink(1)
                .padding(8)
            }
            .padding(.top, self.node.safeAreaInsets.top)
            .padding(.bottom, self.node.safeAreaInsets.bottom)
        }
    }
}
