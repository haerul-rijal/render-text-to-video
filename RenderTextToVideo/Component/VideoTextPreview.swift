//
//  VideoTextPreview.swift
//  RenderTextToVideo
//
//  Created by haerul.rijal on 07/06/23.
//

import RxSwift
import UIKit


final class VideoTextPreview: UIView {
    
    public var videoTextState: VideoTextState
    
    public var textLabels: [VideoTextLabel] = []
    private var selectedTextLabel: VideoTextLabel?
    
    private var dragGesture = UIPanGestureRecognizer()
    private var pinchGesture = UIPinchGestureRecognizer()
    private var rotationGesture = UIRotationGestureRecognizer()
    
    private var snapGuideLineWidth: CGFloat = 1.0
    
    private let snapGuideTolerance: CGFloat = 2.0
    private let edgeSnapGuideVisibilityTolerance: CGFloat = 3.0
    
    private var verticalSnapGuideLine: UIView?
    private var horizontalSnapGuideLine: UIView?
    private var topSnapGuideLine: UIView?
    private var leftSnapGuideLine: UIView?
    private var rightSnapGuideLine: UIView?
    private var bottomSnapGuideLine: UIView?
    private var snapGuideInset: UIEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
    
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    
    private var isSelectedLabelDraggedToTrash: Bool = false
    
    private let deleteView: DeleteView
    
    init(state: VideoTextState) {
        self.videoTextState = state
        self.deleteView = DeleteView(frame: .init(x: 0, y: 0, width: 40, height: 40))
        super.init(frame: .zero)
        backgroundColor = .clear
        layer.backgroundColor = UIColor.clear.cgColor
        isUserInteractionEnabled = true
        isMultipleTouchEnabled = true
        clipsToBounds = true
        layer.borderColor = UIColor.yellow.cgColor
        layer.borderWidth = 1
        setupGesture()
        feedbackGenerator.prepare()
        addSubview(deleteView)
    }
    
