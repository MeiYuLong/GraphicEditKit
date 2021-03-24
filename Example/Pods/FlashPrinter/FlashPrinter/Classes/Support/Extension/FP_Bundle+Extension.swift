//
//  FP_Bundle+Extension.swift
//  FlashPrinter
//
//  Created by yulong mei on 2021/3/15.
//

import Foundation

extension UIImage {
    /// Pod中加载Image
    /// - Parameter name: ImageName
    /// - Returns: UIImage
    public static func fp_make(name: String) -> UIImage? {
        guard let bundlePath = Bundle(for: FPBaseViewController.self).resourcePath else { return nil }
        let bundle = Bundle(path: bundlePath + "/FlashPrinter.bundle")
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
}
