//
//  VideoTextLabel.swift
//  RenderTextToVideo
//
//  Created by haerul.rijal on 06/07/23.
//

import UIKit

final class VideoTextLabel: UILabel {
    
    var onTouchBegan: ((VideoTextLabel) -> Void)?
    var onTap: ((VideoTextLabel) -> Void)?
    
    init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = true
        numberOfLines = 0
        lineBreakMode = .byWordWrapping
        shadowColor = .black.withAlphaComponent(0.2)
        shadowOffset = .init(width: 0.0, height: 0.0)
        textAlignment = .center
        textColor = .white
        backgroundColor = .lightGray.withAlphaComponent(0.5)
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapped))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func tapped() {
        self.onTap?(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first != nil else { return }
        self.onTouchBegan?(self)
    }
    
}
