#include "baseMethod.h"
#include <math.h>

unsigned char* baseTool::convert_rgb2gray(unsigned char*image,int width,int height,int channel)
{
    unsigned char *image_gray = new unsigned char[width*height];
    unsigned char* ptr = image;
    unsigned char* ptr_hsv = image_gray;

	int step1=1;
	int step2=2;
	if (channel==1){step1=0;step2=0;}

    for(int idr=0;idr<height;idr++)
    {
        for(int idc=0;idc<width;idc++,ptr+=channel,ptr_hsv++)
        {
            int R = *ptr;
            int G = *(ptr+step1);
            int B = *(ptr+step2);

            int minValue = (R <B ? R :B) < G ? (R <B ? R :B) :G;
			int maxValue = (R >B ? R :B) > G ? (R >B ? R :B) :G;
            int Value = (4*(R+G+B- (minValue + maxValue))+minValue)/5;
			/*int grayValue = int(R*0.299 + G*0.587 + B*0.114);*/
			*ptr_hsv = Value;
        }
    }

    return image_gray;
}

unsigned char* baseTool::copy(unsigned char*image,int width,int height)
{
    unsigned char *image_gray = new unsigned char[width*height];
    unsigned char* ptr = image;
    unsigned char* ptr_hsv = image_gray;

    for(int idr=0;idr<height;idr++)
    {
        for(int idc=0;idc<width;idc++,ptr++,ptr_hsv++)
        {
			*ptr_hsv = *ptr;
        }
    }

    return image_gray;
}

 void baseTool::Rgb2Hsv(float R, float G, float B, float& H, float& S, float&V)
{
      // r,g,b values are from 0 to 1
     // h = [0,360], s = [0,1], v = [0,1]
     // if s == 0, then h = -1 (undefined)

     float minValue, maxValue, delta;
     minValue = (R < G ? R : G) < B ? (R < G ? R : G) : B ;
     maxValue = (R > G ? R : G) > B ? (R < G ? R : G) : B ;

     V = maxValue; //

     delta = maxValue - minValue;

     if( maxValue != 0 )
       S = delta / maxValue; // s
     else
     {
        // r = g = b = 0 // s = 0, v is undefined
       S = 0;
       H = 0;
       return;
     }

     if(delta ==0)
        H=0;
     else if( R == maxValue )
         H = ( G - B ) / delta; // between yellow & magenta
     else if( G == maxValue )
         H = 2 + ( B - R ) / delta; // between cyan & yellow
     else
         H = 4 + ( R - G ) / delta; // between magenta & cyan

      H *= 60; // degrees
      if( H < 0 )
         H += 360;

}

unsigned char* baseTool::convert_rgb2hsv(unsigned char* image,int width,int height)
{
    unsigned char *image_hsv = new unsigned char[width*height];
    unsigned char* ptr = image;
    unsigned char* ptr_hsv = image_hsv;

    for(int idr=0;idr<height;idr++)
    {
        for(int idc=0;idc<width;idc++,ptr+=3,ptr_hsv++)
        {
            int B = *ptr;
            int G = *(ptr+1);
            int R = *(ptr+2);

            float H,S,V;
            Rgb2Hsv((float)R,(float)G,(float)B,H,S,V);

			H = V-S;
			H = H <0 ?0:H;
			*ptr_hsv = H;
        }
    }

    return image_hsv;
}


void baseTool::convert_gray2binay(unsigned char* image,int threshold,int width,int height)
{
    unsigned char* ptr = image;

    for(int idr=0;idr<height;idr++)
    {
        for(int idc=0;idc<width;idc++,ptr++)
        {
            int nValue = *ptr;

            if( nValue > threshold)
                *ptr = 255;
            else
                *ptr = 0;
        }
    }

    return ;
}

void baseTool::convert_invert(unsigned char* image,int width,int height)
{
    unsigned char* ptr = image;

    for(int idr=0;idr<height;idr++)
    {
        for(int idc=0;idc<width;idc++,ptr++)
        {
            int nValue = *ptr;
            nValue = 255 - nValue;

            *ptr = nValue;
        }
    }

    return ;
}


