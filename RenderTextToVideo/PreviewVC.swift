//
//  PreviewVC.swift
//  RenderTextToVideo
//
//  Created by haerul.rijal on 07/06/23.
//

import SwiftUI

import AsyncDisplayKit
import TextureSwiftSupport


class TheNode: ASDisplayNode {
    
    private let containerNode: ASDisplayNode = {
        let node = ASDisplayNode()
        node.style.flexShrink = 1
        node.style.flexGrow = 1
        node.backgroundColor = .red
        return node
    }()
    
    //States
    var videoTexts: [VideoText] = []
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            CenterLayout {
                containerNode
            }
        }
    }
    
}


class PreviewVC: DisplayNodeViewController {
    
//    private let theNode = TheNode()
    private let theNode: TheNode = {
        let node = TheNode()
        node.style.flexShrink = 1
        node.style.flexGrow = 1
        return node
    }()
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        LayoutSpec {
            CenterLayout {
                theNode
            }
            
        }
    }
    
}

struct PreviewVC_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView()
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        typealias UIViewControllerType = PreviewVC
        
        func makeUIViewController(context: Context) -> PreviewVC {
            return PreviewVC()
        }
        
        func updateUIViewController(_ uiViewController: PreviewVC, context: Context) {
            
        }
        
    }
}
