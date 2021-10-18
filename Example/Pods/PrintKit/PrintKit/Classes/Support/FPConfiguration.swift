//
//  FPConfiguration.swift
//  flashprint
//
//  Created by yulong mei on 2021/3/3.
//

import Foundation
import CoreBluetooth

/// 支持的打印机厂商：Alison、365、...
enum FPPrinterVendor {
    case Alison
    case EPrint
    case Unknown
}

/// 支持的所有打印机类型
enum FPPeripheralType: String, CaseIterable {
    case alison = "Alison" 
    case flashToy = "FlashToy"
    case periPage = "PeriPage"
    case ePrintP3 = "365Print-P3"
    case ePrintP2 = "365Print-P2"
    case unknown
    
    /// 当前打印机所对应的SDK厂商
    var vendor: FPPrinterVendor {
        switch self {
        case .alison,
             .flashToy,
             .periPage:
            return .Alison
        case .ePrintP3,
             .ePrintP2:
            return .EPrint
        default:
            return .Unknown
        }
    }
    
    init(name: String) {
        self = FPPeripheralType.allCases.filter{name.contains($0.rawValue)}.first ?? .unknown
    }
}

/// 监测到的设备
public struct FPPeripheral {
    
    /// MAC地址
    var mac: String
    
    /// 设备对象
    var cbPeripheral: CBPeripheral
    
    /// 设备类型
    var type: FPPeripheralType = .unknown
}
