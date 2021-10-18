//
//  FPPeripheralManager.swift
//  flashprint
//
//  Created by yulong mei on 2021/3/3.
//

import Foundation
import CoreBluetooth

class FPPeripheralManager: NSObject {
    static let shared = FPPeripheralManager()
    
    /// 蓝牙检测到的外围设备
    var peripherals: [FPPeripheral] = []
    
    typealias FPPeripheralDiscoverHandle = (([FPPeripheral])->Void)
    var discoverHandle: FPPeripheralDiscoverHandle?
    
    /** CBCentralManagerDelegate
     最开始想着是我自己本地写一个扫描设备管理，最后发现CBCentralManager不是一个单例，所以自己创建的CBCentralManager和SDK的CBCentralManager扫描到的设备是不能共享对象的（只能共享属性数据），原因就是iOS CBCentralManager扫描到的设备会将Mac地址加密为UUID，所以同一个设备用两个CBCentralManager扫描就会有两个不同的UUID
     https://developer.apple.com/forums/thread/20810
     https://stackoverflow.com/questions/32221338/are-multiple-instances-of-cbcentralmanager-objects-supported
     
     centerManager = CBCentralManager.init(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey:true])
     
    var centerManager: CBCentralManager?
    /// 蓝牙状态更新
    public var blutoothStatusUpdate: ((CBManagerState) -> Void)?
    public var blutoothStatus: CBManagerState = .unknown
     */
    
    override init() {
        super.init()
    }
}

/// Start Stop
extension FPPeripheralManager{
    /// 开启检索设备
    /// - Parameter discover: 回传闭包
    func start(discover: @escaping FPPeripheralDiscoverHandle) {
        peripherals = []
        discoverHandle = discover
    }

    /// 停止检索 释放对象
    func stop() {
        peripherals = []
//        centerManager?.delegate = nil
//        centerManager = nil
    }
}

extension FPPeripheralManager {
    
    /// 搜索到设备
    /// - Parameters:
    ///   - peripheral: 外围设备
    ///   - sourcetype: 检索到的设备来源
    public func findPeripheral(peripheral: CBPeripheral, sourcetype: FPPrinterVendor) {
        guard let name = peripheral.name else { return }
        debugPrint("FPPeripheralManager----didDiscover----", name)
        let peripheralType = FPPeripheralType(name: name)
        if peripheralType.vendor == .Unknown || peripheralType.vendor != sourcetype { return }
        for item in peripherals {
            if item.cbPeripheral == peripheral {
                return
            }
        }
        peripherals.append(FPPeripheral(mac: "", cbPeripheral: peripheral, type: peripheralType))
        self.discoverHandle?(peripherals)
    }
}

/*
//MARK: CBCentralManagerDelegate
extension FPPeripheralManager{
    /// 监听蓝牙状态
    /// - Parameter central: CBCentralManager
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        self.blutoothStatus = central.state
        self.blutoothStatusUpdate?(central.state)
    }

}

public protocol CBManagerStateTract {
    var description: String { get }
}

extension CBManagerState: CBManagerStateTract {
    public var description: String {
        switch self {
        case .poweredOff:
            return "fp.Bluetooth is off".FP_Locale
        case .poweredOn:
            return "fp.Bluetooth is on".FP_Locale
        case .resetting:
            return "fp.Bluetooth is resetting".FP_Locale
        case .unauthorized:
            return "fp.Bluetooth is not authorized".FP_Locale
        case .unknown:
            return "fp.Bluetooth unknown error".FP_Locale
        case .unsupported:
            return "fp.Bluetooth version is not applicable".FP_Locale 
        default:
            return "fp.Bluetooth unknown error".FP_Locale.FP_Locale
        }
    }
}
 */
