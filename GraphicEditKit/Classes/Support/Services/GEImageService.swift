//
//  GEImageService.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/17.
//

import Foundation
import GPUImage
import CoreImage

class GEImageService {
    /// 调整图片效果
    /// - Parameters:
    ///   - image: 原始图
    ///   - brightness: 亮度-1.0 ～ 1.0，默认为0.0
    ///   - contrast: 对比度0.0 ～ 4.0，默认为1.0-------项目中和安卓实现统一取值0～2，1为正常
    ///   - frame: 所有参数都是0.0 ～ 1.0，起始点和宽高都是1，就是剪裁都是百分比
    /// - Returns: 返回处理好的图
    static func setImage(_ image: UIImage?, brightness: CGFloat, contrast: CGFloat, frame: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1 )) -> UIImage? {
        guard let image = image else { return nil }
        let picture = GPUImagePicture(image: image, smoothlyScaleOutput: true)
        let filterGroup = GPUImageFilterGroup()
        picture?.addTarget(filterGroup)
        let contrastFilter = GPUImageContrastFilter()
        let brightnessFilter = GPUImageBrightnessFilter()
        let cropFilter = GPUImageCropFilter()
        cropFilter.cropRegion = frame
        brightnessFilter.brightness = brightness
        contrastFilter.contrast = contrast
        filterGroup.ftp_addFilter(filter: cropFilter)
        filterGroup.ftp_addFilter(filter: contrastFilter)
        filterGroup.ftp_addFilter(filter: brightnessFilter)
        picture?.processImage()
        filterGroup.useNextFrameForImageCapture()
        let newImage = filterGroup.imageFromCurrentFramebuffer()
        return newImage
    }
    
    static func setImage(_ image: UIImage?, brightness: CGFloat) -> UIImage? {
        guard let image = image else { return nil }
        let brightnessFilter = GPUImageBrightnessFilter()
        brightnessFilter.brightness = brightness
        brightnessFilter.useNextFrameForImageCapture()
        let picture = GPUImagePicture(image: image, smoothlyScaleOutput: true)
        picture?.addTarget(brightnessFilter)
        picture?.processImage()
//        GPUImageContext.sharedFramebufferCache()?.addFramebuffer(toActiveImageCaptureList: picture?.framebufferForOutput())
        let newImage = brightnessFilter.imageFromCurrentFramebuffer(with: image.imageOrientation)
        return newImage
    }
    
    static func setImage(_ image: UIImage?, contrast: CGFloat) -> UIImage? {
        guard let image = image else { return nil }
        let contrastFilter = GPUImageContrastFilter()
        contrastFilter.contrast = contrast
        contrastFilter.useNextFrameForImageCapture()
        let picture = GPUImagePicture(image: image, smoothlyScaleOutput: true)
        picture?.addTarget(contrastFilter)
        picture?.processImage()
        let newImage = contrastFilter.imageFromCurrentFramebuffer(with: image.imageOrientation)
        return newImage
    }
    
    static func setImage(_ image: UIImage?, frame: CGRect) -> UIImage? {
        guard let image = image else { return nil }
        let cropFilter = GPUImageCropFilter()
        cropFilter.cropRegion = frame
        cropFilter.useNextFrameForImageCapture()
        let picture = GPUImagePicture(image: image, smoothlyScaleOutput: true)
        picture?.addTarget(cropFilter)
        picture?.processImage()
        let newImage = cropFilter.imageFromCurrentFramebuffer(with: image.imageOrientation)
        return newImage
    }
    
    static func textModel(image: UIImage?) -> UIImage? {
//        return self.grayModel(image: image)
        guard let image = image else { return nil }
//        let newImage1 = self.setImage(image, brightness: 0.15, contrast: 1.5)
        let picture = GPUImagePicture(image: image, smoothlyScaleOutput: true)
        let filterGroup = GPUImageFilterGroup()
        
        let f2 = GPUImageSharpenFilter()
        filterGroup.ftp_addFilter(filter: f2)
        f2.sharpness = 1.3
//
//        let f3 = GPUImageHighPassFilter()
//        f3.filterStrength = 0.9
//        filterGroup.ftp_addFilter(filter: f3)

        let f1 = GPUImageAverageLuminanceThresholdFilter()
        f1.thresholdMultiplier = 0.75
        filterGroup.ftp_addFilter(filter: f1)

        picture?.addTarget(filterGroup)
        picture?.processImage()
        filterGroup.useNextFrameForImageCapture()
        let newImage = filterGroup.imageFromCurrentFramebuffer()
        return newImage
    }

    static func imageModel(image: UIImage?) -> UIImage? {
        guard let image = image else { return nil }
        guard let newImage = self.grayModel(image:image) else { return nil }
//        let newImage = ZYFilterTool.freudSteinbergDitherImage(image)
        let newImage1 = FPFloydImage.image(with: newImage)
        return newImage1
    }
        
    static func grayModel(image: UIImage?) -> UIImage? {
        guard let image = image else { return nil }
        let picture = GPUImagePicture(image: image, smoothlyScaleOutput: true)
        let filterGroup = GPUImageFilterGroup()
        picture?.addTarget(filterGroup)
        let f2 = GPUImageSharpenFilter()
        filterGroup.ftp_addFilter(filter: f2)
        f2.sharpness = 1.3
        let f1 = GPUImageGrayscaleFilter()
        filterGroup.ftp_addFilter(filter: f1)
        picture?.processImage()
        filterGroup.useNextFrameForImageCapture()
        let newImage = filterGroup.imageFromCurrentFramebuffer()
        return newImage
    }
}
extension GPUImageFilterGroup {
    func ftp_addFilter(filter: GPUImageOutput & GPUImageInput) {
        self.addFilter(filter)
        let newTerminalFilter = filter
        let count = self.filterCount()
        if count == 1 {
            self.initialFilters = [newTerminalFilter]
            self.terminalFilter = newTerminalFilter
        } else {
            if let terminalFilter = self.terminalFilter, let initialFilters = self.initialFilters {
                terminalFilter.addTarget(newTerminalFilter)
                self.initialFilters = [initialFilters[0]]
                self.terminalFilter = newTerminalFilter
            }
        }
    }
}
