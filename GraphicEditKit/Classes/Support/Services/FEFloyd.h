#pragma once
#ifndef DETECTTEXTANGLE_H_
#define DETECTTEXTANGLE_H_


enum ResizeType
{
    noResize,
    widthResize,
    heightResize,
	maxResize,
	minResize
};


/*
Make Binary image looks like a "gray" image,through move/delete black/wihte points
*/
#ifdef __cplusplus
extern "C"
{
#endif

/*
image_data:input pics data(channel=3)
diffuse_ratio:floyd difuse ratio
min_length: make sure max length <= min_length
base_ratio,chang_ratio to see source code
*/
// min_length=380 fratio=0.7 base_ratio=0.3 change_ratio=0.7

unsigned char* floyd(unsigned char* image_data,int image_width,int image_height,int image_channel,int min_length,float fratio,float base_ratio,float change_ratio,int type);
//void floyd(unsigned char* image_data,int& image_width,int& image_height,int min_length=380,float fratio=0.7,float base_ratio=0.3,float change_ratio=0.7);
void floyd_inplace(unsigned char* image_data,int image_width,int image_height,float fratio,float base_ratio,float change_ratio);
void floyd_inplace32(int* image_data,int image_width,int image_height,float fratio,float base_ratio,float change_ratio);

/*
clean data
*/
bool clean_img(unsigned char* image_data);

#ifdef __cplusplus
}
#endif
#endif
