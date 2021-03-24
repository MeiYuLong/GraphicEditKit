//
//  GETextEditView.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/16.
//

import UIKit

class GETextEditView: UIView {
    
    /// 文本编辑回调
    /// 文字大小
    var textFontSizeChanged: ((CGFloat) -> Void)?
    /// 文字样式
    var textStyleChanged: ((GETextStyleEditView.TextStyle, Bool) -> Void)?
    
    /// 头缩进
    var textHeadIndentChanged: ((_ size: CGFloat) -> Void)?
    /// 排版
    var textAlignmentChanged: ((_ alignment: NSTextAlignment) -> Void)?
    /// 行高
    var textLineSpacingChanged: ((_ spacing: CGFloat) -> Void)?
    
    
    var textAttributedStrChangedClosure: ((NSAttributedString) -> Void)?
    
    var showAligment: Bool = true {
        didSet {
            if !showAligment {
                textAlignmentButton.isHidden = true
            }
        }
    }
    
    lazy var textStyleButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage.ge_bundle(named: "icon_tool_fontstyle_default"), for: .normal)
        view.addTarget(self, action: #selector(clickTextStyle), for: .touchUpInside)
        let color = UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1)
        view.setBackgroundImage(UIImage.ge_createImage(color: color), for: .normal)
        view.setBackgroundImage(UIImage.ge_createImage(color: UIColor.white), for: .selected)
        view.isSelected = true
        return view
    }()
    lazy var textAlignmentButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage.ge_bundle(named: "icon_tool_align_default"), for: .normal)
        view.addTarget(self, action: #selector(clickTextAlignment), for: .touchUpInside)
        let color = UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1)
        view.setBackgroundImage(UIImage.ge_createImage(color: color), for: .normal)
        view.setBackgroundImage(UIImage.ge_createImage(color: UIColor.white), for: .selected)
        return view
    }()
    lazy var textStyleEditView: GETextStyleEditView = {
        let view = GETextStyleEditView()
        view.sizeChange = { [weak self](size) in
            self?.textFontSizeChanged?(size)
        }
        view.styleChange = { [weak self](style, isSelected) in
            self?.textStyleChanged?(style, isSelected)
        }
        return view
    }()
    lazy var textAlignmentEditView: GETextAlignmentEditView = {
        let view = GETextAlignmentEditView()
        view.headIndentChange = { [weak self](size) in
            self?.textHeadIndentChanged?(size)
        }
        view.textAlignmentChange = { [weak self](aligment) in
            self?.textAlignmentChanged?(aligment)
        }
        view.lineSpacingChange = { [weak self](spacing) in
            self?.textLineSpacingChanged?(spacing)
        }
        view.isHidden = true
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
        self.layoutSubview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadData() {
        
    }
    
    func loadView() {
        self.backgroundColor = .white
        self.addSubview(textStyleButton)
        self.addSubview(textAlignmentButton)
        self.addSubview(textStyleEditView)
        self.addSubview(textAlignmentEditView)
    }
    
    func layoutSubview() {
        let buttonWidth: CGFloat = 48.0
        let buttonHeight: CGFloat = 98.0

        textStyleButton.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
        textAlignmentButton.frame = CGRect(x: 0, y: buttonHeight, width: buttonWidth, height: buttonHeight)
        textStyleEditView.frame = CGRect(x: buttonWidth, y: 0, width: self.frame.width - buttonWidth, height: self.frame.height)
        textAlignmentEditView.frame = CGRect(x: buttonWidth, y: 0, width: self.frame.width - buttonWidth, height: self.frame.height)
    }

}

//MARK: Logic
extension GETextEditView {
    @objc func clickTextStyle() {
        guard !textStyleButton.isSelected else { return }
        textStyleButton.isSelected = true
        textAlignmentButton.isSelected = false
        textStyleEditView.isHidden = false
        textAlignmentEditView.isHidden = true
    }
    
    @objc func clickTextAlignment() {
        guard !textAlignmentButton.isSelected else { return }
        textStyleButton.isSelected = false
        textAlignmentButton.isSelected = true
        textStyleEditView.isHidden = true
        textAlignmentEditView.isHidden = false
    }
    

}

class GETextStyleEditView: UIView {
    var fontSize: CGFloat = 12.0 {
        didSet {
            sizeSlider.setThumbImage(UIImage.ge_creataImage(string: String(format: "%.0f", fontSize)), for: .normal)
            sizeSlider.value = Float(fontSize)
        }
    }
    var isBold: Bool = false {
        didSet {
            boldButton.isSelected = isBold
        }
    }
    var isObliqueness: Bool = false {
        didSet {
            obliquenessButton.isSelected = isObliqueness
        }
    }
    var isUnderline: Bool = false {
        didSet {
            underlineButton.isSelected = isUnderline
        }
    }
    var isStrikethrough: Bool = false {
        didSet {
            strikethroughButton.isSelected = isStrikethrough
        }
    }
    
