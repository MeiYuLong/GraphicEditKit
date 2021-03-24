//
//  GECropLayerView.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/17.
//

import UIKit

class GECropLayerView: UIView {

    enum GETagLocation {
        case TopLeft, TopRight, BottomLeft, BottomRight
    }

    let tagLineHeight: CGFloat = 20
    let tagLineWidth: CGFloat = 20
    let space: CGFloat = 5
    let lineColor = UIColor.white.cgColor
    
    var visibleAreaOriginSize: CGSize = CGSize(width: 300, height: 300)
    var cropFrame: CGRect = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isUserInteractionEnabled = true
        self.layer.masksToBounds =  true
        
        visibleAreaOriginSize = CGSize(width: 300, height: 300)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
                
        cropFrame = CGRect(x: (self.bounds.width - visibleAreaOriginSize.width) / 2, y: (self.bounds.height - visibleAreaOriginSize.height) / 2, width: visibleAreaOriginSize.width, height: visibleAreaOriginSize.height)
        drawVisibleArea()
    }
    
    private func drawVisibleArea() {
        let shareLayer = CAShapeLayer()
        shareLayer.frame = self.bounds
        shareLayer.backgroundColor = UIColor.clear.cgColor
        shareLayer.fillColor = UIColor.black.cgColor
        shareLayer.strokeColor = lineColor
//        shareLayer.lineJoin = .miter
        shareLayer.lineWidth = 2
//        shareLayer.fillRule = .evenOdd
        shareLayer.opacity = 0.5
        
        let bigPathFrame = CGRect(x: -1, y: -1, width: self.bounds.width + 2, height: self.bounds.height + 2)
        let path = UIBezierPath.init(roundedRect: bigPathFrame, cornerRadius: 0)
        path.append(UIBezierPath.init(rect: cropFrame))
        shareLayer.path = path.cgPath
        self.layer.addSublayer(shareLayer)
        
        shareLayer.addSublayer(createLayer(location: .TopLeft))
        shareLayer.addSublayer(createLayer(location: .TopRight))
        shareLayer.addSublayer(createLayer(location: .BottomLeft))
        shareLayer.addSublayer(createLayer(location: .BottomRight))
    }
    
    private func createLayer(location: GETagLocation) -> CAShapeLayer{
        let shareLayer = CAShapeLayer()
        var frame: CGRect
        switch location {
        case .TopLeft:
            frame = CGRect(x: cropFrame.origin.x + space, y: cropFrame.origin.y + space, width: tagLineWidth, height: tagLineWidth)
        case .TopRight:
            frame = CGRect(x: cropFrame.maxX - space - tagLineWidth, y: cropFrame.origin.y + space, width: tagLineWidth, height: tagLineWidth)
        case .BottomLeft:
            frame = CGRect(x:  cropFrame.origin.x + space, y: cropFrame.maxY - space - tagLineHeight, width: tagLineWidth, height: tagLineWidth)
        case .BottomRight:
            frame = CGRect(x: cropFrame.maxX - space - tagLineWidth, y: cropFrame.maxY - space - tagLineHeight, width: tagLineWidth, height: tagLineWidth)
        }
        shareLayer.frame = frame
        shareLayer.backgroundColor = UIColor.clear.cgColor
        shareLayer.fillColor = UIColor.clear.cgColor
        shareLayer.strokeColor = lineColor
//        shareLayer.lineJoin = .miter
        shareLayer.lineWidth = 2
        shareLayer.path = createPath(location: location).cgPath
        return shareLayer
    }
    
    private func createPath(location: GETagLocation) -> UIBezierPath {
        let path = UIBezierPath()
        var start: CGPoint
        var center: CGPoint
        var end: CGPoint
        
        switch location {
        case .TopLeft:
            start = CGPoint(x: 0, y: tagLineHeight)
            center = CGPoint(x: 0, y: 0)
            end = CGPoint(x: tagLineWidth, y: 0)
        case .TopRight:
            start = CGPoint(x: 0, y: 0)
            center = CGPoint(x: tagLineWidth, y: 0)
            end = CGPoint(x: tagLineWidth, y: tagLineHeight)
        case .BottomLeft:
            start = CGPoint(x: 0, y: 0)
            center = CGPoint(x: 0, y: tagLineHeight)
            end = CGPoint(x: tagLineWidth, y: tagLineHeight)
        case .BottomRight:
            start = CGPoint(x: 0, y: tagLineHeight)
            center = CGPoint(x: tagLineWidth, y: tagLineHeight)
            end = CGPoint(x: tagLineWidth, y: 0)
        }
        path.move(to: start)
        path.addLine(to: center)
        path.addLine(to: end)
        return path
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(touches)
    }
}