unsigned char* baseTool::convert_resize(unsigned char *image,int &width,int &height,int channel,int nSize)
{
	float fratio = (float)sqrt((float)nSize / (float)(width*height));

    int newWidth = int(width *fratio);
    int newHeight = int(height*fratio);

	if(newWidth > width || newHeight > height || fratio >1 || fratio < 0.01)
	{
		newWidth = width;
		newHeight = height;
		fratio =1.0;
	}

    unsigned char* resizeImg = new unsigned char[newHeight*newWidth*channel];
    unsigned char*ptr = image;
    unsigned char*ptr1 = resizeImg;

    float fStep = 1.0/fratio;


	if(1 == channel)
		for(int idr=0;idr<newHeight;idr++)
		{
			int next_h =int(idr * fStep);
			next_h = next_h >height-1? height -1:next_h;
			unsigned char* ptr_r = ptr + next_h*width;
			for(int idc=0;idc <newWidth;idc++,ptr1++)
			{
				int next_c= int(idc*fStep);
				*ptr1 = *(ptr_r+next_c);

			}
		}
	else
		for(int idr=0;idr<newHeight;idr++)
		{
			int next_h =int(idr * fStep);
			next_h = next_h >height-1? height -1:next_h;
			unsigned char* ptr_r = ptr + next_h*width*3;

			for(int idc=0;idc <newWidth;idc++,ptr1+=3)
			{
				int next_c= int(idc*fStep);

				*ptr1 = *(ptr_r+next_c*3);
				*(ptr1+1) =*(ptr_r+next_c*3+1);
				*(ptr1+2) =*(ptr_r+next_c*3+2);
			}
		}

	width = newWidth;
	height = newHeight;

    return resizeImg;
}

//resize image by max length
unsigned char* baseTool::convert_resize_maxlength(unsigned char *image,int &width,int &height,int channel,int max_length,int type)
{
	int newWidth=width;
	int newHeight=height;

	float fratio_w = float((float)max_length / width);
	float fratio_h = float((float)max_length / height);
	float fratio =1.0;

	if (type==3 || type ==4)
	{
		int max_len = width > height ? width:height;
		if (max_len==width){type=1;}
		else{type=2;}
	}


	switch(type)
	{
		//width resize
		case 1:
			newWidth=max_length;
			fratio=fratio_w;
			newHeight=int(height*fratio_w);
			break;

		//height resize
		case 2:
			newHeight=max_length;
			fratio=fratio_h;
			newWidth=int(width*fratio_h);
			break;
	}


	//float length= width > height ? width:height;
	//float fratio = float((float)max_length / length);
	//fratio = fratio >1.0 ? 1.0:fratio;

	//int newWidth=max_length;
	//int newHeight=max_length;
	
	
	//if (length==width && length!=height){newHeight = int(height*fratio);}
	//if (length==height && length !=width){newWidth = int(width*fratio);}

    //int newWidth = int(width *fratio);
    //int newHeight = int(height*fratio);


	if(newWidth > width || newHeight > height || fratio >1 || fratio < 0.01)
	{
		newWidth = width;
		newHeight = height;
		fratio =1.0;
	}

    unsigned char* resizeImg = new unsigned char[newHeight*newWidth*channel];
    unsigned char*ptr = image;
    unsigned char*ptr1 = resizeImg;

    float fStep = 1.0/fratio;


	if(1 == channel)
		for(int idr=0;idr<newHeight;idr++)
		{
			int next_h =int(idr * fStep);
			next_h = next_h >height-1? height -1:next_h;
			unsigned char* ptr_r = ptr + next_h*width;
			for(int idc=0;idc <newWidth;idc++,ptr1++)
			{
				int next_c= int(idc*fStep);
				*ptr1 = *(ptr_r+next_c);

			}
		}
	else
		for(int idr=0;idr<newHeight;idr++)
		{
			int next_h =int(idr * fStep);
			next_h = next_h >height-1? height -1:next_h;
			unsigned char* ptr_r = ptr + next_h*width*3;

			for(int idc=0;idc <newWidth;idc++,ptr1+=3)
			{
				int next_c= int(idc*fStep);

				*ptr1 = *(ptr_r+next_c*3);
				*(ptr1+1) =*(ptr_r+next_c*3+1);
				*(ptr1+2) =*(ptr_r+next_c*3+2);
			}
		}

	width = newWidth;
	height = newHeight;

    return resizeImg;
}

