//
//  VideoTextPreview.swift
//  RenderTextToVideo
//
//  Created by haerul.rijal on 07/06/23.
//

import RxSwift
import UIKit


final class VideoTextPreview: UIView {
    
    public private(set) var videoTextState: VideoTextState
    
    public var textLabels: [UILabel] = []
    private var selectedTextLabel: UILabel?
    
    private var dragGesture = UIPanGestureRecognizer()
    private var pinchGesture = UIPinchGestureRecognizer()
    private var rotationGesture = UIRotationGestureRecognizer()
    
    
    init(state: VideoTextState) {
        self.videoTextState = state
        super.init(frame: .zero)
        backgroundColor = .clear
        layer.backgroundColor = UIColor.clear.cgColor
        isUserInteractionEnabled = true
        isMultipleTouchEnabled = true
        clipsToBounds = true
        
        setupGesture()
    }
    
    internal required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGesture() {
        dragGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleDrag(_:)))
        dragGesture.delegate = self
        addGestureRecognizer(dragGesture)
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch(_:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
        rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(self.handleRotation(_:)))
        rotationGesture.delegate = self
        addGestureRecognizer(rotationGesture)
    }
        
    func loadMockData(_ mockData: VideoTextState) {
        clearAllText()
        self.videoTextState = mockData
        
        videoTextState.texts.forEach { _, value in
            addNewText(value)
        }
    }
    
    func addNewText(_ text: VideoText? = nil) {
        var videoText = text ?? VideoText(
            text: .loremIpsumText,
            centerPosition: CGPoint(x: frame.width * 0.5, y: frame.height * 0.5),
            fontSize: videoTextState.initialFontSize
        )
        let label = VideoTextLabel()
        label.text = videoText.text
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
//        label.adjustsFontSizeToFitWidth = false
//        label.minimumScaleFactor = 0.1
        label.shadowColor = .black.withAlphaComponent(0.8)
        label.shadowOffset = .init(width: 1, height: 1)
        
        
        label.accessibilityIdentifier = videoText.id
        label.isUserInteractionEnabled = true
        label.backgroundColor = .lightGray.withAlphaComponent(0.5)
        label.font = self.font(size: videoText.fontSize)
        
        let size = CGSize(width: frame.width-32, height: .infinity)
        let labelSize = label.sizeThatFits(size)
        label.frame.size = labelSize
        label.onTouchBegan = selectText(label:)
//        label.onTouchEnded = updateLabel(_:)
        
        label.center = videoText.centerPosition
        label.transform = videoText.transform
        videoTextState.texts[videoText.id] = videoText
        textLabels.append(label)
        addSubview(label)
        label.textColor = GlobalColor.colors.randomElement()
    }
    
    
    
    func clearAllText() {
        textLabels.forEach { label in
            label.removeFromSuperview()
        }
        textLabels.removeAll()
        videoTextState.texts.removeAll()
    }
    
    private func font(size: CGFloat) -> UIFont? {
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }
    
    
    private func selectText(label :UILabel) {
        selectedTextLabel = label
        bringSubviewToFront(label)
    }

    
    @objc private func handleDrag(_ gesture: UIPanGestureRecognizer) {
        guard let selectedTextLabel, let identifier = selectedTextLabel.accessibilityIdentifier else { return }
        
        switch gesture.state {
        case .began, .changed:
            let translation = gesture.translation(in: gesture.view)
            selectedTextLabel.center = CGPoint(x: selectedTextLabel.center.x + translation.x, y: selectedTextLabel.center.y + translation.y)
            videoTextState.texts[identifier]?.centerPosition = selectedTextLabel.center
        default:
            print("Pan State :", gesture.state.rawValue)
            break
        }
        gesture.setTranslation(.zero, in: self)
    }
    
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let selectedTextLabel, let identifier = selectedTextLabel.accessibilityIdentifier else { return }
        switch gesture.state {
        case .began, .changed:
            let scale = gesture.scale
            selectedTextLabel.transform = selectedTextLabel.transform.scaledBy(x: scale, y: scale)
            videoTextState.texts[identifier]?.transform = selectedTextLabel.transform
        case .ended, .cancelled:
            // Improve rendering quality
            selectedTextLabel.layer.shouldRasterize = true
            selectedTextLabel.layer.rasterizationScale = UIScreen.main.scale
        default:
            print("Pinch State :", gesture.state.rawValue)
            break
        }
        gesture.scale = 1.0
    }
    
    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        guard let selectedTextLabel, let identifier = selectedTextLabel.accessibilityIdentifier else { return }
        switch gesture.state {
        case .began, .changed:
            selectedTextLabel.transform = selectedTextLabel.transform.rotated(by: gesture.rotation)
            videoTextState.texts[identifier]?.transform = selectedTextLabel.transform
        default:
            print("Rotate State :", gesture.state.rawValue)
            break
        }
        gesture.rotation = 0
    }
    
