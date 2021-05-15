#include "FEFloyd.h"
#include "baseMethod.h"

// floyd-dithtering method
//void floyd(unsigned char* image_data,int& image_width,int& image_height,int max_length,float fratio,float base_ratio,float change_ratio)
unsigned char* floyd(unsigned char* image_data,int image_width,int image_height,int image_channel,int max_length,float fratio,float base_ratio,float change_ratio,int type)
{
	//int width = image_width;
	//int height = image_height;

	unsigned char* image_resize;
	if (image_channel==3 || image_channel==4)
	{
		unsigned char* gray = baseTool::convert_rgb2gray(image_data,image_width,image_height,image_channel);

		image_resize = baseTool::convert_resize_maxlength(gray,image_width,image_height,1,max_length,type);
		delete [] gray;
	}
	else{
		image_resize = baseTool::convert_resize_maxlength(image_data,image_width,image_height,1,max_length,type);
	}
	//return image_resize;
	
	int thres = baseTool::findThrHistogram(image_resize,image_width,image_height,0.8,false);
	
	//Floyd coefficient  
	float diffuse_ratio[4]={0.4375,0.1875,0.3125,0.0625};
	
	unsigned char* floyd_img = baseTool::floyd_core(image_resize,thres,image_width,image_height,diffuse_ratio,image_channel,max_length,fratio,base_ratio,change_ratio);
	//baseTool::floyd_core(image_resize,thres,image_width,image_height,diffuse_ratio,1,max_length,fratio,base_ratio,change_ratio);
	delete [] image_resize;                                   
	return floyd_img;
	
}

void floyd_inplace(unsigned char* image_data,int image_width,int image_height,float fratio,float base_ratio,float change_ratio)
{
	int thres = baseTool::findThrHistogram(image_data,image_width,image_height,0.80,false);

	//Floyd coefficient  
	float diffuse_ratio[4]={0.4375,0.1875,0.3125,0.0625};

	baseTool::floyd_core_inplace(image_data,thres,image_width,image_height,diffuse_ratio,fratio,base_ratio,change_ratio);

	return ;
}
void floyd_inplace32(int* image_data,int image_width,int image_height,float fratio,float base_ratio,float change_ratio) {

    int thres = baseTool::findThrHistogram((unsigned char*)image_data,image_width,image_height,0.80,false);

    //Floyd coefficient
    float diffuse_ratio[4]={0.4375,0.1875,0.3125,0.0625};

    baseTool::floyd_core_inplace32(image_data,thres,image_width,image_height,diffuse_ratio,fratio,base_ratio,change_ratio);

    return ;
}


//clean data
bool clean_img(unsigned char* image_data)
{
	try
	{
		delete [] image_data;
		return true;
	}
	catch(...)
	{
		return false;
	}
}
