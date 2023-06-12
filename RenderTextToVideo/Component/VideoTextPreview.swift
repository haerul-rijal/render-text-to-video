//
//  VideoTextPreview.swift
//  RenderTextToVideo
//
//  Created by haerul.rijal on 07/06/23.
//

import RxSwift
import UIKit

final class VideoTextPreview: UIView {
    
    private var videoTexts: [VideoText] = []
    private var textLabels: [UILabel] = []
    private var selectedTextLabel: UILabel?
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        isUserInteractionEnabled = true
        isMultipleTouchEnabled = true
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
    
    func addNewText() {
        var videoText = VideoText(
            text: "Hello World",
            position: .zero
        )
        let label = UILabel()
        label.text = videoText.text
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        //label.backgroundColor = .lightGray
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.accessibilityIdentifier = videoText.id
        label.isUserInteractionEnabled = true
        label.font = self.font(size: 18)
        label.sizeToFit()
        
        let centerPosition = CGPoint(x: frame.width * 0.5, y: frame.height * 0.5)
        videoText.position = centerPosition
        videoText.initialSize = label.frame.size
        videoText.size = label.frame.size
        label.center = centerPosition
        videoTexts.append(videoText)
        textLabels.append(label)
        addSubview(label)
        label.textColor = GlobalColor.colors().randomElement()
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
    
    @objc private func handleDrag(_ gesture: UIPanGestureRecognizer) {
        guard let selectedTextLabel else { return }
        let translation = gesture.translation(in: self)
        selectedTextLabel.center = CGPoint(
            x: selectedTextLabel.center.x + translation.x,
            y: selectedTextLabel.center.y + translation.y
        )
        gesture.setTranslation(.zero, in: self)
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let selectedTextLabel else { return }
        let scale = gesture.scale
        selectedTextLabel.transform = selectedTextLabel.transform.scaledBy(x: scale, y: scale)
        let fontSize = selectedTextLabel.font.pointSize
        print("Scale: ", scale, "PointSize: ", fontSize)
        print("Estimated : ", fontSize)
        gesture.scale = 1.0
    }

    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        guard let selectedTextLabel else { return }
        selectedTextLabel.transform = selectedTextLabel.transform.rotated(by: gesture.rotation)
        gesture.rotation = 0
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        var isLabelTouched = false
        for label in textLabels.reversed() {
            let touchSlopFrame = label.frame.insetBy(dx: -10, dy: -10)
            if touchSlopFrame.contains(location) {
                selectedTextLabel = label
                isLabelTouched = true
                break
            }
        }
        if !isLabelTouched {
            selectedTextLabel = nil
        }
        
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
