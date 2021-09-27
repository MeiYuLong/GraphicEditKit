//
//  FPTipsViewModel.swift
//  flashprint
//
//  Created by yulong mei on 2021/3/8.
//

import UIKit

class FPTipsViewModel: FPBaseViewModel {
    
    var index: Int?
    var total: Int?
    
    /// 更新当前计数
    public var updateCount: ((Int, Int) -> Void)?
    
    /// 打印结束
    public var printDone: (() -> Void)?
    
    override init() {
        super.init()
        
        self.index = FPPrintManager.shared.printIndex
        self.total = FPPrintManager.shared.printIndex
        
        FPPrintManager.shared.updateCount = { [weak self](index, total) in
            guard let self = self else { return }
            self.updateCount?(index, total)
        }

        FPPrintManager.shared.printDone = { [weak self] in
            guard let self = self else { return }
            self.printDone?()
        }
    }
}
