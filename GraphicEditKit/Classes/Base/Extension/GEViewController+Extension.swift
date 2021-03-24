//
//  GEViewController+Extension.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/17.
//

import Foundation

extension UIViewController {
    
    //可在viewController即将消失之前调用的函数
    typealias GEDismissControllerClosure = (_ controller: UIViewController) -> Void
    
    //AlterController点击确定闭包
    typealias  GEAlertControlerConfirmClosure = (_ alertAction: UIAlertAction) -> Void
    //AlterController点击取消闭包
    typealias GEAlertControlerCancelClosure = (_ alertAction: UIAlertAction) -> Void
    
    
    @objc(onLeftBarClick:)
    func ge_onLeftBarClick(_ sender:UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc(onRightBarClick:)
    func ge_onRightBarClick(_ sender:UIBarButtonItem) {
        return
    }
    
    func ge_createLeftButtonWithImageName(_ name: String?, target: Any?) {
        
        if let imageName = name {
            
            if let image = UIImage.ge_bundle(named: imageName)?.withRenderingMode(.alwaysOriginal) {
                
                let leftItem = UIBarButtonItem.init(image: image, style: .plain, target: target, action: #selector(ge_onLeftBarClick(_:)))
                self.navigationItem.leftBarButtonItem = leftItem
                
            }else {
                self.navigationItem.leftBarButtonItem = UIBarButtonItem()
            }
            
        }else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem()
        }
    }
    
    func ge_createRightButtonWithImageName(_ name: String?, target: Any?) {
        
        if let imageName = name {
            
            if let image = UIImage.ge_bundle(named: imageName)?.withRenderingMode(.alwaysOriginal) {
                
                let rightItem = UIBarButtonItem.init(image: image, style: .plain, target: target, action: #selector(ge_onRightBarClick(_:)))
                self.navigationItem.rightBarButtonItem = rightItem
                
            }else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem()
            }
            
        }else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem()
        }
        
    }
    
    func ge_createButtonWithView(_ customView: UIView?) {
        if let view = customView {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: view)
        }else{
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func ge_createButtonWithTitle(_ title: String?, target: Any?) {
        
        let rightItem = UIBarButtonItem.init(title: title, style: .plain, target: target, action: #selector(ge_onRightBarClick(_:)))
        rightItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:GEMainTitleColor,NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16)], for: .normal)
        rightItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:GEPlaceholderColor,NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16)], for: .disabled)
        rightItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:GEPlaceholderColor,NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16)], for: .highlighted)
        
        self.navigationItem.rightBarButtonItem = rightItem
        
    }
    
    /**
     * param confirmHandle确定按钮的事件回调
     * param confirmHandle取消按钮的事件回调
     */
    func ge_showAlertController(title: String?, message: String?, leftTitle: String?, rightTitle: String, confirmHandle: GEAlertControlerConfirmClosure? = nil, cancelHandle: GEAlertControlerCancelClosure? = nil) {
        
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction.init(title: rightTitle, style: .default) {  (action) in
            
            if let closure = confirmHandle {
                closure(action)
            }
        }
        alertController.addAction(confirmAction)
        
        if let cancelTitle = leftTitle {
            
            let cancelAction = UIAlertAction.init(title: cancelTitle, style: .cancel) { (action) in
                if let closure = cancelHandle {
                    closure(action)
                }
            }
            alertController.addAction(cancelAction)
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
}

