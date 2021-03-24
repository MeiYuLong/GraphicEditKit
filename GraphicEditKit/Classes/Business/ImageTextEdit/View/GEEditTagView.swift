//
//  GEEditTagView.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/16.
//

import UIKit

/// 编辑的四个操作tag
class GEEditTagView: UIView {

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    public var imageName: String? {
        didSet{
            iconImageView.image = UIImage.ge_bundle(named: imageName ?? "")
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.autoresizesSubviews = false
        self.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.height / 2
    }
    
//    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//
//        var  bounds = self.bounds
//        let widthDelta: CGFloat = -50.0
//        let heightDelta: CGFloat = -50.0
//
//        bounds = bounds.insetBy(dx: widthDelta, dy: heightDelta)
//        return bounds.contains(point)
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
