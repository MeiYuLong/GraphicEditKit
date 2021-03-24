#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "BLEGATTService.h"
#import "BLEService.h"
#import "Printer.h"

FOUNDATION_EXPORT double FlashPrinterVersionNumber;
FOUNDATION_EXPORT const unsigned char FlashPrinterVersionString[];

