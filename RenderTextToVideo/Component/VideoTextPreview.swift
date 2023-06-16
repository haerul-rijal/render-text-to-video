//
//  VideoTextPreview.swift
//  RenderTextToVideo
//
//  Created by haerul.rijal on 07/06/23.
//

import RxSwift
import UIKit


final class VideoTextLabel: UILabel {
    
    var onTouchBegan: ((UILabel) -> Void)?
    
    init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first != nil else { return }
        self.onTouchBegan?(self)
    }
}

final class VideoTextPreview: UIView {
    
    private var mockData: [VideoText]  {
        let videoTexts = [
            VideoText(text: "Hello World", position: .init(x: 195.1666717529297, y: 280.50000254313153), angle: 0.8337175272646314, fontSize: 89.39357687222396),
            VideoText(text: "Hello World", position: .init(x: 199.8333511352539, y: 274.49998728434247), angle: -0.47580464260803695, fontSize: 82.1565932713097),
            VideoText(text: "Hello World", position: .init(x: 68.49998474121094, y: 466.1666666666667), angle: 0, fontSize: 18)
        ]
        return videoTexts
    }
    
    private var videoTexts: [String: VideoText] = [:]
    private var textLabels: [UILabel] = []
    private var selectedTextLabel: UILabel?
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        isUserInteractionEnabled = true
        isMultipleTouchEnabled = true
        clipsToBounds = true
        setupGesture()
    }
    
    internal required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGesture() {
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleDrag(_:)))
        dragGesture.delegate = self
        addGestureRecognizer(dragGesture)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch(_:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(self.handleRotation(_:)))
        rotationGesture.delegate = self
        addGestureRecognizer(rotationGesture)
    }
    
    func loadMockData() {
        clearAllText()
        
        mockData.forEach { data in
            addNewText(data)
        }
    }
    
    func addNewText(_ text: VideoText? = nil) {
        var videoText = text ?? VideoText(
            text: "Hello World",
            position: CGPoint(x: frame.width * 0.5, y: frame.height * 0.5),
            angle: 0,
            fontSize: 18
        )
        let label = VideoTextLabel()
        label.text = videoText.text
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.accessibilityIdentifier = videoText.id
        label.isUserInteractionEnabled = true
        label.font = self.font(size: videoText.fontSize)
        label.sizeToFit()
        label.onTouchBegan = selectText(label:)
        
        label.center = videoText.position
        label.transform = CGAffineTransform(rotationAngle: videoText.angle)
        videoTexts[videoText.id] = videoText
        textLabels.append(label)
        addSubview(label)
        label.textColor = GlobalColor.colors.randomElement()
    }
    
    
    
    func clearAllText() {
        textLabels.forEach { label in
            label.removeFromSuperview()
        }
        textLabels.removeAll()
        videoTexts.removeAll()
    }
    
    private func font(size: CGFloat) -> UIFont? {
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }

    
    private func selectText(label :UILabel) {
        selectedTextLabel = label
        bringSubviewToFront(label)
    }
    
    @objc private func handleDrag(_ gesture: UIPanGestureRecognizer) {
        guard let selectedTextLabel else { return }

        let translation = gesture.translation(in: gesture.view)
        selectedTextLabel.center = CGPoint(
            x: selectedTextLabel.center.x + translation.x,
            y: selectedTextLabel.center.y + translation.y
        )
        if gesture.state == .ended {
            updateLabel(selectedTextLabel)
        }
        gesture.setTranslation(.zero, in: gesture.view)
    }

   
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let selectedTextLabel, let identifier = selectedTextLabel.accessibilityIdentifier else { return }
        if gesture.state == .began {
            videoTexts[identifier]?.fontSize = selectedTextLabel.font.pointSize
        }
        
        let scale = gesture.scale
        selectedTextLabel.transform = selectedTextLabel.transform.scaledBy(x: scale, y: scale)
        videoTexts[identifier]!.fontSize = videoTexts[identifier]!.fontSize * scale
        
        if gesture.state == .ended {
            updateLabel(selectedTextLabel)
        }
        gesture.scale = 1.0
    }
    
    private func updateLabel(_ label: UILabel) {
        guard let identifier = label.accessibilityIdentifier else { return }
        let center = label.center
        let radians = atan2(label.transform.b, label.transform.a)
        label.font = font(size: videoTexts[identifier]!.fontSize)
        label.transform = CGAffineTransform(scaleX: 1, y: 1)
        label.frame.size = label.intrinsicContentSize
        label.center = center
        label.transform = CGAffineTransform(rotationAngle: radians)
        videoTexts[identifier]!.angle = radians
        videoTexts[identifier]!.position = center
        print(String(describing: videoTexts))
    }
    
    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        guard let selectedTextLabel else { return }
        selectedTextLabel.transform = selectedTextLabel.transform.rotated(by: gesture.rotation)
        if gesture.state == .ended {
            updateLabel(selectedTextLabel)
        }
        gesture.rotation = 0
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first != nil else { return }
        selectedTextLabel = nil
        
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedTextLabel = nil
    }

}

extension VideoTextPreview: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
