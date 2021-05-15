
class baseTool
{
public:
    //convert rgb to hsv
    static unsigned char* convert_rgb2hsv(unsigned char* image,int width,int height);

    static void Rgb2Hsv(float R, float G, float B, float& H, float& S, float&V);

    //convert to gray
    static unsigned char* convert_rgb2gray(unsigned char* image,int width,int height,int channel=3);
	
	//copy i
	static unsigned char* copy(unsigned char* image,int width,int height);

    //convert to binary
    static void convert_gray2binay(unsigned char* image,int threshold,int width,int height);

    //invert
    static void convert_invert(unsigned char* image,int width,int height);

    //resize
	//Ĭ��Ϊ�Ҷ�ͼ����гߴ�ת��
    static unsigned char* convert_resize(unsigned char* image,int &width,int &height,int channel=1,int nSize =500000);

	//��ͼ��ĳߴ�ת����(width,height):��֧�ֻҶ�ͼ(Ŀǰ�����ò�����ɫͼ�ĳ߶Ȼ�ԭ)
	static unsigned char* convert_resizeFixedSize(unsigned char* image,int in_width,int in_height,int out_width,int out_height,int channel=1);
    
    //resize by max_length
	//type=0;no resize
	//type=1:width resize(default)
	//type=2 height resize
	//type=3 max resize
	//type=4 min resize
    static unsigned char* convert_resize_maxlength(unsigned char* image,int &width,int &height,int channel=1,int max_length =380,int type=1);

	//mat dif
	//��������Ϊ�Ҷ�ͼ
	static void convert_dif(unsigned char* src,unsigned char* dst,int width,int height);

	//����ͼ���������������ҳ�ͼ��ķֽ���ֵ
	//�����ǻҶ�ͼ
	static int findThrHistogram(unsigned char *img,int width,int height,float fratio = 0.98,bool isUpper = true);

	//����Ȥ������ȡ
	static unsigned char* img_roi(unsigned char *img,int width,int height,int x_min,int x_max,int y_min,int y_max);
	static unsigned char* img_roi_rgb2gray(unsigned char *img,int width,int height,int channel,int x_min,int x_max,int y_min,int y_max);

	//��ʴ
	static unsigned char* img_erosion(unsigned char* img,int image_width,int image_height,int h,int w);

	//����
	static bool isOK(unsigned char* img,int image_width,int image_height);

	//ɸѡ����
	//limit_rect_num �������Ƶĸ���
	static int* filterarr(int rect_num,int width,int height,int pts[][4],int limit_rect_num=6);


	//floyd method
    static unsigned char* floyd_core(unsigned char* image,int threshold,int &width,int &height,float diffuse_ratio[4],int channel=1,int max_length =380,float fratio=0.7,float base_ratio=0.3,float change_ratio=0.7);
	//static void floyd_core(unsigned char* image,int threshold,int &width,int &height,float diffuse_ratio[4],int channel=1,int max_length =380,float fratio=0.7,float base_ratio=0.3,float change_ratio=0.7);

    static void floyd_core_inplace(unsigned char* image,int threshold,int width,int height,float *diffuse_ratio,float fratio,float base_ratio,float change_ratio);
    static void floyd_core_inplace2(unsigned char* image,int threshold,int width,int height,float *diffuse_ratio,float fratio,float base_ratio,float change_ratio);
    static void floyd_core_inplace32(int* image,int threshold,int width,int height,float *diffuse_ratio,float fratio,float base_ratio,float change_ratio);
};

