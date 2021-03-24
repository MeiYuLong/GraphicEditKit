//
//  GEKeyboardInputView.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/17.
//

import UIKit
import MBProgressHUD

enum GEInputType: String {
    case Text = "ge.please_input" // "ge.7"="请输入"
    case QRCode = "ge.please_enter_QRCode" // "ge.y"="请输入生成二维码  "Please input the text content of generating QR code 限定100位"
    case BarCode = "ge.please_enter_barcode" // "ge.x"="请输入生成条形码" "Please input the text content of generating Bar code 限定100位"
}

class GEKeyboardInputView: UIView {

    private let barMaxLegth = 30
    private let QRMaxLegth = 100
    
    public var text: String? {
        didSet{
            textView.text = text
            let _ = textView.becomeFirstResponder()
        }
    }
    
    public var inputType: GEInputType = .Text {
        didSet {
            textView.placeholder = inputType.rawValue.GE_Locale
            if inputType == .BarCode {
                textView.keyboardType = .asciiCapable
            }else {
                textView.keyboardType = .default
            }
        }
    }

    /// 确定提交
    /// String 文本内容
    public var confirmClosure: ((String) -> Void)?
    
    /// 当注销响应者成功时回调
    public var resignFirstClosure: (() -> Void)?
    
    private lazy var textView: GEKeyboardTextView = {
        let view = GEKeyboardTextView()
        view.resignFirstResponderClosure = { [weak self] in
            self?.resignFirstClosure?()
        }
        let strongSelf = self
        view.font = UIFont.systemFont(ofSize: 14)
        view.backgroundColor = GEBGColor
        view.textColor = .black
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = GELayerColor
        button.setImage(UIImage.ge_bundle(named: "icon_btn_coficton_default"), for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(checkText), for: .touchUpInside)
        return button
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = GETOPLineColor
        return view
    }()
    
    init(frame: CGRect, inputType: GEInputType) {
        super.init(frame: frame)
        self.inputType = inputType
        self.loadSubViews()
        self.layoutSubview()
    }
    
    @objc private func checkText() {
        guard let text = self.textView.text, !text.isEmpty else {
            self.confirmClosure?("")
            return
        }
        switch inputType {
        case .QRCode:
            if text.utf16.count > self.QRMaxLegth {
                let message = "ge.Please_enter_100".GE_Locale
                self.showHUD(message)
                return
            }
        case .BarCode:
            if !GE_IsASIIC(text) || text.utf16.count > self.barMaxLegth {
                let message = "ge.Please_input_numbers".GE_Locale
                self.showHUD(message)
                return
            }
        default:
            break
        }
        
        self.confirmClosure?(text)
    }
    
    public func showHUD(_ detail: String)  {
        let hud = MBProgressHUD.showAdded(to: self.superview ?? self, animated: true)
        hud.mode = .text
        hud.label.text = nil
        hud.detailsLabel.text = detail
        hud.detailsLabel.textColor = .black
        hud.hide(animated: true, afterDelay: 1.5)
    }
    
    private func loadSubViews() {
        self.backgroundColor = .white
        self.addSubview(lineView)
        self.addSubview(textView)
        self.addSubview(submitButton)
    }
    
    private func layoutSubview() {
        lineView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(1)
        }
        submitButton.snp.makeConstraints { (make) in
            make.top.equalTo(15)
            make.right.bottom.equalTo(-10)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        textView.snp.makeConstraints { (make) in
            make.top.left.equalTo(10)
            make.bottom.equalTo(-10)
            make.right.equalTo(self.submitButton.snp.left).offset(-10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
