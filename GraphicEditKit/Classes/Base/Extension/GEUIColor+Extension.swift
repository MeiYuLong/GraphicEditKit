//
//  GEUIColor+Extension.swift
//  GraphicEdit
//
//  Created by yulong mei on 2021/3/11.
//

import Foundation

let GEMainTitleColor = UIColor.black
let GEMainButtonColor = UIColor.init(GE_R: 48, GE_G: 118, GE_B: 238)//UIColor.init(GE_R: 255, GE_G: 235, GE_B: 51)
let GETableViewBGColor = UIColor.init(GE_R: 244, GE_G: 244, GE_B: 244)
let GEMainBGColor = UIColor.white
let GEPlaceholderColor = UIColor.init(GE_R: 152, GE_G: 152, GE_B: 152)
let GEInputColor = UIColor.init(geHex: 0x313043)
let GESecondaryTitleColor = UIColor.init(GE_R: 102, GE_G: 102, GE_B: 102)
let GELineColor = UIColor.init(GE_R: 222, GE_G: 222, GE_B: 222)
let GEItemFillColor = UIColor.init(GE_R: 248, GE_G: 249, GE_B: 251)
let GELinkColor = UIColor.init(GE_R: 1, GE_G: 144, GE_B: 254)

let GEThemeColor = UIColor.init(GE_R:48, GE_G: 117, GE_B:238)
let GELayerColor = UIColor.init(GE_R:48, GE_G: 117, GE_B:238)
let GEBGColor = UIColor.init(GE_R:247, GE_G: 248, GE_B:250)
let GEShadowColor = UIColor.init(GE_R:0, GE_G: 0, GE_B:0)
let GEEditingTextBGColor = UIColor.init(GE_R:198, GE_G: 216, GE_B:234)
let GEBGAlphaColor = UIColor.init(GE_R:0, GE_G: 0, GE_B:0, alpha: 0.5)
let GETOPLineColor = UIColor.init(GE_R:247, GE_G: 248, GE_B:250)
let GETextPlaceholderColor = UIColor.init(GE_R: 220, GE_G: 222, GE_B: 224)

extension UIColor {
    
    convenience init(GE_R:CGFloat, GE_G:CGFloat, GE_B:CGFloat, alpha:CGFloat) {
        self.init(red: GE_R/255.0, green: GE_G/255.0, blue: GE_B/255.0, alpha: alpha)
    }
    
    convenience init(GE_R:CGFloat, GE_G:CGFloat, GE_B:CGFloat) {
        self.init(GE_R: GE_R, GE_G: GE_G, GE_B: GE_B, alpha: 1.0)
    }
    
    convenience init(geHex:UInt, alpha:CGFloat) {
        let r = ((geHex >> 16) & 0x000000FF)
        let g = ((geHex >> 8) & 0x000000FF)
        let b = ((geHex >> 0) & 0x000000FF)
        
        self.init(GE_R: CGFloat(r), GE_G: CGFloat(g), GE_B: CGFloat(b), alpha: alpha)
    }
    
    convenience init(geHex:UInt) {
        self.init(geHex: geHex, alpha: 1.0)
    }
    
    class func geRandomColor() -> UIColor {
        let seed:UInt32 = 256
        //获取一个范围是[0,256)的随机数
        let r = CGFloat(arc4random_uniform(seed))
        let g = CGFloat(arc4random_uniform(seed))
        let b = CGFloat(arc4random_uniform(seed))
        
        return UIColor(GE_R: r, GE_G: g, GE_B: b, alpha:1.0)
    }
    
    //        return UIColor(hue: weight, saturation: 1, brightness: 1, alpha: 1)
    //        /**
    //         * hue : 色调 0~1
    //         * saturation : 饱和度 0~1
    //         * brightness : 亮度 0~1
    //         */
    //    }
    
    
    func geImageWithColor(size: CGSize = CGSize.init(width: 1, height: 1)) -> UIImage? {
        
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor( self.cgColor )
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
