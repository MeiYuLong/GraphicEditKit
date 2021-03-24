/**
 * 查询标识
 */
typedef enum {
    /**
     * 校验打印机，用于判断是否为可允许打印机
     */
    CHECKPRINTER = 0,
    /**
     * 查询打印机状态
     */
    PRINTERSTATUS,
    /**
     * 查询电量
     */
    BATTERYVOL,
    /**
     * 查询温湿度
     */
    TEMPANDHUM,
    /**
     * 查询BT名称
     */
    BTNAME,
    /**
     * 查询MAC地址
     */
    MAC,
    /**
     * 查询BT版本
     */
    BTVERSION,
    /**
     * 查询打印机版本
     */
    PRINTERVERSION,
    /**
     * 查询打印机SN
     */
    PRINTERSN,
    /**
     * 查询打印机型号
     */
    PRINTERMODEL,
    /**
     * 查询打印机信息
     */
    PRINTERINFOR,
    /**
     * 查询标签高度
     */
    LABELHEIGHT,
    /**
     * 查询打印状态
     */
    PRINTSTATUS,
    /**
     * 自动识别高度
     */
    RECOGNITIONHEIGHT,
    /**
     * 预留，暂时无用
     */
    THICKNESS
} SEARCHTYPE;
/**
 * 打印机升级过程标识，仅用于sdk内部，二次开发无用
 */
typedef enum {
    WAITING_DEVICE_REBOOT = 0,
    DEVICE_REBOOT,
    UPDATA_VIEW_BEFORE,
    SPACE_WIPEOUT,
    UPDATTING,
    CALIBRATION,
    CHECKFLAG,
    UPDATA_VIEW_AFTER
} UPDATEPRINTER;
/**
 * 打印机类型
 */
typedef enum {
    IP200 = 0,
    IP300,
    IP303,
    IP320,
    IP330,
    OTHER
} TYPEPRINTER;


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBCharacteristic.h>
#import "BLEGATTService.h"

NS_ASSUME_NONNULL_BEGIN
#define SERVICE_UUID_DATA_TRANSMISSION @"FF00"
#define SERVICE_UUID_BRT_ATCMD @"FF80"
#define CHAR_UUID_BRT_ATCMD_NOTIFY @"FF81"
#define CHAR_UUID_BRT_ATCMD_WRITE  @"FF82"

#define SERVICE_UUID_BRT_OTA        @"FF10"
#define CHAR_UUID_BRT_OTA_NOTIFY    @"FF11"
#define CHAR_UUID_BRT_OTA_WRITE     @"FF11"
/**
 * 打印机回调协议
 */
@protocol PrinterInterfaceDelegate <NSObject>

@optional
/**
 * 搜索到打印机设备
 * @param peripheral  CBCentralManager通过扫描、连接的外围设备
 * @param RSSI  设备信号强度
 */
- (void)bleDidDiscoverPrinters: (CBPeripheral *)peripheral RSSI:(nullable NSNumber *)RSSI;
/**
 * 打印机数据接收
 * @param revData  接收到的数据
 * 备注：在未进行查询动作的情况下：
 * 若打印最后发送了【printerPosition】则打印成功后会收到OK，不成功收到RE
 * 若打印最后未发送【printerPosition】则发送成功后会收到0xAA，不成功无返回
 */
- (void)bleDataReceived:(nullable NSData *)revData;
/**
 * 打印机连接成功
 * @param peripheral  CBCentralManager通过扫描、连接的外围设备
 */
- (void)bleDidConnectPeripheral:(CBPeripheral *)peripheral;
/**
 * 打印机连接失败
 * @param peripheral  CBCentralManager通过扫描、连接的外围设备
 * @param error  错误信息
 */
- (void)bleDidFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error;
/**
 * 打印机断开连接
 * @param peripheral  CBCentralManager通过扫描、连接的外围设备
 * @param error  错误信息
 */
- (void)bleDidDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error;
/**
 * 打印机开启服务
 * @param bleGattService GATT服务
 * @param result YES：开启成功 NO：开启失败
 */
- (void)bleGattService:(BLEGATTService *)bleGattService didStart:(BOOL)result;
/**
 * 蓝牙打开
 */
- (void)bleBTOpen;
/**
 * 蓝牙断开
 */
- (void)bleBTClose;
/**
 * 蓝牙异常断开
 */
- (void)bleAbnormalDisconnection;
/**
 * 打印机开始升级
 */
- (void)startUpdatePrinter;
/**
 * 打印机升级失败
 */
- (void)updatePrinterFail;
/**
 * 打印机升级进度
 * @param progress 进度值
 */
- (void)updatePrinterProgress:(int)progress;
/**
 * 打印机升级结束
 */
- (void)updatePrinterFinish;
/**
 * 打印机自动返回缺纸
 */
- (void) onPrinterOutPaperAuto;
/**
 * 打印机自动返回开盖
 */
- (void) onPrinterOpenCoverAuto;
/**
 * 打印机自动返回过热
 */
- (void) onPrinterOverHeatAuto;
/**
 * 打印机自动返回低电压
 */
