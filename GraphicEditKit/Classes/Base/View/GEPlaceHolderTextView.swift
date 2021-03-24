//
//  GEPlaceHolderTextView.swift
//  GraphicEdit
//
//  Created by yulong mei on 2021/3/11.
//

import UIKit
import SnapKit

class GEPlaceHolderTextView: UITextView {
    
    public var placeholder: String? {
        didSet {
            placeHolderLabel.text = placeholder
            guard let placeholderText = placeholder, !placeholderText.isEmpty else {
                self.placeHolderLabel.isHidden = true
                return
            }
            self.placeHolderLabel.isHidden = self.hasText
        }
    }
    
    override var text: String! {
        didSet {
            self.placeHolderLabel.isHidden = !text.isEmpty
        }
    }
    
    lazy var placeHolderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = GETextPlaceholderColor
        return label
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.loadSubViews()
        NotificationCenter.default.addObserver(self, selector: #selector(textValue_didChanged(_:)), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func loadSubViews() {
        self.addSubview(placeHolderLabel)
        placeHolderLabel.snp.makeConstraints { (make) in
            make.top.equalTo(8)
            make.left.equalTo(15)
            make.width.lessThanOrEqualToSuperview().offset(-10)
        }
    }
    
    @objc func textValue_didChanged(_ notification: Notification) {
        
        guard let placeholderText = placeholder, !placeholderText.isEmpty else {
            return
        }
        if let textView = notification.object as? GEPlaceHolderTextView {
            self.placeHolderLabel.isHidden = textView.hasText
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
