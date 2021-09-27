//
//  FP_UIView+FrameExtension.swift
//  flashprint
//
//  Created by yulong mei on 2021/3/4.
//

import UIKit

extension UIView {
    
    var minX: CGFloat {
        get {
            return self.frame.minX
        }
        set {
            let frame = CGRect.init(x: newValue, y: self.frame.minY, width: self.frame.width, height: self.frame.height)
            self.frame = frame
        }
    }
    
    var minY: CGFloat {
        get {
            return self.frame.minY
        }
        set {
            let frame = CGRect.init(x: self.frame.minX, y: newValue, width: self.frame.width, height: self.frame.height)
            self.frame = frame
        }
    }
    
    var width: CGFloat {
        get {
            return self.frame.width
        }
        set {
            let frame = CGRect.init(x: self.frame.minX, y: self.frame.minY, width: newValue, height: self.frame.height)
            self.frame = frame
        }
    }
    
    var height: CGFloat {
        get {
            return self.frame.height
        }
        set {
            let frame = CGRect.init(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: newValue)
            self.frame = frame
        }
    }
    
    var midX: CGFloat {
        get {
            return self.frame.midX
        }
        set {
            let center = CGPoint(x: self.center.x, y: newValue)
            self.center = center
        }
    }
    
    var midY: CGFloat {
        get {
            return self.frame.midY
        }
        set {
            let center = CGPoint(x: newValue, y: self.center.y)
            self.center = center
        }
    }
    
    var maxX: CGFloat {
        get {
            return self.frame.maxX
        }
    }
    
    var maxY: CGFloat {
        get {
            return self.frame.maxY
        }
    }
    
    var size: CGSize {
        get {
            return self.frame.size
        }
        set {
            let frame = CGRect(origin: self.frame.origin, size: newValue)
            self.frame = frame
        }
    }
    
    var origin: CGPoint {
        get {
            return self.frame.origin
        }
        set {
            let frame = CGRect(origin: newValue, size: self.frame.size)
            self.frame = frame
        }
    }
    
    var boundsCenter: CGPoint {
        get {
            return CGPoint(x:self.width/2, y:self.height/2)
        }
    }
}
