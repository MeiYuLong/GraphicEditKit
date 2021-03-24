//
//  GETextStyleEditManager.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/17.
//

import Foundation

/// 文字样式管理
class GETextStyleEditManager {
    
    static let shared = GETextStyleEditManager()
    var toolBar: GEToolBar?
    var attributedStr: NSAttributedString?
//    var active: Bool = false
    
    // 定义编辑结束回调处理
    typealias GEEditTextDoneHandler = (NSAttributedString) -> Void
    var editTextDoneHandler: GEEditTextDoneHandler?
    
    // 定义注销响应者回调处理
    typealias GETextResignFirstHandler = () -> Void
    var resignFirstHandler: GETextResignFirstHandler?
    
    init() {}
    
    public func textBoxEditView() -> GETextEditView {
        let editTextView = GETextEditView(frame: .zero)
//        editTextView.showAligment = false
        editTextView.textFontSizeChanged = { [weak self](size) in
            self?.fontSizeChange(size)
        }
        editTextView.textStyleChanged = { [weak self] (style, isSelected) in
            self?.textStyleChange(style, isSelected)
        }
        editTextView.textHeadIndentChanged = { [weak self] (size) in
            self?.textHeadIndentChange(size)
        }
        editTextView.textAlignmentChanged = { [weak self] (alignment) in
            self?.textAlignmentChange(alignment)
        }
        editTextView.textLineSpacingChanged = { [weak self] (spacing) in
            self?.textLineSpacingChange(spacing)
        }
        return editTextView
    }

    public func startEditText(attributed: NSAttributedString?, done: @escaping GEEditTextDoneHandler, resignFirst: @escaping GETextResignFirstHandler) {
        self.attributedStr = attributed
        self.editTextDoneHandler = done
        if let resignhadler = self.resignFirstHandler {
            resignhadler()
        }
        self.resignFirstHandler = resignFirst
//        self.active = true
        self.toolBar?.setSelected(index: 1)
    }
    
    public func editTextEnd(attributedText: NSAttributedString) {
        self.editTextDoneHandler?(attributedText)
    }
}
extension GETextStyleEditManager {
    
    private func fontSizeChange(_ size: CGFloat) {
        guard let attributed = attributedStr else {
            return
        }
        let mutable = GETextService.setAttributedString(attributed, fontSize: size, range: NSRange(location: 0, length: attributed.length))
        self.attributedStr = mutable
        editTextEnd(attributedText: mutable)
    }
    
    private func textStyleChange(_ style: GETextStyleEditView.TextStyle, _ isSelected: Bool) {
        guard let attributed = attributedStr else {
            return
        }
        let range = NSRange(location: 0, length: attributed.length)
        var mutable: NSAttributedString
        switch style {
        case .bold:
            mutable = GETextService.setAttributedString(attributed, isBold: isSelected, range: range)
        case .obliqueness:
            mutable = GETextService.setAttributedString(attributed, isObliqueness: isSelected, range: range)
        case .strikethrough:
            mutable = GETextService.setAttributedString(attributed, isStrikethrough: isSelected, range: range)
        case .underline:
            mutable = GETextService.setAttributedString(attributed, isUnderline: isSelected, range: range)
        }
        self.attributedStr = mutable
        editTextEnd(attributedText: mutable)
    }
    
    private func textHeadIndentChange(_ size: CGFloat) {
        guard let attributed = attributedStr else {
            return
        }
        let range = NSRange(location: 0, length: attributed.length)
        let mutable = GETextService.setAttributedString(attributed, headIndent: size, range: range)
        self.attributedStr = mutable
        editTextEnd(attributedText: mutable)
    }
    
    private func textAlignmentChange(_ alignment: NSTextAlignment) {
        guard let attributed = attributedStr else {
            return
        }
        let range = NSRange(location: 0, length: attributed.length)
        let mutable = GETextService.setAttributedString(attributed, alignment: alignment, range: range)
        self.attributedStr = mutable
        editTextEnd(attributedText: mutable)
    }
    
    private func textLineSpacingChange(_ lineSpacing: CGFloat) {
        guard let attributed = attributedStr else {
            return
        }
        let range = NSRange(location: 0, length: attributed.length)
        let mutable = GETextService.setAttributedString(attributed, lineSpacing: lineSpacing, range: range)
        self.attributedStr = mutable
        editTextEnd(attributedText: mutable)
    }
}
