//
//  ZYFilterTool.m
//  ZYNaNian
//
//  Created by HenryVarro on 16/11/18.
//  Copyright © 2016年 ZYNaNian. All rights reserved.
//

#import "ZYFilterTool.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <Foundation/Foundation.h>
#import "FEFloyd.h"

//#import "UIImage+ZY.h"
@implementation ZYFilterTool
//static  void *bitmap;

+ (UIImage *)floydWithImage:(UIImage *)inImage {
    UIImage *resultImage;
    // 分配内存
    const int imageWidth = inImage.size.width;
    const int imageHeight = inImage.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t* oldImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    uint32_t* newImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    
    // 创建context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();// 色彩范围的容器
    CGContextRef oldContext = CGBitmapContextCreate(oldImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(oldContext, CGRectMake(0, 0, imageWidth, imageHeight), inImage.CGImage);
    
    CGContextRef newContext = CGBitmapContextCreate(newImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(newContext, CGRectMake(0, 0, imageWidth, imageHeight), inImage.CGImage);
        // 遍历像素
//    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = oldImageBuf;
//    uint32_t* newCurPtr = newImageBuf;
    uint8_t* ptr = (uint8_t*)pCurPtr;
//    uint8_t* newptr = (uint8_t*)newCurPtr;
    floyd_inplace(ptr, imageWidth, imageHeight, 0.7, 0.3, 0.7);
//    floyd_core_inplace32(pCurPtr, imageWidth, imageHeight, 0.7, 0.3, 0.7);
    // 将内存转成image
    CGDataProviderRef dataProvider =CGDataProviderCreateWithData(NULL, oldImageBuf, bytesPerRow * imageHeight, nil);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight,8, 32, bytesPerRow, colorSpace,kCGImageAlphaLast |kCGBitmapByteOrder32Little, dataProvider,NULL,true,kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    
    resultImage = [UIImage imageWithCGImage:imageRef];
    
    // 释放
    CGImageRelease(imageRef);
    CGContextRelease(oldContext);
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    return resultImage;
}

+ (UIImage*)ditherImage:(UIImage *)inImage{
    //获取图片
    CIImage *image = [CIImage imageWithCGImage:[inImage CGImage]];
    //创建CIFilter CIMinimumComponent黑白 CIPhotoEffectFade相册
    CIFilter *filter = [CIFilter filterWithName:@"CIDither"];
    [filter setValue:image forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:5.0] forKey:@"inputIntensity"];

    //进行默认设置
    [filter setDefaults];
    //创建CIContext对象
    CIContext *context = [CIContext contextWithOptions:nil];
    //创建处理后的图片
    CIImage *resultImage = filter.outputImage;
    CGImageRef imageRef = [context createCGImage:resultImage fromRect:CGRectMake(0,0,inImage.size.width,inImage.size.height)];
    UIImage *resultImg = [UIImage imageWithCGImage:imageRef];
    CFRelease(imageRef);
    return resultImg;
}
typedef struct {
    int off;    // 像素偏移
    int depth;  // 像素颜色深度 0 ～ 15 级
} Pixel;
static CGContextRef CreateRGBABitmapContext (CGImageRef inImage)// 返回一个使用RGBA通道的位图上下文
{
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData; //内存空间的指针，该内存空间的大小等于图像使用RGB通道所占用的字节数。
    unsigned long bitmapByteCount;
    unsigned long bitmapBytesPerRow;
    
    size_t pixelsWide = CGImageGetWidth(inImage); //获取横向的像素点的个数
    size_t pixelsHigh = CGImageGetHeight(inImage); //纵向
    
    bitmapBytesPerRow	= (pixelsWide * 4); //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit(0-255)的空间
    bitmapByteCount	= (bitmapBytesPerRow * pixelsHigh); //计算整张图占用的字节数
    
    colorSpace = CGColorSpaceCreateDeviceRGB();//创建依赖于设备的RGB通道
    
    bitmapData = malloc(bitmapByteCount); //分配足够容纳图片字节数的内存空间
    
    context = CGBitmapContextCreate (bitmapData, pixelsWide, pixelsHigh, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    //创建CoreGraphic的图形上下文，该上下文描述了bitmaData指向的内存空间需要绘制的图像的一些绘制参数
    
    CGColorSpaceRelease( colorSpace );
    //Core Foundation中通过含有Create、Alloc的方法名字创建的指针，需要使用CFRelease()函数释放
//    free(bitmapData);
    return context;
}

static unsigned char *RequestImagePixelData(UIImage *inImage)
// 返回一个指针，该指针指向一个数组，数组中的每四个元素都是图像上的一个像素点的RGBA的数值(0-255)，用无符号的char是因为它正好的取值范围就是0-255
{
    CGImageRef img = [inImage CGImage];
    CGSize size = [inImage size];
    
    CGContextRef cgctx = CreateRGBABitmapContext(img); //使用上面的函数创建上下文
    
    CGRect rect = {{0,0},{size.width, size.height}};
    
    CGContextDrawImage(cgctx, rect, img); //将目标图像绘制到指定的上下文，实际为上下文内的bitmapData。
    unsigned char *data = CGBitmapContextGetData (cgctx);

    CGContextRelease(cgctx);//释放上面的函数创建的上下文
    
    return data;
}

static void changeRGBA(int *red,int *green,int *blue,int *alpha, const float* f)//修改RGB的值
{
    int redV = *red;
    int greenV = *green;
    int blueV = *blue;
    int alphaV = *alpha;
    
    *red = f[0] * redV + f[1] * greenV + f[2] * blueV + f[3] * alphaV + f[4];
    *green = f[0+5] * redV + f[1+5] * greenV + f[2+5] * blueV + f[3+5] * alphaV + f[4+5];
    *blue = f[0+5*2] * redV + f[1+5*2] * greenV + f[2+5*2] * blueV + f[3+5*2] * alphaV + f[4+5*2];
    *alpha = f[0+5*3] * redV + f[1+5*3] * greenV + f[2+5*3] * blueV + f[3+5*3] * alphaV + f[4+5*3];
    
    if (*red > 255)
    {
        *red = 255;
    }
    if(*red < 0)
    {
        *red = 0;
    }
    if (*green > 255)
    {
        *green = 255;
    }
    if (*green < 0)
    {
        *green = 0;
    }
    if (*blue > 255)
    {
        *blue = 255;
    }
    if (*blue < 0)
    {
        *blue = 0;
    }
    if (*alpha > 255)
    {
        *alpha = 255;
    }
    if (*alpha < 0)
    {
        *alpha = 0;
    }
}

//bitmapData 手动释放

+ (UIImage*)imageWithImage:(UIImage*)inImage
{
    
    CGImageRef img = [inImage CGImage];
    CGSize size = [inImage size];
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData; //内存空间的指针，该内存空间的大小等于图像使用RGB通道所占用的字节数。
    unsigned long bitmapByteCount;
    unsigned long bitmapBytesPerRow;
    
    size_t pixelsWide = CGImageGetWidth(img); //获取横向的像素点的个数
    size_t pixelsHigh = CGImageGetHeight(img); //纵向
    
    bitmapBytesPerRow	= (pixelsWide * 4); //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit(0-255)的空间
    bitmapByteCount	= (bitmapBytesPerRow * pixelsHigh); //计算整张图占用的字节数
    
    colorSpace = CGColorSpaceCreateDeviceRGB();//创建依赖于设备的RGB通道
    
    bitmapData = malloc(bitmapByteCount); //分配足够容纳图片字节数的内存空间
    
    context = CGBitmapContextCreate (bitmapData, pixelsWide, pixelsHigh, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    //创建CoreGraphic的图形上下文，该上下文描述了bitmaData指向的内存空间需要绘制的图像的一些绘制参数
    
    CGColorSpaceRelease( colorSpace );

   
    
    CGRect rect = {{0,0},{size.width, size.height}};
     //使用上面的函数创建上下文
    CGContextDrawImage(context, rect, img); //将目标图像绘制到指定的上下文，实际为上下文内的bitmapData。
    unsigned char *data = CGBitmapContextGetData (context);
    
    CGContextRelease(context);
    //释放上面的函数创建的上下文
    unsigned char *imgPixel = data;
   
    int wOff = 0;
    int pixOff = 0;
    
    
    for(GLuint y = 0;y< pixelsHigh;y++)//双层循环按照长宽的像素个数迭代每个像素点
    {
        pixOff = wOff;

        for (GLuint x = 0; x<pixelsWide; x++)
        {
            int red = (unsigned char)imgPixel[pixOff];
            int green = (unsigned char)imgPixel[pixOff+1];
            int blue = (unsigned char)imgPixel[pixOff+2];
            int alpha = (unsigned char)imgPixel[pixOff+3];
//            changeRGBA(&red, &green, &blue, &alpha, f);

            int d = (red + green + blue) / 3;
            if (d < 140) {
                red = 0;
                green = 0;
                blue = 0;
            } else {
                red = 255;
                green = 255;
                blue = 255;
            }
            alpha = 255;
            
            //回写数据
            imgPixel[pixOff] = red;
            imgPixel[pixOff+1] = green;
            imgPixel[pixOff+2] = blue;
            imgPixel[pixOff+3] = alpha;

            pixOff += 4; //将数组的索引指向下四个元素
        }

        wOff += pixelsWide * 4;
    }

    NSInteger dataLength = pixelsWide * pixelsHigh * 4;
    
    //下面的代码创建要输出的图像的相关参数
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
    
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    unsigned long bytesPerRow = 4 * pixelsWide;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    CGImageRef imageRef = CGImageCreate(pixelsWide, pixelsHigh, bitsPerComponent, bitsPerPixel, bytesPerRow,colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);//创建要输出的图像
    
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    
    CGDataProviderRelease(provider);
    NSData *imageData = UIImageJPEGRepresentation(myImage, 0.5);
    free(bitmapData);
    return [UIImage imageWithData:imageData];
}

+ (UIImage *)freudSteinbergDitherImage:(UIImage *)inImage {
    UIImage *resultImage;
    // 分配内存
    const int imageWidth = inImage.size.width;
    const int imageHeight = inImage.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t* oldImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    uint32_t* newImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    
    // 创建context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();// 色彩范围的容器
    CGContextRef oldContext = CGBitmapContextCreate(oldImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(oldContext, CGRectMake(0, 0, imageWidth, imageHeight), inImage.CGImage);
    
    CGContextRef newContext = CGBitmapContextCreate(newImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(newContext, CGRectMake(0, 0, imageWidth, imageHeight), inImage.CGImage);
        // 遍历像素
        int pixelNum = imageWidth * imageHeight;
        uint32_t* pCurPtr = oldImageBuf;
        uint32_t* newCurPtr = newImageBuf;
    
        for (int i = 0; i < pixelNum; i++, pCurPtr++, newCurPtr++)
        {
            int row = i / imageWidth ;
            int column = i % imageWidth;
            uint8_t* ptr = (uint8_t*)pCurPtr;
            uint8_t r = ptr[3];
            uint8_t g = ptr[2];
            uint8_t b = ptr[1];
            uint8_t nearColor = [ZYFilterTool getNearstColor:r g:g b:b];
            uint8_t* newptr = (uint8_t*)newCurPtr;
            //残差
            int eRgb[3];
            if (nearColor == 0) {
                newptr[3] = 0;
                newptr[2] = 0;
                newptr[1] = 0;
                newptr[0] = 255;
                eRgb[0] = r;
                eRgb[1] = g;
                eRgb[2] = b;
            } else {
                newptr[3] = 255;
                newptr[2] = 255;
                newptr[1] = 255;
                newptr[0] = 255;
                eRgb[0] = r-255;
                eRgb[1] = g-255;
                eRgb[2] = b-255;
            }
            //残差 16分之 7、5、3、1
            float rate1 = 0.4375;
            float rate2 = 0.3125;
            float rate3 = 0.1875;
            float rate4 = 0.0625;
            uint32_t rgb1 = [ZYFilterTool getPixel:oldImageBuf width:imageWidth height:imageHeight row:row column:column+1 rate:rate1 eRgb:eRgb];
            uint32_t rgb2 = [ZYFilterTool getPixel:oldImageBuf width:imageWidth height:imageHeight row:row+1 column:column rate:rate2 eRgb:eRgb];
            uint32_t rgb3 = [ZYFilterTool getPixel:oldImageBuf width:imageWidth height:imageHeight row:row+1 column:column-1 rate:rate3 eRgb:eRgb];
            uint32_t rgb4 = [ZYFilterTool getPixel:oldImageBuf width:imageWidth height:imageHeight row:row+1 column:column+1 rate:rate4 eRgb:eRgb];
            [self setPixel:oldImageBuf width:imageWidth height:imageHeight row:row column:column+1 value:rgb1];
            [self setPixel:oldImageBuf width:imageWidth height:imageHeight row:row+1 column:column value:rgb2];
            [self setPixel:oldImageBuf width:imageWidth height:imageHeight row:row+1 column:column-1 value:rgb3];
            [self setPixel:oldImageBuf width:imageWidth height:imageHeight row:row+1 column:column+1 value:rgb4];
            
//            [self asetPixel:oldImageBuf width:imageWidth height:imageHeight row:row-1 column:column+1 value:rgb4];
//            [self asetPixel:oldImageBuf width:imageWidth height:imageHeight row:row column:column value:rgb4];
//            [self asetPixel:oldImageBuf width:imageWidth height:imageHeight row:row column:column-1 value:rgb4];
//            [self asetPixel:oldImageBuf width:imageWidth height:imageHeight row:row column:column+1 value:rgb4];

        }
    
    // 将内存转成image
    CGDataProviderRef dataProvider =CGDataProviderCreateWithData(NULL, newImageBuf, bytesPerRow * imageHeight, nil);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight,8, 32, bytesPerRow, colorSpace,kCGImageAlphaLast |kCGBitmapByteOrder32Little, dataProvider,NULL,true,kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    
    resultImage = [UIImage imageWithCGImage:imageRef];
    
    // 释放
    CGImageRelease(imageRef);
    CGContextRelease(oldContext);
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    return resultImage;
}
#pragma mark- 获取相邻像素值
+ (int )getNearstColor:(uint8_t) r g:(uint8_t) g b:(uint8_t) b {
    int distance0Squared = pow(r, 2) + pow(g, 2) + pow(b, 2);
    int distance255Squared = pow((255-r), 2) + pow((255-g), 2) + pow((255-b), 2);
    if (distance0Squared < distance255Squared) {
        return 0;
    } else {
        return 1;
    }
}
#pragma mark- 获取像素点
+ (uint32_t)getPixel:(uint32_t*)imageBuf width:(int)width height:(int)height   row:(int)row column:(int)column rate:(float)rate eRgb:(int *)eRgb {
    if (row < 0 || row >= height || column < 0 || column >= width) {
        return 0xFFFFFFFF;
    }
    int index = row * width + column;
    uint32_t *ptr = imageBuf + index;
    uint8_t* newptr = (uint8_t*)ptr;
    uint8_t r = newptr[3];
    uint8_t g = newptr[2];
    uint8_t b = newptr[1];
    uint8_t a = newptr[0];
    int er = eRgb[0];
    int eg = eRgb[1];
    int eb = eRgb[2];
    r = clamp(r + (int)(rate*er));
    g = clamp(g + (int)(rate*eg));
    b = clamp(b + (int)(rate*eb));
    return (r << 24) + (g << 16) + (b << 8) + a;
}
#pragma mark- 设置像素点
+ (void)setPixel:(uint32_t*)imageBuf width:(int)width height:(int)height   row:(int)row column:(int)column value:(uint32_t)value {
    if (row < 0 || row >= height || column < 0 || column >= width) {
        return;
    }
    int index = row * width + column;
    uint32_t *ptr = imageBuf + index;
    uint8_t* newptr = (uint8_t*)ptr;
    int r = (value & 0xFF000000) >> 24;
    int g = (value & 0x00FF0000) >> 16;
    int b = (value & 0x0000FF00) >> 8;
    int a = value & 0x000000FF;

    newptr[3] = r;
    newptr[2] = g;
    newptr[1] = b;
    newptr[0] = a;

    uint8_t thisR = newptr[3];
    uint8_t thisG = newptr[2];
    uint8_t thisB = newptr[1];
    uint16_t thisR10 = (uint16_t)thisR;
    uint16_t thisG10 = (uint16_t)thisG;
    uint16_t thisB10 = (uint16_t)thisB;
//    int thisColorDepth = [ZYFilterTool colorDepthWithPtr:newptr];
//    int black = 30;
//    if (thisColorDepth > 200) {
//
//    }
//    if (column + 1 < width) {
//        int rIndex = row * width + column + 1;
//        uint32_t *rightPtr = imageBuf + rIndex;
//        uint8_t* rptr = (uint8_t*)rightPtr;
//        int colorDepth = [ZYFilterTool colorDepthWithPtr:rptr];
//        if (colorDepth < black) {
//            return;
//        }
//    }
//    if (column - 1 < 0) {
//        int lIndex = row * width + column - 1;
//        uint32_t *leftPtr = imageBuf + lIndex;
//        uint8_t* lptr = (uint8_t*)leftPtr;
//        int colorDepth = [ZYFilterTool colorDepthWithPtr:lptr];
//        if (colorDepth < black) {
//            return;
//        }
//    }
//    if (row - 1 >= 0) {
//        int tIndex = (row - 1) * width + column;
//        uint32_t *topPtr = imageBuf + tIndex;
//        uint8_t* tptr = (uint8_t*)topPtr;
//        int colorDepth = [ZYFilterTool colorDepthWithPtr:tptr];
//        if (colorDepth < black) {
//            return;
//        }
//        if (column + 1 < width) {
//            int rIndex = (row - 1) * width + column + 1;
//            uint32_t *rightPtr = imageBuf + rIndex;
//            uint8_t* rptr = (uint8_t*)rightPtr;
//            int colorDepth = [ZYFilterTool colorDepthWithPtr:rptr];
//            if (colorDepth < black) {
//                return;
//            }
//        }
//        if (column - 1 < 0) {
//            int lIndex = (row - 1) * width + column - 1;
//            uint32_t *leftPtr = imageBuf + lIndex;
//            uint8_t* lptr = (uint8_t*)leftPtr;
//            int colorDepth = [ZYFilterTool colorDepthWithPtr:lptr];
//            if (colorDepth < black) {
//                return;
//            }
//        }
//
//    }
//    if (row + 1 < height) {
//        int bIndex = (row + 1) * width + column;
//        uint32_t *bottomPtr = imageBuf + bIndex;
//        uint8_t* bptr = (uint8_t*)bottomPtr;
//        int colorDepth = [ZYFilterTool colorDepthWithPtr:bptr];
//        if (colorDepth < black) {
//            return;
//        }
//        if (column + 1 < width) {
//            int rIndex = (row + 1) * width + column + 1;
//            uint32_t *rightPtr = imageBuf + rIndex;
//            uint8_t* rptr = (uint8_t*)rightPtr;
//            int colorDepth = [ZYFilterTool colorDepthWithPtr:rptr];
//            if (colorDepth < black) {
//                return;
//            }
//        }
//        if (column - 1 < 0) {
//            int lIndex = (row + 1) * width + column - 1;
//            uint32_t *leftPtr = imageBuf + lIndex;
//            uint8_t* lptr = (uint8_t*)leftPtr;
//            int colorDepth = [ZYFilterTool colorDepthWithPtr:lptr];
//            if (colorDepth < black) {
//                return;
//            }
//        }
//    }
//    if (thisColorDepth < 30) {
//        return;
//    }



    newptr[3] = r;
    newptr[2] = g;
    newptr[1] = b;
    newptr[0] = a;
}

+ (void)asetPixel:(uint32_t*)imageBuf width:(int)width height:(int)height row:(int)row column:(int)column value:(uint32_t)value {
    if (row < (0 + 1) || row >= (height - 1) || column < (0 + 1) || column >= (width - 1)) {
        return;
    }
    if (row < 0 || row >= height || column < 0 || column >= width) {
        return;
    }
    int index = row * width + column;
    uint32_t *ptr = imageBuf + index;
    uint8_t* newptr = (uint8_t*)ptr;
    int r = (value & 0xFF000000) >> 24;
    int g = (value & 0x00FF0000) >> 16;
    int b = (value & 0x0000FF00) >> 8;
    int a = value & 0x000000FF;
    
    int thisColorDepth = [ZYFilterTool colorDepthWithPtr:newptr];

    int zrIndex = row * width + column + 1;
    uint32_t *zrightPtr = imageBuf + zrIndex;
    uint8_t* zrptr = (uint8_t*)zrightPtr;
    int zrcolorDepth = [ZYFilterTool colorDepthWithPtr:zrptr];

    int zlIndex = row * width + column - 1;
    uint32_t *zleftPtr = imageBuf + zlIndex;
    uint8_t* zlptr = (uint8_t*)zleftPtr;
    int zlcolorDepth = [ZYFilterTool colorDepthWithPtr:zlptr];

    int tIndex = (row - 1) * width + column;
    uint32_t *topPtr = imageBuf + tIndex;
    uint8_t* tptr = (uint8_t*)topPtr;
    int tcolorDepth = [ZYFilterTool colorDepthWithPtr:tptr];
    
    int trIndex = (row - 1) * width + column + 1;
    uint32_t *trightPtr = imageBuf + trIndex;
    uint8_t* trptr = (uint8_t*)trightPtr;
    int trcolorDepth = [ZYFilterTool colorDepthWithPtr:trptr];
    
    int tlIndex = (row - 1) * width + column - 1;
    uint32_t *tleftPtr = imageBuf + tlIndex;
    uint8_t* tlptr = (uint8_t*)tleftPtr;
    int tlcolorDepth = [ZYFilterTool colorDepthWithPtr:tlptr];
    
    int bIndex = (row + 1) * width + column;
    uint32_t *bottomPtr = imageBuf + bIndex;
    uint8_t* bptr = (uint8_t*)bottomPtr;
    int bcolorDepth = [ZYFilterTool colorDepthWithPtr:bptr];
    
    int brIndex = (row + 1) * width + column + 1;
    uint32_t *brightPtr = imageBuf + brIndex;
    uint8_t* brptr = (uint8_t*)brightPtr;
    int brcolorDepth = [ZYFilterTool colorDepthWithPtr:brptr];
    
    int blIndex = (row + 1) * width + column - 1;
    uint32_t *bleftPtr = imageBuf + blIndex;
    uint8_t* blptr = (uint8_t*)bleftPtr;
    int blcolorDepth = [ZYFilterTool colorDepthWithPtr:blptr];
    
    int white = 220;
    int black = 40;
    
    int ttlbb[5] = {tlcolorDepth,tcolorDepth,zlcolorDepth,blcolorDepth,bcolorDepth};
    int ttrbb[5] = {trcolorDepth,tcolorDepth,zrcolorDepth,brcolorDepth,bcolorDepth};

    int tlb[3] = {tlcolorDepth,zlcolorDepth,blcolorDepth};
    int trb[3] = {trcolorDepth,zrcolorDepth,brcolorDepth};

    if (thisColorDepth < black) {
        int allWhite = 0;
        for (int i = 0; i < 5; i++) {
            int depth = ttlbb[i];
            if (depth > white) {
                allWhite = allWhite + 1;
            }
        }
        bool allBlack = YES;
        for (int i = 0; i < 3; i++) {
            int depth = trb[i];
            if (depth > black) {
                allWhite = NO;
            }
        }
        if (allWhite >= 5 && allBlack) {
            r = 255;
            g = 255;
            b = 255;
            a = 255;
        } else {
            r = 0;
            g = 0;
            b = 0;
            a = 255;
        }
    }
    if (thisColorDepth < black) {
        int allWhite = 0;
        for (int i = 0; i < 5; i++) {
            int depth = ttrbb[i];
            if (depth > white) {
                allWhite = allWhite + 1;
            }
        }
        bool allBlack = YES;
        for (int i = 0; i < 3; i++) {
            int depth = tlb[i];
            if (depth > black) {
                allWhite = NO;
            }
        }
        if (allWhite >= 5 && allBlack) {
            r = 255;
            g = 255;
            b = 255;
            a = 255;
        } else {
            r = 0;
            g = 0;
            b = 0;
            a = 255;
        }
    }
    
    
    
//    if (thisColorDepth < 30) {
//        return;
//    }

                                                                                                                                                                    

    newptr[3] = r;
    newptr[2] = g;
    newptr[1] = b;
    newptr[0] = a;
}


+ (void)getR:(int*)r g:(int*)g b:(int*)b ptr:(uint8_t*)ptr {
    uint8_t thisR = ptr[3];
    uint8_t thisG = ptr[2];
    uint8_t thisB = ptr[1];
    *r = (uint16_t)thisR;
    *g = (uint16_t)thisG;
    *b = (uint16_t)thisB;
}
+ (int)colorDepthWithPtr:(uint8_t*)ptr {
    int r = -1;
    int g = -1;
    int b = -1;
    [ZYFilterTool getR:&r g:&g b:&b ptr:ptr];
    return (r+g+b) / 3;
}

int clamp(int value) {
    return value > 255 ? 255 : (value < 0 ? 0: value);
}
@end