    let minFontSize: CGFloat = 16.0
    let maxFontSize: CGFloat = 100.0
    
    var sizeChange: ((_ size: CGFloat) -> Void)?
    var styleChange: ((_ style: GETextStyleEditView.TextStyle, _ isSelected: Bool) -> Void)?

    private lazy var plusSizeButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage.ge_bundle(named: "icon_tool_fontsizeplus_default"), for: .normal)
        view.setImage(UIImage.ge_bundle(named: "icon_tool_fontsizeplus_disable"), for: .disabled)
        view.addTarget(self, action: #selector(clickPlusSize), for: .touchUpInside)
        return view
    }()
    
    private lazy var minusSizeButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage.ge_bundle(named: "icon_tool_fontsizeminus_default"), for: .normal)
        view.setImage(UIImage.ge_bundle(named: "icon_tool_fontsizeminus_disable"), for: .disabled)
        view.addTarget(self, action: #selector(clickMinusSize), for: .touchUpInside)
        return view
    }()
    
    private lazy var sizeSlider: UISlider =  {
        let view = UISlider()
        view.minimumTrackTintColor = GEThemeColor
        view.setThumbImage(UIImage.ge_creataImage(string: String(format: "%.0f", minFontSize)), for: .normal)
        view.addTarget(self, action: #selector(sliderChange), for: .valueChanged)
        view.minimumValue = Float(minFontSize)
        view.maximumValue = Float(maxFontSize)
        return view
    }()

    private lazy var boldButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage.ge_bundle(named: "icon_tool_bold_default"), for: .normal)
        view.setImage(UIImage.ge_bundle(named: "icon_tool_bold_selected"), for: .selected)
        view.addTarget(self, action: #selector(clickBold), for: .touchUpInside)
        return view
    }()

    private lazy var obliquenessButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage.ge_bundle(named: "icon_tool_inclined_default"), for: .normal)
        view.setImage(UIImage.ge_bundle(named: "icon_tool_inclined_selected"), for: .selected)
        view.addTarget(self, action: #selector(clickObliqueness), for: .touchUpInside)
        return view
    }()

    private lazy var underlineButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage.ge_bundle(named: "icon_tool_underline_default"), for: .normal)
        view.setImage(UIImage.ge_bundle(named: "icon_tool_underline_selected"), for: .selected)
        view.addTarget(self, action: #selector(clickUnderline), for: .touchUpInside)
        return view
    }()

    private lazy var strikethroughButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage.ge_bundle(named: "icon_tool_strikethrough_default"), for: .normal)
        view.setImage(UIImage.ge_bundle(named: "icon_tool_strikethrough_selected"), for: .selected)
        view.addTarget(self, action: #selector(clickStrikethrough), for: .touchUpInside)
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
        self.layoutSubview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadData() {
        
    }
    
    func loadView() {
        self.addSubview(plusSizeButton)
        self.addSubview(minusSizeButton)
        self.addSubview(sizeSlider)
        self.addSubview(boldButton)
        self.addSubview(obliquenessButton)
        self.addSubview(underlineButton)
        self.addSubview(strikethroughButton)
    }
    
    func layoutSubview() {
        let leftSpacing: CGFloat = 16.0
        let top1: CGFloat = 36.0
        let top2: CGFloat = 112.0
        let spacing: CGFloat = 12.0
        let buttonWidth: CGFloat = 44.0
        let buttonHeight: CGFloat = buttonWidth
        let sliderWidth: CGFloat = self.frame.width - ((leftSpacing + spacing + buttonWidth) * 2)
        minusSizeButton.frame = CGRect(x: leftSpacing , y: top1, width: buttonWidth, height: buttonHeight)
        sizeSlider.frame = CGRect(x: minusSizeButton.frame.maxX + spacing, y: top1, width: sliderWidth, height: buttonHeight)
        plusSizeButton.frame = CGRect(x: sizeSlider.frame.maxX + spacing, y: top1, width: buttonWidth, height: buttonHeight)
        boldButton.frame = CGRect(x: leftSpacing, y: top2, width: buttonWidth, height: buttonHeight)
        obliquenessButton.frame = CGRect(x: boldButton.frame.maxX + leftSpacing, y: top2, width: buttonWidth, height: buttonHeight)
        underlineButton.frame = CGRect(x: obliquenessButton.frame.maxX + leftSpacing, y: top2, width: buttonWidth, height: buttonHeight)
        strikethroughButton.frame = CGRect(x: underlineButton.frame.maxX + leftSpacing, y: top2, width: buttonWidth, height: buttonHeight)

    }
}

