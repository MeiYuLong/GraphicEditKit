//
//  FPTipsView.swift
//  flashprint
//
//  Created by yulong mei on 2021/3/5.
//

import UIKit

class FPTipsView: UIView {
    
    let vm = FPTipsViewModel()
    let IconAnimationKey = "transform.translation.y"
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 24
        
        self.cancelButton.layer.masksToBounds = true
        self.cancelButton.layer.cornerRadius = 12
        self.cancelButton.layer.borderWidth = 1
        self.cancelButton.layer.borderColor = FPRedButtonColor.cgColor
        
        self.setAnimationV2()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.loadData()
        self.loadSubView()
        self.layoutSubview()
    }
    
    private func loadSubView() {
        self.backgroundColor = .white
        self.addSubview(iconView)
        self.addSubview(bottomBGView)
        bottomBGView.addSubview(tipLabel)
        bottomBGView.addSubview(totalLabel)
        bottomBGView.addSubview(cancelButton)
    }
    
    private func layoutSubview() {
        iconView.snp.makeConstraints { (make) in
            make.top.equalTo(30)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 152, height: 152))
        }
        bottomBGView.snp.makeConstraints { (make) in
            make.top.equalTo(iconView.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
        }
        tipLabel.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualTo(32)
            make.right.lessThanOrEqualTo(-32)
        }
        totalLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tipLabel.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(totalLabel.snp.bottom).offset(25)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-15)
        }
    }
    
    private func loadData() {
        self.tipLabel.text = "fp.Printing location".FP_Locale.replacingOccurrences(of: "*", with: "\(FPPrintManager.shared.printIndex ?? 0)")
        self.totalLabel.text = "fp.copy".FP_Locale.replacingOccurrences(of: "*", with: "\(FPPrintManager.shared.printTotal ?? 0)")
        vm.updateCount = { [weak self](index, total) in
            guard let self = self else { return }
            self.tipLabel.text = "fp.Printing location".FP_Locale.replacingOccurrences(of: "*", with: "\(index)")
            self.totalLabel.text = "fp.copy".FP_Locale.replacingOccurrences(of: "*", with: "\(total)")
        }
        vm.printDone = { [weak self] in
            guard let self = self else { return }
            self.tipLabel.text = "fp.print done".FP_Locale
            self.cancelButton.isHidden = true
            self.iconView.image = UIImage.fp_make(name: "print_done")
            self.removeAnimation()
        }
    }
    
    @objc func cancelPrint() {
        FPPrintManager.shared.cancelPrint()
        cancelButton.isEnabled = false
        cancelButton.backgroundColor = FPSecondaryTitleColor
    }
    
    lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage.fp_make(name: "img_address_printing")
        return view
    }()
    
    lazy var bottomBGView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = FPMainTitleColor
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = FPSecondaryTitleColor
        label.textAlignment = .center
        return label
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("fp.cancel print".FP_Locale, for: .normal)
        button.setTitleColor(FPRedButtonColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(cancelPrint), for: .touchUpInside)
        button.contentEdgeInsets = .init(top: 3, left: 10, bottom: 3, right: 10)
        return button
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: 动画
extension FPTipsView {
    
    private func setAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.y")
        animation.fromValue = 0
        animation.byValue = Double.pi
        animation.toValue = Double.pi * 2
        animation.duration = 1.5
        animation.repeatCount = MAXFLOAT
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        iconView.layer.add(animation, forKey: nil)
    }
    
    private func setAnimationV2() {
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.fromValue = 152
        animation.byValue = 50
        animation.toValue = 0
        animation.duration = 1.5
        
        let group = CAAnimationGroup.init()
        group.animations = [animation]
        group.duration = 1.8
        group.repeatCount = MAXFLOAT
        group.timingFunction = CAMediaTimingFunction(name: .linear)
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards
        iconView.layer.add(group, forKey: IconAnimationKey)
    }
    
    private func removeAnimation() {
        iconView.layer.removeAnimation(forKey: IconAnimationKey)
    }
}
