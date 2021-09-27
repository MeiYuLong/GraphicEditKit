//
//  FPPrintManager.swift
//  flashprint
//
//  Created by yulong mei on 2021/3/4.
//

import Foundation
import UIKit

/// PrintManager 入口
public class FPPrintManager{
    
    public typealias FPPrintCallback = (FPPrinterStatus) -> Void
    
    /// 打印对外暴露回调
    public var callback: FPPrintCallback?
    
    /// 弹出的Window
    private var window: FPBaseWindow?
    
    /// 需要打印的数据Dictionary
    private var printDic: Dictionary<String, Any>?
    
    /// 需要打印的数据Image
    private var printImage: UIImage?
    
    /// 当前打印的index
    public var printIndex: Int?
    
    /// 需要打印数据的总个数
    public var printTotal: Int?
    
    /// 更新当前计数
    public var updateCount: ((Int, Int) -> Void)?
    
    public var printDone: (() -> Void)?
    
    /// 取消打印
    private var canceledPrint = false
        
    public static let shared = FPPrintManager()
    
    /// 显示Window
    private func show() {
        if FPCentralManager.shared.service?.isConnected ?? false {
            self.window = FPBaseWindow(vc: FPPrintViewController())
        }else {
            FPCentralManager.shared.start()
            self.window = FPBaseWindow(vc: FPSelectPrinterViewController())
        }
        self.canceledPrint = false
    }
    
    /// 隐藏Window
    public func hidden() {
        self.window?.isHidden = true
        self.window = nil
    }
    
    public func start() {
        self.show()
    }
    
    public func end() {
        FPCentralManager.shared.stop()
    }
    
    /// 开始连接设备，配置监听
    /// - Parameter peripheral: 外设
    public func startConnect(peripheral: FPPeripheral) {
        FPCentralManager.shared.connect(peripheral: peripheral)
        guard let service = FPCentralManager.shared.service else {
            return
        }
        service.printerStatusMonitor = { [weak self](status) in
            debugPrint("printer Status Monitor: ---", status)
            var state = status
            guard let self = self else { return }
            switch status {
            case .PRINTER_READY:
                guard let image = self.printImage else {
                    return
                }
                service.fpPrint(image)
                break
            case .PRINTER_PRINTING,
                 .PRINTER_OPENED,
                 .PRINTER_NO_PAPER,
                 .PRINTER_LOW_BATTERY,
                 .PRINTER_OVERHEAT,
                 .PRINTER_PRINT_UNKNOW,
                 .PRINTER_PRINT_VERSION_ERROR,
                 .PRINTER_CONNECT_FAILD,
                 .PRINTER_GATTSERVICE_FAILD:
                self.showAlert(status.error)
                break
            case .PRINTER_PRINT_MAC:
                // 获取到MAC地址表示已经连接并且开启服务成功
                FPCentralManager.shared.stopScan()
                self.hidden()
                self.show()
                break
            case .PRINTER_PRINT_OK:
                break
            case .PRINTER_PRINT_END:
                if self.printIndex == self.printTotal || self.canceledPrint {
                    self.printDone?()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.hidden()
                    }
                    state = .PRINTER_PRINT_STOP
                }
                break
            case .PRINTRT_DISCONNECT:
                self.hidden()
            default:
                break
            }
            self.callback?(state)
        }
    }
}

//MARK: 打印Action
extension FPPrintManager {
    
    /// 开启打印
    /// - Parameters:
    ///   - image: 打印的图片
    ///   - handle: 回调
    public func print(image: UIImage, thickness: Int? = nil, index: Int, total: Int, _ handle: @escaping FPPrintCallback) {
        self.printImage = image
        self.printIndex = index
        self.printTotal = total
        self.callback = handle
        
        if let thickness = thickness {
            FPCentralManager.shared.service?.fpSetThickness(thickness)
        }
        
        if FPCentralManager.shared.service?.isConnected ?? false {
            FPCentralManager.shared.service?.fpWillPrint()
        }
        self.updateCount?(index, total)
    }
    
    /// 取消打印
    public func cancelPrint() {
        self.canceledPrint = true
    }
}

extension FPPrintManager {
    public func showAlert(_ message: String) {
        let alert = UIAlertController.init(title: "fp.Prompt".FP_Locale, message: message, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "fp.ok".FP_Locale, style: .default, handler: nil)
        alert.addAction(action)
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
