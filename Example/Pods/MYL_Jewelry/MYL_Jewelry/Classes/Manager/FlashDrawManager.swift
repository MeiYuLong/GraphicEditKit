//
//  FlashDrawManager.swift
//  MYL_Jewelry
//
//  Created by yulong mei on 2021/3/10.
//

import Foundation

public class FlashDrawManager {
    
    public static func draw365Label(data: FDLabelBaseData, _ bottomMargin: CGFloat) -> UIImage {
        return FlashDraw.shared.draw365Label(data: data, bottomMargin)
    }
    
    public static func drawPNOLabel(data: FDTicketLabelData, _ bottomMargin: CGFloat) -> UIImage {
        return FlashDraw.shared.drawPNOLabel(data: data, bottomMargin)
    }
}
