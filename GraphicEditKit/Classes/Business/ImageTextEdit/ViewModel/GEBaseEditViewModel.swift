//
//  GEBaseEditViewModel.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/16.
//

import Foundation
/// 处理文本图片编辑框的数据交互
class GEBaseEditViewModel {
    var viewLayerData:  GEImageTextLayer!
    
    /// 第一次渲染的data，宽高不变，x、y随拖动变化
    var data: GEImageTextLayer? {
        didSet {
            viewLayerData = data
        }
    }
    
    var orgin: CGPoint? {
        didSet {
            viewLayerData.x = orgin?.x
            viewLayerData.y = orgin?.y
        }
    }
    
    /// 文本框的Frame是动态变化的，（图片的记录数据是初始图片的宽高不变）
    var frame: CGRect? {
        didSet {
            viewLayerData.x = frame?.origin.x
            viewLayerData.y = frame?.origin.y
            viewLayerData.width = frame?.width
            viewLayerData.height = frame?.height
        }
    }
    
    var scale: CGFloat? {
        didSet {
            viewLayerData.scale = scale
        }
    }
    
    var rotate: CGFloat? {
        didSet {
            viewLayerData.rotate = rotate
        }
    }
    
    /// 亮度对比度编辑的原始图片 裁剪后的图片
    var orginImage: UIImage? {
        didSet {
            if let info = viewLayerData.imageInfo {
                info.image = orginImage
            }else {
                let imageInfo = GEImageInfo()
                imageInfo.image = orginImage
                viewLayerData.imageInfo = imageInfo
            }
        }
    }
    
    /// 显示用的图片 裁剪后的图片、亮度对比度编辑后的图片
    var currentImage: UIImage? {
        didSet {
            if let info = viewLayerData.imageInfo {
                info.showImage = currentImage
            }else {
                let imageInfo = GEImageInfo()
                imageInfo.image = currentImage
                imageInfo.showImage = currentImage
                viewLayerData.imageInfo = imageInfo
            }
        }
    }
    
    var brightness: CGFloat? {
        didSet {
            if let info = viewLayerData.imageInfo, let bright = brightness {
                info.brightness = bright
            }
        }
    }
    
    var contrast: CGFloat? {
        didSet {
            if let info = viewLayerData.imageInfo, let contrast = contrast {
                info.contrast = contrast
            }
        }
    }
    
    var text: String? {
        didSet {
            let textInfo = GETextInfo()
            textInfo.text = text
            viewLayerData.textInfo = textInfo
        }
    }
    
    init() {
        viewLayerData = GEImageTextLayer()
    }

    
}
