//
//  GEAlertViewController.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/5/31.
//

import UIKit

class GEAlertAction: NSObject {

    enum GEAlertActionStyle {
        case cancel, confirm, delete
    }
    
    var title: String?
    var style: GEAlertActionStyle = .confirm
    
    typealias GEAlertHandle = (GEAlertAction) -> Void
    var handle: GEAlertHandle?
    
    init(title: String, style: GEAlertActionStyle, handle: GEAlertHandle? = nil) {
        self.title = title
        self.style = style
        self.handle = handle
    }
    
    @objc func action() {
        self.handle?(self)
    }
}

class GEAlertViewController: UIViewController {

    var alertStyle: GEAlertStyle = .Text
    var alertTitle: String?
    var alertMessage: String?
    var actions: [GEAlertAction] = []
    
    convenience init(title: String, message: String, style: GEAlertStyle) {
        self.init()
        alertTitle = title
        alertMessage = message
        alertStyle = style
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadSubview()
        self.layoutSubview()
    }
    
    private func loadSubview() {
        self.view.backgroundColor = GEBGAlphaColor3
        self.view.addSubview(bgView)
        bgView.addSubview(titleLabel)
        bgView.addSubview(contentView)
        contentView.addSubview(messageLabel)
        contentView.addSubview(textView)
    }
    
    private func layoutSubview() {
        let width = 304 * UIScreen.main.bounds.width / 375
        bgView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(width)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(16)
            make.width.lessThanOrEqualTo(width - 66)
            make.centerX.equalToSuperview()
        }
        contentView.snp.makeConstraints { (make) in
            make.left.equalTo(32)
            make.right.equalTo(-32)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.bottom.lessThanOrEqualTo(-16).priority(.low)
        }
        titleLabel.text = alertTitle
        if alertStyle == .Text {
            textView.isHidden = true
            messageLabel.isHidden = false
            messageLabel.text = alertMessage
            messageLabel.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }else {
            textView.isHidden = false
            messageLabel.isHidden = true
            textView.text = alertMessage
            textView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        self.addActions()
    }
    
    private func addActions() {
        let allWidth: CGFloat = 304 * UIScreen.main.bounds.width / 375
        let count = actions.count
        let allButtonsWidth: CGFloat = allWidth - 32 - CGFloat((count - 1) * 8)
        let buttonWidth = allButtonsWidth / CGFloat(count)
        var x: CGFloat = 16
        for action in actions {
            let button = GEButton()
            button.action = action
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            button.setTitle(action.title, for: .normal)
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 16
            bgView.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.top.equalTo(contentView.snp.bottom).offset(16)
                make.left.equalTo(x)
                make.width.equalTo(buttonWidth)
                make.bottom.lessThanOrEqualTo(bgView.snp.bottom).offset(-16)
            }
            x += buttonWidth + 8
        }
    }
    
    @objc func buttonAction(_ sender: UIButton) {
        guard let button = sender as? GEButton else { return }
        self.dismiss(animated: true) {
            button.action?.action()
        }
    }
    
    deinit {
        debugPrint("deinit \(type(of: self))")
    }
    
    private lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var textView: UITextView = {
        let view = UITextView()
        return view
    }()
    
    enum GEAlertStyle {
        case Text, TextView
    }

}
