//
//  FPEPrintService.swift
//  PrintKit
//
//  Created by yulong mei on 2021/9/6.
//

import Foundation

class FPEPrintService: FPServiceBase {
    #if !(arch(x86_64) || arch(i386))
    private var printer: SLWPrinter?
    
    /// 打印浓度 0、1、2
    private var thickness: Int =  2
    
    override func start() {
        printer = SLWPrinter.sharedInstance()
        printer?.delegate = self
    }
    
    override func stop() {
        printer?.delegate = nil
        printer = nil
    }
    
    override func fpScan() {
        scan()
    }
    
    override func fpStopScan() {
        stopScan()
    }
    
    override func fpConnect(_ peripheral: CBPeripheral) {
        connect(periphral: peripheral)
    }
    
    override func fpDisconnect() {
        disconnect()
    }
    
    override func fpWillPrint() {
        checkPrinterStatus()
    }
    
    override func fpSetThickness(_ thickness: Int) {
        if thickness >= 0 || thickness <= 2 {
            self.thickness = thickness
        }else {
            debugPrint("Out of range for SetThickness......")
        }
    }
    
    override func fpPrint(_ data: Any) {
        guard let image = data as? UIImage else { return }
        print(image: image)
    }
    
    override func fpStopPrintJob() {
        stopPrint()
    }
    #endif
}

// MARK: Action
#if !(arch(x86_64) || arch(i386))
extension FPEPrintService {
    /// 打印数据
    /// - Parameter image: 数据图片
    private func print(image: UIImage) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            guard let printer = self.printer else { return }
            printer.pageSetup(576, pageHeight: Int32(image.size.height))
            printer.drawGraphic(withLabel: 0, start_y: 0, bmp_size_x: Int32(image.size.width), bmp_size_y: Int32(image.size.height), img: image)
            printer.print(0, skip: 0)
            self.printerStatusMonitor?(.PRINTER_PRINT_OK)
        }
    }
    
    private func stopPrint() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            guard let printer = self.printer else { return }
            printer.print(0, skip: 0)
        }
    }
    
    private func scan() {
        printer?.startScanPrinters()
    }
    
    private func stopScan() {
        printer?.stopScanPrinters()
    }
    
    private func connect(periphral: CBPeripheral) {
        printer?.connect(periphral)
    }
    
    private func disconnect() {
        if let peripheral = self.connectedPeripheral {
            printer?.disconnect(peripheral)
            connectedPeripheral = nil
        }
        printer?.stopService()
        printerStatusMonitor?(.PRINTRT_DISCONNECT)
    }
    
    private func checkPrinterStatus() {
        printer?.getStatus()
    }
    
    /// 部署MAC地址
    /// - Parameter result: MacAddrss
    private func deployMacAddress(_ macAddrss: String) {
        guard let connect = self.connectedPeripheral else { return }
        let peripheral = FPPeripheral(mac: macAddrss, cbPeripheral: connect, type: .Alison)
        FPCentralManager.shared.currentPeripheral = peripheral
        
        self.printerStatusMonitor?(.PRINTER_PRINT_MAC)
        
        // 连接成功后自动打印
        self.checkPrinterStatus()
    }
}

extension FPEPrintService: PrinterInterfaceDelegate {
    
    func bleDidDiscoverPrinters(_ peripheral: CBPeripheral, rssi RSSI: NSNumber?) {
        FPPeripheralManager.shared.findPeripheral(peripheral: peripheral, sourcetype: .EPrint)
    }
    
    func bleDidConnect(_ peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        printer?.getBTInf(0x06)
    }
    
    func bleDidFail(toConnect peripheral: CBPeripheral, error: Error?) {
        printerStatusMonitor?(.PRINTER_CONNECT_FAILD)
    }
    
    func bleDidDisconnectPeripheral(_ peripheral: CBPeripheral, error: Error?) {
        printer?.stopService()
    }
    
    func bleGattService(_ bleGattService: BLEGATTService, didStart result: Bool) {
        guard result else {
            self.printerStatusMonitor?(.PRINTER_GATTSERVICE_FAILD)
            return
        }
    }
    
    func bleDataReceived(_ revData: Data?) {
        guard let bleData = revData else { return }
        let macAddress = FPPrintTool.converDataToHexStr(data: bleData)
        self.deployMacAddress(macAddress)
    }
    
    func blePrinterStatus(_ status: printerStatus) {
        switch status.rawValue {
        case 0:
            printerStatusMonitor?(.PRINTER_OPENED)
        case 1:
            printerStatusMonitor?(.PRINTER_NO_PAPER)
        case 2:
            printerStatusMonitor?(.PRINTER_OVERHEAT)
        case 3:
            printerStatusMonitor?(.PRINTER_PRINTING)
        case 4:
            printerStatusMonitor?(.PRINTER_LOW_BATTERY)
        case 5:
            printerStatusMonitor?(.PRINTER_READY)
        default:
            printerStatusMonitor?(.PRINTER_ERROR)
        }
    }

    func bleDidFinishPrint(_ state: printResult) {
        switch state.rawValue {
        case 0:
            printerStatusMonitor?(.PRINTER_PRINT_END)
            debugPrint("--printResultSuccessful---打印成功--")
        case 1:
            printerStatusMonitor?(.PRINTER_ERROR)
            debugPrint("--printResultFailed---打印失败--")
        default:
            printerStatusMonitor?(.PRINTER_ERROR)
            debugPrint("--printResultError---打印报错--")
        }
    }
    
    func bleBTClose() {
        disconnect()
    }
    
}
#endif

