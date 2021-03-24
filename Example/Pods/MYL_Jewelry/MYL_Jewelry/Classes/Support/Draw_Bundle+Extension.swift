//
//  Draw_UIImage+Extension.swift
//  MYL_Jewelry
//
//  Created by yulong mei on 2021/3/10.
//

import Foundation

extension UIImage {
    
    /// Pod中加载Image
    /// - Parameter name: ImageName
    /// - Returns: UIImage
    static func make(name: String) -> UIImage? {
        guard let bundlePath = Bundle(for: FlashDraw.self).resourcePath else { return nil }
        let bundle = Bundle(path: bundlePath + "/MYL_Jewelry.bundle")
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
}
