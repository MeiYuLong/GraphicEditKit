//
//  FPSelectPrinterView.swift
//  flashprint
//
//  Created by yulong mei on 2021/3/2.
//

import UIKit
import SnapKit

/// 选择打印机View
class FPSelectPrinterView: UIView {
    
    let cellReuseIdentifier = "FPPeripheralCell"
    var vm: FPSelectPrinterViewModel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.loadSubView()
        self.layoutSubview()
        self.loadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.setAnimation()
//        self.setContentAnimation()
    }
    
    private func loadSubView() {
        self.backgroundColor = .clear
        self.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(closeButton)
        contentView.addSubview(noteBGView)
        contentView.addSubview(peripheralTableView)
        peripheralTableView.addSubview(tipsBGView)
        
        noteBGView.addSubview(noteIconView)
        noteBGView.addSubview(noteLabel)
        tipsBGView.addSubview(tipsIndicatorView)
        tipsBGView.addSubview(tipsLabel)
        
        peripheralTableView.delegate = self
        peripheralTableView.dataSource = self
    }
    
    private func layoutSubview() {
        let height = 335 * UIScreen.main.bounds.height / 667
        contentView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(height)
        }
        closeButton.snp.makeConstraints { (make) in
            make.top.equalTo(12)
            make.left.equalTo(10)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(11)
            make.centerX.equalTo(contentView)
            make.left.greaterThanOrEqualTo(closeButton.snp.right).offset(30)
            make.right.lessThanOrEqualToSuperview().offset(54)
        }
        noteBGView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(13)
            make.left.equalTo(12)
            make.right.equalTo(-12)
        }
        noteIconView.snp.makeConstraints { (make) in
            make.top.left.equalTo(5)
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
        noteLabel.snp.makeConstraints { (make) in
            make.top.equalTo(6)
            make.bottom.equalTo(-5)
            make.left.equalTo(noteIconView.snp.right).offset(5)
            make.right.equalTo(-5)
        }
        peripheralTableView.snp.makeConstraints { (make) in
            make.top.equalTo(noteBGView.snp.bottom).offset(12)
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.bottom.equalTo(-12)
        }
        tipsBGView.snp.makeConstraints { (make) in
            make.center.equalTo(peripheralTableView.snp.center)
        }
        tipsIndicatorView.snp.makeConstraints { (make) in
            make.left.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        tipsLabel.snp.makeConstraints { (make) in
            make.top.right.bottom.equalToSuperview()
            make.left.equalTo(tipsIndicatorView.snp.right).offset(5)
        }
    }
    
    private func loadData() {
        vm = FPSelectPrinterViewModel()
        vm?.dataSourceChangedClosure = { [weak self] in
            self?.peripheralTableView.reloadData()
        }
    }
    
    @objc private func close() {
        vm?.closeClosure?()
    }
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.backgroundColor = .white
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.text = "fp.Connect the printer".FP_Locale
        return label
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.fp_make(name: "fp_icon_nav_close"), for: .normal)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        return button
    }()
    
    lazy var noteBGView: UIView = {
        let view = UIView()
        view.backgroundColor = FPNoteBGColor
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 12
        return view
    }()
    
    lazy var noteIconView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage.fp_make(name: "fp_icon_note")
        return view
    }()
    
    lazy var noteLabel: UILabel = {
        let label = UILabel()
        label.textColor = FPNormalTextColor
        label.font = UIFont.systemFont(ofSize:12)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "fp.Printer not found?".FP_Locale
        return label
    }()
    
    lazy var peripheralTableView: UITableView = {
        let tableView = UITableView.init(frame: .zero, style: .plain)
        tableView.backgroundColor = .white
        tableView.register(FPPeripheralCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        let view = UIView()
        tableView.tableFooterView = view
        return tableView
    }()
    
    lazy var tipsBGView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.textColor = FPBlueTextColor
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "fp.Searching for printers".FP_Locale
        label.textAlignment = .center
        return label
    }()
    
    lazy var tipsIndicatorView: UIActivityIndicatorView = {
        var view: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            view = UIActivityIndicatorView(style: .medium)
        } else {
            view = UIActivityIndicatorView(style: .gray)
        }
        view.color = FPBlueTextColor
        view.hidesWhenStopped = true
        view.startAnimating()
        return view
    }()
    
}

extension FPSelectPrinterView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm?.data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? FPPeripheralCell {
            let data = vm?.data[indexPath.row]
            cell.title = data?.cbPeripheral.name ?? "---"
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = vm?.data[indexPath.row] else { return }
        vm?.contentClouse?(data)
    }
}

extension FPSelectPrinterView {
    public func setAnimation() {
        
        let animation = CATransition()
        animation.type = .moveIn
        animation.subtype = .fromTop
        animation.duration = 0.6
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        self.layer.add(animation, forKey: nil)
    }
    
    public func setContentAnimation() {
        let height = contentView.layer.bounds.height
        let spring = CASpringAnimation(keyPath: "bounds.size.height")
        spring.fromValue = height
        spring.toValue = height + 10
        spring.damping = 1
        spring.stiffness = 0
        spring.initialVelocity = -16
        spring.mass = 1
        spring.duration = 1.5
        contentView.layer.add(spring, forKey: nil)
    }
}
