//
//  GENSAttributedString+Extension.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/17.
//

import Foundation

extension NSAttributedString {
    
    func ge_sizeFittingWidth(_ w: CGFloat) -> CGSize {
        let textStorage = NSTextStorage(attributedString: self)
        let size = CGSize(width: w, height: CGFloat.greatestFiniteMagnitude)
        let boundingRect = CGRect(origin: .zero, size: size)
        
        let textContainer = NSTextContainer(size: size)
        textContainer.lineFragmentPadding = 0
        
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        
        textStorage.addLayoutManager(layoutManager)
        
        layoutManager.glyphRange(forBoundingRect: boundingRect, in: textContainer)
        
        let rect = layoutManager.usedRect(for: textContainer)
        return rect.integral.size
    }
}


// NSFontAttributeName                设置字体属性，默认值：字体：Helvetica(Neue) 字号：12
// NSForegroundColorAttributeNam      设置字体颜色，取值为 UIColor对象，默认值为黑色
// NSBackgroundColorAttributeName     设置字体所在区域背景颜色，取值为 UIColor对象，默认值为nil, 透明色
// NSLigatureAttributeName            设置连体属性，取值为NSNumber 对象(整数)，0 表示没有连体字符，1 表示使用默认的连体字符
// NSKernAttributeName                设定字符间距，取值为 NSNumber 对象（整数），正值间距加宽，负值间距变窄
// NSStrikethroughStyleAttributeName  设置删除线，取值为 NSNumber 对象（
// NSStrikethroughColorAttributeName  设置删除线颜色，取值为 UIColor 对象，默认值为黑色
// NSUnderlineStyleAttributeName      设置下划线，取值为 NSNumber 对象（整数），枚举常量 NSUnderlineStyle中的值，与删除线类似
// NSUnderlineColorAttributeName      设置下划线颜色，取值为 UIColor 对象，默认值为黑色
// NSStrokeWidthAttributeName         设置笔画宽度，取值为 NSNumber 对象（整数），负值填充效果，正值中空效果
// NSStrokeColorAttributeName         填充部分颜色，不是字体颜色，取值为 UIColor 对象
// NSShadowAttributeName              设置阴影属性，取值为 NSShadow 对象
// NSTextEffectAttributeName          设置文本特殊效果，取值为 NSString 对象，目前只有图版印刷效果可用：
// NSBaselineOffsetAttributeName      设置基线偏移值，取值为 NSNumber （float）,正值上偏，负值下偏
// NSObliquenessAttributeName         设置字形倾斜度，取值为 NSNumber （float）,正值右倾，负值左倾
// NSExpansionAttributeName           设置文本横向拉伸属性，取值为 NSNumber （float）,正值横向拉伸文本，负值横向压缩文本
// NSWritingDirectionAttributeName    设置文字书写方向，从左向右书写或者从右向左书写
// NSVerticalGlyphFormAttributeName   设置文字排版方向，取值为 NSNumber 对象(整数)，0 表示横排文本，1 表示竖排文本
// NSLinkAttributeName                设置链接属性，点击后调用浏览器打开指定URL地址
// NSAttachmentAttributeName          设置文本附件,取值为NSTextAttachment对象,常用于文字图片混排
// NSParagraphStyleAttributeName      设置文本段落排版格式，取值为 NSParagraphStyle 对象

// NSUnderlineStyleNone   不设置删除线
// NSUnderlineStyleSingle 设置删除线为细单实线
// NSUnderlineStyleThick  设置删除线为粗单实线
// NSUnderlineStyleDouble 设置删除线为细双实线

// NSUnderlineStyleNone //没有下划线
// NSUnderlineStyleSingle //单下划线
// NSUnderlineStyleThick //粗下划线
// NSUnderlineStyleDouble //双下划线
// NSUnderlinePatternSolid //实心下划线
// NSUnderlinePatternDot //点下划线
// NSUnderlinePatternDash //破折号下划线
// NSUnderlinePatternDashDot //破折号和点下划线
// NSUnderlinePatternDashDotDot //一个破折号和两个点的下划线
// NSUnderlineByWord //下划线紧贴文字

