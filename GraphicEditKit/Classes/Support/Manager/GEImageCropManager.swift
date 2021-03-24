//
//  GEImageCropManager.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/17.
//

import Foundation

class GEImageCropManager {
    
    var image: UIImage?
    
    static let shared = GEImageCropManager()
    init() {}
    
    // 定义InputView设置回调处理
    typealias CropImageHandler = (UIImage) -> Void
    var cropImageHandler: CropImageHandler?
    
    public func startImageCrop(image: UIImage?, handler: @escaping CropImageHandler) {
        
        guard let img =  image else { return }
        self.cropImageHandler = handler
        self.image = img
        let cropController = GEImageCropViewController()
        cropController.image = img
        cropController.cropImageClosure = { [weak self](image) in
            self?.cropImageHandler?(image)
        }
        UIApplication.shared.delegate?.window??.rootViewController?.show(cropController, sender: self)
    }
}