    internal required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGesture() {
        dragGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        dragGesture.delegate = self
        addGestureRecognizer(dragGesture)
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch(_:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
        rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(self.handleRotation(_:)))
        rotationGesture.delegate = self
        addGestureRecognizer(rotationGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        deleteView.center = CGPoint(x: bounds.midX, y: bounds.height - deleteView.frame.height*0.5 - 20)
        self.videoTextState.displaySize = frame.size
    }
        
    func loadMockData(_ mockData: VideoTextState) {
        clearAllText()
        self.videoTextState = mockData
        
        videoTextState.texts.forEach { _, value in
            addNewText(value)
        }
    }
    
    func addNewText(_ text: VideoText? = nil) {
        let videoText = text ?? VideoText(
            text: .loremIpsumText,
            centerPosition: CGPoint(x: frame.width * 0.5, y: frame.height * 0.5),
            fontSize: videoTextState.initialFontSize,
            textColor: GlobalColor.colors.randomElement() ?? .white
        )
        let label = VideoTextLabel()
        addSubview(label)
        label.text = videoText.text
        
        label.accessibilityIdentifier = videoText.id
        label.font = self.font(size: videoText.fontSize)
        label.textColor = videoText.textColor
        
//        let size = CGSize(width: frame.width-32, height: .infinity)
//        let labelSize = label.sizeThatFits(size)
//        label.frame.size = labelSize
        setLabelSize(label: label)
        label.onTouchBegan = selectText(label:)
        label.onTap = onTapText(label:)
        //label.contentScaleFactor = UIScreen.main.scale
        label.transform = videoText.transform
        label.center = videoText.centerPosition
        
        
        videoTextState.texts[videoText.id] = videoText
        textLabels.append(label)
        
    }
    
    private func setLabelSize(label: VideoTextLabel) {
        let size = CGSize(width: videoTextState.displaySize.width-32, height: .infinity)
        let labelSize = label.sizeThatFits(size)
        label.frame.size = labelSize
        
    }
    
    private func deleteLabel(_ label: VideoTextLabel) {
        guard let identifier = label.accessibilityIdentifier else { return }
        
        videoTextState.texts.removeValue(forKey: identifier)
        textLabels.removeAll { textLabel in
            textLabel.accessibilityIdentifier == identifier
        }
        subviews.forEach { view in
            if view.accessibilityIdentifier == identifier {
                view.removeFromSuperview()
            }
        }
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
    
    
    private func selectText(label: VideoTextLabel) {
        selectedTextLabel = label
        bringSubviewToFront(label)
    }
    
    private func onTapText(label: VideoTextLabel) {
        self.updateLabelText(label)
    }

    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let selectedTextLabel, let identifier = selectedTextLabel.accessibilityIdentifier else { return }
        
        deleteView.show()
        
        if !isSelectedLabelDraggedToTrash {
            
            let translation = gesture.translation(in: self)
            let position = selectedTextLabel.center
            
            selectedTextLabel.center = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
            
            // Display vertical snap guide line if dragged close to the center
            let snapGuideX = bounds.midX
            //let centerX = selectedTextLabel.bounds.midX
            let centerX = selectedTextLabel.center.x
            let distanceToSnapGuideX = abs(centerX - snapGuideX)
            
            if distanceToSnapGuideX <= snapGuideTolerance {
                showVerticalSnapGuideLine()
                let snappedCenterX = snapGuideX
                selectedTextLabel.center = CGPoint(x: snappedCenterX, y: selectedTextLabel.center.y)
            } else {
                hideVerticalSnapGuideLine()
            }
            
            // Display horizontal snap guide line if dragged close to the center
            let snapGuideY = bounds.midY
            //let centerY = selectedTextLabel.bounds.midY
            let centerY = selectedTextLabel.center.y
            let distanceToSnapGuideY = abs(centerY - snapGuideY)
            
            if distanceToSnapGuideY <= snapGuideTolerance {
                showHorizontalSnapGuideLine()
                let snappedCenterY = snapGuideY
                selectedTextLabel.center = CGPoint(x: selectedTextLabel.center.x, y: snappedCenterY)
            } else {
                hideHorizontalSnapGuideLine()
            }
            
            // Display top snap guide line if dragged close to the top padding
            let snapGuideTop = snapGuideInset.top + snapGuideTolerance
            let distanceToSnapGuideTop = abs(selectedTextLabel.frame.minY - snapGuideTop)

            if distanceToSnapGuideTop <= snapGuideTolerance {
                showTopSnapGuideLine()
                let snappedCenterY = snapGuideTop + (selectedTextLabel.frame.height * 0.5)
                selectedTextLabel.center = CGPoint(x: selectedTextLabel.center.x, y: snappedCenterY)
            } else {
                hideTopSnapGuideLine()
            }

            // Display left snap guide line if dragged close to the left padding
            let snapGuideLeft = snapGuideInset.left + snapGuideTolerance
            let distanceToSnapGuideLeft = abs(selectedTextLabel.frame.minX - snapGuideLeft)

            if distanceToSnapGuideLeft <= snapGuideTolerance {
                showLeftSnapGuideLine()
                let snappedCenterX = snapGuideLeft + (selectedTextLabel.frame.width * 0.5)
                selectedTextLabel.center = CGPoint(x: snappedCenterX, y: selectedTextLabel.center.y)
            } else {
                hideLeftSnapGuideLine()
            }
            
            // Display right snap guide line if dragged close to the right padding
            let snapGuideRight = bounds.width - snapGuideInset.right - snapGuideTolerance
            let distanceToSnapGuideRight = abs(selectedTextLabel.frame.maxX - snapGuideRight)

            if distanceToSnapGuideRight <= snapGuideTolerance {
                showRightSnapGuideLine()
                let snappedCenterX = snapGuideRight - (selectedTextLabel.frame.width * 0.5)
                selectedTextLabel.center = CGPoint(x: snappedCenterX, y: selectedTextLabel.center.y)
            } else {
                hideRightSnapGuideLine()
            }
            
            // Display bottom snap guide line if dragged close to the bottom padding
            let snapGuideBottom = bounds.height - snapGuideInset.bottom - snapGuideTolerance
            let distanceToSnapGuideBottom = abs(selectedTextLabel.frame.maxY - snapGuideBottom)

            if distanceToSnapGuideBottom <= snapGuideTolerance {
                showBottomSnapGuideLine()
                let snappedCenterY = snapGuideBottom - (selectedTextLabel.frame.height * 0.5)
                selectedTextLabel.center = CGPoint(x: selectedTextLabel.center.x, y: snappedCenterY)
            } else {
                hideBottomSnapGuideLine()
            }
        
            // ------------
            
            videoTextState.texts[identifier]?.centerPosition = selectedTextLabel.center
            videoTextState.texts[identifier]?.transform = selectedTextLabel.transform
        }
        
        
        let location = gesture.location(in: self)
        if deleteView.frame.contains(location) {
            if !isSelectedLabelDraggedToTrash {
                isSelectedLabelDraggedToTrash = true
                UIView.animate(withDuration: 0.3) { [weak self] in
                    guard let self else { return }
                    selectedTextLabel.center = self.deleteView.center
                    selectedTextLabel.transform = CGAffineTransform.identity.scaledBy(x: 0.05, y: 0.05) //selectedTextLabel.transform.scaledBy(x: 0.05, y: 0.05)
                }
            }
        } else {
            if isSelectedLabelDraggedToTrash {
                isSelectedLabelDraggedToTrash = false
                UIView.animate(withDuration: 0.3) { [weak self] in
                    guard let self else { return }
                    selectedTextLabel.center =  location//self.videoTextState.texts[identifier]!.centerPosition
                    selectedTextLabel.transform = videoTextState.texts[identifier]!.transform
                }
            }
        }
        
        // Hide all snap guide
        if gesture.state == .ended {
            if isSelectedLabelDraggedToTrash {
                deleteLabel(selectedTextLabel)
            }
            hideSnapGuideLines()
            deleteView.hide()
            
            self.selectedTextLabel = nil
            print("UIPanGestureRecognizer gesture.state = .ended ")
        }
        gesture.setTranslation(.zero, in: self)
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let selectedTextLabel, let identifier = selectedTextLabel.accessibilityIdentifier else { return }
        let scale = gesture.scale
        selectedTextLabel.transform = selectedTextLabel.transform.scaledBy(x: scale, y: scale)
        videoTextState.texts[identifier]?.transform = selectedTextLabel.transform
        gesture.scale = 1.0
    }
    
    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        guard let selectedTextLabel, let identifier = selectedTextLabel.accessibilityIdentifier else { return }
        
        selectedTextLabel.transform = selectedTextLabel.transform.rotated(by: gesture.rotation)
        videoTextState.texts[identifier]?.transform = selectedTextLabel.transform
        gesture.rotation = 0.0
    }
    
