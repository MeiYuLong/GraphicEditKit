//
//  FPPaintManager.swift
//  FlashPainterKit
//
//  Created by yulong mei on 2021/9/24.
//

import Foundation

public class FPPaintManager {
    
    /// 绘制365小标签
    /// - Parameters:
    ///   - type: 尺寸类型
    ///   - data: 地址信息
    ///   - bottom: 底部边距
    /// - Returns: 图片
    public static func draw365Label(type: EPPrinterType = .P2, data: FPLabelBaseData, _ bottom: CGFloat = 10) -> UIImage {
        return EPPaint.shared.draw365Label(type: type, data: data, bottom: bottom)
    }
    
    /// 绘制快递小标签
    /// - Parameters:
    ///   - data: 订单数据
    ///   - bottom: 底部边距
    /// - Returns: 图片
    public static func drawPNOLabel(data: FPTicketLabelData, _ bottom: CGFloat = 10) -> UIImage {
        return FPPaint.shared.drawPNOLabel(data: data, bottom)
    }
}