//    func calculateTransformedFrameSize(label: UILabel) -> CGSize {
//        let transformedBounds = label.bounds.applying(label.transform)
//        let transformedSize = CGSize(width: transformedBounds.width, height: transformedBounds.height)
//        return transformedSize
//    }
    
//    func calculateAppropriateFontSize(for size: CGSize, label: UILabel) -> CGFloat {
//        // Calculate the appropriate font size based on the label’s size after transform
//        let scaleTransform = CGAffineTransform(scaleX: label.transform.a, y: label.transform.d)
//        let scaledSize = size.applying(scaleTransform)
//        // Calculate the available height for multiline text
//        let lineHeight = label.font.lineHeight
//        let numberOfLines = floor(scaledSize.height / lineHeight)
//        let availableHeight = numberOfLines * lineHeight
//        // Adjust this calculation as per your desired logic
//        let fontSize = min(scaledSize.width, availableHeight) / 2.0
//        return fontSize
//    }
    
//    func calculateAppropriateFontSize(for size: CGSize, label: UILabel) -> CGFloat {
//        guard let lines = label.lines, lines.count > 0 else { return label.font.pointSize}
//        let numberOfLines = CGFloat(lines.count)
//        let lineHeight = size.height / numberOfLines
//        // Adjust this calculation as per your desired logic
//        let lineSize = CGSize(width: size.width, height: lineHeight)
//
//        let fontSize = fontSizeThatFits(inSize: lineSize, font: label.font, text: lines.first!)
//        return fontSize
//    }
//
//    private func fontSizeThatFits(inSize size: CGSize, font: UIFont, text: String) -> CGFloat {
//        let textSampling = text
//        let minimumFontSize: CGFloat = 1
//        let attributes = [NSAttributedString.Key.font: font]
//        let attString = NSAttributedString(string: textSampling, attributes: attributes)
//        let framesetter = CTFramesetterCreateWithAttributedString(attString)
//        let baseSize: CGSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0,length: 0), nil, CGSize(width: size.width, height: .greatestFiniteMagnitude), nil)
//
//        let pointSize: CGFloat = floor(size.height/baseSize.height * font.pointSize)
//        return pointSize < minimumFontSize ? minimumFontSize : pointSize
//    }
    
    
//    func applyTransformedFrameSize(_ transformedSize: CGSize, to label: UILabel) {
//        label.frame.size = transformedSize
//        let fontSize = calculateAppropriateFontSize(for: transformedSize, label: label)
//        label.font = label.font.withSize(fontSize)
//    }
    
//    func calculateAppropriateFontSize(for label: UILabel) -> CGFloat {
//        let text = label.text ?? ""
//        let labelSize = label.frame.size
//
//        let attributes: [NSAttributedString.Key: Any] = [
//            .font: label.font
//        ]
//
//        var fontSize: CGFloat = 18
//        var currentSize = (text as NSString).size(withAttributes: attributes)
//
//        while currentSize.width > labelSize.width || currentSize.height > labelSize.height {
//            fontSize -= 1
//            let newFont = label.font.withSize(fontSize)
//            currentSize = (text as NSString).size(withAttributes: [.font: newFont])
//        }
//
//        return fontSize
//    }
    