//Ä¿Ç°½öÖ§³Ö»Ò¶ÈÍ¼
unsigned char* baseTool::convert_resizeFixedSize(unsigned char* image,int in_width,int in_height,int out_width,int out_height,int channel)
{
	float fr1 = (float)in_width/(float)out_width;
	float fr2 = (float)in_height/(float)out_height;

	unsigned char*ptr_in = image;
	unsigned char*ptr_re = new unsigned char[out_width*out_height];
	unsigned char*ptr_out = ptr_re;

	for(int idr=0;idr<out_height;idr++)
	{
		int next_h =int(idr * fr2);
		next_h = next_h >out_height-1? out_height -1:next_h;

		unsigned char* ptr_r = ptr_in + next_h*in_width;

		for(int idc=0;idc<out_width;idc++,ptr_out++)
		{
			int next_c = int(idc*fr1);
			next_c = next_c >out_width-1?out_width-1:next_c;

			*ptr_out = *(ptr_r+next_c);
		}
	}


	return ptr_re;
}


void baseTool::convert_dif(unsigned char *src,unsigned char*dst,int width,int height)
{
	unsigned char *pt1 = src;
	unsigned char *pt2 = dst;

	for(int idr=0;idr<height;idr++)
		for(int idc=0;idc<width;idc++,pt1++,pt2++)
		{
			//int n1 = *pt1;
			//int n2 = *pt2 ;
			//int nValue = n2 - n1;
			//nValue = nValue < 0? 0:-nValue;
			//*pt2 = (n2 - n1);

			if(*pt1 > 128 && *pt2 > 128)
				*pt2 = 255;
			else
				*pt2 =0;
		}

	return ;
}


//ÕÒ³öãÐÖµ
int baseTool::findThrHistogram(unsigned char *img,int width,int height,float fratio ,bool isUpper)
{
    int nThreshold =128;
    int arr_256[256]={0};
//    int sizeNum = (width*height)*(1.0-fratio);
    int channel =4;

    unsigned char* ptr = img;
    for(int idr=0;idr<height;idr++)
        for(int idc=0;idc<width;idc++,ptr+=channel)
            arr_256[*(ptr+2)]++;
    int sizeNum = (width*height-arr_256[255])*(1.0-fratio);
    int sizePartNum =0;
    if(isUpper)
    {
        for(int idx=0;idx<256;idx++)
            if(sizePartNum < sizeNum)
                sizePartNum += arr_256[255-idx];
            else
            {
                nThreshold = 255-idx;
                break;
            }
    }
    else
    {
        for(int idx=0;idx<256;idx++)
            if(sizePartNum < sizeNum)
                sizePartNum += arr_256[idx];
            else
            {
                nThreshold =idx;
                break;
            }
    }

    nThreshold = nThreshold < 50? 50 : nThreshold;
    nThreshold = nThreshold > 255 ? 128 :nThreshold;

    return nThreshold;
}


//¸ÐÐËÈ¤ÇøÓòÌáÈ¡
unsigned char* baseTool::img_roi(unsigned char *image,int width,int height,int x_min,int x_max,int y_min,int y_max)
{
	unsigned char *image_gray = new unsigned char[(x_max-x_min)*(y_max-y_min)];
    unsigned char* ptr = image;
    unsigned char* ptr_hsv = image_gray;

    for(int idr=y_min;idr<y_max;idr++)
    {
        for(int idc=x_min;idc<x_max;idc++,ptr_hsv++)
        {
			*ptr_hsv = *(ptr+idr*width+idc);
        }
    }

    return image_gray;
}