//MARK: Logic
extension GETextStyleEditView {
    enum TextStyle {
        case bold
        case obliqueness
        case underline
        case strikethrough
    }

    @objc func clickPlusSize() {
        let newValue = fontSize + 1
        fontSize = newValue >= maxFontSize ? maxFontSize : newValue
        self.sizeChange?(fontSize)
    }
    @objc func sliderChange() {
        fontSize = CGFloat(sizeSlider.value)
        self.sizeChange?(fontSize)
    }
    @objc func clickMinusSize() {
        let newValue = fontSize - 1
        fontSize = newValue <= minFontSize ? minFontSize : newValue
        self.sizeChange?(fontSize)
    }
    @objc func clickBold() {
        boldButton.isSelected = !boldButton.isSelected
        self.styleChange?(.bold, boldButton.isSelected)
    }
    @objc func clickObliqueness() {
        obliquenessButton.isSelected = !obliquenessButton.isSelected
        self.styleChange?(.obliqueness, obliquenessButton.isSelected)
    }
    @objc func clickUnderline() {
        underlineButton.isSelected = !underlineButton.isSelected
        self.styleChange?(.underline, underlineButton.isSelected)
    }
    @objc func clickStrikethrough() {
        strikethroughButton.isSelected = !strikethroughButton.isSelected
        self.styleChange?(.strikethrough, strikethroughButton.isSelected)
    }
}

class GETextAlignmentEditView: UIView {
    var textAlignment: NSTextAlignment = .left {
        didSet {
            self.updateAlignmentButton(alignment: textAlignment)
        }
    }
    var lineSpacing: CGFloat = 0.0 {
        didSet {
            lineSpacingSlider.setThumbImage(UIImage.ge_creataImage(string: String(format: "%.0f", lineSpacing)), for: .normal)
            lineSpacingSlider.value = Float(lineSpacing)
        }
    }
    var headIndent: CGFloat = 0.0
    
    let minLineSpacing: CGFloat = 0.0
    let maxLineSpacing: CGFloat = 100.0
    
    var headIndentChange: ((_ size: CGFloat) -> Void)?
    var textAlignmentChange: ((_ alignment: NSTextAlignment) -> Void)?
    var lineSpacingChange: ((_ spacing: CGFloat) -> Void)?

    private var selectedButton: UIButton?
    
