/*打印结果*/
typedef enum _printResult {
    printResultSuccessful = 0,//打印成功
    printResultFailed,//打印失败
}printResult;
/*发送结果*/
typedef enum _sendResult {
    sendResultSuccessful = 0,//发送成功
    sendResultFailed//发送失败
}sendResult;
/**
 打印机状态
 */
typedef enum _printerStatus{
    printerCoverOpen = 0,//纸舱盖打开
    printerNoPaper,//缺纸
    printerOverHeat,//打印头过热
    printerPrinting,//打印中
    printerBatteryLow,//低电压
    printerOk,//正常
}printerStatus;

/**
 手机蓝牙状态
 */
typedef enum _btState{
    btStatePoweredOff = 0,//蓝牙关闭
    btStatePoweredOn//蓝牙打开
}btState;

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

//---------------------------------------------------------------
#pragma mark - 打印机状态委托
/**
 * 打印机状态回调
 * @param status 打印机状态
 */
- (void)blePrinterStatus:(printerStatus)status;
/**
 * 打印结果回调
 * @param state 打印结果回调
 */
- (void)bleDidFinishPrint:(printResult)state;
@end

@interface SLWPrinter : NSObject

@property (nonatomic,assign)_Nullable id<PrinterInterfaceDelegate> delegate;

+ (SLWPrinter *)sharedInstance;
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
 * 发送数据接口
 */
-(void)writeWithBytes:(NSData*) sendData;
/**
 * 断开连接
 */
- (void)disconnect:(CBPeripheral*)peripheral;

/**
 * 停止服务
 */
- (void)stopService;

//——--------------------------接口-------------------------
#pragma mark - 查询接口
/**
 * 返回打印机的状态
 * 查询结果在blePrinterStatus委托中
 */
- (void)getPrinterStatus;

/**
 *获取蓝牙信息 发送后需要在bleDataReceived中解析结果）
 *@param mode 0x04:读蓝牙2.0 mac
 * 0x06:读蓝牙4.0 mac
 * 0x08:读蓝牙版本
*/
-(void) getBTInf:(int) mode;

#pragma mark - 打印接口
/**
 * 页模式下打印
 * @param horizontal: 旋转
 *                    0:正常打印，不旋转；
 *                    1：整个页面顺时针旋转180°后，再打印
 * @param skip:       定位
 *                    0：打印结束后不定位，直接停止；
 *                    >0：打印结束后定位到标签分割线，如果无缝隙，最大进纸skip个dot后停止(1mm==8dot)
 */
- (void)print:(int)horizontal skip:(NSUInteger)skip;
/**
 * 设置打印纸张大小（打印区域）的大小
 * @param pageWidth:  打印区域宽度
 * @param pageHeight:  打印区域高度
 */
- (void)pageSetup:(int)pageWidth  pageHeight:(int)pageHeight;

/**
 * 打印图片
 * @param start_x:     图片起始点x坐标
 * @param start_y:     图片起始点y坐标
 * @param bmp_size_x:  图片的宽度
 * @param bmp_size_y:  图片的高度
 * @param img:         图片
 */

- (void)drawGraphicWithBmp:(int)start_x start_y:(int)start_y bmp_size_x:(int) bmp_size_x bmp_size_y:(int)bmp_size_y img:(UIImage *)img;

/**
 * 打印标签
 * @param start_x:     图片起始点x坐标
 * @param start_y:     图片起始点y坐标
 * @param bmp_size_x:  图片的宽度
 * @param bmp_size_y:  图片的高度
 * @param img:         图片
 */
- (void)drawGraphicWithLabel:(int)start_x start_y:(int)start_y bmp_size_x:(int) bmp_size_x bmp_size_y:(int)bmp_size_y img:(UIImage *)img;

#pragma mark -P2接口
/**
 * 唤醒打印机 每次打印之前都要调用该函数，防止由于打印机进入低功耗模式而丢失数据
 */
-(NSData *)printerWakeP2;
/**
 *使能打印机
 */
- (NSData *) enablePrinterP2;
/**
 * 结束打印任务
 */
- (NSData *) stopPrintJobP2;
/**
 * 打印定位
 */
-(NSData *)printerPositionP2;
/**
 * 走纸命令
 * @param lines 走纸行数
 */
-(NSData *) printLinedotsP2:(int) linedots;
/**
 * 打印光栅位图
 *
 * @param bitmap 位图
 * @param mode   0：正常打印；1：倍宽打印；2：倍高打印； 3：倍宽倍高打印
 * @return 发送的数据
 */
-(NSData *) drawGraphicP2:(UIImage *)bitmap;

/**
 * 查询打印机状态
 *0:打印机正常
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
-(NSData *)printerStatusP2;

NS_ASSUME_NONNULL_END

@end