unsigned char* baseTool::img_roi_rgb2gray(unsigned char *image,int width,int height,int channel,int x_min,int x_max,int y_min,int y_max)
{
	unsigned char *image_gray = new unsigned char[(x_max-x_min)*(y_max-y_min)];
    unsigned char* ptr = image;
    unsigned char* ptr_hsv = image_gray;

	if (channel ==1)
	{
		for(int idr=y_min;idr<y_max;idr++)
		{
			for(int idc=x_min;idc<x_max;idc++,ptr_hsv++)
			{
				*ptr_hsv = *(ptr+idr*width+idc);
			}
		}
	}
	else
	{
		for(int idr=y_min;idr<y_max;idr++)
		{
			for(int idc=x_min*3;idc<x_max*3;idc+=3,ptr_hsv++)
			{
				int R = *(ptr+idr*width*3+idc);
				int G = *(ptr+idr*width*3+idc+1);
				int B = *(ptr+idr*width*3+idc+2);

				int minValue = (R <B ? R :B) < G ? (R <B ? R :B) :G;
				int maxValue = (R >B ? R :B) > G ? (R >B ? R :B) :G;
				int Value = R+G+B- (minValue + maxValue);

				*ptr_hsv = Value;
			}
		}
	}

    return image_gray;
}

//¸¯Ê´
unsigned char* baseTool::img_erosion(unsigned char* img,int image_width,int image_height,int h,int w)
{
	unsigned char *image_erosin = new unsigned char[image_width*image_height];

	int flag;
	for (int i = h / 2; i<image_height - h / 2; i++)
	{
		for (int j = w / 2; j<image_width - w / 2; j++)
		{
			flag = 1;
			for (int k = -h / 2; k <= h / 2; k++)
			{
				for (int l = -w / 2; l <= w / 2; l++)
				{
					if (*(img+(k + h / 2)*w + l + w / 2))
					{
						if (!*(img + (i + k)*image_width + j + l))
							flag = 0;
					}
				}
			}

			if (flag)
				*(image_erosin + i*image_width + j) = 255;
			else
				*(image_erosin + i*image_width + j) = 0;
		}

	}

	return image_erosin;
}

void maoPaoSort(int array[],int len)
{
    for (int i = 0; i < len-1; i++)
    {
	for (int j = 0; j < len-1-i; j++)
        {
	    if (array[j] > array[j+1])
            {
		int temp = array[j+1];
		array[j+1] = array[j];
		array[j] = temp;
	    }
	}
    }
}


//ÍÆËã
bool baseTool::isOK(unsigned char* image,int image_width,int image_height)
{
	int edge_dif =3;
	int height_dif=5;
	int width_dif =20;
	int height_part = (int)(image_height/height_dif)+1;
	int width_part = (int)(image_width/width_dif)+1;

	int image_hist[5][20]={0}; 
	int value_list[100]={0};
    unsigned char* ptr = image;

    for(int idr=0;idr<image_height;idr++)
    {
        for(int idc=0;idc<image_width;idc++,ptr++)
        {
			if (*ptr==0 && idr > edge_dif && idr < image_height - edge_dif && idc > edge_dif && idc < image_width - edge_dif)
			{
				image_hist[(int)(idr/height_part)][(int)(idc/width_part)] +=1;
				value_list[(int)(idr/height_part)*height_dif +(int)(idc/width_part)] +=1;
			}
        }
    }

    //sort(value_list,value_list+100);
	maoPaoSort(value_list,100);
	int start_idx=-1;
	for (int idx=0;idx<100;idx++)
	{
		if (value_list[idx] >0 && start_idx<0)
		{
			start_idx=idx;
			break;
		}
	}

	int medium_value=1;
	if (start_idx >0 && start_idx <99)
		medium_value=value_list[(int)((99-start_idx)/5+start_idx)];

	int arr_list[3][2]={0};

	for (int idr=1;idr<height_dif-1;idr++)
	{
		for (int idc=0;idc<width_dif;idc++)
		{
			if (image_hist[idr][idc] <medium_value )
			{
				image_hist[idr][idc] =0;
			}
			else
			{
				if(idc <width_dif*2/5)
					arr_list[idr-1][0]+=1;
				else if(idc >width_dif*3/5)
					arr_list[idr-1][1]+=1;
			}
		}
	}

	if ((arr_list[0][0]-arr_list[0][1] >3 && arr_list[2][0]-arr_list[2][1] <-2) || (arr_list[0][0]-arr_list[0][1] < -3 && arr_list[2][0]-arr_list[2][1] >2))
		return false;

    return true;
}

