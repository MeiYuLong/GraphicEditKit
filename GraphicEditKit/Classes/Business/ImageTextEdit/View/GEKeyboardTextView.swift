//
//  GEKeyboardTextView.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/17.
//

import UIKit

class GEKeyboardTextView: GEPlaceHolderTextView {

    // 成为第一响应者回调
    public var becomeFirstResponderClosure: (() -> Void)?
    // 注销第一响应者回调
    public var resignFirstResponderClosure: (() -> Void)?
        
    override func becomeFirstResponder() -> Bool {
        self.becomeFirstResponderClosure?()
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        if result {
            self.resignFirstResponderClosure?()
        }
        return result
    }

}
