//
//  GEImageEditManager.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/17.
//

import Foundation

/// 图片编辑管理
class GEImageEditManager {
    static let shared = GEImageEditManager()
    
    var toolBar: GEToolBar?
    var editViewModel: GEBaseEditViewModel?
    var active: Bool = false
    
    // 定义InputView设置回调处理
    typealias GESetInputViewHandler = (UIView) -> Void
    var setInputViewHandler: GESetInputViewHandler?
    
    // 定义编辑结束回调处理   (结果图片, 亮度值， 对比度值)
    typealias GEEditImageDoneHandler = (UIImage, CGFloat?, CGFloat?) -> Void
    var editDoneHandler: GEEditImageDoneHandler?

    // 定义注销响应者回调处理
    typealias  GEImageResignFirstHandler = () -> Void
    var resignFirstHandler: GEImageResignFirstHandler?
    
    init() {}
    
    public func startEditImage(viewModel: GEBaseEditViewModel, done: @escaping GEEditImageDoneHandler, resignFirst: @escaping GEImageResignFirstHandler) {
        self.editViewModel = viewModel
        self.editDoneHandler = done
        if let resignhadler = self.resignFirstHandler {
            resignhadler()
        }
        self.resignFirstHandler = resignFirst
        self.active = true
        self.toolBar?.setSelected(index: 2)
    }
    
    public func editImageEnd(brightness: Float?, contrast: Float?) {
        guard let viewModel = self.editViewModel else {
            return
        }
        if let brightness = brightness {
            var newValue = brightness
            // 设置阈值
            if brightness <= -0.6 {
                newValue = -0.6
            }
            if brightness >= 0.6 {
                newValue = 0.6
            }
            let image = GEImageService.setImage(viewModel.orginImage, brightness: CGFloat(newValue))
            guard let newImage = image else {
                return
            }
            self.editDoneHandler?(newImage, brightness50Value(value: CGFloat(brightness)), nil)
        }
        if let contrast = contrast {
            var newValue = contrast
            // 设置阈值
            if contrast <= 0.2 {
                newValue = 0.2
            }
            let image = GEImageService.setImage(viewModel.orginImage, contrast: CGFloat(newValue))
            guard let newImage = image else {
                return
            }
            self.editDoneHandler?(newImage, nil, contrast50Value(value: CGFloat(contrast)))
        }
    }
    
    public func continueEdit(viewModel: GEBaseEditViewModel, done: @escaping GEEditImageDoneHandler, resignFirst: @escaping GEImageResignFirstHandler) {
        // 当工具栏选中时才设置编辑
        if self.toolBar?.currentIndex == 2 {
            self.editViewModel = viewModel
            self.editDoneHandler = done
            self.resignFirstHandler = resignFirst
            self.active = true
        }else{
            if active {
                endEditStatus()
            }
        }
    }
    
    /// 结束编辑状态
    public func endEditStatus() {
        guard let _ = self.editViewModel else {
            return
        }
        self.editViewModel = nil
        self.editDoneHandler = nil
        if let resignhadler = self.resignFirstHandler {
            resignhadler()
        }
        self.resignFirstHandler = nil
        self.active = false
        self.toolBar?.hide()
    }
    
    // -1~1 / 0.02 => -50~50
    private func brightness50Value(value: CGFloat) -> CGFloat{
        let result =  value / 0.02
        return result
    }
    
    // 0~4 / 0.04 => -50~50
    // 对比度0.0 ～ 4.0，默认为1.0-------项目中和安卓实现统一取值0～2，1为正常
    // (0~2 * 50 -50) =>-50~50
    private func contrast50Value(value: CGFloat) -> CGFloat {
        let result = value * 50 - 50
        return result
    }
    
    public func getBrightness() -> Float{
        return Float(self.editViewModel?.brightness ?? 0)
    }
    
    public func getContrast() -> Float{
        return Float(self.editViewModel?.contrast ?? 0)
    }
}
