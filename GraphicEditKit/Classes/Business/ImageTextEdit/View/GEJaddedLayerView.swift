//
//  GEJaddedLayerView.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/17.
//

import UIKit

/// 图文绘制背景锯齿View
class GEJaddedLayerView: UIView {

    private let JaddedHeight: CGFloat = 5.0
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let topLayer = CAShapeLayer()
        topLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: JaddedHeight)
        topLayer.path = createJaggedPath(true).cgPath
        topLayer.backgroundColor = UIColor.clear.cgColor
        topLayer.fillColor = UIColor.white.cgColor
        topLayer.strokeColor = UIColor.clear.cgColor
        topLayer.lineWidth = 1
//        topLayer.lineCap = .butt
        self.layer.addSublayer(topLayer)
        
        let bottomLayer = CAShapeLayer()
        bottomLayer.frame = CGRect(x: 0, y: self.bounds.height - JaddedHeight, width: self.bounds.width, height: JaddedHeight)
        bottomLayer.path = createJaggedPath(false).cgPath
        topLayer.backgroundColor = UIColor.clear.cgColor
        bottomLayer.fillColor = UIColor.white.cgColor
        bottomLayer.strokeColor = UIColor.clear.cgColor
        self.layer.addSublayer(bottomLayer)
        
        self.layer.masksToBounds = true
        
    }
    
    private func createJaggedPath(_ isTop: Bool) -> UIBezierPath {
        let width = self.bounds.width
        let height: CGFloat = JaddedHeight
        let path = UIBezierPath.init()
        path.lineJoinStyle = .bevel
        var pointX: CGFloat = 0.0
        var pointY: CGFloat = isTop ? JaddedHeight : 0.0
        path.move(to: CGPoint(x: pointX, y: pointY))
        while pointX < width {
            pointX += 6
            pointY = pointY >= height ? 0.0 : height
            path.addLine(to: CGPoint(x: pointX, y: pointY))
        }
        return path
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
