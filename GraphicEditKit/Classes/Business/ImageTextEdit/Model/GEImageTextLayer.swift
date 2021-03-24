//
//  GEImageTextLayer.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/16.
//

import Foundation

class GEImageTextLayer {
    var x: CGFloat?                 // 实际内容contentView放置想对与最底部TextView的x坐标
    var y: CGFloat?                 // 实际内容contentView放置想对与最底部TextView的放置的y坐标
    var width: CGFloat?             // 实际内容contentView宽度
    var height: CGFloat?            // 实际内容contentView高度
    var rotate: CGFloat?            // 旋转角度
    var scale: CGFloat?             // 缩放
    var drawIndex: Int?             // 绘制顺序
    var type: Int?                  // 内容类型 0图片 1文字
    var textInfo: GETextInfo?      // 文本信息
    var imageInfo: GEImageInfo?    // 图片信息
}
