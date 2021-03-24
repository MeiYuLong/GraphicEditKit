//
//  GEEditContentView.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/17.
//

import UIKit

/// 图文编辑的主体内容
class GEEditContentView: UIView {

    var type: GEEditType = .IMAGE
    let minLabelWidth: CGFloat = 50
    let minLabelHeight: CGFloat = 50
    
    let defulttext = "ge.Double_click".GE_Locale
    /// 编辑Text样式回调
    public var editTextStyleClosure: (() -> Void)?
    
    public lazy var textLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.text = defulttext
        view.font = UIFont.systemFont(ofSize: 12)
        view.numberOfLines = 0
        view.sizeToFit()
        view.textColor = .black
        if let attri = view.attributedText {
            view.attributedText = attributesAddParagraphStyle(attri: attri)
        }
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    public var text: String? {
        set {
            if newValue?.isEmpty ?? true {
                textLabel.text = defulttext
            }else {
                textLabel.text = newValue
            }
            if let attri = textLabel.attributedText {
                textLabel.attributedText = attributesAddParagraphStyle(attri: attri)
            }
        }
        get {
            return textLabel.text
        }
    }
    
    public var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    public var labelWidth: CGFloat {
        get{
            return textLabel.bounds.width
        }
    }
    
    init(frame: CGRect, type: GEEditType) {
        super.init(frame: frame)
        
        self.type = type
        self.loadData()
        self.loadSubViews()
        self.layoutSubview()
    }
    
    private func loadData() {
    }
    
    private func loadSubViews() {
        if type == .TEXT {
            self.addSubview(textLabel)
        }else {
            self.addSubview(imageView)
        }
    }
    
    private func layoutSubview() {
        if type == .TEXT {
            textLabel.snp.makeConstraints { (make) in
                make.top.bottom.equalToSuperview()
                make.left.equalTo(10)
                make.right.equalTo(-10)
            }
        }else {
            imageView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    public func  getLabelHeight(width: CGFloat) -> CGFloat {
        let size = calculateTextSize(text: text ?? defulttext, maxSize: CGSize.init(width: width, height: CGFloat(MAXFLOAT)))
        return size.height < minLabelHeight ? minLabelHeight : (size.height + 3)
    }
    
    private func calculateTextSize(text: String, maxSize: CGSize) -> CGSize {
        
        var size = CGSize.init(width: 0, height: 0)
        if let attri = self.textLabel.attributedText {
            size = attri.boundingRect(with: CGSize(width: maxSize.width, height: maxSize.height), options: [NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.usesFontLeading], context: nil).size
        }else {
            let textNS = (text as NSString)
            size = textNS.boundingRect(with: CGSize(width: maxSize.width, height: maxSize.height), options:[NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.usesFontLeading] , attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15)], context: nil).size
        }
        return size
    }
    
    private func attributesAddParagraphStyle(attri: NSAttributedString) -> NSAttributedString {
        var range = NSRange(location: 0, length: attri.length)
        let newParagraph = NSMutableParagraphStyle()
        if let paragraph = attri.attribute(.paragraphStyle, at: 0, effectiveRange: &range) {
            if let paragraph = paragraph as? NSParagraphStyle {
                newParagraph.setParagraphStyle(paragraph)
            }
        }
        newParagraph.lineBreakMode = .byWordWrapping
        let abString = NSMutableAttributedString.init(attributedString: attri)
        abString.addAttributes([.paragraphStyle:newParagraph], range: range)
        return abString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
