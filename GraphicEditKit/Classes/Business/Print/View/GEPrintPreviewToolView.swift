//
//  GEPrintPreviewToolView.swift
//  GPUImage
//
//  Created by yulong mei on 2021/3/17.
//

import Foundation

class GEPrintPreviewToolView: UIView {
    var contentHeight: CGFloat = 234
    var model: GEPrintPreviewToolView.PrintModel = .text {
        didSet {
            self.updateTitleLabel()
        }
    }
    var depth: GEPrintPreviewToolView.PrintDensity = .miderate {
        didSet {
            self.updateTitleLabel()
        }
    }
    var copies: Int = 1 {
        didSet {
            self.updateSubtitleLabel()
            self.copiesNumberLabel.text = "\(copies)"
        }
    }
    var lenth: CGFloat = 0.0 {
        didSet {
            self.updateSubtitleLabel()
        }
    }
    var maxCopies: Int = 20
    var minCopies: Int = 1
    var isShow: Bool = false
    var clickPrint: (() -> Void)?
    var clickInfo: (() -> Void)?
    var clickCancel: (() -> Void)?
    var clickSubmit: (() -> Void)?

    private var defaultFrame: CGRect?
    
    private lazy var backgroundView: UIView = {
        let image = UIImage.ge_bundle(named: "bg_tools")?.resizableImage(withCapInsets: UIEdgeInsets(top: 30, left: 20, bottom: 30, right: 20), resizingMode: UIImage.ResizingMode.stretch)
        let view = UIImageView(image: image)
        view.isUserInteractionEnabled = true
        return view
    }()
    private lazy var infoView: UIView = {
        let view = UIView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickInfoView)))
        return view
    }()
    private lazy var operationView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    // infoView
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(red: 0.19, green: 0.19, blue: 0.20, alpha: 1)
        view.font = UIFont.systemFont(ofSize: 14)
        return view
    }()
    private lazy var subtitleLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(red: 0.56, green: 0.58, blue: 0.60, alpha: 1)
        view.font = UIFont.systemFont(ofSize: 12)
        return view
    }()
    private lazy var button: UIButton = {
        let view = UIButton()
        view.backgroundColor = GEThemeColor
        view.setTitle("ge.print_now".GE_Locale, for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.layer.cornerRadius = 6
        view.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        view.addTarget(self, action: #selector(clickPrintButton), for: .touchUpInside)
        return view
    }()
    private lazy var arrowView: UIImageView = {
        let view = UIImageView(image: UIImage.ge_bundle(named: "icon_tab_btn_open"))
        return view
    }()
    
    // operationView
    private lazy var cancelButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage.ge_bundle(named: "icon_nav_close"), for: .normal)
        view.addTarget(self, action: #selector(clickCancelButton), for: .touchUpInside)
        return view
    }()
    private lazy var submitButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage.ge_bundle(named: "icon_nav_confirm"), for: .normal)
        view.addTarget(self, action: #selector(clickSubmitButton), for: .touchUpInside)
        return view
    }()
    private lazy var operationTitleLabel: UILabel = {
        let view = UILabel()
        view.text = "ge.Print_setting".GE_Locale
        view.textColor = UIColor(red: 0.19, green: 0.19, blue: 0.20, alpha: 1)
        view.font = UIFont.systemFont(ofSize: 16)
        view.textAlignment = .center
        return view
    }()
    private lazy var lineView0: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1)
        return view
    }()
    private lazy var printModelView: GEPrintPreviewOperationView = {
        let view = GEPrintPreviewOperationView()
        view.items = ["ge.Image_&_Text".GE_Locale, "ge.text".GE_Locale]
        view.title =  "ge.Print_type".GE_Locale
        view.selectedIndex = 0
        view.clickItem = { (index) in
            if index == 0 {
                self.model = .image
            } else {
                self.model = .text
            }
        }
        
        return view
    }()
    private lazy var lineView1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1)
        return view
    }()
    private lazy var printDensityView: GEPrintPreviewOperationView = {
        let view = GEPrintPreviewOperationView()
        view.items = ["ge.light".GE_Locale, "ge.moderate".GE_Locale, "ge.strong".GE_Locale]
        view.title = "ge.Print_density".GE_Locale
        view.selectedIndex = 1
        view.clickItem = { (index) in
            if index == 0 {
                self.depth = .light
            } else if index == 1 {
                self.depth = .miderate
            } else {
                self.depth = .dark
            }
        }
        return view
    }()
    private lazy var lineView2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1)
        return view
    }()
    private lazy var copiesTitleLabel: UILabel = {
        let view = UILabel()
        view.text = "ge.quantity".GE_Locale
        view.sizeToFit()
        view.textColor = UIColor(red: 0.19, green: 0.19, blue: 0.20, alpha: 1)
        view.font = UIFont.systemFont(ofSize: 12)
        return view
    }()
    private lazy var copiesNumberLabel: UILabel = {
        let view = UILabel()
        view.text = "1"
        view.textColor = UIColor(red: 0.19, green: 0.19, blue: 0.20, alpha: 1)
        view.font = UIFont.systemFont(ofSize: 16)
        view.textAlignment = .center
        return view
    }()
    private lazy var minusButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage.ge_bundle(named: "icon_btn_minus_default"), for: .normal)
        view.setImage(UIImage.ge_bundle(named: "icon_btn_minus_disable"), for: .disabled)
        view.addTarget(self, action: #selector(clickMinusButton), for: .touchUpInside)
        view.isEnabled = false
        return view
    }()
    private lazy var plusButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage.ge_bundle(named: "icon_btn_plus_default"), for: .normal)
        view.setImage(UIImage.ge_bundle(named: "icon_btn_plus_disable"), for: .disabled)
        view.addTarget(self, action: #selector(clickPlusButton), for: .touchUpInside)
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
        self.addSubview(backgroundView)
        
        backgroundView.addSubview(infoView)
        infoView.addSubview(titleLabel)
        infoView.addSubview(subtitleLabel)
        infoView.addSubview(button)
        infoView.addSubview(arrowView)
        
        backgroundView.addSubview(operationView)
        operationView.addSubview(cancelButton)
        operationView.addSubview(submitButton)
        operationView.addSubview(operationTitleLabel)
        operationView.addSubview(lineView0)
        operationView.addSubview(printModelView)
        operationView.addSubview(lineView1)
        operationView.addSubview(printDensityView)
        operationView.addSubview(lineView2)
        operationView.addSubview(copiesTitleLabel)
        operationView.addSubview(minusButton)
        operationView.addSubview(copiesNumberLabel)
        operationView.addSubview(plusButton)
    }
    
    func layoutSubview() {
        backgroundView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        //infoView
        infoView.frame = backgroundView.bounds
        button.frame = CGRect(x: self.frame.width - 98, y: 26, width: 88, height: 28)
        titleLabel.frame = CGRect(x: 16, y: 7 + 16, width: titleLabel.frame.width, height: titleLabel.frame.height)
        arrowView.frame = CGRect(x: titleLabel.frame.maxX + 10, y: 26, width: arrowView.frame.width, height: arrowView.frame.height)
        subtitleLabel.frame = CGRect(x: 16, y: 27 + 16, width: subtitleLabel.frame.width, height: subtitleLabel.frame.height)
        
        //operationView
        operationView.frame = backgroundView.bounds
        cancelButton.frame = CGRect(x: 0, y: 16, width: 44, height: 48)
        submitButton.frame = CGRect(x: self.frame.width - 44, y: 16, width: 44, height: 48)
        operationTitleLabel.frame = CGRect(x: cancelButton.frame.maxX, y: 16, width: self.frame.width - cancelButton.frame.width - submitButton.frame.width, height: 48)
        lineView0.frame = CGRect(x: 16, y: operationTitleLabel.frame.maxY, width: self.frame.width - 32, height: 1)
        
        printModelView.frame = CGRect(x: 16, y: operationTitleLabel.frame.maxY + 12, width: self.frame.width - 32, height: 18+8+36)
        let itemWidth = (printModelView.frame.width - (2.0 * printModelView.itemSpacing)) / 3.0
        printModelView.itemSize = CGSize(width: itemWidth, height: 36)
        
        lineView1.frame = CGRect(x: 16, y: printModelView.frame.maxY + 12, width: self.frame.width - 32, height: 1)
        printDensityView.frame = CGRect(x: 16, y: operationTitleLabel.frame.maxY + 99, width: self.frame.width - 32, height: 18+8+36)
        printDensityView.itemSize = CGSize(width: itemWidth, height: 36)
        
        lineView2.frame = CGRect(x: 16, y: printDensityView.frame.maxY + 12, width: self.frame.width - 32, height: 1)
        copiesTitleLabel.frame = CGRect(x: 16, y: operationTitleLabel.frame.maxY + 194, width: copiesTitleLabel.frame.width, height: 18)
        minusButton.frame = CGRect(x: copiesTitleLabel.frame.maxX + 24, y: operationTitleLabel.frame.maxY + 188, width: 32, height: 32)
        copiesNumberLabel.frame = CGRect(x: minusButton.frame.maxX, y: operationTitleLabel.frame.maxY + 188, width: 86, height: 32)
        plusButton.frame = CGRect(x: copiesNumberLabel.frame.maxX, y: operationTitleLabel.frame.maxY + 188, width: 32, height: 32)
    }
}