int* baseTool::filterarr(int rect_num,int width,int height,int pts[][4],int limit_rect_num)
{
	int *new_rect=new int[6];

	if (rect_num>6)
	{
		for(int idx=0;idx<6;idx++)
			new_rect[idx]=-1;

		int start_idx=0;
		for(int idx=0;idx < rect_num;idx++)
		{
			int *pt_itr = pts[idx];
			int x_min = pt_itr[0];
			int x_max = pt_itr[2];
			int x_mid = (int)((x_min+x_max)/2);

			if (x_mid > width/5 && x_mid < width*4/5 && x_max -x_min >40)
			{
				new_rect[start_idx]=idx;
				start_idx+=1;
				if (start_idx>5)
					break;
			}	
		}

		if (start_idx<3)
		{
			for(int idx=0;idx < rect_num;idx++)
			{
				int *pt_itr = pts[idx];
				int x_min = pt_itr[0];
				int x_max = pt_itr[2];
				int x_mid = (int)((x_min+x_max)/2);

				if (x_mid > width/5 && x_mid < width*4/5 && x_max -x_min <=40)
				{
					new_rect[start_idx]=idx;
					start_idx+=1;
					if (start_idx>5)
						break;
				}	
			}
		}

		if (start_idx<3)
		{
			for(int idx=0;idx < rect_num;idx++)
			{
				int *pt_itr = pts[idx];
				int x_min = pt_itr[0];
				int x_max = pt_itr[2];
				int x_mid = (int)((x_min+x_max)/2);

				new_rect[start_idx]=idx;
				start_idx+=1;
				if (start_idx>5)
					break;
			
			}
		}
		
	}
	else
		for(int idx=0;idx<6;idx++)
			new_rect[idx]=idx;
	
	return new_rect;
}


int safe_value(int value)
{
	int new_value=value>255?255:value;
	return new_value <0 ?0:new_value;
}

