//
//  FD_BarcodeTools.swift
//  MYL_Jewelry
//
//  Created by yulong mei on 2021/3/10.
//

import Foundation

/// barcode使用的工具类
struct BarcodeTools {
    
    
    /// 将原始的pno进行加密
    /// - Parameter pno: ori pno
    /// - Returns: pno
    public static func secretPno(origin pno: String) -> String {
        var array = Array(pno)
        print("字符串转数组:\(array)")
        
        var sum = 0
        for i in  2 ..< (array.count-1) {
            
            let char = array[i]
            if char.isASCII, let ascii = array[i].asciiValue {
                sum += Int(ascii)
            }
        }
        let ret = sum % 8
        
        array[0] = ((ret & 4) == 4) ? Character(String(array[0]).uppercased()) : Character(String(array[0]).lowercased())
        array[1] = ((ret & 2) == 2) ? Character(String(array[1]).uppercased()) : Character(String(array[1]).lowercased())
        array[array.count-1] = ((ret & 1) == 1) ? Character(String(array[array.count-1]).uppercased()) : Character(String(array[array.count-1]).lowercased())
        
        let newCodeStr = String(array)
        print("数组转字符串:\(newCodeStr)")
        return newCodeStr
    }
    
    /// 生成条形码
    /// - Parameter IDCodeString: ID Code
    /// - Returns: 条形码图片
    static func generateBarCode(IDCodeString: String) -> UIImage? {
        
        // Create a new filter with the given name.
        guard let filter = CIFilter.init(name: "CICode128BarcodeGenerator") else {
            return nil
        }
        
        filter.setDefaults()
        
        //二维码数据
        //    NSString *QRMessage = [NSString stringWithFormat:@"heibais://heibaixiaoyuan.com?type=page&path=personinfo&userid=%@",[[Pub currentUserInfo].userId URLEncoding]];
        //    官方建议使用 NSISOLatin1StringEncoding 来编码，但经测试这种编码对中文或表情无法生成，改用 NSUTF8StringEncoding 就可以了。
        let inputData = IDCodeString.data(using: String.Encoding.ascii)
        
        //NSUTF8StringEncoding
        // 设置过滤器的输入值, KVC赋值
        filter.setValue(inputData, forKey: "inputMessage")
        filter.setValue(0, forKey: "inputQuietSpace")
        
        let outputImage = filter.outputImage
        // 图片小于(27,27),放大10倍
        if let ciimage = outputImage?.transformed(by: CGAffineTransform(scaleX: 10,y: 10)) {
            let barcodeImage = UIImage.init(ciImage: ciimage)
            return barcodeImage
        }else {
            return nil
        }
    }
}