//MARK: Logic
extension GEPrintPreviewToolView {
    enum PrintModel {
        case image
        case text
        
    }
    enum PrintDensity: String {
        case light
        case miderate
        case dark
    }
    func show() {
        self.defaultFrame = self.frame
        guard let defFrame = self.defaultFrame else { return }
        guard isShow == false else { return }
        isShow = true
        UIView.animate(withDuration: 0.3) {
            self.frame = CGRect(x: 0.0, y: defFrame.minY - self.contentHeight, width: defFrame.width, height: defFrame.height + self.contentHeight)
            self.operationView.isHidden = false
            self.infoView.isHidden = true
        } completion: { (isCompletion) in
            
        }
    }
    
    func hide() {
        guard let defFrame = self.defaultFrame else { return }
        guard isShow == true else { return }
        isShow = false
        UIView.animate(withDuration: 0.3) {
            self.frame = defFrame
            self.operationView.isHidden = true
            self.infoView.isHidden = false
        } completion: { (isCompletion) in
            
        }
    }
}
extension GEPrintPreviewToolView {
    @objc private func clickPrintButton() {
        self.clickPrint?()
    }
    @objc private func clickInfoView() {
        self.clickInfo?()
    }
    
    private func updateTitleLabel() {
        var modelString: String
        switch model {
        case .image:
            modelString = "ge.Image_&_Text".GE_Locale
        case .text:
            modelString = "ge.text".GE_Locale
        }
        var depthString: String
        switch depth {
        case .light:
            depthString = "ge.light".GE_Locale
        case .miderate:
            depthString = "ge.moderate".GE_Locale
        case .dark:
            depthString = "ge.strong".GE_Locale
        }
        titleLabel.text = modelString + " 、" + depthString
        titleLabel.sizeToFit()
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    private func updateSubtitleLabel() {
        var string: String?
        let copiesString = "ge.quantity".GE_Locale
        let pieceString = "ge.portion".GE_Locale
        let lenthString = "ge.length".GE_Locale
        string = String(format: "%@: %ld %@  |  %@: %.1fcm", copiesString, copies, pieceString, lenthString, lenth)

        subtitleLabel.text = string
        subtitleLabel.sizeToFit()
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
extension GEPrintPreviewToolView {
    @objc private func clickCancelButton() {
        self.clickCancel?()
    }
    @objc private func clickSubmitButton() {
        self.clickSubmit?()
    }
    @objc private func clickMinusButton() {
        copies = copies - 1
        self.updateCopiesButton()
    }
    @objc private func clickPlusButton() {
        copies = copies + 1
        self.updateCopiesButton()
    }
    private func updateCopiesButton() {
        minusButton.isEnabled = !(copies <= minCopies)
        plusButton.isEnabled = !(copies >= maxCopies)
    }

}
