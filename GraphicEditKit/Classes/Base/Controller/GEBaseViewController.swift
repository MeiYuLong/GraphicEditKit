//
//  GEBaseViewController.swift
//  GraphicEdit
//
//  Created by yulong mei on 2021/3/11.
//

import UIKit

public class GEBaseViewController: UIViewController {
    func safeAreaInsetsBottom() -> CGFloat {
        var value: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            value = self.view.safeAreaInsets.bottom
        }
        return value
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
    }
    func safeAreaInsetsTop() -> CGFloat {
        var value: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            value = self.view.safeAreaInsets.top
        }
        return value
    }
    
    func safeWindowAreaInsetsBottom() -> CGFloat {
        var value: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            value = UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0
        }
        return value
    }
    func safewindowAreaInsetsTop() -> CGFloat {
        var value: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            value = UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0
        }
        return value
    }
    
    func statusBarHeight() -> CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    func navHeight() -> CGFloat {
        return self.navigationController?.navigationBar.frame.height ?? 44
    }
}