    // Vertical Center
    private func showVerticalSnapGuideLine() {
        guard verticalSnapGuideLine == nil else { return }
        verticalSnapGuideLine = UIView(frame: CGRect(x: bounds.midX - (snapGuideLineWidth*0.5), y: 0, width: snapGuideLineWidth, height: bounds.height))
        verticalSnapGuideLine?.backgroundColor = UIColor.cyan
        addSubview(verticalSnapGuideLine!)
        self.feedbackGenerator.selectionChanged()
    }
    
    private func hideVerticalSnapGuideLine() {
        self.verticalSnapGuideLine?.removeFromSuperview()
        self.verticalSnapGuideLine = nil
    }
    
    // Horizontal Center
    private func showHorizontalSnapGuideLine() {
        guard horizontalSnapGuideLine == nil else { return }
        horizontalSnapGuideLine = UIView(frame: CGRect(x: 0, y: bounds.midY - (snapGuideLineWidth*0.5), width: bounds.width, height: snapGuideLineWidth))
        horizontalSnapGuideLine?.backgroundColor = UIColor.cyan
        addSubview(horizontalSnapGuideLine!)
        self.feedbackGenerator.selectionChanged()
    }
    
    private func hideHorizontalSnapGuideLine() {
        self.horizontalSnapGuideLine?.removeFromSuperview()
        self.horizontalSnapGuideLine = nil
    }
    
