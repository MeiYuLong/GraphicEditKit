//
//  FPTipsView.swift
//  flashprint
//
//  Created by yulong mei on 2021/3/5.
//

import UIKit

class FPTipsView: UIView {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 24
        
        self.setAnimation()
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
        self.addSubview(tipLabel)
        self.addSubview(totalLabel)
        self.addSubview(cancelButton)
    }
    
    private func layoutSubview() {
        iconView.snp.makeConstraints { (make) in
            make.top.equalTo(47)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 100, height: 130))
        }
        tipLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconView.snp.bottom).offset(10)
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
        self.tipLabel.text = "fp.Printing location".FP_Locale + "\(vm.index ?? 0)" + "fp.copy".FP_Locale
        self.totalLabel.text = "fp.Total".FP_Locale + "\(vm.total ?? 0)" + "fp.copy".FP_Locale
    }
    
    @objc func cancelPrint() {
        FPPrintManager.shared.cancelPrint()
        cancelButton.isEnabled = false
        cancelButton.backgroundColor = FPSecondaryTitleColor
    }
    
    lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage.fp_make(name: "print")
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
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = FPMainButtonColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(cancelPrint), for: .touchUpInside)
        return button
    }()
    
    lazy var vm: FPTipsViewModel = {
        let vm = FPTipsViewModel()
        vm.updateCount = { [weak self](index, total) in
            guard let self = self else { return }
            self.tipLabel.text = "fp.Printing location".FP_Locale + "\(index)" + "fp.copy".FP_Locale
            self.totalLabel.text = "fp.Total".FP_Locale + "\(total)" + "fp.copy".FP_Locale
        }
        return vm
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
    
}