//floyd core
//unsigned char* baseTool::floyd_core(unsigned char* image,int threshold,int &width,int &height,float *diffuse_ratio,int channel,int max_length,float fratio,float base_ratio,float change_ratio)
unsigned char* baseTool::floyd_core(unsigned char* image,int threshold,int &width,int &height,float *diffuse_ratio,int channel,int max_length,float fratio,float base_ratio,float change_ratio)
{
    unsigned char* floydImg = new unsigned char[width*height];
    unsigned char* ptr = image;
    unsigned char* ptr_floyd = floydImg;
    int new_value=0;
    int value=0;
    float dif_value=0;
	
	for(int idr=0;idr<height-1;idr++)
	{
		for(int idc=0;idc<width-1;idc++)
		{
			value = *(ptr+idr*width+idc);

			if (value > threshold){new_value=255;}
			else{new_value=0;}
			

			if (idr==height-2 || idc ==width-2)
			{
				int width_step=idr==height-2?1:0;
				int step=idc ==width-2?1:0;
				//*(ptr_floyd+step+width_step)=new_value;
				*(ptr_floyd+(idr+width_step)*width+idc) = new_value;
			}

			int value1 = abs(*(ptr+idr*width+idc+1)-value);
			int value2 = abs(*(ptr+(idr+1)*width+idc-1)-value);
			int value3 = abs(*(ptr+(idr+1)*width+idc)-value);
			int value4 = abs(*(ptr+(idr+1)*width+idc+1)-value);

			dif_value = (value-new_value)*fratio;
			*(ptr+idr*width+idc) = new_value;
			*(ptr_floyd+idr*width+idc) = new_value;

			float fratio1=base_ratio+change_ratio*(1.0- value1/255.0);
			float fratio2=base_ratio+change_ratio*(1.0- value2/255.0);
			float fratio3=base_ratio+change_ratio*(1.0- value3/255.0);
			float fratio4=base_ratio+change_ratio*(1.0- value4/255.0);

			int movement = int(4.0*sin(float(idr*idc)/16.0*6.28));

			//F-S dithering
			int new_value1 = int(*(ptr+idr*width+idc+1)+dif_value*diffuse_ratio[movement%4]*fratio1);
			int new_value2 = int(*(ptr+(idr+1)*width+idc-1)+dif_value*diffuse_ratio[(movement+1)%4]*fratio2);
			int new_value3 = int(*(ptr+(idr+1)*width+idc)+dif_value*diffuse_ratio[(movement+2)%4]*fratio3);
			int new_value4 = int(*(ptr+(idr+1)*width+idc+1)+dif_value*diffuse_ratio[(movement+3)%4]*fratio4);

				
			*(ptr+idr*width+idc+1) = new_value1 >255?255:new_value1<0?0:new_value1;
			*(ptr+(idr+1)*width+idc-1)=new_value2 >255?255:new_value2<0?0:new_value2;
			*(ptr+(idr+1)*width+idc)=new_value3 >255?255:new_value3<0?0:new_value3;
			*(ptr+(idr+1)*width+idc+1)=new_value4 >255?255:new_value4<0?0:new_value4;

		}
	}

	return floydImg;
}



