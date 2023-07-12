//
//  DeleteView.swift
//  RenderTextToVideo
//
//  Created by haerul.rijal on 11/07/23.
//

import UIKit


final class DeleteView: UIView {
    
    private let trashImage: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .clear
        iv.image = UIImage(named: "delete")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(trashImage)
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        alpha = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        trashImage.frame = bounds.insetBy(dx: 8, dy: 8)
        layer.cornerRadius = frame.width * 0.5
    }
    
    public func show() {
        guard alpha != 1.0 else { return }
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.alpha = 1
        }
    }
    
    public func hide() {
        guard alpha != 0.0 else { return }
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.alpha = 0
        }
    }
}

