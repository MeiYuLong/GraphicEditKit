//
//  GEImageEditView.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/17.
//

import UIKit

class GEImageEditView: UIView {

    var brightness: Float = 0.0 {
        didSet {
            brightnessSlider.value = brightness
            brightnessSlider.setThumbImage(UIImage.ge_creataImage(string: String(format: "%d", Int(brightness))), for: .normal)
        }
    }
    var contrast: Float = 0.0 {
        didSet {
            contrastSlider.value = contrast
            contrastSlider.setThumbImage(UIImage.ge_creataImage(string: String(format: "%d", Int(contrast))), for: .normal)
        }
    }
    
    /// 图片亮度变更
    var brightnessChangedClosure: ((_ brightness: Float) -> Void)?
    
    ///图片对比度变更
    var contrastChangedClosure: ((_ contrast: Float) -> Void)?

    private lazy var brightnessIconView: UIImageView = {
        let view = UIImageView(image: UIImage.ge_bundle(named: "icon_tool_Lightness_default"))
        return view
    }()
    
    private lazy var contrastIconView: UIImageView = {
        let view = UIImageView(image: UIImage.ge_bundle(named: "icon_tool_contrastratio_default"))
        return view
    }()
    
    // -1~1
    private lazy var brightnessSlider: UISlider =  {
        let view = UISlider()
        view.minimumTrackTintColor = GEThemeColor
        view.setThumbImage(UIImage.ge_creataImage(string: "0"), for: .normal)
        view.minimumValue = -50
        view.maximumValue = 50
        view.value = 0
        return view
    }()
    
    // 0.0-4
    private lazy var contrastSlider: UISlider =  {
        let view = UISlider()
        view.minimumTrackTintColor = GEThemeColor
        view.setThumbImage(UIImage.ge_creataImage(string: "0"), for: .normal)
        view.minimumValue = -50
        view.maximumValue = 50
        view.value = 0
        return view
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadData()
        self.loadView()
        self.layoutSubview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.isUserInteractionEnabled = true
        lineView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 1)
        let iconLeft: CGFloat = 10.0
        let iconWidth: CGFloat = 24.0
        let sliderLeft: CGFloat = 56.0
        let sliderWidth: CGFloat = self.frame.width - sliderLeft - 42.0
        brightnessIconView.frame = CGRect(x: iconLeft, y: 46, width: iconWidth, height: iconWidth)
        brightnessSlider.frame = CGRect(x: sliderLeft, y: 46, width: sliderWidth, height: iconWidth)
        contrastIconView.frame = CGRect(x: iconLeft, y: 122, width: iconWidth, height: iconWidth)
        contrastSlider.frame = CGRect(x: sliderLeft, y: 122, width: sliderWidth, height: iconWidth)
        
        brightnessSlider.addTarget(self, action: #selector(brightnessSliderChanged(_:)), for: .valueChanged)
        contrastSlider.addTarget(self, action: #selector(contrastSliderChanged(_:)), for: .valueChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadData() {
        
    }
    
    func loadView() {
        self.backgroundColor = .white
        self.addSubview(lineView)
        self.addSubview(brightnessIconView)
        self.addSubview(contrastIconView)
        self.addSubview(brightnessSlider)
        self.addSubview(contrastSlider)
    }
    
    func layoutSubview() {
        
    }

}

//MARK: Logic
extension GEImageEditView {
    
    @objc func brightnessSliderChanged(_ sender: UISlider) {
        let value = sender.value
        brightnessSlider.setThumbImage(UIImage.ge_creataImage(string: String(format: "%d", Int(value))), for: .normal)
        self.brightnessChangedClosure?(brightnessRealValue(value: value))
    }
    
    @objc func contrastSliderChanged(_ sender: UISlider) {
        let value = sender.value
        contrastSlider.setThumbImage(UIImage.ge_creataImage(string: String(format: "%d", Int(value))), for: .normal)
        self.contrastChangedClosure?(contrastRealValue(value: value))
    }
    
    // -50~50 * 0.02 => -1~1
    private func brightnessRealValue(value: Float) -> Float{
        let result = 0.02 * value
        return result
    }
    
    // 对比度0.0 ～ 4.0，默认为1.0-------项目中和安卓实现统一取值0～2，1为正常
    // （-50~50 + 50） / 50  => 0~2
    private func contrastRealValue(value: Float) -> Float {
        let result = (value + 50) / 50
        return result
    }
}
