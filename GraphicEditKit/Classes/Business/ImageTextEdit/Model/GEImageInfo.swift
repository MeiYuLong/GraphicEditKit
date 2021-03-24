//
//  GEImageInfo.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/16.
//

import Foundation

class GEImageInfo {
//    var path: String?           // 图片路径，相对路径
//    var cropX: CGFloat?         // 裁剪点x坐标
//    var cropY: CGFloat?         // 裁剪点y坐标
//    var cropWidth: CGFloat?     // 裁剪宽度
//    var cropHeight: CGFloat?    // 裁剪高度
    var brightness: CGFloat?    // 亮度 -1.0到1.0 => 公共对应 -50～50
    var contrast: CGFloat?      // 对比度 0.0到4.0 => 公共对应 -50～50
    
    var image: UIImage?         // 数据中Origin Image，对比度、亮度作用的Image
    
    var showImage: UIImage?     // 用来显示的Image
}
