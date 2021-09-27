//
//  FPAlisonService.swift
//  flashprint
//
//  Created by yulong mei on 2021/2/26.
//

import Foundation

class FPAlisonService: FPServiceBase {
//    #if !(arch(x86_64) || arch(i386))
//    private var printer: Printer?
//    private var searchType: SEARCHTYPE = CHECKPRINTER
//    private var typePrinter: TYPEPRINTER = OTHER
//
//    /// 打印浓度 0、1、2
//    private var thickness: Int =  2
//
//    override func start() {
//        printer = Printer.sharedInstance()
//        printer?.delegate = self
//    }
//
//    override func stop() {
//        printer?.delegate = nil
//        printer = nil
//    }
//
//    /// 扫描设备
//    override func fpScan() {
//        self.scan()
//    }
//
//    /// 停止扫描
//    override func fpStopScan(){
//        self.stopScan()
//    }
//
//    /// 连接设备
//    override func fpConnect(_ peripheral: CBPeripheral){
//        self.connect(periphral: peripheral)
//    }
//
//    /// 断开设备
//    override func fpDisconnect(){
//        self.disconnectDevice()
//    }
//
//    /// 将要打印检查打印机状体
//    override func fpWillPrint(){
//        self.checkPrinterStatus()
//    }
//
//    override func fpSetThickness(_ thickness: Int) {
//        if thickness >= 0 || thickness <= 2 {
//            self.thickness = thickness
//        }else {
//            debugPrint("Out of range for SetThickness......")
//        }
//    }
//
//    /// 打印
//    override func fpPrint(_ data: Any) {
//        guard let image = data as? UIImage else { return }
//        self.print(image: image)
//    }
//
//    override func fpStopPrintJob() {
//        self.stopPrint()
//    }
//    #endif
}