    // Top
    private func showTopSnapGuideLine() {
        guard topSnapGuideLine == nil else { return }
        topSnapGuideLine = UIView(frame: CGRect(x: 0, y: snapGuideInset.top, width: bounds.width, height: snapGuideLineWidth))
        topSnapGuideLine?.backgroundColor = UIColor.cyan
        addSubview(topSnapGuideLine!)
        self.feedbackGenerator.selectionChanged()
    }
    
    private func hideTopSnapGuideLine() {
        topSnapGuideLine?.removeFromSuperview()
        topSnapGuideLine = nil
    }
    
    // Left
    
    private func showLeftSnapGuideLine() {
        guard leftSnapGuideLine == nil else { return }
        leftSnapGuideLine = UIView(frame: CGRect(x: snapGuideInset.left, y: 0, width: snapGuideLineWidth, height: bounds.height))
        leftSnapGuideLine?.backgroundColor = UIColor.cyan
        addSubview(leftSnapGuideLine!)
        self.feedbackGenerator.selectionChanged()
    }
    
    private func hideLeftSnapGuideLine() {
        leftSnapGuideLine?.removeFromSuperview()
        leftSnapGuideLine = nil
    }
    
    // Right
    private func showRightSnapGuideLine() {
        guard rightSnapGuideLine == nil else { return }
        rightSnapGuideLine = UIView(frame: CGRect(x: bounds.width - snapGuideInset.right - snapGuideLineWidth, y: 0, width: snapGuideLineWidth, height: bounds.height))
        rightSnapGuideLine?.backgroundColor = UIColor.cyan
        addSubview(rightSnapGuideLine!)
        self.feedbackGenerator.selectionChanged()
    }
    
    private func hideRightSnapGuideLine() {
        rightSnapGuideLine?.removeFromSuperview()
        rightSnapGuideLine = nil
    }
    
    // Bottom
    private func showBottomSnapGuideLine() {
        guard bottomSnapGuideLine == nil else { return }
        bottomSnapGuideLine = UIView(frame: CGRect(x: 0, y: bounds.height - snapGuideInset.bottom - snapGuideLineWidth, width: bounds.width, height: snapGuideLineWidth))
        bottomSnapGuideLine?.backgroundColor = UIColor.cyan
        addSubview(bottomSnapGuideLine!)
        self.feedbackGenerator.selectionChanged()
    }
    
    private func hideBottomSnapGuideLine() {
        bottomSnapGuideLine?.removeFromSuperview()
        bottomSnapGuideLine = nil
    }
    
    private func hideSnapGuideLines() {
        hideVerticalSnapGuideLine()
        hideHorizontalSnapGuideLine()
        hideTopSnapGuideLine()
        hideLeftSnapGuideLine()
        hideRightSnapGuideLine()
        hideBottomSnapGuideLine()
    }
    
    func updateLabelText(_ label: VideoTextLabel) {
        let ac = UIAlertController(title: "Enter Text", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.textFields?[0].text = label.text
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, unowned ac] _ in
            guard
                let self = self,
                let textField = ac.textFields?[0],
                let text = textField.text, !text.isEmpty,
                let identifier = label.accessibilityIdentifier,
                !(self.videoTextState.texts[identifier]!.text == text)
            else { return }
            
            let center = label.center
            let transform = label.transform
            label.text = text
            label.transform = .identity
            self.videoTextState.texts[identifier]!.text = text
            self.setLabelSize(label: label)
            label.center = center
            label.transform = transform
        }
        
        ac.addAction(submitAction)
        topVC()?.present(ac, animated: true)
    }
    
    private func topVC() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            return topController
        }
        return nil
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


