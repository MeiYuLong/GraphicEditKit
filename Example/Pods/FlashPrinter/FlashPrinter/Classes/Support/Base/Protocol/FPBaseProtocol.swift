//
//  FPBaseProtocol.swift
//  flashprint
//
//  Created by yulong mei on 2021/3/3.
//

import Foundation
import CoreBluetooth

public protocol FPPrintProtocol {
    
    /// 扫描设备
    func fpScan()
    
    /// 停止扫描
    func fpStopScan()
    
    /// 发现设备
    func fpDiscover(_ peripheral: CBPeripheral)
    
    /// 连接设备
    func fpConnect(_ peripheral: CBPeripheral)
    
    /// 断开设备
    func fpDisconnect()
    
    /// 将要打印
    func fpWillPrint()
    
    /**
     * 设置打印机浓度(0-2)
     * 0:低浓度
     * 1:中浓度
     * 2:高浓度
     */
    func fpSetThickness(_ thickness: Int)
    
    /// 打印
    func fpPrint(_ data: Any)
    
    /// 停止打印
    func fpStopPrintJob()

}

public protocol FPServiceProtocol {
    func start()
    func stop()
}
