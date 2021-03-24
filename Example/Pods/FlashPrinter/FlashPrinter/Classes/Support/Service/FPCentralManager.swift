//
//  FPCentralManager.swift
//  flashprint
//
//  Created by yulong mei on 2021/2/26.
//

import Foundation
import CoreBluetooth
import UIKit

class FPCentralManager: FPServiceProtocol {
    
    static let shared = FPCentralManager()
    
    /// 当前打印机的服务SDK
    var service: FPServiceBase? {
        get {
            switch type {
            case .Alison:
                return alisonService
            default:
                return nil
            }
        }
    }
    
    /// 当前PrinterSDK类型
    var type: FPPrinterType = .Unknown
    
    /// Alison SDK
    private var alisonService = FPAlisonService()
    
    var currentPeripheral: FPPeripheral?
    
    /// 需要将SDK的扫描统一管理
    public func scan() {
        alisonService.fpScan()
    }
    
    public func stopScan() {
        alisonService.fpStopScan()
    }
    
    public func connect(peripheral: FPPeripheral) {
        type = peripheral.type
        service?.fpConnect(peripheral.cbPeripheral)
    }
}

//MARK: FPServiceProtocol
extension FPCentralManager {
    
    func start() {
        // 需要提前将SDK初始化，因为CBCentralManager需要先去检测蓝牙状态才能扫描设备
        alisonService.start()
    }
    
    func stop() {
        alisonService.stop()
        
        type = .Unknown
        currentPeripheral = nil
    }
}


