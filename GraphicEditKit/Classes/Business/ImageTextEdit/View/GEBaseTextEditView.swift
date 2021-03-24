//
//  GEBaseTextEditView.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/17.
//

import UIKit

/// 文字框编辑View 个别事件交互需重写
class GEBaseTextEditView: GEBaseEditView {

    var originSize: CGSize = .zero
    
    func updateSize() {
        let bounds = self.bounds
        var center = self.center
        if center.y < 0 {
            center.y = 0
        }
        let labelWidth = contentView.labelWidth
        let labeHeight = contentView.getLabelHeight(width: labelWidth)
        let allHeight = labeHeight + contentLayoutConstant * 2
        
        let newSize = CGSize(width: bounds.size.width, height: allHeight)
        let origin = bounds.origin
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.bounds = CGRect(origin: origin, size: newSize)
            self?.center = center
        } completion: { [weak self](_) in
            self?.setTextLabelFrame(width: labelWidth, height: labeHeight)
        }
    }
    
    private func setTextLabelFrame(width: CGFloat, height: CGFloat) {
        let x = self.frame.origin.x + self.contentLayoutConstant + self.contentTextLabelLeftConstant
        let y = self.frame.origin.y + self.contentLayoutConstant
        let labelFrame = CGRect(x: x, y: y, width: width, height: height)
        self.viewModel.frame = labelFrame
    }
}

extension GEBaseTextEditView {
    
    //文本编辑拖动时，为改变宽高，不放大缩小, 宽度变化，高度自适应
    override func panScaleHandle(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: self)
        switch sender.state {
        case .began:
            panScaleBeginPoint = location
            originSize = self.bounds.size
            break
        case .changed:
            let bounds = self.bounds
            var center = self.center
            if center.y < 0 {
                center.y = 0
            }
            let changeX = location.x - panScaleBeginPoint.x
            let newWidth = originSize.width + changeX
            
            let labelWidth = newWidth - contentLayoutConstant * 2 - contentTextLabelLeftConstant * 2
            if labelWidth < minTextLabelWidth { return }
            let labeHeight = contentView.getLabelHeight(width: labelWidth)
            let allHeight = labeHeight + contentLayoutConstant * 2
            
            let newSize = CGSize(width: newWidth, height: allHeight)
            let origin = bounds.origin
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.bounds = CGRect(origin: origin, size: newSize)
                self?.center = center
            } completion: { [weak self](_) in
                self?.setTextLabelFrame(width: labelWidth, height: labeHeight)
            }
        default:
            break
        }
    }
    
    override func pinchHandle(_ sender: UIPinchGestureRecognizer) {}

    override func cropTapHandle(_ sender: UITapGestureRecognizer) {
        self.editTextStyle()
    }
    
    override func doubleTapHandle(_ sender: UITapGestureRecognizer) {
        switch editType {
        case .TEXT:
            self.editContentText()
        default:
            break
        }
    }
    
    /// 双击文本框
    /// - Parameter sender: 手势
    private func editContentText() {
        let text = contentView.text ?? ""
        GETextInputManager.shared.startInputText(text: text, inputType: .Text) { [weak self](text) in
            self?.contentView.text = text
            let _ = self?.becomeFirstResponder()
            self?.updateSize()
        } resignFirst: { [weak self] in
            self?.resignActive()
        }
        // 当输入框为第一响应者时，editContentView也需要边框)
        self.becomeActive()
    }
    
    /// 编辑文本框text样式
    private func editTextStyle() {
        let attributedStr = contentView.textLabel.attributedText
        GETextStyleEditManager.shared.startEditText(attributed: attributedStr){ [weak self](attributedText) in
            self?.contentView.textLabel.attributedText = attributedText
            self?.updateSize()
        } resignFirst: { [weak self] in
            self?.resignActive()
        }
        // 当输入框为第一响应者时，editContentView也需要边框)
        self.becomeActive()
    }
}
