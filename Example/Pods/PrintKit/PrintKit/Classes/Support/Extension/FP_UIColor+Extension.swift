//
//  FP_UIColor+Extension.swift
//  flashprint
//
//  Created by yulong mei on 2021/3/2.
//

import UIKit

let FPMainTitleColor = UIColor.black
let FPMainButtonColor = UIColor.init(FP_R: 255, FP_G: 235, FP_B: 51)
let FPTableViewBGColor = UIColor.init(FP_R: 244, FP_G: 244, FP_B: 244)
let FPMainBGColor = UIColor.white
let FPPlaceholderColor = UIColor.init(FP_R: 152, FP_G: 152, FP_B: 152)
let FPSecondaryTitleColor = UIColor.init(FP_R: 102, FP_G: 102, FP_B: 102)
let FPLineColor = UIColor.init(FP_R: 222, FP_G: 222, FP_B: 222)
let FPItemFillColor = UIColor.init(FP_R: 248, FP_G: 249, FP_B: 251)
let FPLinkColor = UIColor.init(FP_R: 1, FP_G: 144, FP_B: 254)
let FPNormalTextColor = UIColor.init(FP_R: 48, FP_G: 49, FP_B: 51)
let FPBlueTextColor = UIColor.init(FP_R: 22, FP_G: 155, FP_B: 213)
let FPRedButtonColor = UIColor.init(FP_R: 255, FP_G: 68, FP_B: 68)
let FPNoteBGColor = UIColor.init(FP_R: 255, FP_G: 219, FP_B: 51, alpha: 0.21)

extension UIColor {
    
    convenience init(FP_R:CGFloat, FP_G:CGFloat, FP_B:CGFloat, alpha:CGFloat = 1) {
        self.init(red: FP_R/255.0, green: FP_G/255.0, blue: FP_B/255.0, alpha: alpha)
    }
}