//#if !(arch(x86_64) || arch(i386))
//extension FPAlisonService {
//    /// 打印数据
//    /// - Parameter image: 数据图片
//    public func print(image: UIImage) {
//        searchType = PRINTSTATUS
//        DispatchQueue.global().async { [weak self] in
//            guard let self = self else { return }
//            guard let printer = self.printer else { return }
//            var sendData = Data.init()
//            sendData.append(printer.enable())
//            sendData.append(printer.setThickness(Int32(self.thickness)))
//            sendData.append(printer.printerWake())
//            sendData.append(printer.printLinedots(10))
//            sendData.append(printer.drawGraphic(image, mode: 0))
//            sendData.append(printer.printLinedots(70))
//            printer.write(withBytes: sendData)
//            printer.write(withBytes: printer.stopPrintJob())
//        }
//    }
//
//    public func stopPrint() {
//        searchType = PRINTSTATUS
//        DispatchQueue.global().async { [weak self] in
//            guard let printer = self?.printer else { return }
//            printer.write(withBytes: printer.stopPrintJob())
//        }
//    }
//
//    public func scan() {
//        printer?.startScanPrinters()
//    }
//
//    /// 停止扫描
//    public func stopScan() {
//        printer?.stopScanPrinters()
//    }
//
//    public func connect(periphral: CBPeripheral) {
//        printer?.connect(periphral)
//    }
//
//    /// 断开设备
//    public func disconnectDevice() {
//        if let peripheral = self.connectedPeripheral {
//            self.printer?.disconnect(peripheral)
//            connectedPeripheral = nil
//        }
//        printer?.stopService()
//        self.printerStatusMonitor?(.PRINTRT_DISCONNECT)
//    }
//
//    /// 每次打印先检查Alison打印机状态 在代理里去打印
//    public func checkPrinterStatus () {
//        guard let printer = self.printer else { return }
//        searchType = PRINTERSTATUS
//        printer.write(withBytes: printer.printerStatus())
//    }
//
//    /// 获取MAC地址
//    public func getAlisonPrintMAC () {
//        guard let printer = self.printer else { return }
//        searchType = MAC
//        printer.write(withBytes:printer.printerMac())
//    }
//
//    /// 查询打印机版本
//    public func getAlisonPrinterVersion(){
//        guard let printer = self.printer else { return }
//        searchType = PRINTERVERSION
//        printer.write(withBytes: printer.printerVersion())
//    }
//
//    /// 获取打印机型号
//    public func getAlisonPrinterModel(){
//        guard let printer = self.printer else { return }
//        searchType = PRINTERMODEL
//        printer.write(withBytes: printer.printerModel())
//    }
//
//    /// 打印机版本判断
//    public func deviceVersionCheck(_ version: String){
//        if !FPPrintTool.checkVersion(version: version) {
//            //不能打印 断开链接
//            printerStatusMonitor?(.PRINTER_PRINT_VERSION_ERROR)
//            disconnectDevice()
//        }else{
//            DispatchQueue.global().async { [weak self] in
//                guard let strongSelf = self else { return }
//                strongSelf.getAlisonPrinterModel()
//            }
//        }
//    }
//
//    /// 设置打印机类型
//    /// - Parameter result: bleData String
//    private func setPrintModel(_ result: String) {
//        if result.contains("303") {
//            typePrinter = IP303
//        }else if result.contains("200") {
//            typePrinter = IP200
//        }else if result.contains("330") {
//            typePrinter = IP330
//        }else if result.contains("320") {
//            typePrinter = IP320
//        }else if result.contains("300") {
//            typePrinter = IP300
//        }else {
//            typePrinter = OTHER
//        }
//        printer?.setPrinterType(typePrinter)
//        DispatchQueue.global().async { [weak self] in
//            guard let strongSelf = self else { return }
//                strongSelf.getAlisonPrintMAC()
//        }
//
//    }
//
//    /// 部署MAC地址
//    /// - Parameter result: MacAddrss
//    private func deployMacAddress(_ macAddrss: String) {
//        guard let connect = self.connectedPeripheral else { return }
//        let peripheral = FPPeripheral(mac: macAddrss, cbPeripheral: connect, type: .Alison)
//        FPCentralManager.shared.currentPeripheral = peripheral
//
//        self.printerStatusMonitor?(.PRINTER_PRINT_MAC)
//
//        // 连接成功后自动打印
//        self.checkPrinterStatus()
//    }
//}
//
//extension FPAlisonService: PrinterInterfaceDelegate {
//
//    /// Alison 监测设备，项目中不用，改为统一管理
//    func bleDidDiscoverPrinters(_ peripheral: CBPeripheral, rssi RSSI: NSNumber?) {
//        FPPeripheralManager.shared.findPeripheral(peripheral: peripheral, sourcetype: .Alison)
//    }
//
//    func bleDidConnect(_ peripheral: CBPeripheral) {
//        printer?.start(SERVICE_UUID_DATA_TRANSMISSION, on: peripheral)
//        connectedPeripheral = peripheral
//    }
//
//    func bleDidFail(toConnect peripheral: CBPeripheral, error: Error?) {
//        self.printerStatusMonitor?(.PRINTER_CONNECT_FAILD)
//    }
//
//    func bleDidDisconnectPeripheral(_ peripheral: CBPeripheral, error: Error?) {
//        printer?.stopService()
//    }
//
//    func bleGattService(_ bleGattService: BLEGATTService, didStart result: Bool) {
//        guard result else {
//            self.printerStatusMonitor?(.PRINTER_GATTSERVICE_FAILD)
//            return
//        }
//        if let peripheral = self.connectedPeripheral {
//            DispatchQueue.global().async {
//                if let name = peripheral.name,name.contains("PeriPage"){
//                    self.getAlisonPrinterVersion()
//                }else{
//                    self.getAlisonPrinterModel()
//                }
//            }
//        }
//    }
//
//    func bleDataReceived(_ revData: Data?) {
//        guard let bleData = revData else { return }
//        switch searchType {
//        case PRINTERSTATUS:
//            let statusStr =  FPPrintTool.revDataCheckStatus(data: bleData)
//            let status = FPPrinterStatus.init(rawValue: statusStr)
//            self.printerStatusMonitor?(status ?? .PRINTER_PRINT_UNKNOW)
//            debugPrint("bleDataReceived---PrinterStatus \(statusStr)")
//            break
//        case PRINTSTATUS:
//            let hex2string = FPPrintTool.hex2String(data: bleData)
//            if hex2string.isEmpty {
//                // 此处对应  alisonPrinter.stopPrintJob() 停止打印工作时 打印结束
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8) { [weak self] in
//                    debugPrint("bleDataReceived---停止打印工作！可以断开")
//                    self?.printerStatusMonitor?(.PRINTER_PRINT_END)
//                }
//            }else {
//                // 数据已发送给打印机，还没有打印结束
//                let status = FPPrinterStatus.init(rawValue: hex2string)
//                self.printerStatusMonitor?(status ?? .PRINTER_PRINT_UNKNOW)
//                debugPrint("bleDataReceived---数据已发送给打印机！")
//            }
//            break
//        case MAC:
//            let macAddress = FPPrintTool.converDataToHexStr(data: bleData)
//            self.deployMacAddress(macAddress)
//            debugPrint("bleDataReceived---MAC \(macAddress)")
//            break
//        case PRINTERVERSION:
//            let result = FPPrintTool.hex2String(data: bleData)
//            self.deviceVersionCheck(result)
//            debugPrint("bleDataReceived--- PrinterVersion \(result)")
//            break
//        case PRINTERMODEL:
//            let result = FPPrintTool.hex2String(data: bleData)
//            self.setPrintModel(result)
//            debugPrint("bleDataReceived---PrinterModel \(result)")
//            break
//        default:
//            break
//        }
//    }
//
//    func bleBTOpen() {
//
//    }
//
//    func bleBTClose() {
//        disconnectDevice()
//    }
//
//    func bleAbnormalDisconnection() {
//        disconnectDevice()
//    }
//
//    func startUpdatePrinter() {
//
//    }
//
//    func updatePrinterFail() {
//
//    }
//
//    func updatePrinterProgress(_ progress: Int32) {
//
//    }
//
//    func updatePrinterFinish() {
//
//    }
//
//    func onPrinterOutPaperAuto() {
//
//    }
//
//    func onPrinterOpenCoverAuto() {
//
//    }
//
//    func onPrinterOverHeatAuto() {
//
//    }
//
//    func onPrinterLowValAuto() {
//
//    }
//}
//#endif
