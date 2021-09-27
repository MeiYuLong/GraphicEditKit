
#import <Foundation/Foundation.h>

@interface NSString (FscKit)


//十进制转十六进制
+ (NSString *)stringToHexString:(uint32_t)number;
// 十六进制数据转字符串
+ (NSString *)fan_dataToHexString:(NSData *)data;
// 转换地址头部
+ (NSString *)transformAddressHandString:(NSString *)string;
// 地址解析
+ (NSString *)getAddress:(NSString *)string;
// 反转地址头部
+ (NSString *)getAddressHandString:(NSString *)string;
// 后缀->16进制
+ (NSString *)tailStringToHexString:(NSString *)string;
// 16进制字符串->网址
+ (NSString *)getAddressFromHexString:(NSString *)string;
// 网址->16进制字符串
+ (NSString *)HexConvertToASCII:(NSString *)hexString;
//将uint32_t转换成十六进制的字符串
+ (NSString *)stringWithHexNumber:(uint32_t)hexNumber;
//十进制转换十六进制
+ (NSString *)getHexByDecimal:(unsigned int)decimal;
// 转换地址尾部
+ (NSString *)getAddressTailString:(NSString *)string;
// 模块型号
+ (NSString *)getModle:(NSString *)string;
//获取bundle版本
+ (NSString *)getLocalAppVersion;

+ (NSString *)getNowTimeTimestamp;


@end