    private lazy var plusLineSpacingButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage.ge_bundle(named: "icon_tool_rowspacingplus_default"), for: .normal)
        view.setImage(UIImage.ge_bundle(named: "icon_tool_rowspacingplus_disable"), for: .disabled)
        view.addTarget(self, action: #selector(clickPlusLineSpacing), for: .touchUpInside)
        return view
    }()
    
    private lazy var minusLineSpacingButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage.ge_bundle(named: "icon_tool_rowspacingminus_default"), for: .normal)
        view.setImage(UIImage.ge_bundle(named: "icon_tool_rowspacingminus_disable"), for: .disabled)
        view.addTarget(self, action: #selector(clickMinusLineSpacing), for: .touchUpInside)
        return view
    }()
    
    private lazy var lineSpacingSlider: UISlider =  {
        let view = UISlider()
        view.minimumTrackTintColor = GEThemeColor
        view.setThumbImage(UIImage.ge_creataImage(string: String(format: "%.0f", minLineSpacing)), for: .normal)
        view.addTarget(self, action: #selector(sliderChange), for: .valueChanged)
        view.minimumValue = Float(minLineSpacing)
        view.maximumValue = Float(maxLineSpacing)
        return view
    }()

    private lazy var leftButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage.ge_bundle(named: "icon_tool_alignleft_default"), for: .normal)
        view.setImage(UIImage.ge_bundle(named: "icon_tool_alignleft_selected"), for: .selected)
        view.addTarget(self, action: #selector(clickLeft), for: .touchUpInside)
        view.isSelected = true
        selectedButton = view
        return view
    }()

    private lazy var centerButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage.ge_bundle(named: "icon_tool_aligncenter_default"), for: .normal)
        view.setImage(UIImage.ge_bundle(named: "icon_tool_aligncenter_selected"), for: .selected)
        view.addTarget(self, action: #selector(clickCenter), for: .touchUpInside)
        return view
    }()

    private lazy var rightButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage.ge_bundle(named: "icon_tool_alignright_default"), for: .normal)
        view.setImage(UIImage.ge_bundle(named: "icon_tool_alignright_selected"), for: .selected)
        view.addTarget(self, action: #selector(clickRight), for: .touchUpInside)
        return view
    }()

    private lazy var plusHeadIndentButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage.ge_bundle(named: "icon_tool_indentleft_default"), for: .normal)
        view.addTarget(self, action: #selector(clickPlusHeadIndent), for: .touchUpInside)
        return view
    }()

    private lazy var minusHeadIndentButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage.ge_bundle(named: "icon_tool_indentright_default"), for: .normal)
        view.addTarget(self, action: #selector(clickMinusHeadIndent), for: .touchUpInside)
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
        self.layoutSubview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadData() {
        
    }
    
    func loadView() {
        self.addSubview(plusLineSpacingButton)
        self.addSubview(minusLineSpacingButton)
        self.addSubview(lineSpacingSlider)
        self.addSubview(leftButton)
        self.addSubview(centerButton)
        self.addSubview(rightButton)
        self.addSubview(plusHeadIndentButton)
        self.addSubview(minusHeadIndentButton)
    }
    
    func layoutSubview() {
        let leftSpacing: CGFloat = 16.0
        let top1: CGFloat = 36.0
        let top2: CGFloat = 112.0
        let spacing: CGFloat = 12.0
        let buttonWidth: CGFloat = 44.0
        let buttonHeight: CGFloat = buttonWidth
        let sliderWidth: CGFloat = self.frame.width - ((leftSpacing + spacing + buttonWidth) * 2)
        leftButton.frame = CGRect(x: leftSpacing, y: top1, width: buttonWidth, height: buttonHeight)
        centerButton.frame = CGRect(x: leftButton.frame.maxX + leftSpacing, y: top1, width: buttonWidth, height: buttonHeight)
        rightButton.frame = CGRect(x: centerButton.frame.maxX + leftSpacing, y: top1, width: buttonWidth, height: buttonHeight)
        plusHeadIndentButton.frame = CGRect(x: rightButton.frame.maxX + leftSpacing, y: top1, width: buttonWidth, height: buttonHeight)
        minusHeadIndentButton.frame = CGRect(x: plusHeadIndentButton.frame.maxX + leftSpacing, y: top1, width: buttonWidth, height: buttonHeight)
        
        minusLineSpacingButton.frame = CGRect(x: leftSpacing , y: top2, width: buttonWidth, height: buttonHeight)
        lineSpacingSlider.frame = CGRect(x: minusLineSpacingButton.frame.maxX + spacing, y: top2, width: sliderWidth, height: buttonHeight)
        plusLineSpacingButton.frame = CGRect(x: lineSpacingSlider.frame.maxX + spacing, y: top2, width: buttonWidth, height: buttonHeight)
    }
}

//MARK: Logic
extension GETextAlignmentEditView {
    @objc private func clickPlusLineSpacing() {
        let newValue = lineSpacing + 1
        lineSpacing = newValue >= maxLineSpacing ? maxLineSpacing : newValue
        self.lineSpacingChange?(lineSpacing)
    }
    @objc private func sliderChange() {
        lineSpacing = CGFloat(lineSpacingSlider.value)
        self.lineSpacingChange?(lineSpacing)
    }
    @objc private func clickMinusLineSpacing() {
        let newValue = lineSpacing - 1
        lineSpacing = newValue <= minLineSpacing ? minLineSpacing : newValue
        self.lineSpacingChange?(lineSpacing)
    }
    @objc private func clickLeft() {
        guard !leftButton.isSelected else { return }
        self.updateAlignmentButton(alignment: .left)
        self.textAlignmentChange?(.left)
    }
    @objc private func clickCenter() {
        guard !centerButton.isSelected else { return }
        self.updateAlignmentButton(alignment: .center)
        self.textAlignmentChange?(.center)
    }
    @objc private func clickRight() {
        guard !rightButton.isSelected else { return }
        self.updateAlignmentButton(alignment: .right)
        self.textAlignmentChange?(.right)
    }
    @objc private func clickPlusHeadIndent() {
        headIndent = headIndent + 1
        self.headIndentChange?(headIndent)
    }
    @objc private func clickMinusHeadIndent() {
        headIndent = headIndent - 1
        self.headIndentChange?(headIndent)
    }
    private func updateAlignmentButton(alignment: NSTextAlignment) {
        selectedButton?.isSelected = false
        var newSelected: UIButton
        switch alignment {
        case .left:
            newSelected = leftButton
        case .center:
            newSelected = centerButton
        case .right:
            newSelected = rightButton
        default:
            newSelected = leftButton
        }
        selectedButton = newSelected
        selectedButton?.isSelected = true
    }
}
