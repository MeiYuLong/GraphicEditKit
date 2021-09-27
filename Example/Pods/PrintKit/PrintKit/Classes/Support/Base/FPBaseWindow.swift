//
//  FPBaseWindow.swift
//  flashprint
//
//  Created by yulong mei on 2021/3/5.
//

import UIKit

class FPBaseWindow: UIWindow {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(vc: UIViewController) {
        self.init(frame: UIScreen.main.bounds)
        
        if #available(iOS 13.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.filter{ $0.activationState == .foregroundActive }.first
            if let scene = windowScene as? UIWindowScene {
                self.windowScene = scene
            }
        } else {
            // Fallback on earlier versions
        }
        self.windowLevel = .alert - 1
        self.backgroundColor = UIColor.init(FP_R: 0, FP_G: 0, FP_B: 0, alpha: 0.6)
        self.isHidden = false
        self.rootViewController = vc

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