void baseTool::floyd_core_inplace(unsigned char* image,int threshold,int width,int height,float *diffuse_ratio,float fratio,float base_ratio,float change_ratio)
{
    unsigned char* ptr = image;
    int new_value=0;
    int value=0;
    float dif_value=0;
    int channel =4;
    
    for(int idr=0;idr<height-1;idr++)
    {
        for(int idc=0;idc<width-1;idc++)
        {
            for(int idch=0;idch<channel;idch++)
            {
                //alpha channel
                if (idch==0) {
                    *(ptr+(idr*width+idc)*channel+idch) = 255;
                    continue;
                }
                //grenn value
                value = *(ptr+idr*width*channel+idc*channel+1);

                if (value > threshold){new_value=255;}
                else{new_value=0;}
            
                //egde
                if (idr==height-2 || idc ==width-2)
                {
                    int width_step=idr==height-2?1:0;
                    int step=idc ==width-2?1:0;
                    *(ptr+((idr+width_step)*width+idc+step)*channel + idch) = new_value;
                }

                int value1 = abs(*(ptr+(idr*width+idc+1)*channel+idch)-value);
                int value2 = abs(*(ptr+((idr+1)*width+idc-1)*channel+idch)-value);
                int value3 = abs(*(ptr+((idr+1)*width+idc)*channel+idch)-value);
                int value4 = abs(*(ptr+((idr+1)*width+idc+1)*channel+idch)-value);

                dif_value = (value-new_value)*fratio;
                *(ptr+(idr*width+idc)*channel+idch) = new_value;

                float fratio1=base_ratio+change_ratio*(1.0- value1/255.0);
                float fratio2=base_ratio+change_ratio*(1.0- value2/255.0);
                float fratio3=base_ratio+change_ratio*(1.0- value3/255.0);
                float fratio4=base_ratio+change_ratio*(1.0- value4/255.0);

                int movement = int(4.0*sin(float(idr*idc)/16.0*6.28));

                //F-S dithering
                int new_value1 = int(*(ptr+(idr*width+idc+1)*channel+idch)+dif_value*diffuse_ratio[movement%4]*fratio1);
                int new_value2 = int(*(ptr+((idr+1)*width+idc-1)*channel+idch)+dif_value*diffuse_ratio[(movement+1)%4]*fratio2);
                int new_value3 = int(*(ptr+((idr+1)*width+idc)*channel+idch)+dif_value*diffuse_ratio[(movement+2)%4]*fratio3);
                int new_value4 = int(*(ptr+((idr+1)*width+idc+1)*channel+idch)+dif_value*diffuse_ratio[(movement+3)%4]*fratio4);

                
                *(ptr+(idr*width+idc+1)*channel+idch) = new_value1 >255?255:new_value1<0?0:new_value1;
                *(ptr+((idr+1)*width+idc-1)*channel+idch)=new_value2 >255?255:new_value2<0?0:new_value2;
                *(ptr+((idr+1)*width+idc)*channel+idch)=new_value3 >255?255:new_value3<0?0:new_value3;
                *(ptr+((idr+1)*width+idc+1)*channel+idch)=new_value4 >255?255:new_value4<0?0:new_value4;
            }
        }
    }

    return ;
}
void baseTool::floyd_core_inplace32(int* image,int threshold,int width,int height,float *diffuse_ratio,float fratio,float base_ratio,float change_ratio)
{
    int* ptr = image;
    int new_value=0;
    int single_value=0;
    int value=0;
    float dif_value=0;
    
    for(int idr=0;idr<height-1;idr++)
    {
        for(int idc=0;idc<width-1;idc++)
        {
            int b = (int)(unsigned char)(*(ptr+idr*width+idc));
            int g = (int)(unsigned char)(*(ptr+idr*width+idc)>>8);
            int r = (int)(unsigned char)(*(ptr+idr*width+idc)>>16);
            int a = (int)(unsigned char)(*(ptr+idr*width+idc)>>24);

            if (g > threshold){new_value=((int)255<<24)|((int)255 << 16)|((int)255<<8)|255;single_value=255;}
            else{((int)255<<24)|((int)0 << 16)|((int)0<<8)|0;single_value=0;}
            


            if (idr==height-2 || idc ==width-2)
            {
                int width_step=idr==height-2?1:0;
                int step=idc ==width-2?1:0;
                *(ptr+(idr+width_step)*width+idc+step) = new_value;
            }

            int value1 = abs((int)(unsigned char)(*(ptr+idr*width+idc+1)>>8)-g);
            int value2 = abs((int)(unsigned char)(*(ptr+(idr+1)*width+idc-1)>>8)-g);
            int value3 = abs((int)(unsigned char)(*(ptr+(idr+1)*width+idc)>>8)-g);
            int value4 = abs((int)(unsigned char)(*(ptr+(idr+1)*width+idc+1)>>8)-g);

            dif_value = (g-single_value)*fratio;
            *(ptr+idr*width+idc) = new_value;

            float fratio1=base_ratio+change_ratio*(1.0- value1/255.0);
            float fratio2=base_ratio+change_ratio*(1.0- value2/255.0);
            float fratio3=base_ratio+change_ratio*(1.0- value3/255.0);
            float fratio4=base_ratio+change_ratio*(1.0- value4/255.0);

            int movement = int(4.0*sin(float(idr*idc)/16.0*6.28));

            //F-S dithering
            int new_value1 = int((int)(unsigned char)(*(ptr+idr*width+idc+1)>>8)+dif_value*diffuse_ratio[movement%4]*fratio1);
            int new_value2 = int((int)(unsigned char)(*(ptr+(idr+1)*width+idc-1)>>8)+dif_value*diffuse_ratio[(movement+1)%4]*fratio2);
            int new_value3 = int((int)(unsigned char)(*(ptr+(idr+1)*width+idc)>>8)+dif_value*diffuse_ratio[(movement+2)%4]*fratio3);
            int new_value4 = int((int)(unsigned char)(*(ptr+(idr+1)*width+idc+1)>>8)+dif_value*diffuse_ratio[(movement+3)%4]*fratio4);

            int safe_value1 = new_value1 >255?255:new_value1<0?0:new_value1;
            int safe_value2 =new_value2 >255?255:new_value2<0?0:new_value2;
            int safe_value3 =new_value3 >255?255:new_value3<0?0:new_value3;
            int safe_value4 =new_value4 >255?255:new_value4<0?0:new_value4;
                
            *(ptr+idr*width+idc+1) = ((int)255<<24)|((int)safe_value1 << 16)|((int)safe_value1<<8)|safe_value1;
            *(ptr+(idr+1)*width+idc-1)= ((int)255<<24)|((int)safe_value2 << 16)|((int)safe_value2<<8)|safe_value2;
            *(ptr+(idr+1)*width+idc)= ((int)255<<24)|((int)safe_value3 << 16)|((int)safe_value3<<8)|safe_value3;
            *(ptr+(idr+1)*width+idc+1)= ((int)255<<24)|((int)safe_value4 << 16)|((int)safe_value4<<8)|safe_value4;
        }
    }

    return ;
}
void baseTool::floyd_core_inplace2(unsigned char* image,int threshold,int width,int height,float *diffuse_ratio,float fratio,float base_ratio,float change_ratio)
{
    unsigned char* ptr = image;
    int new_value=0;
    int value=0;
    float dif_value=0;
    int channel =4;
    int pixelNum = width * height;

    
    for (int i = 0; i < pixelNum; i++) {
        
    }
    
    for(int idr=0;idr<height-1;idr++)
    {
        for(int idc=0;idc<width-1;idc++)
        {
            for(int idch=0;idch<channel;idch++)
            {
                //alpha channel
                if (idch==0) {
                    *(ptr+(idr*width+idc)*channel+idch) = 255;
                    continue;
                }
                //grenn value
                value = *(ptr+idr*width*channel+idc*channel+1);

                if (value > threshold){new_value=255;}
                else{new_value=0;}
            
                //egde
                if (idr==height-2 || idc ==width-2)
                {
                    int width_step=idr==height-2?1:0;
                    int step=idc ==width-2?1:0;
                    *(ptr+((idr+width_step)*width+idc+step)*channel + idch) = new_value;
                }

                int value1 = abs(*(ptr+(idr*width+idc+1)*channel+idch)-value);
                int value2 = abs(*(ptr+((idr+1)*width+idc-1)*channel+idch)-value);
                int value3 = abs(*(ptr+((idr+1)*width+idc)*channel+idch)-value);
                int value4 = abs(*(ptr+((idr+1)*width+idc+1)*channel+idch)-value);

                dif_value = (value-new_value)*fratio;
                *(ptr+(idr*width+idc)*channel+idch) = new_value;

                float fratio1=base_ratio+change_ratio*(1.0- value1/255.0);
                float fratio2=base_ratio+change_ratio*(1.0- value2/255.0);
                float fratio3=base_ratio+change_ratio*(1.0- value3/255.0);
                float fratio4=base_ratio+change_ratio*(1.0- value4/255.0);

                int movement = int(4.0*sin(float(idr*idc)/16.0*6.28));

                //F-S dithering
                int new_value1 = int(*(ptr+(idr*width+idc+1)*channel+idch)+dif_value*diffuse_ratio[movement%4]*fratio1);
                int new_value2 = int(*(ptr+((idr+1)*width+idc-1)*channel+idch)+dif_value*diffuse_ratio[(movement+1)%4]*fratio2);
                int new_value3 = int(*(ptr+((idr+1)*width+idc)*channel+idch)+dif_value*diffuse_ratio[(movement+2)%4]*fratio3);
                int new_value4 = int(*(ptr+((idr+1)*width+idc+1)*channel+idch)+dif_value*diffuse_ratio[(movement+3)%4]*fratio4);

                
                *(ptr+(idr*width+idc+1)*channel+idch) = new_value1 >255?255:new_value1<0?0:new_value1;
                *(ptr+((idr+1)*width+idc-1)*channel+idch)=new_value2 >255?255:new_value2<0?0:new_value2;
                *(ptr+((idr+1)*width+idc)*channel+idch)=new_value3 >255?255:new_value3<0?0:new_value3;
                *(ptr+((idr+1)*width+idc+1)*channel+idch)=new_value4 >255?255:new_value4<0?0:new_value4;
            }
        }
    }

    return ;
}