// alignment 对齐；
// firstLineHeadIndent：首行缩进
// tailIndent：段落尾部缩进
// headIndent：段落前部缩进（左缩进？）
// maximumLineHeight：最大行高
// minimumLineHeight：最小行高
// lineSpacing：行间距
// paragraphSpacing：段落间距
// lineBreakMode：断行模式
// defaultWritingDirectionForLanguage：默认书写方向（可以指定某种语言）
// baseWritingDirection（基础的书写方向）

// NSLineBreakByCharWrapping;以字符为显示单位显示，后面部分省略不显示。
// NSLineBreakByClipping;剪切与文本宽度相同的内容长度，后半部分被删除。
// NSLineBreakByTruncatingHead;前面部分文字以……方式省略，显示尾部文字内容。
// NSLineBreakByTruncatingMiddle;中间的内容以……方式省略，显示头尾的文字内容。
// NSLineBreakByTruncatingTail;结尾部分的内容以……方式省略，显示头的文字内容。
// NSLineBreakByWordWrapping;以单词为显示单位显示，后面部分省略不显示。

extension NSAttributedString {
    
    open func setFont(_ font: UIFont, range: NSRange?) -> NSAttributedString {
        return self.setKey(.font, value: font, range: range)
    }
    func setTextColor(_ color: UIColor, range: NSRange?) -> NSAttributedString {
        return self.setKey(.foregroundColor, value: color, range: range)
    }
    func setStrokeWidth(_ width: Int, range: NSRange?) -> NSAttributedString {
        return self.setKey(.strokeWidth, value: width, range: range)
    }
    func setObliqueness(_ obliqueness: CGFloat, range: NSRange?) -> NSAttributedString{
        return self.setKey(.obliqueness, value: obliqueness, range: range)
    }
    func setUnderlineStyle(_ style: Int, range: NSRange?) -> NSAttributedString {
        return self.setKey(.underlineStyle, value: style, range: range)
    }
    func setUnderlineColor(_ color: UIColor, range: NSRange?) -> NSAttributedString {
        return self.setKey(.underlineColor, value: color, range: range)
    }
    func setStrikethroughStyle(_ style: Int, range: NSRange?) -> NSAttributedString {
        return self.setKey(.strikethroughStyle, value: style, range: range)
    }
    func setStrikethroughColor(_ color: UIColor, range: NSRange?) -> NSAttributedString {
        return self.setKey(.strikethroughColor, value: color, range: range)
    }
    func setParagraphStyle(_ style: NSParagraphStyle) -> NSAttributedString {
        return self.setKey(.paragraphStyle, value: style, range: nil)
    }
    func setKey(_ key: NSAttributedString.Key, value: Any?, range: NSRange?) -> NSAttributedString {
        var newRange: NSRange
        if let range = range {
            newRange = range
        } else {
            newRange = NSRange(location: 0, length: self.length)
        }
        let abString = NSMutableAttributedString(attributedString: self)
        if let value = value {
            abString.addAttributes([key:value], range: newRange)
        } else {
            abString.removeAttribute(key, range: newRange)
        }
        return abString
    }
    
    func valueForKey(_ key: NSAttributedString.Key, range: NSRange?) -> Any? {
        var newRange: NSRange
        if let range = range {
            newRange = range
        } else {
            newRange = NSRange(location: 0, length: self.string.count)
        }
        let value = self.attribute(key, at: 0, effectiveRange: &newRange)
        return value
    }
}

extension NSMutableAttributedString {
    
    /// 移除掉NSOriginalFont 当所使用的字体不支持字符串中的一个或多个字符时，将创建属性，会导致计算大小错误，不是预期结果
    func stripOriginalFont() {
        self.enumerateAttribute(NSAttributedString.Key(rawValue: "NSOriginalFont"), in: NSRange(location: 0, length: self.length), options: NSAttributedString.EnumerationOptions(rawValue: 0)) { (value, range, _) in
            guard let _ = value else {
                return
            }
            self.removeAttribute(NSAttributedString.Key(rawValue: "NSOriginalFont"), range: range)
        }
    }
}
