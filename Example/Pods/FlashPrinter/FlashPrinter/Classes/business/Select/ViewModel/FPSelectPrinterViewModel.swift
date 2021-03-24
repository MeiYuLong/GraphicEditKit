//
//  FPSelectPrinterViewModel.swift
//  flashprint
//
//  Created by yulong mei on 2021/3/4.
//

import Foundation

class FPSelectPrinterViewModel: FPBaseViewModel {
    
    /// 关闭View
    var closeClosure: (() -> Void)?
    
    /// 数据源更新
    var dataSourceChangedClosure: (() -> Void)?
    
    /// 选择连接设备
    var contentClouse: ((FPPeripheral)->Void)?
    
    var data: [FPPeripheral] = [] {
        didSet {
            dataSourceChangedClosure?()
        }
    }
}
