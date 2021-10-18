//
//  FP_Bundle+Extension.swift
//  FlashPainterKit
//
//  Created by yulong mei on 2021/9/24.
//

import Foundation

extension UIImage {
    
    /// Pod中加载Image
    /// - Parameter name: ImageName
    /// - Returns: UIImage
    static func make(name: String) -> UIImage? {
        guard let bundlePath = Bundle(for: FPPaint.self).resourcePath else { return nil }
        let bundle = Bundle(path: bundlePath + "/FlashPainterKit.bundle")
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
}
