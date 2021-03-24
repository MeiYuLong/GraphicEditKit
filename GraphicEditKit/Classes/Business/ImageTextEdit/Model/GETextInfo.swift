//
//  GETextInfo.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/16.
//

import Foundation

class GETextInfo {
    var text: String?                       // 文字内容
    var textStyles: [GETextInfoStyle]?     // 样式列表
}

class GETextInfoStyle {
    var style: TextStyle?       // 样式类型Int 0字号 1是否加粗 2是否倾斜 3是否有下划线 4是否有删除线 5行间距 6对齐方式 7首行缩进
    var location: Int?          // 应用样式的起始位置
    var length: Int?            // 应用样式的长度
    var value: Any?             // 应用样式的值，根据style判断值类型
}

extension GETextInfoStyle {
    enum TextStyle: Int {
        case fontSize = 0               // 字号 Float
        case bold = 1                   // 是否加粗 Bool
        case obliqueness = 2            // 是否倾斜 Bool
        case underline = 3              // 是否有下划线 Bool
        case strikethrough = 4          // 是否有删除线 Bool
        case lineSpacing = 5            // 行间距 Float
        case alignment = 6              // 对齐方式 Int 0居左，1居中，2居右，3末行对其
        case firstLineHeadIndent = 7    // 首行缩进 Float
    }
}
