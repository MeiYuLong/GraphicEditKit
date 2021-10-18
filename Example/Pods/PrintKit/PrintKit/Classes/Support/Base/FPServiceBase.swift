//
//  FPServiceBase.swift
//  flashprint
//
//  Created by yulong mei on 2021/2/26.
//

import Foundation
import CoreBluetooth

class FPServiceBase: NSObject, FPPrintProtocol, FPServiceProtocol {
    
    func fpScan() {}
    
    func fpStopScan() {}
    
    func fpDiscover(_ peripheral: CBPeripheral) {}
    
    func fpConnect(_ peripheral: CBPeripheral) {}
    
    func fpDisconnect() {}
    
    func fpWillPrint() {}
    
    func fpSetThickness(_ thickness: Int) {}
    
    func fpPrint(_ data: Any) {}
    
    func fpStopPrintJob() {}
    
    func start() {}
    
    func stop() {}
    
    typealias FPPrintHandler = (FPPrinterStatus) -> Void
    var printHandler: FPPrintHandler?
    
    /// 连接的设备
    public var connectedPeripheral: FPPeripheral?
    
    /// 是否连接
    public var isConnected: Bool{
        get {
            return connectedPeripheral != nil
        }
    }
    
    /// 监听打印状态
    public var printerStatusMonitor: ((FPPrinterStatus) -> Void)?
        
    
}

/// 打印机的状态
public enum FPPrinterStatus: String {
    
    /// 已准备好
    case PRINTER_READY = "0"
    
    /// 打印中
    case PRINTER_PRINTING = "1"
    
    /// 缺纸
    case PRINTER_NO_PAPER = "4"
    
    /// 开盖
    case PRINTER_OPENED = "6"
    
    /// 低电量
    case PRINTER_LOW_BATTERY = "8"
    
    /// 过热
    case PRINTER_OVERHEAT = "16"
    
    /// 获取了MAC
    case PRINTER_PRINT_MAC = "MAC"
    
    /// 数据已发送给打印机
    case PRINTER_PRINT_OK = "OK"
    
    /// stopPrintJob() 停止打印工作
    case PRINTER_PRINT_END = "END"
    
    case PRINTER_PRINT_STOP = "STOP"
    
    /// 厂商不支持Flash, 版本错误
    case PRINTER_PRINT_VERSION_ERROR = "VERSION_ERROR"
    
    /// 未知错误
    case PRINTER_PRINT_UNKNOW = "UNKNOW"
    
    /// 打印机回传数据有问题
    case PRINTER_PRINT_NIL = ""
    
    /// 错误
    case PRINTER_ERROR = "ERROR"
    
    /// 连接错误
    case PRINTER_CONNECT_FAILD = "CONNECT_FAILD"
    
    /// 开启蓝牙服务失败
    case PRINTER_GATTSERVICE_FAILD = "GATTSERVICE_FAILD"
    
    /// 打印设备断开链接
    case PRINTRT_DISCONNECT = "PRINTRT_DISCONNECT"
    
    public var error: String {
        switch self {
        case .PRINTER_PRINTING:
            return "fp.printing".FP_Locale
        case .PRINTER_OPENED:
            return "fp.Device's cover is open".FP_Locale
        case .PRINTER_NO_PAPER:
            return "fp.Paper shortage".FP_Locale
        case .PRINTER_LOW_BATTERY:
            return "fp.Low battery".FP_Locale
        case .PRINTER_OVERHEAT:
            return "fp.Device is overheated".FP_Locale
        case .PRINTER_PRINT_UNKNOW:
            return "fp.unknown error".FP_Locale
        case .PRINTER_PRINT_NIL:
            return "fp.Recevied data error".FP_Locale
        case .PRINTER_PRINT_VERSION_ERROR:
            return "fp.Your printer does not support".FP_Locale
        case .PRINTER_GATTSERVICE_FAILD:
            return "fp.Failed to enable Bluetooth service".FP_Locale
        case .PRINTRT_DISCONNECT:
            return "fp.The printing device is disconnected".FP_Locale
        default:
            return ""
        }
    }
}
