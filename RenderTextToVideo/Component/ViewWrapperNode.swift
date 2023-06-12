//
//  ViewWrapperNode.swift
//  RenderTextToVideo
//
//  Created by haerul.rijal on 07/06/23.
//

import AsyncDisplayKit
import UIKit

/// ASDisplayNode Wrapper for initializing safety-node with a backing view.
public class ViewWrapperNode<View: UIView>: ASDisplayNode {
    ///  initializer with a block to create the backing view.
    /// - Parameters:
    ///   - createView: The block that will be used to create the backing view.
    ///   - didLoadBlock: The block that will be called after the view created by the viewBlock is loaded
    public convenience init(createView: @escaping () -> View, didLoadBlock: @escaping (ASDisplayNode) -> Void) {
        self.init(viewBlock: createView, didLoad: didLoadBlock)
    }
    
    public convenience init(createView: @escaping () -> View) {
        self.init(viewBlock: createView, didLoad: { _ in })
    }
    
    /// The View object that are wrapped by this node
    public var wrappedView: View {
        guard let view = self.view as? View else {
            fatalError("Expecting to convert \(type(of: self.view)) to \(View.description()) but failed")
        }
        
        return view
    }
}

