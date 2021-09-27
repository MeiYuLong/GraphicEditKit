//
//  FPPrintViewController.swift
//  flashprint
//
//  Created by yulong mei on 2021/3/8.
//

import UIKit

/// 打印中界面
class FPPrintViewController: FPBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .clear
        
        self.loadData()
        self.loadSubview()
        self.layoutSubview()
    }
    
    private func loadData() {
        
    }
    
    private func loadSubview() {
        self.view.addSubview(tipsView)
    }
    
    private func layoutSubview() {
        let width = 304 * UIScreen.main.bounds.width / 375
        tipsView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(width)
        }
    }

    lazy var tipsView: FPTipsView = {
        let view = FPTipsView()
        return view
    }()
}
