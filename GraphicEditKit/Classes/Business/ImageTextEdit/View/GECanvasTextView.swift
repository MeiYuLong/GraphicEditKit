//
//  GECanvasTextView.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/16.
//

import UIKit

/// 图文编辑的背景画布
class GECanvasTextView: GEPlaceHolderTextView {

    // 成为第一响应者回调
    public var willBecomeFirstResponderClosure: (() -> Void)?
    // 注销第一响应者回调
    public var resignFirstResponderClosure: (() -> Void)?
        
    // 每次点击TextView 都会调用becomeFirstResponder
    override func becomeFirstResponder() -> Bool {
        self.willBecomeFirstResponderClosure?()
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        if result {
            self.resignFirstResponderClosure?()
        }
        return result
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.delaysContentTouches = false
        self.canCancelContentTouches = true
        self.bounces = false
        self.textColor = .black
        self.showsVerticalScrollIndicator  = true
        self.indicatorStyle = .black
        self.textContainerInset = UIEdgeInsets(top: 10,left: 10,bottom: 10,right: 10)
        self.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async {
            let textContentSize = self.sizeThatFits(CGSize(width: self.frame.width, height: CGFloat(MAXFLOAT)))
            var contentRect = CGRect.zero
            for view in self.subviews {
                if view is GEBaseEditView {
                    contentRect = contentRect.union(view.frame)
                }
            }
            contentRect.size.width = self.frame.width
            if contentRect.size.height < self.frame.height {
                contentRect.size.height = self.frame.height + 1
            }else {
                contentRect.size.height += 10
            }
            if textContentSize.height > contentRect.size.height {
                contentRect.size.height = textContentSize.height + 10
            }
            UIView.animate(withDuration: 0.2) {
                self.contentSize = contentRect.size
            }
        }
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is GEBaseEditView {
            return false
        }
        return true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension GECanvasTextView {
    
    /// 返回文本内容topInset + textHeight + margin的高度
    public func getTextContentHeight() -> CGFloat {
        let attri = self.attributedText
        let padding = self.textContainer.lineFragmentPadding
        let width = self.frame.width - 2 * padding - 20
        let size = attri?.ge_sizeFittingWidth(width)
        return  ceil((size?.height ?? 0) + self.textContainerInset.top + 10)
    }
    
    ///（文本和EditView比较）获取TextView的最大的ContentSize
    /// - Returns: Size
    public func getMaxContentSize() -> CGSize {
        var contentRect = CGRect.zero
        for view in self.subviews {
            if view is GEBaseEditView {
                contentRect = contentRect.union(view.frame)
            }
        }
        contentRect.size.width = frame.width
        let textContentHeight = getTextContentHeight()
        if textContentHeight > contentRect.height {
            //文字获取的带有Padding需要返回+20
            contentRect.size.height = textContentHeight + 20
        }else {
            // 加个10 margin
            contentRect.size.height +=  10
        }
        return contentRect.size
    }
    
    /// 依据新视图的Size 计算出新的TextView的contentSize和新视图的frame
    /// - Parameter size: 新视图的Size
    /// - Returns: 新视图的frame
    public func getContentBottomPoint(size: CGSize) -> CGRect {
        var contentRect = getMaxContentSize()
        let origin = CGPoint(x: (contentRect.width - size.width) / 2, y: contentRect.height)
        let frame = CGRect(origin: origin, size: size)
        contentRect.height += size.height
        self.contentSize = contentRect
        
        let offSet = self.contentSize.height - self.bounds.height
        if offSet > 0 {
            self.setContentOffset(CGPoint(x: 0, y: offSet), animated: true)
        }
        return frame
    }
    
    public func getNSRange(_ form: UITextRange) -> NSRange {
        let beginning = self.beginningOfDocument
        let start = form.start
        let end = form.end
        let location = self.offset(from: beginning, to: start)
        let length = self.offset(from: start, to: end)
        return NSRange(location: location, length: length)
    }
    
    public func getTextRange(_ form: NSRange) -> UITextRange? {
        let beginning = self.beginningOfDocument
        guard let start = self.position(from: beginning, offset: form.location) else {
            return nil
        }
        guard let end = self.position(from: start, offset: form.length) else {
            return nil
        }
        return self.textRange(from: start, to: end)
    }
}