//    private func updateLabel(_ label: UILabel) {
//        guard let identifier = label.accessibilityIdentifier else { return }
//        let center = label.center
//        let radians = atan2(label.transform.b, label.transform.a)
//        
//        label.transform = .identity//CGAffineTransform(scaleX: 1, y: 1)
//        let fittingWidth = videoTextState.texts[identifier]!.fittingWidth
//        let fittingHeight = videoTextState.texts[identifier]!.fittingHeight
//        let fittingSize = CGSize(width: fittingWidth, height: fittingHeight)
//        label.frame.size = fittingSize
//        //label.font = font(size: videoTextState.texts[identifier]!.fontSize)
//        //        let lineHeight = videoTextState.texts[identifier]!.lineHeight
//        //        let ratio = videoTextState.texts[identifier]!.fontRatio
//        //        videoTextState.texts[identifier]!.fontSize = lineHeight * ratio
//        //
//        //        let fittingFontSize = CGSize(width: videoTextState.texts[identifier]!.fittingWidth, height: lineHeight)
//        //        videoTextState.texts[identifier]!.fontSize = fontSizeThatFits(text: "Ay", inSize: fittingFontSize, font: label.font)
//        label.font = font(size: calculateAppropriateFontSize(for: fittingSize, label: label))
////        label.setNeedsDisplay()
////        label.layoutIfNeeded()
////        layoutIfNeeded()
//        
//        label.center = center
//        label.transform = CGAffineTransform(rotationAngle: radians)
//        print("Point Size: ", label.font.pointSize)
//    }
//    
    
//    private func updateLabel(_ label: UILabel) {
//        guard let identifier = label.accessibilityIdentifier else { return }
//        let center = label.center
//        let radians = atan2(label.transform.b, label.transform.a)
//        label.transform = .identity//CGAffineTransform(scaleX: 1, y: 1)
//        let fittingWidth = videoTextState.texts[identifier]!.fittingWidth
//        let fittingHeight = videoTextState.texts[identifier]!.fittingHeight
//        let fittingSize = CGSize(width: fittingWidth, height: fittingHeight)
//        label.frame.size = fittingSize
//        label.font = font(size: videoTextState.texts[identifier]!.fontSize)
//        //        let lineHeight = videoTextState.texts[identifier]!.lineHeight
//        //        let ratio = videoTextState.texts[identifier]!.fontRatio
//        //        videoTextState.texts[identifier]!.fontSize = lineHeight * ratio
//        //
//        //        let fittingFontSize = CGSize(width: videoTextState.texts[identifier]!.fittingWidth, height: lineHeight)
//        //        videoTextState.texts[identifier]!.fontSize = fontSizeThatFits(text: "Ay", inSize: fittingFontSize, font: label.font)
//        label.center = center
//        label.transform = CGAffineTransform(rotationAngle: radians)
//        videoTextState.texts[identifier]!.angle = radians
//        videoTextState.texts[identifier]!.position = center
//
//
//        print(String(describing: videoTextState))
//    }
    
    

    
}

extension VideoTextPreview: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}



extension String {
    //    static let loremIpsumText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    static let loremIpsumText = "Lorem ipsum dolor sit amet, consectetur\nadipiscing elit, sed do eiusmod tempor\nincididunt ut labore et dolore magna\naliqua"
    //    static let loremIpsumText = "Hello world!"
}

final class VideoTextLabel: UILabel {
    
    var onTouchBegan: ((UILabel) -> Void)?
    var onTouchEnded: ((UILabel) -> Void)?
    
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first != nil else { return }
        print("Touches Ended")
        self.onTouchEnded?(self)
    }
}
