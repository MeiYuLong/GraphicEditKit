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
        guard let image = data as? UIImage, let peripheral = self.connectedPeripheral else { return }
        switch peripheral.type {
        case .ePrintP2:
            printP2(image: image)
        case .ePrintP3:
            printP3(image: image)
        default:
            break
        }
    }
    
    override func fpStopPrintJob() {
        guard let peripheral = self.connectedPeripheral else { return }
        switch peripheral.type {
        case .ePrintP2:
            stopPrintP2()
        case .ePrintP3:
            stopPrintP3()
        default:
            break
        }
    }
    #endif
}

// MARK: Action
#if !(arch(x86_64) || arch(i386))
extension FPEPrintService {
    /// 打印数据P3
    /// - Parameter image: 数据图片
    private func printP3(image: UIImage) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let printer = self.printer else { return }
            printer.pageSetup(576, pageHeight: Int32(image.size.height))
            printer.drawGraphic(withLabel: 0, start_y: 0, bmp_size_x: Int32(image.size.width), bmp_size_y: Int32(image.size.height), img: image)
            printer.print(0, skip: 0)
            self.printerStatusMonitor?(.PRINTER_PRINT_OK)
        }
    }
    
    private func stopPrintP3() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let printer = self.printer else { return }
            printer.print(0, skip: 0)
        }
    }
    
    /// 打印数据P2
    /// - Parameter image: 数据图片
    private func printP2(image: UIImage) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let printer = self.printer else { return }
            printer.write(withBytes: printer.enableP2())
            var sendData = Data.init()
            sendData.append(printer.printerWakeP2())
            sendData.append(printer.printLinedotsP2(10))
            sendData.append(printer.drawGraphicP2(image))
            sendData.append(printer.printLinedotsP2(70))
            printer.write(withBytes: sendData)
            printer.write(withBytes: printer.stopPrintJobP2())
            self.printerStatusMonitor?(.PRINTER_PRINT_OK)
        }
    }
    
    private func stopPrintP2() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let printer = self.printer else { return }
            printer.write(withBytes: printer.stopPrintJobP2())
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
            printer?.disconnect(peripheral.cbPeripheral)
            connectedPeripheral = nil
        }
        printer?.stopService()
        printerStatusMonitor?(.PRINTRT_DISCONNECT)
    }
    
    private func didconnect() {
        guard let peripheral = self.connectedPeripheral else { return }
        switch peripheral.type {
        case .ePrintP2:
            self.printerStatusMonitor?(.PRINTER_PRINT_MAC)
            // 连接成功后自动打印
            self.checkPrinterStatus()
        case .ePrintP3:
            printer?.getBTInf(0x04)
        default:
            break
        }
    }
    
    private func checkPrinterStatus() {
        guard let peripheral = self.connectedPeripheral,
              let printer = self.printer else { return }
        switch peripheral.type {
        case .ePrintP2:
            printer.write(withBytes: printer.printerStatusP2())
        case .ePrintP3:
            printer.getStatus()
        default:
            break
        }
    }
    
    /// 部署MAC地址
    /// - Parameter result: MacAddrss
    private func deployMacAddress(_ macAddrss: String) {
        self.connectedPeripheral?.mac = macAddrss
        self.printerStatusMonitor?(.PRINTER_PRINT_MAC)
        
        // 连接成功后自动打印
        self.checkPrinterStatus()
    }
    
    /// 解析打印机状态
    private func analysisState(_ state: printerStatus) {
        switch state.rawValue {
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
    
    private func analysisStateP2(_ state: printerStatus) {
//        let statusStr =  FPPrintTool.revDataCheckStatus(data: bleData)
//        let status = FPPrinterStatus.init(rawValue: statusStr)
//        self.printerStatusMonitor?(status ?? .PRINTER_PRINT_UNKNOW)
        debugPrint("bleDataReceived---PrinterStatus--- P2-- \(state)")
    }
    
    private func analysisStateP3(_ state: printerStatus) {
        debugPrint("bleDataReceived---PrinterStatus--- P3-- \(state)")
    }
}

extension FPEPrintService: PrinterInterfaceDelegate {
    
    func bleDidDiscoverPrinters(_ peripheral: CBPeripheral, rssi RSSI: NSNumber?) {
        FPPeripheralManager.shared.findPeripheral(peripheral: peripheral, sourcetype: .EPrint)
    }
    
    func bleDidConnect(_ peripheral: CBPeripheral) {
        guard let name = peripheral.name else { return }
        let peripheralType = FPPeripheralType(name: name)
        connectedPeripheral = FPPeripheral(mac: "", cbPeripheral: peripheral, type: peripheralType)
        didconnect()
    }
    
    func bleDidFail(toConnect peripheral: CBPeripheral, error: Error?) {
        printerStatusMonitor?(.PRINTER_CONNECT_FAILD)
    }
    
    func bleDidDisconnectPeripheral(_ peripheral: CBPeripheral, error: Error?) {
        disconnect()
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
        analysisState(status)
        debugPrint("blePrinterStatus---PrinterStatus \(status)")
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

