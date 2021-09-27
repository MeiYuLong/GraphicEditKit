//
//  FPSelectPrinterViewController.swift
//  flashprint
//
//  Created by yulong mei on 2021/3/2.
//

import UIKit

/// 选择连接打印机界面
class FPSelectPrinterViewController: FPBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadSubViews()
        self.layoutSubViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        FPPeripheralManager.shared.start { [weak self](peripherals) in
            self?.selectView.vm?.data = peripherals
        }
        // 界面出现无法立即去扫描设备，需要等待检索蓝牙状态结束
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            FPCentralManager.shared.scan()
        }
    }
    
    private func loadSubViews() {
        self.view.backgroundColor = .clear
        self.view.addSubview(selectView)
    }
    
    private func layoutSubViews(){
        selectView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    lazy var selectView: FPSelectPrinterView = {
        let view = FPSelectPrinterView()
        view.vm?.closeClosure = {
            FPCentralManager.shared.stopScan()
            FPPrintManager.shared.hidden()
        }
        view.vm?.contentClouse = { (peripheral) in
            FPPrintManager.shared.startConnect(peripheral: peripheral)
        }
        return view
    }()

}
