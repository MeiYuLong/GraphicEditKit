//
//  GEUIImage+Extension.swift
//  GraphicEdit
//
//  Created by yulong mei on 2021/3/11.
//

import Foundation

extension UIImage {
    class func ge_creataImage(string: String) -> UIImage? {
        let view = UILabel()
        view.text = string
        view.backgroundColor = GEThemeColor
        view.textColor = UIColor.white
        view.font = UIFont.systemFont(ofSize: 12)
        view.textAlignment = .center
        view.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        view.layer.cornerRadius = 17.0
        view.layer.masksToBounds = true
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage
    }
    class func ge_createImage(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIImage {
    /// Pod中加载Image
    /// - Parameter name: ImageName
    /// - Returns: UIImage
    public static func ge_bundle(named: String) -> UIImage? {
        guard let bundlePath = Bundle(for: GEBaseViewController.self).resourcePath else { return nil }
        let bundle = Bundle(path: bundlePath + "/GraphicEditKit.bundle")
        return UIImage(named: named, in: bundle, compatibleWith: nil)
    }
}