- (void) onPrinterLowValAuto;



@end

@interface Printer : NSObject

@property (nonatomic,assign)_Nullable id<PrinterInterfaceDelegate> delegate;

+ (Printer *)sharedInstance;
/**
 * 开始扫描打印机设备
 */
-(void)startScanPrinters;
/**
 * 停止扫描打印机设备
 */
-(void)stopScanPrinters;
/**
 * 连接设备
 */
- (void)connect:(CBPeripheral*)peripheral;
/**
 * 断开连接
 */
- (void)disconnect:(CBPeripheral*)peripheral;
/**
 * 启动服务
 */
- (BOOL)start:(NSString *)serviceUUIDString on:(CBPeripheral *)peripheral;
/**
 * 停止服务
 */
- (void)stopService;
/**
 * 发送数据
 */
-(void)writeWithBytes:(NSData*) sendData;
/**
 * 校验命令
 */
- (NSData *) checkCommand;
/**
 * 设置打印机类型（新加入）
 */
- (void) setPrinterType:(TYPEPRINTER)printerType;
/**
 * 学习标签缝隙
 */
- (NSData *) learnLabelGap;
/**
 * 校验打印机是否有使用权限
 * @param revData   接收到的数据
 * @return YES:可用设备 NO:不可用设备
 */
- (Boolean) checkPrinter:(NSData *)revData;
/**
 * 查询标签高度
 */
- (NSData *) labelHeight;

/**
 *使能打印机
 */
- (NSData *) enablePrinter;
/**
 * 结束打印任务
 */
- (NSData *) stopPrintJob;
/**
 * 查询打印机信息
 */
- (NSData *) printerInfor;
/**
 * 唤醒打印机 每次打印之前都要调用该函数，防止由于打印机进入低功耗模式而丢失数据
 */
-(NSData *)printerWake;
/**
 * 开启／关闭屏幕
 *
 * @param doOpen YES:开启屏幕 NO:关闭屏幕
 */
-(NSData *) openScreen:(BOOL) doOpen;
/**
 * 走纸命令
 * @param lines 走纸行数
 */
-(NSData *) printLinedots:(int) linedots;
/**
 * 打印定位 缝隙纸下调用
 */
-(NSData *)printerPosition;
/**
 * 打印光栅位图
 *
 * @param bitmap 位图
 * @param mode   0：正常打印；1：倍宽打印；2：倍高打印； 3：倍宽倍高打印
 */
-(NSData *) drawGraphic:(UIImage *)bitmap Mode:(int32_t) mode;
/**
 * 打印光栅位图
 *
 * @param bmpData 处理后数据
 * @param width 图片宽度
 * @param height 图片高度
 * @param mode   0：正常打印；1：倍宽打印；2：倍高打印； 3：倍宽倍高打印
 */
-(NSData *) drawGraphicbyData:(NSData *)bmpData Width:(int32_t)width Height:(int32_t) height Mode:(int32_t) mode;
/**
 * 查询打印机状态
 * 0:打印机正常
 * 其他（根据"位"判断打印机状态）
 * 第0位：1：正在打印
 * 第1位：1：纸舱盖开
 * 第2位：1：缺纸
 * 第3位：1：电池电压低
 * 第4位：1：打印头过热
 * 第5位：缺省（默认0）
 * 第6位：缺省（默认0）
 * 第7位：缺省（默认0）
 */
-(NSData *) printerStatus;
/**
 * 查询打印机电池电压（查询后会进入bleDataReceived回调）
 * 电压(百分比)
 */
-(NSData *)printerBatteryVol;
/**
 * 查询打印机温湿度 （查询后会进入bleDataReceived回调）
 * 温湿度 第1个字节表示温度(摄氏度)   第2个字节表示湿度(百分比)
 */

-(NSData *) printerTempHum;

/**
 * 查询蓝牙名称 （查询后会进入bleDataReceived回调）
 */
-(NSData *) printerBtname;

/**
 * 查询打印机mac地址 （查询后会进入bleDataReceived回调）
 */
-(NSData *) printerMac;
/**
 * 查询蓝牙固件版本 （查询后会进入bleDataReceived回调）
 */
-(NSData *)printerBtVersion;
/**
 * 查询打印机固件版本 （查询后会进入bleDataReceived回调）
 */
-(NSData *)printerVersion;


/**
 * 查询打印机SN （查询后会进入bleDataReceived回调）
 */
-(NSData *) PrinterSN;

/**
 * 查询打印机型号 （查询后会进入bleDataReceived回调）
 */
-(NSData *)PrinterModel;
/**
 * 设置打印机浓度(0-2)
 * 0:低浓度
 * 1:中浓度
 * 2:高浓度
 */
-(NSData *)setThickness:(int) value;
/**
 * 设置关机时间(单位：分钟，不接受小数)
 */
-(NSData *)setShutTime:(int) time;
/**
 * 升级打印机
 * @param fileData 升级文件
 */
-(void) updatePrinter:(NSData*) fileData;

NS_ASSUME_NONNULL_END

@end
