//
//  FPFloydImage.m
//  flashexpress
//
//  Created by 刘超 on 2021/3/17.
//  Copyright © 2021 闪电快车软件（北京）有限公司. All rights reserved.
//

#import "FPFloydImage.h"

@implementation FPFloydImage
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
    
    bitmapBytesPerRow    = (pixelsWide * 4); //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit(0-255)的空间
    bitmapByteCount    = (bitmapBytesPerRow * pixelsHigh); //计算整张图占用的字节数
    
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
   
    int threshold = 120;
    float diffuse_ratio[4]={0.4375,0.1875,0.3125,0.0625};
    float fratio = 0.6f;
    float base_ratio = 0.3f;
    float change_ratio = 0.7f;
    int single_value = 0;
    int new_value = 0;
    uint32_t min = 0xFF000000;
    uint32_t max = 0xFFFFFFFF;

    int wOff = 0;
    int pixOff = 0;
    
//    int arr_256[256]={0};
//    //auto threshold
//    for(GLuint y = 0;y< pixelsHigh;y++)
//    {
//        pixOff = wOff;
//        for (GLuint x = 0; x<pixelsWide; x++)
//        {
//            int g = (unsigned char)imgPixel[pixOff+1];
//            arr_256[g]+=1;
//            pixOff+=4;
//        }
//        pixOff += 4*pixelsWide;
//    }
//    int area = pixelsHigh*pixelsWide-arr_256[255];
//    int thread_area = area*0.2;
//    int count_area=0;
//    for (int idx=0;idx < 256;idx++)
//    {
//        count_area+=arr_256[idx];
//        if (count_area>thread_area){
//            threshold=128+(idx-128)/1.5;
//            break;
//        }
//    }
//
//    wOff = 0;
//    pixOff = 0;

    for(GLuint y = 0;y< pixelsHigh;y++)//双层循环按照长宽的像素个数迭代每个像素点
    {
        pixOff = wOff;

        for (GLuint x = 0; x<pixelsWide; x++)
        {
            if (x > pixelsWide - 2 ||
                y > pixelsHigh - 2) {
                pixOff += 4; //将数组的索引指向下四个元素
                continue;
            }
            int red = (unsigned char)imgPixel[pixOff];
            int g = (unsigned char)imgPixel[pixOff+1];
            int blue = (unsigned char)imgPixel[pixOff+2];
            int alpha = (unsigned char)imgPixel[pixOff+3];
//            changeRGBA(&red, &green, &blue, &alpha, f);

            if (g > threshold){
                new_value=max;
                single_value=255;
            }
            else {
                new_value = min;
                single_value=0;
            }

            if (y==pixelsHigh-2 || x ==pixelsWide-2)
            {
                int width_step=y==pixelsHigh-2?1:0;
                int step=x ==pixelsWide-2?1:0;

//                *(ptr+(idr+width_step)*width+idc+step) = new_value;
            }

            int value1 = abs((int)(unsigned char)(imgPixel[pixOff+4+1])-g);
            int value2 = abs((int)(unsigned char)(imgPixel[pixOff+(pixelsWide * 4)-4+1])-g);
            int value3 = abs((int)(unsigned char)(imgPixel[pixOff+(pixelsWide * 4)+1])-g);
            int value4 = abs((int)(unsigned char)(imgPixel[pixOff+(pixelsWide * 4)+4+1])-g);

            float mathe= 2.71828182845904;
//            float dif_value = (g-single_value);
//            fratio = (fratio-0.5+ 1.0) - 1.0/(1.0+ pow(mathe,-abs(dif_value)/36.0));
//            dif_value = dif_value*fratio;
            float dif_value = (g-single_value)*fratio;
            imgPixel[pixOff+0] = single_value;
            imgPixel[pixOff+1] = single_value;
            imgPixel[pixOff+2] = single_value;
            imgPixel[pixOff+3] = 255;
            
            float fratio1=(base_ratio+change_ratio*(1.0- value1/255.0))*2*(1.0 - 1.0/(1.0+ pow(mathe,-abs(value1)/36.0)));
            float fratio2=(base_ratio+change_ratio*(1.0- value2/255.0))*2*(1.0 - 1.0/(1.0+ pow(mathe,-abs(value2)/36.0)));
            float fratio3=(base_ratio+change_ratio*(1.0- value3/255.0))*2*(1.0 - 1.0/(1.0+ pow(mathe,-abs(value3)/36.0)));
            float fratio4=(base_ratio+change_ratio*(1.0- value4/255.0))*2*(1.0 - 1.0/(1.0+ pow(mathe,-abs(value4)/36.0)));

//            float fratio1=base_ratio+change_ratio*(1.0- value1/255.0);
//            float fratio2=base_ratio+change_ratio*(1.0- value2/255.0);
//            float fratio3=base_ratio+change_ratio*(1.0- value3/255.0);
//            float fratio4=base_ratio+change_ratio*(1.0- value4/255.0);

            
//            int movement = (4.0*sin((x*y)/16.0*6.28));
            int movement = rand();

            //F-S dithering
            int new_value1 = ((int)(imgPixel[pixOff+4+1])+dif_value*diffuse_ratio[movement%4]*fratio1)+0;
            int new_value2 = ((int)(imgPixel[pixOff+(pixelsWide * 4)-4+1])+dif_value*diffuse_ratio[(movement+1)%4]*fratio2)+0;
            int new_value3 = ((int)(imgPixel[pixOff+(pixelsWide * 4)+1])+dif_value*diffuse_ratio[(movement+2)%4]*fratio3)+0;
            int new_value4 = ((int)(imgPixel[pixOff+(pixelsWide * 4)+4+1])+dif_value*diffuse_ratio[(movement+3)%4]*fratio4)+0;

            int safe_value1 =new_value1 >255?255:new_value1<0?0:new_value1;
            int safe_value2 =new_value2 >255?255:new_value2<0?0:new_value2;
            int safe_value3 =new_value3 >255?255:new_value3<0?0:new_value3;
            int safe_value4 =new_value4 >255?255:new_value4<0?0:new_value4;

            imgPixel[pixOff+4+0] = safe_value1;
            imgPixel[pixOff+4+1] = safe_value1;
            imgPixel[pixOff+4+2] = safe_value1;
            imgPixel[pixOff+4+3] = 255;

            imgPixel[pixOff+(pixelsWide * 4)-4+0] = safe_value2;
            imgPixel[pixOff+(pixelsWide * 4)-4+1] = safe_value2;
            imgPixel[pixOff+(pixelsWide * 4)-4+2] = safe_value2;
            imgPixel[pixOff+(pixelsWide * 4)-4+3] = 255;

            imgPixel[pixOff+(pixelsWide * 4)+0] = safe_value3;
            imgPixel[pixOff+(pixelsWide * 4)+1] = safe_value3;
            imgPixel[pixOff+(pixelsWide * 4)+2] = safe_value3;
            imgPixel[pixOff+(pixelsWide * 4)+3] = 255;

            imgPixel[pixOff+(pixelsWide * 4)+4+0] = safe_value4;
            imgPixel[pixOff+(pixelsWide * 4)+4+1] = safe_value4;
            imgPixel[pixOff+(pixelsWide * 4)+4+2] = safe_value4;
            imgPixel[pixOff+(pixelsWide * 4)+4+3] = 255;

            
//            //回写数据
//            imgPixel[pixOff] = red;
//            imgPixel[pixOff+1] = g;
//            imgPixel[pixOff+2] = blue;
//            imgPixel[pixOff+3] = alpha;

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

int findThrHistogram(uint32_t* image, int width, int height, float fratio, bool isUpper) {
    int nThreshold = 128;
    int arr_256[256] = {0};
    int sizeNum = (width * height) * (1.0 - fratio);
    unsigned char* ptr = (unsigned char*)image;
    for(int idr = 0; idr < height; idr++) {
        for(int idc = 0; idc < width; idc++, ptr++) {
            arr_256[*ptr]++;
        }
    }

    int sizePartNum =0;
    if (isUpper) {
        for(int idx = 0; idx < 256; idx++) {
            if(sizePartNum < sizeNum) {
                sizePartNum += arr_256[255 - idx];
            } else {
                nThreshold = 255 - idx;
                break;
            }
        }
    } else {
        for(int idx = 0; idx < 256; idx++) {
            if (sizePartNum < sizeNum) {
                sizePartNum += arr_256[idx];
            } else {
                nThreshold = idx;
                break;
            }
        }
    }

    nThreshold = nThreshold < 50 ? 50 : nThreshold;
    nThreshold = nThreshold > 255 ? 128 : nThreshold;

    return nThreshold;
}

@end
