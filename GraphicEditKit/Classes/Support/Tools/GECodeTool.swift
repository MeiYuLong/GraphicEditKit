//
//  GECodeTool.swift
//  GPUImage
//
//  Created by yulong mei on 2021/3/17.
//

import Foundation
import CoreImage

class GECodeTool {
    
    /// 生成二维码
    /// - Parameters:
    ///   - QRContent: 二维码内容
    ///   - QRImageSize: 二维码图片大小
    ///   - middleImage: 二维码中间的图
    ///   - middleImageBorderWidth: 如果有值，会给中间的图加边框
    /// - Returns: 二维码图片
    class public func QRCode(QRContent: String, QRImageSize: CGFloat, middleImage: UIImage? = nil, middleImageBorderWidth: CGFloat? = nil) -> UIImage {
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        filter?.setValue(QRContent.data(using: String.Encoding.utf8), forKey: "inputMessage")
        if let outputImage = filter?.outputImage {
            let qrCodeImage = setupHighDefinitionUIImage(outputImage, size: QRImageSize)
            if var image = middleImage {
                if let borderWidth = middleImageBorderWidth {
                    image = circleImageWithImage(image, borderWidth: borderWidth, borderColor: UIColor.white)
                }
                let newImage = syntheticImage(qrCodeImage, iconImage: image, width: 100, height: 100)
                return newImage
            }
            return qrCodeImage
        }
        return UIImage()
    }
    
    class private func syntheticImage(_ image: UIImage, iconImage:UIImage, width: CGFloat, height: CGFloat) -> UIImage{
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let x = (image.size.width - width) * 0.5
        let y = (image.size.height - height) * 0.5
        iconImage.draw(in: CGRect(x: x, y: y, width: width, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let newImage = newImage {
            return newImage
        }
        return UIImage()
    }

    class private func setupHighDefinitionUIImage(_ image: CIImage, size: CGFloat) -> UIImage {
        let integral: CGRect = image.extent.integral
        let proportion: CGFloat = min(size/integral.width, size/integral.height)
        
        let width = integral.width * proportion
        let height = integral.height * proportion
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: 0)!
        
        let context = CIContext(options: nil)
        let bitmapImage: CGImage = context.createCGImage(image, from: integral)!
        
        bitmapRef.interpolationQuality = CGInterpolationQuality.none
        bitmapRef.scaleBy(x: proportion, y: proportion);
        bitmapRef.draw(bitmapImage, in: integral);
        let image: CGImage = bitmapRef.makeImage()!
        return UIImage(cgImage: image)
    }
    
    class private func circleImageWithImage(_ sourceImage: UIImage, borderWidth: CGFloat, borderColor: UIColor) -> UIImage {
        let imageWidth = sourceImage.size.width + 2 * borderWidth
        let imageHeight = sourceImage.size.height + 2 * borderWidth
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageWidth, height: imageHeight), false, 0.0)
        UIGraphicsGetCurrentContext()
        
        let radius = (sourceImage.size.width < sourceImage.size.height ? sourceImage.size.width:sourceImage.size.height) * 0.5
        let bezierPath = UIBezierPath(arcCenter: CGPoint(x: imageWidth * 0.5, y: imageHeight * 0.5), radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        bezierPath.lineWidth = borderWidth
        borderColor.setStroke()
        bezierPath.stroke()
        bezierPath.addClip()
        sourceImage.draw(in: CGRect(x: borderWidth, y: borderWidth, width: sourceImage.size.width, height: sourceImage.size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    /// 生成条形码
    /// - Parameters:
    ///   - code: Code
    ///   - size: BarCodeImage Size
    /// - Returns: UIImage
    class public func BarCodeWithTitle(code: String, size: CGSize) -> UIImage {
        
        let data = code.data(using: .isoLatin1, allowLossyConversion: false)
        let filter = CIFilter.init(name: "CICode128BarcodeGenerator",
                                   parameters: ["inputMessage": data ?? Data(),
                                               "inputQuietSpace": 0])
        if let outputImage = filter?.outputImage {
            return  autoSizeImage(image: outputImage, code: code, size: size)
        }
        return UIImage()
    }
    
    class func autoSizeImage(image: CIImage, code: String, size: CGSize) -> UIImage {
        let integralRect = image.extent.integral
        let imageSize = CGSize(width: size.width - 20 , height: size.height)
        let barcodeImage = image.transformed(by: CGAffineTransform(scaleX: imageSize.width / integralRect.width, y: imageSize.height / integralRect.height))

        let titleSize = calculateTextSize(text: code, maxSize: CGSize(width: size.width - 20, height: CGFloat(MAXFLOAT)))
        let titleSpace: CGFloat = 5
        let allHeight = size.height + titleSize.height + titleSpace * 2
        
        let titleRect = CGRect(x: (size.width - titleSize.width) / 2, y: size.height + titleSpace, width: titleSize.width, height: titleSize.height)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: titleSize.width, height: titleSize.height))
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = code
        label.textColor = .black

        let codeImage = UIImage(ciImage: barcodeImage)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size.width, height: allHeight), false, 5.0)
        codeImage.draw(in: CGRect(x: 10, y: 0, width: size.width - 20, height: size.height), blendMode: CGBlendMode.darken, alpha: 1)
        label.drawText(in: titleRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ??  UIImage()
    }
    
    class func calculateTextSize(text: String, maxSize: CGSize) -> CGSize {
        
        var size = CGSize.init(width: 0, height: 0)
        let textNS = (text as NSString)
        size = textNS.boundingRect(with: CGSize(width: maxSize.width, height: maxSize.height), options:[NSStringDrawingOptions.truncatesLastVisibleLine,NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.usesFontLeading] , attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16)], context: nil).size
        
        return size
    }
}
