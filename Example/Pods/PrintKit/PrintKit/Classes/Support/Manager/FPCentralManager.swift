//
//  FPCentralManager.swift
//  flashprint
//
//  Created by yulong mei on 2021/2/26.
//

import Foundation
import CoreBluetooth
import UIKit

/*
 PrintKit里面不兼容Alison
 FPCentralManager 负责设备搜索、链接，解析识别多个SDK，调用对应的Service，开启服务、结束服务；
 需要将SDK的扫描统一管理,每个SDK扫描的设备不能通用，所以需要所有的打印机SDK来扫描，依据选择的设置来判断使用哪个SDK服务；
 */
class FPCentralManager: FPServiceProtocol {
    
    static let shared = FPCentralManager()
    
    /// 当前打印机的服务SDK
    var service: FPServiceBase? {
        get {
            switch selectedPeripheral?.type.vendor {
            case .EPrint:
                return ePrintService
            default:
                return nil
            }
        }
    }
    
    /// 当前PrinterSDK类型
    var vendor: FPPrinterVendor = .Unknown
    
    /// Alison SDK
    //private var alisonService = FPAlisonService()
    
    /// 365Print （SLWPrint SDK）
    private var ePrintService = FPEPrintService()
    
    /// 当前Printer
    var selectedPeripheral: FPPeripheral?
    
    public func scan() {
        //alisonService.fpScan()
        ePrintService.fpScan()
    }
    
    public func stopScan() {
        //alisonService.fpStopScan()
        ePrintService.fpStopScan()
    }
    
    public func connect(peripheral: FPPeripheral) {
        selectedPeripheral = peripheral
        stopScan()
        service?.fpConnect(peripheral.cbPeripheral)
    }
}

//MARK: FPServiceProtocol
extension FPCentralManager {
    
    func start() {
        // 需要提前将SDK初始化，因为CBCentralManager需要先去检测蓝牙状态才能扫描设备
        //alisonService.start()
        ePrintService.start()
    }
    
    func stop() {
        //alisonService.stop()
        ePrintService.stop()
        
        vendor = .Unknown
        selectedPeripheral = nil
    }
}


