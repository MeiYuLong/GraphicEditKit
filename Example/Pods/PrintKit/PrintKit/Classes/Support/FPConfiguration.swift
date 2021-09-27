//
//  FPConfiguration.swift
//  flashprint
//
//  Created by yulong mei on 2021/3/3.
//

import Foundation
import CoreBluetooth

/// 支持的打印机类型：Alison、...
enum FPPrinterType {
    case Alison
    case EPrint
    case Unknown
    // ...
    
    init(name: String) {
        for support in FPPeripheralName.allCases {
            if name.contains(support.rawValue) {
                self = support.type
                return
            }
        }
        self = .Unknown
    }
}

/// 支持的所有打印机名字
enum FPPeripheralName: String, CaseIterable {
    case alison = "Alison" 
    case flashToy = "FlashToy"
    case periPage = "PeriPage"
    case ePrint = "365Print"
    
    /// 当前打印机所对应的SDK类型
    var type: FPPrinterType {
        switch self {
        case .alison, .flashToy, .periPage:
            return .Alison
        case .ePrint:
            return .EPrint
        default:
            return .Unknown
        }
    }
}

/// 监测到的设备
public struct FPPeripheral {
    
    /// MAC地址
    var mac: String
    
    /// 设备对象
    var cbPeripheral: CBPeripheral
    
    /// 设备类型
    var type: FPPrinterType = .Unknown
}
